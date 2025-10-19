import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';

class DatabaseService {
  final Client client = Client();
  late Databases databases;

  final String databaseId = '68f2ecfb0025902a0397';
  final String classCollectionId = '68f4365b001247816250';
  final String studentCollectionId = '68f436e4003bb724b589';
  final String scoresCollectionId = '68f437680007d473c174';

  DatabaseService() {
    client
        .setEndpoint('https://cloud.appwrite.io/v1') // your endpoint
        .setProject('68efcba8002c4bd173c8'); // your Appwrite Project ID
    databases = Databases(client);
  }

  /// ✅ Add a class to the database
  Future<void> addClass(String className) async {
    try {
      await databases.createDocument(
        databaseId: '68f2ecfb0025902a0397',
        collectionId: '68f4365b001247816250',
        documentId: ID.unique(),
        data: {
          'className': className,
        },
      );
    } catch (e) {
      print('Error adding class: $e');
      rethrow;
    }
  }

  /// ✅ Get all classes
  Future<List<Document>> getClasses() async {
    try {
      final result = await databases.listDocuments(
        databaseId: '68f2ecfb0025902a0397',
        collectionId: '68f4365b001247816250',
      );
      return result.documents;
    } catch (e) {
      print('Error fetching classes: $e');
      return [];
    }
  }

  /// ✅ Delete a class
  Future<void> deleteClass(String documentId) async {
    try {
      await databases.deleteDocument(
        databaseId: '68f2ecfb0025902a0397',
        collectionId: '68f4365b001247816250',
        documentId: documentId,
      );
    } catch (e) {
      print('Error deleting class: $e');
      rethrow;
    }
  }

  /// ✅ Add a student
  Future<void> addStudent({
    required String studentName,
    required int age,
    required String gender,
    required String className,
    required String classId,
  }) async {
    try {
      await databases.createDocument(
        databaseId: '68f2ecfb0025902a0397',
        collectionId: '68f436e4003bb724b589',
        documentId: ID.unique(),
        data: {
          'studentName': studentName,
          'age': age,
          'gender': gender,
          'className': className,
          'classId': classId,
        },
      );
    } catch (e) {
      print('Error adding student: $e');
      rethrow;
    }
  }

  /// ✅ Update student information
  Future<void> updateStudent({
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await databases.updateDocument(
        databaseId: '68f2ecfb0025902a0397',
        collectionId: '68f436e4003bb724b589',
        documentId: documentId,
        data: data,
      );
    } catch (e) {
      print('Error updating student: $e');
      rethrow;
    }
  }

  /// ✅ Delete a student
  Future<void> deleteStudent(String documentId) async {
    try {
      await databases.deleteDocument(
        databaseId: '68f2ecfb0025902a0397',
        collectionId: '68f436e4003bb724b589',
        documentId: documentId,
      );
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  /// ✅ Get all students
  Future<List<Document>> getStudents() async {
    try {
      final result = await databases.listDocuments(
        databaseId: '68f2ecfb0025902a0397',
        collectionId: '68f436e4003bb724b589',
      );
      return result.documents;
    } catch (e) {
      print('Error fetching students: $e');
      return [];
    }
  }

  /// ✅ Add score
  Future<void> addScore({
    required String studentId,
    required String classId,
    required double score,
  }) async {
    try {
      await databases.createDocument(
        databaseId: '68f2ecfb0025902a0397',
        collectionId: '68f437680007d473c174',
        documentId: ID.unique(),
        data: {
          'studentId': studentId,
          'classId': classId,
          'score': score,
        },
      );
    } catch (e) {
      print('Error adding score: $e');
      rethrow;
    }
  }

  /// ✅ Get scores by class
  Future<List<Document>> getScoresByClass(String classId) async {
    try {
      final result = await databases.listDocuments(
        databaseId: '68f2ecfb0025902a0397',
        collectionId: '68f437680007d473c174',
        queries: [
          Query.equal('classId', classId),
        ],
      );
      return result.documents;
    } catch (e) {
      print('Error fetching scores: $e');
      return [];
    }
  }
}
