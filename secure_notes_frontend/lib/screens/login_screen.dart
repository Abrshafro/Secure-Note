import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:secure_notes_frontend/services/api_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty) {
      _showErrorDialog('Username is required');
      return;
    }
    if (password.isEmpty) {
      _showErrorDialog('Password is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(username, password);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['token'] != null) {
          // TODO: Securely store the token

          // Navigate to home screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          _showErrorDialog('Invalid login credentials');
        }
      } else if (response.statusCode == 401) {
        _showErrorDialog('Incorrect username or password.');
      } else {
        _showErrorDialog('Login failed. (${response.statusCode})');
      }
    } catch (e) {
      _showErrorDialog('An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  width: double.infinity,
                  child: Center(
                    child: Image.asset("assets/images/mobile-login.png"),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Get Started',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: usernameController,
                hintText: 'Username',
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: 'Login',
                      onPressed: () => _login(context),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                    child: const Text(
                      'Register here',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
