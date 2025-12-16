/// Quiz Repository Implementation.
/// Concrete implementation of QuizRepository interface using Firebase Firestore.
/// 
/// Layer: Data
/// Responsibility: Data operations for quizzes and quiz attempts via Firestore.
/// 
/// Firestore Collections Used:
/// - quizzes: Quiz definitions with questions
/// - quiz_attempts: Student quiz attempt records
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studnet_ai_buddy/core/errors/failures.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/quiz.dart';
import 'package:studnet_ai_buddy/domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  final FirebaseFirestore _firestore;
  final String _currentStudentId;

  // Firestore collection names (per schema)
  static const String _quizzesCollection = 'quizzes';
  static const String _quizAttemptsCollection = 'quiz_attempts';

  QuizRepositoryImpl({
    required FirebaseFirestore firestore,
    required String currentStudentId,
  })  : _firestore = firestore,
        _currentStudentId = currentStudentId;

  // ─────────────────────────────────────────────────────────────────────────
  // Quiz Retrieval Operations
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<Quiz?>> getDiagnosticQuiz(String subjectId) async {
    try {
      // Query for diagnostic quiz for the given subject
      final querySnapshot = await _firestore
          .collection(_quizzesCollection)
          .where('subjectId', isEqualTo: subjectId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Success(null);
      }

      final doc = querySnapshot.docs.first;
      final quiz = _mapDocumentToQuiz(doc);

      return Success(quiz);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to fetch diagnostic quiz: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<QuizQuestion>>> getAdaptiveQuestions({
    required String subjectId,
    required double targetDifficulty,
    required int count,
  }) async {
    try {
      // Map target difficulty to schema difficulty string
      final difficultyString = _mapDifficultyToString(targetDifficulty);

      // Query quizzes for the subject with matching difficulty
      final querySnapshot = await _firestore
          .collection(_quizzesCollection)
          .where('subjectId', isEqualTo: subjectId)
          .where('difficulty', isEqualTo: difficultyString)
          .limit(3) // Get multiple quizzes to have enough questions
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Fallback: get any quiz for the subject
        final fallbackSnapshot = await _firestore
            .collection(_quizzesCollection)
            .where('subjectId', isEqualTo: subjectId)
            .limit(1)
            .get();

        if (fallbackSnapshot.docs.isEmpty) {
          return const Success([]);
        }

        final quiz = _mapDocumentToQuiz(fallbackSnapshot.docs.first);
        return Success(quiz.questions.take(count).toList());
      }

      // Collect questions from matching quizzes
      final allQuestions = <QuizQuestion>[];
      for (final doc in querySnapshot.docs) {
        final quiz = _mapDocumentToQuiz(doc);
        allQuestions.addAll(quiz.questions);
      }

      // Return requested count of questions
      final selectedQuestions = allQuestions.take(count).toList();
      return Success(selectedQuestions);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to fetch adaptive questions: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Quiz Result Operations
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<void>> saveQuizResult(Quiz quiz) async {
    try {
      if (quiz.result == null) {
        return const Err(ValidationFailure(
          message: 'Cannot save quiz without result',
        ));
      }

      final attemptData = _mapQuizToAttemptDocument(quiz);

      await _firestore.collection(_quizAttemptsCollection).add(attemptData);

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to save quiz result: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<Quiz>>> getQuizHistory(String subjectId) async {
    try {
      // Query quiz attempts for this student and subject
      final querySnapshot = await _firestore
          .collection(_quizAttemptsCollection)
          .where('studentId', isEqualTo: _currentStudentId)
          .where('subjectId', isEqualTo: subjectId)
          .orderBy('completedAt', descending: true)
          .limit(20)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Success([]);
      }

      // Map attempts to Quiz entities
      final quizzes = <Quiz>[];
      for (final doc in querySnapshot.docs) {
        final quiz = await _mapAttemptToQuiz(doc);
        if (quiz != null) {
          quizzes.add(quiz);
        }
      }

      return Success(quizzes);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to fetch quiz history: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping: Firestore Document → Domain Entity
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps Firestore quiz document to Quiz domain entity.
  /// 
  /// Firestore schema (quizzes):
  /// - quizId: string
  /// - subjectId: string
  /// - title: string
  /// - questions: array of {questionId, text, options, correctAnswerIndex}
  /// - difficulty: string (easy | medium | hard)
  /// - createdAt: timestamp
  Quiz _mapDocumentToQuiz(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    final questionsData = data['questions'] as List<dynamic>? ?? [];
    final questions = questionsData
        .map((q) => _mapDocumentToQuestion(q as Map<String, dynamic>, data['difficulty'] as String?))
        .toList();

    return Quiz(
      id: data['quizId'] as String? ?? doc.id,
      subjectId: data['subjectId'] as String? ?? '',
      topicId: null, // Not in schema
      type: QuizType.diagnostic, // Default type
      questions: questions,
      startedAt: null,
      completedAt: null,
      result: null,
    );
  }

  /// Maps embedded question data to QuizQuestion domain entity.
  /// 
  /// Firestore schema (questions array item):
  /// - questionId: string
  /// - text: string
  /// - options: array of strings
  /// - correctAnswerIndex: int
  QuizQuestion _mapDocumentToQuestion(Map<String, dynamic> data, String? difficultyStr) {
    final options = (data['options'] as List<dynamic>?)
            ?.map((o) => o.toString())
            .toList() ??
        [];

    return QuizQuestion(
      id: data['questionId'] as String? ?? '',
      questionText: data['text'] as String? ?? '',
      options: options,
      correctOptionIndex: data['correctAnswerIndex'] as int? ?? 0,
      explanation: null, // Not in schema
      difficulty: _mapStringToDifficulty(difficultyStr),
      selectedOptionIndex: null,
    );
  }

  /// Maps quiz attempt document to Quiz entity with result.
  /// 
  /// Firestore schema (quiz_attempts):
  /// - attemptId: string
  /// - studentId: string
  /// - quizId: string
  /// - subjectId: string
  /// - scorePercentage: double
  /// - confidenceLevel: int (1-5)
  /// - answers: array of {questionId, selectedIndex}
  /// - completedAt: timestamp
  Future<Quiz?> _mapAttemptToQuiz(DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data()!;

    final quizId = data['quizId'] as String?;
    if (quizId == null) return null;

    // Fetch original quiz to get questions
    final quizDoc = await _firestore
        .collection(_quizzesCollection)
        .doc(quizId)
        .get();

    if (!quizDoc.exists) {
      // Create minimal quiz from attempt data
      return _createQuizFromAttempt(data, doc.id);
    }

    final quiz = _mapDocumentToQuiz(quizDoc);
    final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
    final scorePercentage = (data['scorePercentage'] as num?)?.toDouble() ?? 0.0;

    // Map answers to questions
    final answersData = data['answers'] as List<dynamic>? ?? [];
    final answersMap = <String, int>{};
    for (final answer in answersData) {
      final answerMap = answer as Map<String, dynamic>;
      final questionId = answerMap['questionId'] as String?;
      final selectedIndex = answerMap['selectedIndex'] as int?;
      if (questionId != null && selectedIndex != null) {
        answersMap[questionId] = selectedIndex;
      }
    }

    // Calculate correct answers
    int correctCount = 0;
    for (final question in quiz.questions) {
      final selected = answersMap[question.id];
      if (selected == question.correctOptionIndex) {
        correctCount++;
      }
    }

    final result = QuizResult(
      correctAnswers: correctCount,
      totalQuestions: quiz.questions.length,
      scorePercentage: scorePercentage,
      estimatedMastery: scorePercentage / 100.0,
      aiFeedback: '', // Will be generated by AI service
    );

    return Quiz(
      id: quiz.id,
      subjectId: quiz.subjectId,
      topicId: quiz.topicId,
      type: quiz.type,
      questions: quiz.questions,
      startedAt: null,
      completedAt: completedAt,
      result: result,
    );
  }

  /// Creates a minimal Quiz from attempt data when original quiz is unavailable.
  Quiz _createQuizFromAttempt(Map<String, dynamic> data, String attemptId) {
    final completedAt = (data['completedAt'] as Timestamp?)?.toDate();
    final scorePercentage = (data['scorePercentage'] as num?)?.toDouble() ?? 0.0;

    final result = QuizResult(
      correctAnswers: 0,
      totalQuestions: 0,
      scorePercentage: scorePercentage,
      estimatedMastery: scorePercentage / 100.0,
      aiFeedback: '',
    );

    return Quiz(
      id: data['quizId'] as String? ?? attemptId,
      subjectId: data['subjectId'] as String? ?? '',
      topicId: null,
      type: QuizType.diagnostic,
      questions: [],
      startedAt: null,
      completedAt: completedAt,
      result: result,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping: Domain Entity → Firestore Document
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps Quiz domain entity to quiz_attempts document data.
  Map<String, dynamic> _mapQuizToAttemptDocument(Quiz quiz) {
    final answers = quiz.questions
        .where((q) => q.selectedOptionIndex != null)
        .map((q) => {
              'questionId': q.id,
              'selectedIndex': int.tryParse(q.selectedOptionIndex!) ?? 0,
            })
        .toList();

    // Calculate confidence level (1-5) from score
    final confidenceLevel = _calculateConfidenceLevel(quiz.result?.scorePercentage ?? 0);

    return {
      'attemptId': '${quiz.id}_${DateTime.now().millisecondsSinceEpoch}',
      'studentId': _currentStudentId,
      'quizId': quiz.id,
      'subjectId': quiz.subjectId,
      'scorePercentage': quiz.result?.scorePercentage ?? 0.0,
      'confidenceLevel': confidenceLevel,
      'answers': answers,
      'completedAt': FieldValue.serverTimestamp(),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps difficulty string to numeric value.
  double _mapStringToDifficulty(String? difficulty) {
    return switch (difficulty) {
      'easy' => 0.3,
      'medium' => 0.5,
      'hard' => 0.8,
      _ => 0.5,
    };
  }

  /// Maps numeric difficulty to schema string.
  String _mapDifficultyToString(double difficulty) {
    if (difficulty < 0.4) return 'easy';
    if (difficulty < 0.7) return 'medium';
    return 'hard';
  }

  /// Calculates confidence level (1-5) from score percentage.
  int _calculateConfidenceLevel(double scorePercentage) {
    if (scorePercentage >= 90) return 5;
    if (scorePercentage >= 75) return 4;
    if (scorePercentage >= 60) return 3;
    if (scorePercentage >= 40) return 2;
    return 1;
  }
}
