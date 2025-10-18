import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AuthService _authService = AuthService();
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.currentUser();
      setState(() {
        _userName = user.name;
        _isLoading = false;
      });
    } catch (e) {
      print('⚠️ Failed to load user: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1100;
    double cardWidth = isMobile
        ? (screenWidth / 2) - 30
        : isTablet
            ? (screenWidth / 3) - 40
            : (screenWidth / 4) - 50;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👇 Personalized welcome
                    Text(
                      'Welcome, ${_userName ?? 'User'} 👋',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here’s what’s going on today:',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // ✅ Dashboard cards
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildDashboardCard(
                            Icons.people, "Students", Colors.blue, cardWidth),
                        _buildDashboardCard(
                            Icons.school, "Teachers", Colors.orange, cardWidth),
                        _buildDashboardCard(Icons.assessment, "Results",
                            Colors.green, cardWidth),
                        _buildDashboardCard(Icons.settings, "Settings",
                            Colors.purple, cardWidth),
                        _buildDashboardCard(Icons.announcement, "Notice",
                            Colors.teal, cardWidth),
                      ],
                    ),

                    const SizedBox(height: 35),
                    Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: const [
                          ListTile(
                            leading:
                                Icon(Icons.check_circle, color: Colors.green),
                            title: Text('You successfully logged in'),
                            subtitle: Text('Just now'),
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.person_add, color: Colors.blue),
                            title: Text('New student registered'),
                            subtitle: Text('2 hours ago'),
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.update, color: Colors.orange),
                            title: Text('Result data updated'),
                            subtitle: Text('Yesterday'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDashboardCard(
      IconData icon, String title, Color color, double width) {
    return Container(
      width: width,
      height: 130,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title clicked!')),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
