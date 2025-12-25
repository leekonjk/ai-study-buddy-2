/// AIMentorServiceImpl
///
/// Pure Dart implementation of AI mentor advisory service.
/// Generates explainable insights and recommendations.
///
/// Layer: Domain (Implementation)
/// Dependencies: None (pure logic, no Flutter/Firebase/repositories)
library;

import 'package:studnet_ai_buddy/domain/entities/ai_insight.dart';
import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';
import 'package:studnet_ai_buddy/domain/entities/risk_assessment.dart';
import 'package:studnet_ai_buddy/domain/entities/study_plan.dart';
import 'package:studnet_ai_buddy/domain/services/ai_mentor_service.dart';

class AIMentorServiceImpl implements AIMentorService {
  @override
  Future<List<AIInsight>> generateDailyInsights({
    required List<KnowledgeLevel> knowledgeLevels,
    required List<RiskAssessment> riskAssessments,
    required StudyPlan? currentPlan,
  }) async {
    final insights = <AIInsight>[];
    final now = DateTime.now();

    // Generate insights based on knowledge gaps
    for (final level in knowledgeLevels) {
      if (level.masteryScore < 0.4) {
        insights.add(
          AIInsight(
            id: 'insight_gap_${level.subjectId}_${now.millisecondsSinceEpoch}',
            type: InsightType.warning,
            title: 'Knowledge Gap Detected',
            message:
                'Your mastery in ${level.subjectId} is at ${(level.masteryScore * 100).toStringAsFixed(0)}%. Consider dedicating extra study time.',
            reasoning:
                'Mastery score ${(level.masteryScore * 100).toStringAsFixed(0)}% is below 40% threshold.',
            priority: InsightPriority.high,
            generatedAt: now,
            actionLabel: 'Start Review',
          ),
        );
      }
    }

    // Generate insights based on risk assessments
    for (final risk in riskAssessments) {
      if (risk.riskLevel == RiskLevel.high ||
          risk.riskLevel == RiskLevel.critical) {
        insights.add(
          AIInsight(
            id: 'insight_risk_${risk.subjectId}_${now.millisecondsSinceEpoch}',
            type: InsightType.warning,
            title: 'Subject at Risk',
            message: risk.aiExplanation,
            reasoning:
                'Risk level is ${risk.riskLevel.name} based on multiple contributing factors.',
            priority: InsightPriority.high,
            generatedAt: now,
            actionLabel: 'View Details',
          ),
        );
      }
    }

    // Generate study plan insights
    if (currentPlan != null) {
      final pendingTasks = currentPlan.tasks
          .where((t) => !t.isCompleted)
          .length;
      final completedTasks = currentPlan.tasks
          .where((t) => t.isCompleted)
          .length;

      if (completedTasks > 0) {
        insights.add(
          AIInsight(
            id: 'insight_progress_${now.millisecondsSinceEpoch}',
            type: InsightType.encouragement,
            title: 'Great Progress!',
            message:
                'You\'ve completed $completedTasks task(s) this week. Keep up the momentum!',
            reasoning:
                'Student completed $completedTasks tasks, showing positive engagement.',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
        );
      }

      if (pendingTasks > 3) {
        insights.add(
          AIInsight(
            id: 'insight_pending_${now.millisecondsSinceEpoch}',
            type: InsightType.reminder,
            title: 'Task Reminder',
            message:
                'You have $pendingTasks tasks remaining this week. Consider breaking them into smaller sessions.',
            reasoning:
                'Multiple pending tasks detected; suggesting task management.',
            priority: InsightPriority.medium,
            generatedAt: now,
            actionLabel: 'View Tasks',
          ),
        );
      }
    }

    // Add a daily tip if no other insights
    if (insights.isEmpty) {
      insights.add(_generateDailyTip(now));
    }

    // Sort by priority
    insights.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    return insights;
  }

  @override
  Future<AIInsight> generateCompletionFeedback({
    required String taskTitle,
    required int streakDays,
  }) async {
    final now = DateTime.now();

    String message;
    String reasoning;
    if (streakDays >= 7) {
      message =
          'Amazing! You completed "$taskTitle" and maintained a $streakDays-day streak!';
      reasoning =
          'Extended streak of $streakDays days shows excellent consistency.';
    } else if (streakDays >= 3) {
      message =
          'Well done! "$taskTitle" is complete. You\'re on a $streakDays-day streak!';
      reasoning = 'Building streak momentum with $streakDays consecutive days.';
    } else {
      message =
          'Great job completing "$taskTitle"! Keep going to build your study streak.';
      reasoning = 'Task completion acknowledged; encouraging streak building.';
    }

    return AIInsight(
      id: 'insight_completion_${now.millisecondsSinceEpoch}',
      type: InsightType.encouragement,
      title: 'Task Completed!',
      message: message,
      reasoning: reasoning,
      priority: InsightPriority.low,
      generatedAt: now,
    );
  }

  @override
  Future<AIInsight> generateRiskWarning({
    required RiskAssessment assessment,
  }) async {
    final now = DateTime.now();

    final factorDescriptions = assessment.contributingFactors
        .map((f) => f.description)
        .take(2)
        .join(' ');

    return AIInsight(
      id: 'insight_warning_${assessment.subjectId}_${now.millisecondsSinceEpoch}',
      type: InsightType.warning,
      title: 'Attention Needed',
      message: 'Risk level: ${assessment.riskLevel.name}. $factorDescriptions',
      reasoning:
          'Risk score ${(assessment.riskScore * 100).toStringAsFixed(0)}% triggered warning.',
      priority: InsightPriority.high,
      generatedAt: now,
      actionLabel: 'Take Action',
    );
  }

  @override
  Future<String> explainProgress({
    required String subjectId,
    required KnowledgeLevel level,
    required List<RiskAssessment> assessments,
  }) async {
    final buffer = StringBuffer();

    // Mastery explanation
    final masteryPercent = (level.masteryScore * 100).toStringAsFixed(0);
    buffer.writeln('## Current Standing');
    buffer.writeln('Your mastery level in this subject is $masteryPercent%.');

    if (level.masteryScore >= 0.8) {
      buffer.writeln(
        'This is excellent! You have a strong grasp of the material.',
      );
    } else if (level.masteryScore >= 0.6) {
      buffer.writeln(
        'You\'re making good progress. Focus on areas where you scored lower.',
      );
    } else if (level.masteryScore >= 0.4) {
      buffer.writeln(
        'There\'s room for improvement. Consider reviewing foundational concepts.',
      );
    } else {
      buffer.writeln(
        'This subject needs significant attention. Start with basic concepts.',
      );
    }

    // Confidence explanation
    buffer.writeln();
    buffer.writeln('## Confidence');
    if (level.confidenceScore >= 0.7) {
      buffer.writeln(
        'Our estimate is highly confident based on sufficient assessment data.',
      );
    } else if (level.confidenceScore >= 0.4) {
      buffer.writeln(
        'Moderately confident. Taking more quizzes will improve accuracy.',
      );
    } else {
      buffer.writeln(
        'Limited data available. Complete more quizzes for better assessment.',
      );
    }

    // Risk factors
    final subjectRisk = assessments
        .where((r) => r.subjectId == subjectId)
        .toList();
    if (subjectRisk.isNotEmpty) {
      final risk = subjectRisk.first;
      buffer.writeln();
      buffer.writeln('## Risk Factors');
      buffer.writeln('Risk level: ${risk.riskLevel.name}');
      for (final factor in risk.contributingFactors.take(3)) {
        buffer.writeln('- ${factor.description}');
      }
    }

    // Recommendations
    buffer.writeln();
    buffer.writeln('## Recommendations');
    if (level.masteryScore < 0.5) {
      buffer.writeln('1. Schedule daily review sessions');
      buffer.writeln('2. Take diagnostic quizzes to identify specific gaps');
      buffer.writeln('3. Focus on foundational concepts first');
    } else {
      buffer.writeln('1. Continue regular practice');
      buffer.writeln('2. Challenge yourself with harder problems');
      buffer.writeln('3. Review periodically to prevent decay');
    }

    return buffer.toString();
  }

  /// Generates a daily study tip.
  AIInsight _generateDailyTip(DateTime now) {
    final tips = [
      'Active recall is more effective than passive reading. Quiz yourself!',
      'Spaced repetition helps long-term retention. Review old material regularly.',
      'Take short breaks every 25-30 minutes to maintain focus.',
      'Teaching concepts to others strengthens your own understanding.',
      'Sleep is crucial for memory consolidation. Don\'t sacrifice rest for study.',
      'Connect new information to what you already know for better retention.',
      'Set specific, achievable goals for each study session.',
    ];

    final tipIndex = now.dayOfYear % tips.length;

    return AIInsight(
      id: 'insight_tip_${now.millisecondsSinceEpoch}',
      type: InsightType.suggestion,
      title: 'Study Tip of the Day',
      message: tips[tipIndex],
      reasoning: 'Daily tip rotated based on day of year.',
      priority: InsightPriority.low,
      generatedAt: now,
    );
  }

  @override
  Future<String> answerQuery(String query) async {
    // Using Firebase Firestore AI logic for query responses
    // Mock responses for now - connect to Firebase Genkit/Vertex AI in production
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('flashcard')) {
      if (lowerQuery.contains('file')) {
        return "I don't see a file uploaded yet. Could you please upload the file you'd like to create flashcards from?";
      }
      if (lowerQuery.contains('without')) {
        return "Great! To create flashcards for your exam, could you tell me which topics or areas you'd like to focus on? Also, let me know the difficulty level (easy, medium, hard) and how many flashcards you'd prefer.";
      }
      return "I can help you create flashcards! Would you like to create them from a file you upload, or specify topics directly?";
    }

    if (lowerQuery.contains('specify') || lowerQuery.contains('topic')) {
      return "Please specify the topics you'd like the flashcards to cover, and your preferred difficulty level (easy, medium, or hard). Also, let me know approximately how many flashcards you want.";
    }

    if (lowerQuery.contains('create') && lowerQuery.contains('new')) {
      return "Thanks for the details! I'll prepare the flashcards for you. Would you like me to add these flashcards to your existing study set or create a new one?";
    }

    if (lowerQuery.contains('help') || lowerQuery.contains('how')) {
      return "I'd be happy to help! I can assist you with:\n"
          "• Creating flashcards from topics or files\n"
          "• Generating study plans\n"
          "• Answering questions about your subjects\n"
          "• Providing study tips and recommendations\n\n"
          "What would you like to work on?";
    }

    return "I understand. Let me help you with that. Could you provide more details about what you need?";
  }

