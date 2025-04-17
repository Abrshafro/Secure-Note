import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SecureNotesApp());
}

class SecureNotesApp extends StatelessWidget {
  const SecureNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Notes',
      theme: ThemeData(useMaterial3: true),
      home: LoginScreen(),
    );
  }
}
