/// Note Entity
/// Represents a study note.
class Note {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String subject;
  final DateTime createdAt;
  final String color; // Stored as hex string

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.subject,
    required this.createdAt,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'subject': subject,
      'createdAt': createdAt.toIso8601String(),
      'color': color,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      subject: json['subject'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      color: json['color'] as String,
    );
  }

  Note copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? subject,
    DateTime? createdAt,
    String? color,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
    );
  }
}
