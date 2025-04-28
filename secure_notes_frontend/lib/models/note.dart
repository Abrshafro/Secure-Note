class Note {
  final String id;
  final String title;
  final String content;

  Note({required this.id, required this.title, required this.content});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }

  // Implement the copyWith method
  Note copyWith({String? title, String? content}) {
    return Note(
      id: this.id, // Keep the id the same
      title: title ??
          this.title, // Use the new title if provided, otherwise keep the old one
      content: content ??
          this.content, // Use the new content if provided, otherwise keep the old one
    );
  }
}
