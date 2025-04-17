import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:secure_notes_frontend/services/api_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Center(
                    child: Image.asset("assets/images/mobile-login.png"),
                  ),
                ),
              ),
              const SizedBox(height: 32), // Increased spacing after image
              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16), // Spacing after title
              CustomTextField(
                controller: usernameController,
                hintText: 'Username',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Login',
                onPressed: () async {
                  if (usernameController.text.isEmpty) {
                    _showErrorDialog(context, 'Username is required');
                  } else if (passwordController.text.isEmpty) {
                    _showErrorDialog(context, 'Password is required');
                  } else {
                    // Call login API and handle response
                    final response = await ApiService.login(
                      usernameController.text,
                      passwordController.text,
                    );

                    if (response.statusCode == 200) {
                      // Parse JSON response
                      final Map<String, dynamic> data =
                          jsonDecode(response.body);

                      // Check for successful login and token
                      if (data['token'] != null) {
                        // Save the token (implementation depends on your app)
                        // ... store token securely
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                        );
                      } else {
                        _showErrorDialog(context, 'Invalid login credentials');
                      }
                    } else {
                      _showErrorDialog(
                          context, 'Login failed. Please try again.');
                    }
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterScreen()),
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
      backgroundColor: Colors.white,
    );
  }

  // Helper function to show error messages in a dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
