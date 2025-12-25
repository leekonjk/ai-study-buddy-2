/// Study Set Repository
/// Interface for managing study sets.
library;

import 'package:studnet_ai_buddy/core/utils/result.dart';

/// Study set entity.
class StudySet {
  final String id;
  final String title;
  final String category;
  final String studentId;
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
    required this.isPrivate,
    this.topicCount = 0,
    this.flashcardCount = 0,
    this.fileCount = 0,
    required this.createdAt,
    required this.lastUpdated,
  });
}

/// Study set repository interface.
abstract class StudySetRepository {
  /// Get all study sets for current student.
  Future<Result<List<StudySet>>> getAllStudySets();

  /// Get study sets filtered by date range.
  Future<Result<List<StudySet>>> getStudySetsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get study set by ID.
  Future<Result<StudySet?>> getStudySetById(String studySetId);

  /// Create a new study set.
  Future<Result<StudySet>> createStudySet({
    required String title,
    required String category,
    bool isPrivate = true,
  });

  /// Update study set.
  Future<Result<void>> updateStudySet(StudySet studySet);

  /// Delete study set.
  Future<Result<void>> deleteStudySet(String studySetId);

  /// Add topic to study set.
  Future<Result<void>> addTopic(String studySetId, String topicId);

  /// Add flashcard to study set.
  Future<Result<void>> addFlashcard(String studySetId, String flashcardId);

  /// Add file to study set.
  Future<Result<void>> addFile(String studySetId, String fileId);

  /// Get content counts for study set.
  Future<Result<Map<String, int>>> getContentCounts(String studySetId);
}

