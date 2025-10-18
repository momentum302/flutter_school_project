import 'package:flutter/material.dart';
import 'package:flutter_school_result_system/responsive_layout.dart';

class UploadResultPage extends StatefulWidget {
  const UploadResultPage({super.key});

  @override
  State<UploadResultPage> createState() => _UploadResultPageState();
}

class _UploadResultPageState extends State<UploadResultPage> {
  List<Map<String, dynamic>> students = [
    {"name": "John Doe", "test": 0, "exam": 0, "total": 0, "average": 0.0},
    {"name": "Jane Smith", "test": 0, "exam": 0, "total": 0, "average": 0.0},
    {"name": "Michael Brown", "test": 0, "exam": 0, "total": 0, "average": 0.0},
  ];

  void _computeAll() {
    setState(() {
      for (var student in students) {
        student["total"] = student["test"] + student["exam"];
        student["average"] = student["total"] / 2;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Computation completed successfully!')),
    );
  }

  void _submitToAdmin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📤 Result submitted to admin successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildPage(context, 320),
      tabletBody: _buildPage(context, 600),
      desktopBody: _buildPage(context, 800),
    );
  }

  Widget _buildPage(BuildContext context, double width) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Result'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Student Name')),
                    DataColumn(label: Text('Test')),
                    DataColumn(label: Text('Exam')),
                    DataColumn(label: Text('Total')),
                    DataColumn(label: Text('Average')),
                  ],
                  rows: students.map((student) {
                    return DataRow(cells: [
                      DataCell(Text(student["name"])),
                      DataCell(
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Test',
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            setState(() {
                              student["test"] = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                      DataCell(
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Exam',
                            border: InputBorder.none,
                          ),
                          onChanged: (val) {
                            setState(() {
                              student["exam"] = int.tryParse(val) ?? 0;
                            });
                          },
                        ),
                      ),
                      DataCell(Text(student["total"].toString())),
                      DataCell(Text(student["average"].toStringAsFixed(1))),
                    ]);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _computeAll,
                icon: const Icon(Icons.calculate),
                label: const Text('Compute All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _submitToAdmin,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Submit to Admin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF4F6FA),
    );
  }
}
