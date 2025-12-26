/// Flashcard Entity
/// Represents a single flashcard in a study set.
library;

/// A flashcard with term and definition for spaced repetition learning.
class Flashcard {
  final String id;
  final String studySetId;
  final String term;
  final String definition;
  final String? imageUrl;
  final String creatorId; // Added for Firestore security rules
  final int repetitions;
  final double easeFactor;
  final int interval;
  final DateTime? nextReviewDate;
  final DateTime createdAt;
  final DateTime lastUpdated;

  const Flashcard({
    required this.id,
    required this.studySetId,
    required this.term,
    required this.definition,
    this.imageUrl,
    required this.creatorId, // Added
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.interval = 1,
    this.nextReviewDate,
    required this.createdAt,
    required this.lastUpdated,
  });

  Flashcard copyWith({
    String? id,
    String? studySetId,
    String? term,
    String? definition,
    String? imageUrl,
    String? creatorId,
    int? repetitions,
    double? easeFactor,
    int? interval,
    DateTime? nextReviewDate,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Flashcard(
      id: id ?? this.id,
      studySetId: studySetId ?? this.studySetId,
      term: term ?? this.term,
      definition: definition ?? this.definition,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorId: creatorId ?? this.creatorId,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studySetId': studySetId,
      'term': term,
      'definition': definition,
      'imageUrl': imageUrl,
      'creatorId': creatorId,
      'repetitions': repetitions,
      'easeFactor': easeFactor,
      'interval': interval,
      'nextReviewDate': nextReviewDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String? ?? '',
      studySetId: json['studySetId'] as String? ?? '',
      term: json['term'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      creatorId: json['creatorId'] as String? ?? '',
      repetitions: json['repetitions'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      interval: json['interval'] as int? ?? 1,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.tryParse(json['nextReviewDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }
}
