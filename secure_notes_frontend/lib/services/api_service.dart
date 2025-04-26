import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart'; // For navigation to login screen
import 'package:jwt_decode/jwt_decode.dart';
import 'package:secure_notes_frontend/models/note.dart';

import '../screens/login_screen.dart'; // To decode the JWT token

class ApiService {
  static const String baseUrl = 'http://192.168.73.21:6000/api';

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Register method
  static Future<http.Response> register(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return response;
  }

  // Login method
  static Future<http.Response> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      String token = data[
          'token']; // Assuming the token is returned in the response body as 'token'
      _deleteToken();
      _saveToken(token);
    }

    return response;
  }

  // Save token in FlutterSecureStorage
  static Future<void> _saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Get the token from FlutterSecureStorage
  static Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Delete the token from FlutterSecureStorage
  static Future<void> _deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Check if the token is expired
  static bool _isTokenExpired(String token) {
    final int expiryTimestamp =
        Jwt.parseJwt(token)['exp'] * 1000; // Expiry date in milliseconds
    final DateTime expiryDate =
        DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    return DateTime.now().isAfter(expiryDate);
  }

  // Handle the token expiry: logout user and delete the token
  static Future<void> handleTokenExpiry(BuildContext context) async {
    await _deleteToken(); // Remove the expired token
    // Navigate to the login screen or show a login prompt
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  // Get notes with the token
  static Future<List<Note>> getNotes(BuildContext context) async {
    String? token = await _getToken();

    if (token == null) {
      // No token available, user needs to log in
      await handleTokenExpiry(context);
      throw Exception('Token is not available');
    }

    if (_isTokenExpired(token)) {
      // Token is expired, delete it and prompt the user to log in again
      await handleTokenExpiry(context);
      throw Exception('Token expired');
    }

    // Fetch notes using the valid token
    final response = await http.get(
      Uri.parse('$baseUrl/notes'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      // Parse the JSON response and map to a list of Note objects
      final List<dynamic> jsonData = jsonDecode(response.body);

      final List<Note> notes =
          jsonData.map((noteJson) => Note.fromJson(noteJson)).toList();
      return notes;
    } else {
      // Handle errors
      throw Exception('Failed to fetch notes: ${response.statusCode}');
    }
  }

  static Future<void> addNote(
      BuildContext context, String title, String content) async {
    String? token = await _getToken();

    if (token == null || _isTokenExpired(token)) {
      await handleTokenExpiry(context);
      throw Exception('Authentication required');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/notes/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );
    print(jsonDecode(response.body));
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note added successfully!')),
      );
    } else {
      throw Exception('Failed to add note: ${response.statusCode}');
    }
  }

  static Future<void> updateNote(
      BuildContext context, String noteId, String title, String content) async {
    String? token = await _getToken();

    if (token == null || _isTokenExpired(token)) {
      await handleTokenExpiry(context);
      throw Exception('Authentication required');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/notes/$noteId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note updated successfully!')),
      );
    } else {
      throw Exception('Failed to update note: ${response.statusCode}');
    }
  }

  static Future<void> deleteNote(BuildContext context, String noteId) async {
    String? token = await _getToken();

    if (token == null || _isTokenExpired(token)) {
      await handleTokenExpiry(context);
      throw Exception('Authentication required');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/notes/$noteId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note deleted successfully!')),
      );
    } else {
      throw Exception('Failed to delete note: ${response.statusCode}');
    }
  }

  static Future<String> fetchUsername() async {
    try {
      // Fetch the token
      String? token = await _getToken();

      // Make the HTTP request
      final response = await http.get(
        Uri.parse('$baseUrl/auth/username'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Check if the response status is OK (200)
      if (response.statusCode == 200) {
        // Decode the JSON response
        final data = jsonDecode(response.body);

        // Extract and return the username field
        return data['username'] ??
            'Guest'; // Provide default if username is null
      } else {
        debugPrint('Error: ${response.statusCode} - ${response.body}');
        return 'Guest'; // Default value for non-200 status codes
      }
    } catch (error) {
      debugPrint('Exception occurred: $error');
      return 'Guest'; // Default value for exceptions
    }
  }
}
