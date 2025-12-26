/// Study Set Entity.
/// Represents a collection of study materials (flashcards, files, topics).
///
/// Layer: Domain
/// Responsibility: Core data structure for study sets.
library;

class StudySet {
  final String id;
  final String title;
  final String category;
  final String studentId;
  final String? subjectId; // Added for subject integration
  final bool isPrivate;
  final int topicCount;
  final int flashcardCount;
  final int fileCount;
  final DateTime createdAt;
  final DateTime lastUpdated;

  const StudySet({
    required this.id,
    required this.title,
    required this.category,
    required this.studentId,
    this.subjectId,
    required this.isPrivate,
    this.topicCount = 0,
    this.flashcardCount = 0,
    this.fileCount = 0,
    required this.createdAt,
    required this.lastUpdated,
  });

  StudySet copyWith({
    String? id,
    String? title,
    String? category,
    String? studentId,
    String? subjectId,
    bool? isPrivate,
    int? topicCount,
    int? flashcardCount,
    int? fileCount,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return StudySet(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      isPrivate: isPrivate ?? this.isPrivate,
      topicCount: topicCount ?? this.topicCount,
      flashcardCount: flashcardCount ?? this.flashcardCount,
      fileCount: fileCount ?? this.fileCount,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
