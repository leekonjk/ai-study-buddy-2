/// Knowledge Estimation Service.
/// AI-driven service to estimate student knowledge levels.
/// 
/// Layer: Domain
/// Responsibility: Analyze quiz results and update knowledge estimates.
/// Inputs: Quiz results, historical performance.
/// Outputs: Updated KnowledgeLevel entities with reasoning.
library;

import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';
import 'package:studnet_ai_buddy/domain/entities/quiz.dart';

abstract class KnowledgeEstimationService {
  /// Estimates knowledge level from diagnostic quiz results.
  /// Returns knowledge levels with AI reasoning for each subject/topic.
  Future<List<KnowledgeLevel>> estimateFromDiagnostic(Quiz completedQuiz);

  /// Updates knowledge level based on adaptive quiz performance.
  /// Considers existing level and new evidence.
  Future<KnowledgeLevel> updateFromAdaptiveQuiz({
    required KnowledgeLevel currentLevel,
    required Quiz completedQuiz,
  });

  /// Decays knowledge estimate over time (forgetting curve).
  /// Called periodically to adjust estimates.
  Future<KnowledgeLevel> applyTimeDecay({
    required KnowledgeLevel level,
    required Duration timeSinceLastStudy,
  });

  /// Generates reasoning explanation for a knowledge estimate.
  String generateEstimateReasoning({
    required double score,
    required int questionsAnswered,
    required double averageDifficulty,
  });
}
