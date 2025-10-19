import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';
import '../teachers/upload_scores_page.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
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
        _userRole = role;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('⚠️ Failed to load user: $e'); // replaced print
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

  // Role-based cards
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
      default:
        return []; // Fallback empty
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
      default:
        return [];
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

    final cards = getDashboardCards();
    final activities = getRecentActivities();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
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
        onTap: () => _handleCardTap(title), // ✅ fixed here
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

  void _handleCardTap(String title) {
    if (title == 'Upload Scores') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UploadScoresPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$title feature coming soon!')),
      );
    }
  }
}
