/// KnowledgeEstimationServiceImpl
/// 
/// Pure Dart implementation of knowledge level estimation.
/// Uses deterministic, rule-based logic to estimate mastery from quiz performance.
/// 
/// Layer: Domain (Implementation)
/// Dependencies: None (pure logic, no Flutter/Firebase/repositories)
/// 
/// Estimation Algorithm:
/// 1. Base score from quiz percentage (0.0 - 1.0)
/// 2. Confidence derived from question count and difficulty variance
/// 3. Mastery level categorized as: Low (<40%), Medium (40-75%), High (>75%)
/// 4. Reasoning generated explaining all contributing factors
library;

import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';
import 'package:studnet_ai_buddy/domain/entities/quiz.dart';
import 'package:studnet_ai_buddy/domain/services/knowledge_estimation_service.dart';

class KnowledgeEstimationServiceImpl implements KnowledgeEstimationService {
  // Thresholds for mastery classification
  static const double _lowMasteryThreshold = 0.4;
  static const double _highMasteryThreshold = 0.75;

  // Minimum questions for high confidence estimate
  static const int _minQuestionsForHighConfidence = 10;

  // Forgetting curve decay rate (Ebbinghaus-inspired)
  // Represents proportion retained per day without review
  static const double _dailyRetentionRate = 0.95;

  @override
  Future<List<KnowledgeLevel>> estimateFromDiagnostic(Quiz completedQuiz) async {
    // Validate quiz has been completed
    if (!completedQuiz.isCompleted || completedQuiz.questions.isEmpty) {
      return [];
    }

    // Calculate performance metrics from quiz
    final metrics = _calculateQuizMetrics(completedQuiz);

    // Generate mastery score weighted by difficulty
    final masteryScore = _calculateMasteryScore(
      correctRatio: metrics.correctRatio,
      averageDifficulty: metrics.averageDifficulty,
      difficultyAdjustedScore: metrics.difficultyAdjustedScore,
    );

    // Calculate confidence based on sample size and consistency
    final confidenceScore = _calculateConfidenceScore(
      questionCount: completedQuiz.questions.length,
      scoreVariance: metrics.scoreVariance,
    );

    // Generate human-readable reasoning
    final reasoning = generateEstimateReasoning(
      score: masteryScore,
      questionsAnswered: completedQuiz.questions.length,
      averageDifficulty: metrics.averageDifficulty,
    );

    // Create knowledge level for the subject
    final subjectLevel = KnowledgeLevel(
      subjectId: completedQuiz.subjectId,
      topicId: completedQuiz.topicId,
      masteryScore: masteryScore,
      confidenceScore: confidenceScore,
      estimatedAt: DateTime.now(),
      reasoningNote: reasoning,
    );

    return [subjectLevel];
  }

  @override
  Future<KnowledgeLevel> updateFromAdaptiveQuiz({
    required KnowledgeLevel currentLevel,
    required Quiz completedQuiz,
  }) async {
    if (!completedQuiz.isCompleted || completedQuiz.questions.isEmpty) {
      return currentLevel;
    }

    final metrics = _calculateQuizMetrics(completedQuiz);

    // New evidence from adaptive quiz
    final newScore = _calculateMasteryScore(
      correctRatio: metrics.correctRatio,
      averageDifficulty: metrics.averageDifficulty,
      difficultyAdjustedScore: metrics.difficultyAdjustedScore,
    );

    // Bayesian-inspired update: weight new evidence by confidence
    // Higher existing confidence = less influence from new data
    // Lower existing confidence = more influence from new data
    final existingWeight = currentLevel.confidenceScore;
    final newWeight = 1.0 - existingWeight;

    // Blended mastery score
    final updatedMastery = (currentLevel.masteryScore * existingWeight) +
        (newScore * newWeight);

    // Confidence increases with more evidence
    final newConfidence = _calculateConfidenceScore(
      questionCount: completedQuiz.questions.length,
      scoreVariance: metrics.scoreVariance,
    );
    final updatedConfidence = _blendConfidence(
      existingConfidence: currentLevel.confidenceScore,
      newConfidence: newConfidence,
    );

    // Generate updated reasoning
    final reasoning = _generateUpdateReasoning(
      previousScore: currentLevel.masteryScore,
      newQuizScore: newScore,
      updatedScore: updatedMastery,
      questionCount: completedQuiz.questions.length,
    );

    return KnowledgeLevel(
      subjectId: currentLevel.subjectId,
      topicId: currentLevel.topicId,
      masteryScore: updatedMastery.clamp(0.0, 1.0),
      confidenceScore: updatedConfidence.clamp(0.0, 1.0),
      estimatedAt: DateTime.now(),
      reasoningNote: reasoning,
    );
  }