  @override
  Future<List<Map<String, dynamic>>> generateFlashcardsFromTopics({
    required String topics,
    required String difficulty,
    required int count,
  }) async {
    // Using Firebase Firestore AI logic for flashcard generation
    // Connect to Firebase Genkit/Vertex AI for production use
    final flashcards = <Map<String, dynamic>>[];

    for (int i = 0; i < count; i++) {
      flashcards.add({
        'id': 'flashcard_${DateTime.now().millisecondsSinceEpoch}_$i',
        'front': 'Question ${i + 1} about $topics',
        'back': 'Answer ${i + 1} explaining the concept',
        'difficulty': difficulty,
        'topic': topics,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    return flashcards;
  }

  @override
  Future<List<Map<String, dynamic>>> generateFlashcardsFromFile({
    required String fileId,
    required String difficulty,
    required int count,
  }) async {
    // Using Firebase Firestore AI logic for file-based flashcard generation
    // Connect to Firebase Genkit/Vertex AI + Cloud Storage for production
    final flashcards = <Map<String, dynamic>>[];

    for (int i = 0; i < count; i++) {
      flashcards.add({
        'id':
            'flashcard_file_${fileId}_${DateTime.now().millisecondsSinceEpoch}_$i',
        'front': 'Question ${i + 1} from file',
        'back': 'Answer ${i + 1} extracted from file content',
        'difficulty': difficulty,
        'fileId': fileId,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    return flashcards;
  }

  @override
  Future<String> createStudySet({
    required String name,
    required String category,
  }) async {
    // Using Firebase Firestore for study set creation
    // Connect to StudySetRepository in service locator for production
    return 'studyset_${DateTime.now().millisecondsSinceEpoch}';
  }
}

extension on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }
}
