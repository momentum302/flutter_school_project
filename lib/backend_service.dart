import 'package:appwrite/appwrite.dart';

class AppwriteService {
  final Client client = Client();
  late Account account;

  AppwriteService() {
    client
        .setEndpoint('https://cloud.appwrite.io/v1') // Your Appwrite endpoint
        .setProject('68efcba8002c4bd173c8'); // Replace with your project ID
    account = Account(client);
  }

  Future<void> checkConnection() async {
    try {
      final result = await account.get();
      print('Connected as: ${result.name}');
    } catch (e) {
      print('Connected successfully to Appwrite!');
    }
  }
}
