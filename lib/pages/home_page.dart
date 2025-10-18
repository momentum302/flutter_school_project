import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/results_page.dart';
import '../pages/upload_result_page.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _pages = const [
    DashboardPage(),
    ResultsPage(),
    UploadResultPage(),
  ];

  final List<String> _pageTitles = const [
    "Dashboard",
    "Student Results",
    "Upload Results",
  ];

  void _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Center(
                child: Text(
                  "School Result System",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildDrawerItem(Icons.dashboard, "Dashboard", 0),
            _buildDrawerItem(Icons.list_alt, "Student Results", 1),
            _buildDrawerItem(Icons.upload_file, "Upload Results", 2),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon,
          color: _selectedIndex == index ? Colors.indigo : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? Colors.indigo : Colors.black,
          fontWeight:
              _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // close the drawer
      },
    );
  }
}
