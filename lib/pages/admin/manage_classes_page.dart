// lib/pages/manage_classes_page.dart
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../../responsive_layout.dart'; // adjust path if your file is elsewhere

class ManageClassesPage extends StatefulWidget {
  const ManageClassesPage({Key? key}) : super(key: key);

  @override
  _ManageClassesPageState createState() => _ManageClassesPageState();
}

class _ManageClassesPageState extends State<ManageClassesPage> {
  final Client client = Client();
  late Databases databases;
  List<models.Document> classes = [];

  final TextEditingController classNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = true;

  // Replace these IDs with your actual IDs if different
  final String _databaseId = '68f2ecfb0025902a0397';
  final String _collectionId = '68f4365b001247816250';

  @override
  void initState() {
    super.initState();
    client
        .setEndpoint('https://cloud.appwrite.io/v1')
        .setProject('68efcba8002c4bd173c8');
    databases = Databases(client);
    fetchClasses();
  }

  @override
  void dispose() {
    classNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> fetchClasses() async {
    setState(() => isLoading = true);
    try {
      final response = await databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _collectionId,
      );
      setState(() {
        classes = response.documents;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Error fetching classes: $e')),
      );
    }
  }

  Future<void> addClass() async {
    final name = classNameController.text.trim();
    final desc = descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class name cannot be empty')),
      );
      return;
    }

    try {
      await databases.createDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: 'unique()',
        data: {
          'className': name,
          'description': desc,
        },
      );

      classNameController.clear();
      descriptionController.clear();
      await fetchClasses();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Class added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error adding class: $e')),
      );
    }
  }

  Future<void> editClass(models.Document doc) async {
    classNameController.text = (doc.data['className'] ?? '').toString();
    descriptionController.text = (doc.data['description'] ?? '').toString();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Edit Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: classNameController,
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              onPressed: () async {
                final name = classNameController.text.trim();
                final desc = descriptionController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Class name cannot be empty')),
                  );
                  return;
                }

                try {
                  await databases.updateDocument(
                    databaseId: _databaseId,
                    collectionId: _collectionId,
                    documentId: doc.$id,
                    data: {
                      'className': name,
                      'description': desc,
                    },
                  );
                  Navigator.pop(context);
                  await fetchClasses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✅ Class updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error updating class: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// deleteClass: shows confirmation, then deletes document
  Future<void> deleteClass(String docId) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Confirm delete'),
          content: const Text(
            'Are you sure you want to delete this class? This action cannot be undone.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    try {
      await databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _collectionId,
        documentId: docId,
      );
      await fetchClasses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Class deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error deleting class: $e')),
      );
    }
  }

  void showAddClassDialog() {
    classNameController.clear();
    descriptionController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Add New Class'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: classNameController,
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: () {
                Navigator.pop(context);
                addClass();
              },
            ),
          ],
        );
      },
    );
  }

  // Build function that renders grid with provided column count and aspect ratio
  Widget _buildGrid({required int columns, required double childRatio}) {
    if (classes.isEmpty) {
      return const Center(
        child: Text('📭 No classes found.\nTap + to add one.',
            textAlign: TextAlign.center),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: classes.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: childRatio,
        ),
        itemBuilder: (context, index) {
          final c = classes[index];
          // simple color palette cycling
          final palette = [
            LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100]),
            LinearGradient(colors: [Colors.blue.shade50, Colors.blue.shade100]),
            LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade100]),
            LinearGradient(
                colors: [Colors.purple.shade50, Colors.purple.shade100]),
          ];
          final gradient = palette[index % palette.length];

          return Container(
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school, color: Colors.deepOrange),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      c.data['className']?.toString() ?? 'Unnamed Class',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    c.data['description']?.toString() ?? 'No description',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () => editClass(c),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => deleteClass(c.$id),
                    tooltip: 'Delete',
                  ),
                ])
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap top-level view in Scaffold and ResponsiveLayout
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Classes'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchClasses),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ResponsiveLayout(
              mobileBody: _buildGrid(columns: 1, childRatio: 2.6),
              tabletBody: _buildGrid(columns: 2, childRatio: 2.8),
              desktopBody: _buildGrid(columns: 3, childRatio: 2.6),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddClassDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}
