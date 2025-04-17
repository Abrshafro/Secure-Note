import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:secure_notes_frontend/services/api_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart'; // Import the LoginScreen class

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    void registerUser() async {
      final username = usernameController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      // Validate inputs
      if (username.isEmpty) {
        _showDialog(context, 'Error', 'Username is required');
        return;
      } else if (password.isEmpty) {
        _showDialog(context, 'Error', 'Password is required');
        return;
      } else if (confirmPassword.isEmpty) {
        _showDialog(context, 'Error', 'Confirm Password is required');
        return;
      } else if (password != confirmPassword) {
        _showDialog(context, 'Error', 'Passwords do not match');
        return;
      }

      try {
        // Call the API to register the user
        final response = await ApiService.register(username, password);

        if (response.statusCode == 201) {
          // Assuming 201 indicates success
          final responseData = jsonDecode(response.body);
          final message = responseData['message'] ?? 'Registration successful!';

          // Show success message using SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back after a delay
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
        } else {
          // Handle other status codes and errors
          final responseData = jsonDecode(response.body);
          final error =
              responseData['error'] ?? 'Registration failed. Try again.';

          // Show error dialog
          _showDialog(context, 'Error', error);
        }
      } catch (e) {
        // Handle unexpected errors
        _showDialog(context, 'Error', 'An unexpected error occurred: $e');
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Center(
                    child: Image.asset("assets/images/mobile-sign-up.png"),
                  ),
                ),
              ),
              const SizedBox(height: 22), // Increased spacing after image
              const Text(
                'Register Here',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
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
              CustomTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Register',
                onPressed: registerUser,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Login',
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

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
