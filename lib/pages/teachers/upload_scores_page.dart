import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../responsive_layout.dart'; // ✅ make sure this path matches your file

class UploadScoresPage extends StatefulWidget {
  const UploadScoresPage({Key? key}) : super(key: key);

  @override
  _UploadScoresPageState createState() => _UploadScoresPageState();
}

class _UploadScoresPageState extends State<UploadScoresPage> {
  final Client client = Client();
  late Databases databases;

  List<models.Document> students = [];
  List<models.Document> classes = [];

  String? selectedClass;
  final Map<String, TextEditingController> scoreControllers = {};

  @override
  void initState() {
    super.initState();

    client
        .setEndpoint('https://cloud.appwrite.io/v1') // your endpoint
        .setProject('68efcba8002c4bd173c8'); // your project ID

    databases = Databases(client);
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    try {
      final result = await databases.listDocuments(
        databaseId: 'school_db',
        collectionId: 'classes',
      );

      setState(() {
        classes = result.documents;
      });
    } catch (e) {
      print('Error fetching classes: $e');
    }
  }

  Future<void> fetchStudents(String classId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: 'school_db',
        collectionId: 'students',
        queries: [
          Query.equal('class_id', classId),
        ],
      );

      setState(() {
        students = result.documents;
      });
    } catch (e) {
      print('Error fetching students: $e');
    }
  }

  Future<void> uploadScores() async {
    try {
      for (var student in students) {
        final score = scoreControllers[student.$id]?.text ?? '';
        await databases.createDocument(
          databaseId: 'school_db',
          collectionId: 'scores',
          documentId: 'unique()',
          data: {
            'student_id': student.$id,
            'class_id': selectedClass,
            'score': score,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scores uploaded successfully')),
      );
    } catch (e) {
      print('Error uploading scores: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: buildMainBody(context, width: double.infinity),
      tabletBody: buildMainBody(context, width: 700),
      desktopBody: buildMainBody(context, width: 900),
    );
  }

  Widget buildMainBody(BuildContext context, {required double width}) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Student Scores'),
        backgroundColor: Colors.deepPurple.shade600,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          width: width,
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Class',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: selectedClass,
                    onChanged: (value) {
                      setState(() {
                        selectedClass = value;
                        fetchStudents(value!);
                      });
                    },
                    items: classes.map((c) {
                      return DropdownMenuItem(
                        value: c.$id,
                        child: Text(c.data['class_name']),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Scrollable student list
                  Expanded(
                    child: students.isEmpty
                        ? const Center(
                            child: Text(
                              'No students found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Scrollbar(
                            thumbVisibility: true,
                            radius: const Radius.circular(10),
                            child: ListView.builder(
                              itemCount: students.length,
                              itemBuilder: (context, index) {
                                final student = students[index];
                                scoreControllers[student.$id] =
                                    TextEditingController();

                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color: Colors.grey.shade50,
                                  child: ListTile(
                                    title: Text(
                                      student.data['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6.0),
                                      child: TextField(
                                        controller:
                                            scoreControllers[student.$id],
                                        decoration: InputDecoration(
                                          labelText: 'Enter Score',
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 8),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: uploadScores,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text(
                        'Submit Scores',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
