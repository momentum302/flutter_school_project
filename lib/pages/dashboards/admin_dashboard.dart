import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  String? _userName;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.currentUser();
      final role = await _authService.getUserRole(user.$id);
      setState(() {
        _userName = user.name;
        _userRole = role ?? 'admin';
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

  List<Map<String, dynamic>> getDashboardCards() {
    switch (_userRole) {
      case 'teacher':
        return [
          {
            'icon': Icons.upload_file,
            'title': 'Upload Scores',
            'color': Colors.blue
          },
          {
            'icon': Icons.assessment,
            'title': 'Compute Results',
            'color': Colors.orange
          },
          {
            'icon': Icons.history,
            'title': 'Computation History',
            'color': Colors.green
          },
          {
            'icon': Icons.report,
            'title': 'Generate Reports',
            'color': Colors.purple
          },
        ];
      case 'student':
        return [
          {'icon': Icons.score, 'title': 'View Scores', 'color': Colors.blue},
          {
            'icon': Icons.access_time,
            'title': 'Attendance',
            'color': Colors.orange
          },
          {'icon': Icons.report, 'title': 'Reports', 'color': Colors.green},
          {
            'icon': Icons.announcement,
            'title': 'Notices',
            'color': Colors.purple
          },
        ];
      case 'parent':
        return [
          {
            'icon': Icons.child_care,
            'title': 'Student Performance',
            'color': Colors.blue
          },
          {
            'icon': Icons.access_time,
            'title': 'Attendance',
            'color': Colors.orange
          },
          {
            'icon': Icons.announcement,
            'title': 'Notices',
            'color': Colors.green
          },
          {'icon': Icons.message, 'title': 'Messages', 'color': Colors.purple},
        ];
      case 'admin':
      default:
        return [
          {'icon': Icons.people, 'title': 'Students', 'color': Colors.blue},
          {'icon': Icons.school, 'title': 'Teachers', 'color': Colors.orange},
          {'icon': Icons.assessment, 'title': 'Results', 'color': Colors.green},
          {'icon': Icons.settings, 'title': 'Settings', 'color': Colors.purple},
          {'icon': Icons.announcement, 'title': 'Notice', 'color': Colors.teal},
        ];
    }
  }

  List<Map<String, String>> getRecentActivities() {
    switch (_userRole) {
      case 'teacher':
        return [
          {'icon': 'upload', 'title': 'Scores uploaded', 'time': 'Just now'},
          {'icon': 'update', 'title': 'Result updated', 'time': '1 hour ago'},
        ];
      case 'student':
        return [
          {'icon': 'score', 'title': 'New results posted', 'time': 'Today'},
          {
            'icon': 'announcement',
            'title': 'New notice received',
            'time': 'Yesterday'
          },
        ];
      case 'parent':
        return [
          {
            'icon': 'report',
            'title': 'Student report updated',
            'time': 'Today'
          },
          {
            'icon': 'announcement',
            'title': 'New notice received',
            'time': 'Yesterday'
          },
        ];
      case 'admin':
      default:
        return [
          {
            'icon': 'check',
            'title': 'You successfully logged in',
            'time': 'Just now'
          },
          {
            'icon': 'person_add',
            'title': 'New student registered',
            'time': '2 hours ago'
          },
          {
            'icon': 'update',
            'title': 'Result data updated',
            'time': 'Yesterday'
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int columns;
    double cardWidth;

    if (screenWidth < 600) {
      columns = 2;
      cardWidth = (screenWidth / columns) - 24;
    } else if (screenWidth < 1100) {
      columns = 3;
      cardWidth = (screenWidth / columns) - 24;
    } else {
      columns = 4;
      cardWidth = (screenWidth / columns) - 24;
    }

    final cards = getDashboardCards();
    final activities = getRecentActivities();

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
                    Text(
                      'Welcome, ${_userName ?? 'User'} 👋',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here’s what’s going on today:',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 15 : 17,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: cards
                          .map((c) => _buildDashboardCard(
                              c['icon'] as IconData,
                              c['title'] as String,
                              c['color'] as Color,
                              cardWidth))
                          .toList(),
                    ),
                    const SizedBox(height: 35),
                    Text(
                      'Recent Activities',
                      style: TextStyle(
                        fontSize: screenWidth < 600 ? 18 : 20,
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
                        children: activities
                            .map(
                              (a) => Column(
                                children: [
                                  ListTile(
                                    leading: _getActivityIcon(a['icon']!),
                                    title: Text(a['title']!),
                                    subtitle: Text(a['time']!),
                                  ),
                                  const Divider(height: 1),
                                ],
                              ),
                            )
                            .toList(),
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

  Widget _getActivityIcon(String iconName) {
    switch (iconName) {
      case 'upload':
        return const Icon(Icons.upload_file, color: Colors.blue);
      case 'update':
        return const Icon(Icons.update, color: Colors.orange);
      case 'score':
        return const Icon(Icons.score, color: Colors.green);
      case 'report':
        return const Icon(Icons.report, color: Colors.purple);
      case 'person_add':
        return const Icon(Icons.person_add, color: Colors.blue);
      case 'announcement':
        return const Icon(Icons.announcement, color: Colors.teal);
      case 'check':
      default:
        return const Icon(Icons.check_circle, color: Colors.green);
    }
  }
}
