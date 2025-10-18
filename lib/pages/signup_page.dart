// lib/pages/signup_page.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'student';
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _onSignUpPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Account created successfully! Please log in.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 420,
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_alt_1,
                      size: 70, color: Colors.indigo),
                  const SizedBox(height: 10),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Full Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline,
                          color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FB),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your full name' : null,
                  ),
                  const SizedBox(height: 20),

                  // Email Field
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
                    validator: (value) => value!.isEmpty || !value.contains('@')
                        ? 'Enter a valid email address'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password (min 8 chars)',
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.indigo),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.indigo,
                        ),
                        onPressed: () => setState(() {
                          _obscurePassword = !_obscurePassword;
                        }),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FB),
                    ),
                    validator: (value) =>
                        value!.length < 8 ? 'Password too short' : null,
                  ),
                  const SizedBox(height: 20),

                  // Role Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                          value: 'teacher', child: Text('Teacher')),
                      DropdownMenuItem(value: 'parent', child: Text('Parent')),
                      DropdownMenuItem(
                          value: 'student', child: Text('Student')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedRole = value ?? 'student'),
                    decoration: InputDecoration(
                      labelText: 'Select Role',
                      prefixIcon: const Icon(Icons.group_outlined,
                          color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FB),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _onSignUpPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 15),

                  // Redirect to Login
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
