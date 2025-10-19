import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import '../../services/database_service.dart';

class ManageStudentsPage extends StatefulWidget {
  const ManageStudentsPage({super.key});

  @override
  State<ManageStudentsPage> createState() => _ManageStudentsPageState();
}

class _ManageStudentsPageState extends State<ManageStudentsPage> {
  final DatabaseService _databaseService = DatabaseService();
  List<Document> students = [];
  bool _isLoading = true;

  // Controllers for adding/editing students
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final fetchedStudents = await _databaseService.getStudents();
      setState(() {
        students = fetchedStudents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading students: $e')),
      );
    }
  }

  Future<void> _addStudent() async {
    if (_studentNameController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _genderController.text.isEmpty ||
        _classNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    try {
      await _databaseService.addStudent(
        studentName: _studentNameController.text,
        age: int.tryParse(_ageController.text) ?? 0,

        //age: _ageController.text,
        gender: _genderController.text,
        className: _classNameController.text,
        classId: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      Navigator.pop(context);
      _clearForm();
      _fetchStudents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding student: $e')),
      );
    }
  }

  Future<void> _updateStudent(Document student) async {
    try {
      await _databaseService.updateStudent(
        documentId: student.$id,
        data: {
          'studentName': _studentNameController.text,
          'age': _ageController.text,
          'gender': _genderController.text,
          'className': _classNameController.text,
        },
      );
      Navigator.pop(context);
      _clearForm();
      _fetchStudents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating student: $e')),
      );
    }
  }

  Future<void> _deleteStudent(String id) async {
    try {
      await _databaseService.deleteStudent(id);
      _fetchStudents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting student: $e')),
      );
    }
  }

  void _clearForm() {
    _studentNameController.clear();
    _ageController.clear();
    _genderController.clear();
    _classNameController.clear();
  }

  void _showStudentForm({Document? student}) {
    if (student != null) {
      _studentNameController.text = student.data['studentName'];
      _ageController.text = student.data['age'];
      _genderController.text = student.data['gender'];
      _classNameController.text = student.data['className'];
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(student == null ? 'Add Student' : 'Edit Student'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _studentNameController,
                decoration: const InputDecoration(labelText: 'Student Name'),
              ),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                controller: _classNameController,
                decoration: const InputDecoration(labelText: 'Class Name'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                student == null ? _addStudent() : _updateStudent(student),
            child: Text(student == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentForm(),
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // ✅ Mobile layout - vertical list
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index].data;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(student['studentName'] ?? ''),
                          subtitle: Text(
                            'Class: ${student['className'] ?? ''}\n'
                            'Age: ${student['age'] ?? ''} | Gender: ${student['gender'] ?? ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showStudentForm(
                                  student: students[index],
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteStudent(students[index].$id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // ✅ Web/tablet layout - data table
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          MaterialStateProperty.all(Colors.deepPurple.shade100),
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Age')),
                        DataColumn(label: Text('Gender')),
                        DataColumn(label: Text('Class')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: students.map((studentDoc) {
                        final student = studentDoc.data;
                        return DataRow(cells: [
                          DataCell(Text(student['studentName'] ?? '')),
                          DataCell(Text(student['age'] ?? '')),
                          DataCell(Text(student['gender'] ?? '')),
                          DataCell(Text(student['className'] ?? '')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showStudentForm(student: studentDoc),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteStudent(studentDoc.$id),
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  );
                }
              },
            ),
    );
  }
}
