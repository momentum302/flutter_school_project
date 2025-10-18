import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';

class RoleDashboard extends StatefulWidget {
  const RoleDashboard({super.key});

  @override
  State<RoleDashboard> createState() => _RoleDashboardState();
}

class _RoleDashboardState extends State<RoleDashboard> {
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
        _userRole = role ?? 'user';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('⚠️ Failed to load user: $e');
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

  // Role-based dashboard cards
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

  // Role-based recent activities
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
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1100;
    double cardWidth = isMobile
        ? (screenWidth / 2) - 24
        : isTablet
            ? (screenWidth / 3) - 32
            : (screenWidth / 4) - 40;

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
                    _buildWelcomeCard(),
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
                    _buildRecentActivities(activities),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    String message;
    IconData icon;

    switch (_userRole) {
      case 'teacher':
        message = "Upload scores and compute results efficiently.";
        icon = Icons.school;
        break;
      case 'student':
        message = "Check your scores, attendance, and reports.";
        icon = Icons.person;
        break;
      case 'parent':
        message = "Monitor your child's performance and notices.";
        icon = Icons.child_care;
        break;
      case 'admin':
      default:
        message = "Manage users and approve results from here.";
        icon = Icons.admin_panel_settings;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Icon(icon, size: 50, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Welcome, ${_userName ?? 'User'}!\n$message",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('$title clicked!')));
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

  Widget _buildRecentActivities(List<Map<String, String>> activities) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8)
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
