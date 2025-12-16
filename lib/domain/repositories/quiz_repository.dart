/// Quiz Repository Interface.
/// Defines contract for quiz data operations.
/// 
/// Layer: Domain
/// Responsibility: Abstract data access for quizzes and questions.
/// Implementation: Data layer provides concrete implementation.
library;

import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/quiz.dart';

abstract class QuizRepository {
  /// Retrieves available diagnostic quiz for a subject.
  Future<Result<Quiz?>> getDiagnosticQuiz(String subjectId);

  /// Retrieves questions for adaptive quiz based on knowledge gaps.
  Future<Result<List<QuizQuestion>>> getAdaptiveQuestions({
    required String subjectId,
    required double targetDifficulty,
    required int count,
  });

  /// Saves quiz result.
  Future<Result<void>> saveQuizResult(Quiz quiz);

  /// Retrieves quiz history for a subject.
  Future<Result<List<Quiz>>> getQuizHistory(String subjectId);
}
