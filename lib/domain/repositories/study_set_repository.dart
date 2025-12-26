/// Study Set Repository
/// Interface for managing study sets.
library;

import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/study_set.dart';

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
    String? subjectId,
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
