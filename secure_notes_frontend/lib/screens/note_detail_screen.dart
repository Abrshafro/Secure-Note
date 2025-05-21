import 'package:flutter/material.dart';
import 'package:secure_notes_frontend/services/api_service.dart';
import '../models/note.dart';
import '../widgets/custom_textfield.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;
  final Function onDeleteSuccess; // Add this callback to notify HomeScreen

  const NoteDetailScreen(
      {super.key, required this.note, required this.onDeleteSuccess});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pop(context), // Navigate back on back icon press
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete,
            color: Colors.white,
            size: 28.0,),
            onPressed: () async {
              // Confirm deletion
              bool confirmDelete = await _showDeleteConfirmationDialog(context);
              if (confirmDelete) {
                try {
                  // Call the delete API
                  await ApiService.deleteNote(context, note.id);

                  // Notify HomeScreen to refresh the notes
                  onDeleteSuccess();

                  // Navigate back to the previous screen after successful deletion
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Note deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error while : $error'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
        ],
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
                    'Edit  Note',
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
                      maxLines: 8,
                      borderRadius: 16,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('All fields are required!'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      try {
                        // Update the note
                        await ApiService.updateNote(
                          context,
                          note.id,
                          titleController.text,
                          contentController.text,
                        );

                        // Create a new updated note with the new details
                        Note updatedNote = note.copyWith(
                          title: titleController.text,
                          content: contentController.text,
                        );

                        // Pass the updated note back to the previous screen
                        Navigator.pop(context, updatedNote);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notes updated successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error while updating : $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize:
                          const Size.fromHeight(50), // Full-width button
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Save Change',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Notes'),
              content: const Text('Are you sure you want to delete this note  ?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User canceled
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User confirmed
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed
  }
}
