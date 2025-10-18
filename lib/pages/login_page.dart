import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';

// Dashboard imports with prefixes to avoid conflicts
import 'dashboards/admin_dashboard.dart' as admin;
import 'dashboards/teachers_dashboard.dart' as teacher;
import 'dashboards/parent_dashboard.dart' as parent;
import 'dashboards/student_dashboard.dart' as student;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ✅ LOGIN FUNCTION
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Step 1: Login user
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Step 2: Get current user and their role
      final user = await _authService.currentUser();
      final role = await _authService.getUserRole(user.$id);

      // Step 3: Navigate to correct dashboard
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const admin.AdminDashboard()),
        );
      } else if (role == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const teacher.TeacherDashboard()),
        );
      } else if (role == 'parent') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const parent.ParentDashboard()),
        );
      } else if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const student.StudentDashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unknown role detected!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double formWidth;
        if (constraints.maxWidth < 600) {
          formWidth = 320; // mobile
        } else if (constraints.maxWidth < 1100) {
          formWidth = 450; // tablet
        } else {
          formWidth = 500; // desktop
        }
        return _buildLoginForm(context, formWidth);
      },
    );
  }

  // ✅ UI LAYOUT
  Widget _buildLoginForm(BuildContext context, double formWidth) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: formWidth,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school, size: 70, color: Colors.indigo),
                const SizedBox(height: 10),
                const Text(
                  "School Result Portal",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 30),

                // 🧾 FORM
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: const Icon(Icons.email_outlined,
                              color: Colors.indigo),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FB),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your email' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: Colors.indigo),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.indigo,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FB),
                        ),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your password'
                            : null,
                      ),
                      const SizedBox(height: 30),

                      // 🟦 LOGIN BUTTON
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // TODO: implement forgot password later
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.indigo),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.indigo),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
