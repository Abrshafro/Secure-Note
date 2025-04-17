import 'package:flutter/material.dart';
import 'package:secure_notes_frontend/services/api_service.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class AddNoteScreen extends StatelessWidget {
  const AddNoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Create a New Note',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                    child: CustomTextField(
                      controller: titleController,
                      hintText: 'Title',
                      borderRadius: 16,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                    child: CustomTextField(
                      controller: contentController,
                      hintText: 'Content',
                      maxLines: 5,
                      borderRadius: 16,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Save Note',
                    onPressed: () {
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('All fields are required!'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      ApiService.addNote(
                        context,
                        titleController.text,
                        contentController.text,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Note added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    color: Colors.white,
                    textColor: Colors.deepPurple,
                    borderRadius: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