  @override
  Future<KnowledgeLevel> applyTimeDecay({
    required KnowledgeLevel level,
    required Duration timeSinceLastStudy,
  }) async {
    final daysSinceStudy = timeSinceLastStudy.inDays;

    // No decay for recent study
    if (daysSinceStudy <= 0) {
      return level;
    }

    // Ebbinghaus forgetting curve: R = e^(-t/S)
    // Simplified: use exponential decay with daily retention rate
    // Mastery decays more slowly for higher initial mastery (better encoded)
    final retentionFactor = _calculateRetentionFactor(
      daysSinceStudy: daysSinceStudy,
      initialMastery: level.masteryScore,
    );

    final decayedMastery = level.masteryScore * retentionFactor;

    // Confidence also decays (estimate becomes less certain over time)
    final confidenceDecay = 0.98; // 2% confidence loss per calculation
    final decayedConfidence = level.confidenceScore * confidenceDecay;

    final reasoning = _generateDecayReasoning(
      daysSinceStudy: daysSinceStudy,
      previousMastery: level.masteryScore,
      decayedMastery: decayedMastery,
    );

    return KnowledgeLevel(
      subjectId: level.subjectId,
      topicId: level.topicId,
      masteryScore: decayedMastery.clamp(0.0, 1.0),
      confidenceScore: decayedConfidence.clamp(0.0, 1.0),
      estimatedAt: DateTime.now(),
      reasoningNote: reasoning,
    );
  }

