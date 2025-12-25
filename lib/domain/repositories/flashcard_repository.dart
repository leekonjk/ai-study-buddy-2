/// Flashcard Repository Interface
library;

import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/flashcard.dart';

abstract class FlashcardRepository {
  /// Create a new flashcard
  Future<Result<Flashcard>> createFlashcard({
    required String studySetId,
    required String term,
    required String definition,
    String? imageUrl,
  });

  /// Get all flashcards for a specific study set
  Future<Result<List<Flashcard>>> getFlashcardsByStudySetId(String studySetId);

  /// Update an existing flashcard
  Future<Result<void>> updateFlashcard(Flashcard flashcard);

  /// Delete a flashcard
  Future<Result<void>> deleteFlashcard(String flashcardId);

  /// Batch create flashcards (for efficiency when creating a set)
  Future<Result<List<Flashcard>>> createFlashcardsBatch(
    List<Flashcard> flashcards,
  );
}
