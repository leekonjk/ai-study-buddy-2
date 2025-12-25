/// AI Mentor Service.
/// Generates advisory insights and explanations for the student.
/// 
/// Layer: Domain
/// Responsibility: Produce explainable AI guidance and encouragement.
/// Inputs: Academic state, risk assessments, progress data.
/// Outputs: AIInsight messages with actionable recommendations.
library;

import 'package:studnet_ai_buddy/domain/entities/ai_insight.dart';
import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';
import 'package:studnet_ai_buddy/domain/entities/risk_assessment.dart';
import 'package:studnet_ai_buddy/domain/entities/study_plan.dart';

abstract class AIMentorService {
  /// Generates daily insights based on current academic state.
  Future<List<AIInsight>> generateDailyInsights({
    required List<KnowledgeLevel> knowledgeLevels,
    required List<RiskAssessment> riskAssessments,
    required StudyPlan? currentPlan,
  });

  /// Generates encouragement after task completion.
  Future<AIInsight> generateCompletionFeedback({
    required String taskTitle,
    required int streakDays,
  });

  /// Generates warning insight for high-risk subjects.
  Future<AIInsight> generateRiskWarning({
    required RiskAssessment assessment,
  });

  /// Answers student query about their academic progress.
  Future<String> explainProgress({
    required String subjectId,
    required KnowledgeLevel level,
    required List<RiskAssessment> assessments,
  });

  /// Answers a general query from the user in chat.
  Future<String> answerQuery(String query);

  /// Generates flashcards from topics.
  Future<List<Map<String, dynamic>>> generateFlashcardsFromTopics({
    required String topics,
    required String difficulty, // 'easy', 'medium', 'hard'
    required int count,
  });

  /// Generates flashcards from uploaded file.
  Future<List<Map<String, dynamic>>> generateFlashcardsFromFile({
    required String fileId,
    required String difficulty,
    required int count,
  });

  /// Creates a new study set.
  Future<String> createStudySet({
    required String name,
    required String category,
  });
}
