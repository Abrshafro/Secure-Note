import 'package:flutter/material.dart';
import 'package:secure_notes_frontend/models/note.dart';
import 'package:secure_notes_frontend/screens/login_screen.dart';
import 'package:secure_notes_frontend/services/api_service.dart';

import 'aboutScreen.dart';
import 'add_note_screen.dart';
import '../widgets/note_card.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> futureNotes;
  String username = "guest";

  @override
  void initState() {
    super.initState();
    // Fetch notes on initialization
    futureNotes = ApiService.getNotes(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh notes when the route is popped
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        futureNotes = ApiService.getNotes(context);
      });
    });
  }

  void _confirmDelete(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content:
            Text('Are you sure you want to delete the note "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              try {
                await ApiService.deleteNote(context, note.id);
                setState(() {
                  futureNotes = ApiService.getNotes(context); // Refresh notes
                });
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting note: $error')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Notes'), centerTitle: true),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<String>(
              future: ApiService.fetchUsername(),
              builder: (context, snapshot) {
                final username = snapshot.data ?? 'Guest';
                return DrawerHeader(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.note, size: 80, color: Colors.white),
                      const SizedBox(height: 10),
                      Text(
                        username,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                setState(() {
                  futureNotes = Future.value([]); // Clear the notes
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Note>>(
        future: futureNotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading spinner while waiting for the notes
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if something went wrong
            return Center(child: Text('Error Found: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final notes = snapshot.data!;
            if (notes.isEmpty) {
              return const Center(child: Text('No notes found .'));
            }
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return GestureDetector(
                  onLongPress: () {
                    _confirmDelete(context, note);
                  },
                  child: NoteCard(
                    title: note.title,
                    subtitle: note.content,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteDetailScreen(
                            note: note,
                            onDeleteSuccess: () {
                              // Refresh notes immediately after deletion
                              setState(() {
                                futureNotes = ApiService.getNotes(
                                    context); // Refresh the notes
                              });
                            },
                          ),
                        ),
                      ).then((updatedNote) {
                        if (updatedNote != null) {
                          setState(() {
                            // Update the note in the list with the updated note
                            notes[index] = updatedNote;
                          });
                        }
                      });
                    },
                  ),
                );
              },
            );
          } else {
            // Show a message if no data is available
            return const Center(child: Text('No data available in the app.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          ).then((_) {
            // Refresh notes after adding a new one
            setState(() {
              futureNotes = ApiService.getNotes(context);
            });
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
