/// Quiz Entity.
/// Represents diagnostic or adaptive quiz for knowledge assessment.
/// 
/// Layer: Domain
/// Responsibility: Quiz structure with questions and results.
/// Inputs: Question bank, AI-selected questions.
/// Outputs: Used to update knowledge levels.
library;

class Quiz {
  final String id;
  final String subjectId;
  final String? topicId;
  final QuizType type;
  final List<QuizQuestion> questions;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final QuizResult? result;
  final int? timeLimitMinutes; // From template
  final double? passingScore; // From template (0.0 to 1.0)
  final String? templateName; // From template
  final String? description; // From template
  final String? difficulty; // beginner/intermediate/advanced from template

  const Quiz({
    required this.id,
    required this.subjectId,
    this.topicId,
    required this.type,
    required this.questions,
    this.startedAt,
    this.completedAt,
    this.result,
    this.timeLimitMinutes,
    this.passingScore,
    this.templateName,
    this.description,
    this.difficulty,
  });

  bool get isCompleted => completedAt != null;
  int get totalQuestions => questions.length;
}

enum QuizType {
  diagnostic, // Initial knowledge assessment
  adaptive, // AI-triggered based on gaps
  review, // Periodic review quiz
  practice, // Practice quiz from template
}

class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation; // Why the answer is correct
  final double difficulty; // 0.0 (easy) to 1.0 (hard)
  final String? selectedOptionIndex; // User's answer

  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    required this.difficulty,
    this.selectedOptionIndex,
  });
}

class QuizResult {
  final int correctAnswers;
  final int totalQuestions;
  final double scorePercentage;
  final double estimatedMastery; // AI-derived mastery from performance
  final String aiFeedback; // AI explanation of performance

  const QuizResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.scorePercentage,
    required this.estimatedMastery,
    required this.aiFeedback,
  });
}
