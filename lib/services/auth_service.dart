// lib/services/auth_service.dart
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

class AuthService {
  final Client _client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1') // Appwrite endpoint
    ..setProject('68efcba8002c4bd173c8'); // ✅ Your project ID

  late final Account _account = Account(_client);
  late final Databases _databases = Databases(_client);

  final String _databaseId = '68f2ecfb0025902a0397'; // ✅ Your database ID
  final String _usersCollectionId =
      '68f309320030cd2382ec'; // ✅ Your collection ID

  /// Create new user account and store role in database
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // 1️⃣ Create the user in Appwrite Authentication
      final models.User user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // 2️⃣ Create a matching document in your `users` collection
      await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: user.$id,
        data: {
          'name': name,
          'email': email,
          'role': role,
        },
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Failed to register user');
    } catch (e) {
      throw Exception('Unexpected registration error: $e');
    }
  }

  /// Login user and create session
  Future<void> login(String email, String password) async {
    try {
      await _account.createEmailPasswordSession(
          email: email, password: password);
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    } catch (e) {
      throw Exception('Unexpected login error: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _account.deleteSessions();
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Logout failed');
    } catch (e) {
      throw Exception('Unexpected logout error: $e');
    }
  }

  /// Get current user info
  Future<models.User> currentUser() async {
    try {
      final user = await _account.get();
      return user;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'No active user');
    } catch (e) {
      throw Exception('Unexpected error fetching user: $e');
    }
  }

  /// Fetch user's role from the database
  Future<String?> getUserRole(String userId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: _databaseId,
        collectionId: _usersCollectionId,
        documentId: userId,
      );
      return doc.data['role'];
    } on AppwriteException catch (e) {
      print('⚠️ getUserRole error: ${e.message}');
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      await _account.get();
      return true;
    } catch (_) {
      return false;
    }
  }
}