  @override
  String generateEstimateReasoning({
    required double score,
    required int questionsAnswered,
    required double averageDifficulty,
  }) {
    final masteryLabel = _getMasteryLabel(score);
    final difficultyLabel = _getDifficultyLabel(averageDifficulty);
    final confidenceNote = _getConfidenceNote(questionsAnswered);

    final buffer = StringBuffer();

    // Score impact explanation
    buffer.write('Based on ${(score * 100).toStringAsFixed(0)}% performance, ');
    buffer.write('mastery is classified as $masteryLabel. ');

    // Difficulty impact explanation
    buffer.write('Questions were $difficultyLabel difficulty ');
    buffer.write('(avg: ${(averageDifficulty * 100).toStringAsFixed(0)}%). ');

    // Confidence explanation
    buffer.write(confidenceNote);

    // Actionable insight
    if (score < _lowMasteryThreshold) {
      buffer.write(' Recommend focused review of fundamentals.');
    } else if (score < _highMasteryThreshold) {
      buffer.write(' Recommend practice with varied difficulty.');
    } else {
      buffer.write(' Ready for advanced topics or maintenance review.');
    }

    return buffer.toString();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Calculates comprehensive metrics from quiz performance.
  _QuizMetrics _calculateQuizMetrics(Quiz quiz) {
    if (quiz.questions.isEmpty) {
      return const _QuizMetrics(
        correctRatio: 0.0,
        averageDifficulty: 0.5,
        difficultyAdjustedScore: 0.0,
        scoreVariance: 0.0,
      );
    }

    int correctCount = 0;
    double totalDifficulty = 0.0;
    double weightedScore = 0.0;
    List<double> questionScores = [];

    for (final question in quiz.questions) {
      final isCorrect = question.selectedOptionIndex != null &&
          int.tryParse(question.selectedOptionIndex!) == question.correctOptionIndex;

      if (isCorrect) {
        correctCount++;
        // Harder questions contribute more to weighted score
        weightedScore += question.difficulty;
        questionScores.add(1.0);
      } else {
        questionScores.add(0.0);
      }
      totalDifficulty += question.difficulty;
    }

    final correctRatio = correctCount / quiz.questions.length;
    final averageDifficulty = totalDifficulty / quiz.questions.length;

    // Difficulty-adjusted score: performance relative to question difficulty
    final maxPossibleWeightedScore = totalDifficulty;
    final difficultyAdjustedScore = maxPossibleWeightedScore > 0
        ? weightedScore / maxPossibleWeightedScore
        : correctRatio;

    // Calculate variance in performance (consistency measure)
    final meanScore = questionScores.reduce((a, b) => a + b) / questionScores.length;
    final variance = questionScores
            .map((s) => (s - meanScore) * (s - meanScore))
            .reduce((a, b) => a + b) /
        questionScores.length;

    return _QuizMetrics(
      correctRatio: correctRatio,
      averageDifficulty: averageDifficulty,
      difficultyAdjustedScore: difficultyAdjustedScore,
      scoreVariance: variance,
    );
  }

  /// Calculates mastery score with difficulty weighting.
  double _calculateMasteryScore({
    required double correctRatio,
    required double averageDifficulty,
    required double difficultyAdjustedScore,
  }) {
    // Blend raw score with difficulty-adjusted score
    // Higher difficulty quizzes give more weight to difficulty adjustment
    final difficultyWeight = averageDifficulty;
    final rawWeight = 1.0 - difficultyWeight;

    final blendedScore =
        (correctRatio * rawWeight) + (difficultyAdjustedScore * difficultyWeight);

    return blendedScore.clamp(0.0, 1.0);
  }

  /// Calculates confidence score based on evidence quality.
  double _calculateConfidenceScore({
    required int questionCount,
    required double scoreVariance,
  }) {
    // Base confidence from sample size
    // More questions = higher confidence (asymptotic approach to 1.0)
    final sampleConfidence =
        1.0 - (1.0 / (1.0 + (questionCount / _minQuestionsForHighConfidence)));

    // Penalty for high variance (inconsistent performance)
    // Variance of 0 = no penalty, variance of 0.25 (max for binary) = 20% penalty
    final variancePenalty = scoreVariance * 0.8;

    final confidence = sampleConfidence - variancePenalty;
    return confidence.clamp(0.3, 0.95); // Minimum 30%, maximum 95% confidence
  }

  /// Blends existing and new confidence scores.
  double _blendConfidence({
    required double existingConfidence,
    required double newConfidence,
  }) {
    // Confidence grows with more evidence but with diminishing returns
    final combined = existingConfidence + (newConfidence * (1 - existingConfidence) * 0.5);
    return combined.clamp(0.0, 0.95);
  }

  /// Calculates retention factor based on forgetting curve.
  double _calculateRetentionFactor({
    required int daysSinceStudy,
    required double initialMastery,
  }) {
    // Higher mastery = slower decay (better memory consolidation)
    final masteryBonus = 1.0 + (initialMastery * 0.1); // Up to 10% slower decay
    final effectiveRetentionRate = _dailyRetentionRate * masteryBonus;

    // Exponential decay
    double retention = 1.0;
    for (int i = 0; i < daysSinceStudy && i < 30; i++) {
      retention *= effectiveRetentionRate.clamp(0.9, 0.99);
    }

    // Floor at 40% - some knowledge is retained long-term
    return retention.clamp(0.4, 1.0);
  }

  /// Returns human-readable mastery label.
  String _getMasteryLabel(double score) {
    if (score >= _highMasteryThreshold) return 'High';
    if (score >= _lowMasteryThreshold) return 'Medium';
    return 'Low';
  }

  /// Returns human-readable difficulty label.
  String _getDifficultyLabel(double difficulty) {
    if (difficulty >= 0.7) return 'high';
    if (difficulty >= 0.4) return 'moderate';
    return 'low';
  }

  /// Returns confidence explanation based on question count.
  String _getConfidenceNote(int questionCount) {
    if (questionCount >= _minQuestionsForHighConfidence) {
      return 'Estimate confidence is high ($questionCount questions).';
    } else if (questionCount >= 5) {
      return 'Estimate confidence is moderate ($questionCount questions).';
    } else {
      return 'Estimate confidence is low (only $questionCount questions). More assessment recommended.';
    }
  }

  /// Generates reasoning for adaptive quiz update.
  String _generateUpdateReasoning({
    required double previousScore,
    required double newQuizScore,
    required double updatedScore,
    required int questionCount,
  }) {
    final previousLabel = _getMasteryLabel(previousScore);
    final newLabel = _getMasteryLabel(updatedScore);

    final buffer = StringBuffer();
    buffer.write('Previous mastery: ${(previousScore * 100).toStringAsFixed(0)}% ($previousLabel). ');
    buffer.write('New quiz performance: ${(newQuizScore * 100).toStringAsFixed(0)}% on $questionCount questions. ');

    if (updatedScore > previousScore) {
      buffer.write('Mastery increased to ${(updatedScore * 100).toStringAsFixed(0)}%');
    } else if (updatedScore < previousScore) {
      buffer.write('Mastery adjusted down to ${(updatedScore * 100).toStringAsFixed(0)}%');
    } else {
      buffer.write('Mastery remains at ${(updatedScore * 100).toStringAsFixed(0)}%');
    }

    if (newLabel != previousLabel) {
      buffer.write(' (now classified as $newLabel).');
    } else {
      buffer.write('.');
    }

    return buffer.toString();
  }

  /// Generates reasoning for time decay.
  String _generateDecayReasoning({
    required int daysSinceStudy,
    required double previousMastery,
    required double decayedMastery,
  }) {
    final decayPercent = ((previousMastery - decayedMastery) * 100).toStringAsFixed(1);

    return 'No study activity detected for $daysSinceStudy days. '
        'Mastery estimate reduced by $decayPercent% due to natural forgetting. '
        'Review recommended to maintain knowledge level.';
  }
}

/// Internal data class for quiz performance metrics.
class _QuizMetrics {
  final double correctRatio;
  final double averageDifficulty;
  final double difficultyAdjustedScore;
  final double scoreVariance;

  const _QuizMetrics({
    required this.correctRatio,
    required this.averageDifficulty,
    required this.difficultyAdjustedScore,
    required this.scoreVariance,
  });
}
