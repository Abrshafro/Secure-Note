import 'package:flutter/material.dart';

class NoteCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: const Icon(Icons.note, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }
}
