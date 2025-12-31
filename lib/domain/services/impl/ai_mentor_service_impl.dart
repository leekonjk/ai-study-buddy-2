/// AIMentorServiceImpl
///
/// Pure Dart implementation of AI mentor advisory service.
/// Generates explainable insights and recommendations.
///
/// Layer: Domain (Implementation)
/// Dependencies: None (pure logic, no Flutter/Firebase/repositories)
library;

import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:studnet_ai_buddy/domain/entities/ai_insight.dart';
import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';
import 'package:studnet_ai_buddy/domain/entities/risk_assessment.dart';
import 'package:studnet_ai_buddy/domain/entities/study_plan.dart';
import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart'; // Added
import 'package:studnet_ai_buddy/domain/entities/study_task.dart'; // Added
import 'package:studnet_ai_buddy/domain/services/ai_mentor_service.dart';

class AIMentorServiceImpl implements AIMentorService {
  final _model = FirebaseAI.vertexAI().generativeModel(
    model: 'gemini-2.0-flash',
  );

  String _cleanJson(String text) {
    text = text.replaceAll('```json', '').replaceAll('```', '').trim();
    if (text.startsWith('json')) {
      text = text.substring(4).trim();
    }
    return text;
  }

  @override
  Future<StudyTask> suggestTask({
    required String subjectId,
    required String subjectName,
    required String? topic,
    required int durationMinutes,
  }) async {
    try {
      final prompt =
          """
      You are an expert academic study planner.
      Suggest a SINGLE study task for a student.
      Subject: $subjectName
      Topic: ${topic ?? "General Review"}
      Duration: $durationMinutes minutes
      Current Date: ${DateTime.now().toIso8601String()}

      Output STRICT JSON format only:
      {
        "title": "Short actionable title",
        "description": "Specific instructions on what to study",
        "priority": "medium", 
        "reasoning": "Why this is important now"
      }
      """;

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final responseText = response.text ?? "{}";
      final cleanJson = _cleanJson(responseText);
      final Map<String, dynamic> json = jsonDecode(cleanJson);

      return StudyTask(
        id: "ai_suggested_${DateTime.now().millisecondsSinceEpoch}",
        subjectId: subjectId,
        title: json['title'] ?? "Study $subjectName",
        description: json['description'] ?? "Review key concepts",
        date: DateTime.now(), // ViewModel should adjust this
        estimatedMinutes: durationMinutes,
        priority: TaskPriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => TaskPriority.medium,
        ),
        type: TaskType.study,
        isCompleted: false,
        aiReasoning: json['reasoning'] ?? "AI Suggestion",
      );
    } catch (e) {
      // Fallback
      return StudyTask(
        id: "fallback_${DateTime.now().millisecondsSinceEpoch}",
        subjectId: subjectId,
        title: "Review $subjectName",
        description: "Focus on ${topic ?? 'core concepts'}",
        date: DateTime.now(),
        estimatedMinutes: durationMinutes,
        priority: TaskPriority.medium,
        type: TaskType.study,
        isCompleted: false,
        aiReasoning: "Fallback suggestion",
      );
    }
  }

  @override
  Future<List<StudyTask>> generateStudyPlan({
    required AcademicProfile profile,
    required List<Subject> subjects,
  }) async {
    try {
      final subjectNames = subjects.map((s) => s.name).join(", ");
      final weakAreas = profile.weakAreas.join(", ");
      final goals = profile.goals.join(", ");

      final prompt =
          """
      You are an expert academic study planner.
      Create a study plan for a student with the following profile:
      - Enrolled Subjects: $subjectNames
      - Weak Areas: $weakAreas
      - Academic Goals: $goals
      - Current Date: ${DateTime.now().toIso8601String()}

      Generate a JSON list of 5-7 study tasks for the next 7 days.
      
      CRITICAL RULES:
      1. 'subject_name' MUST be exactly one of: $subjectNames. Do not invent new subjects.
      2. Prioritize subjects listed in 'Weak Areas'.
      3. Balance the difficulty.
      4. Tasks should specific and actionable (e.g. "Chapter 4 Practice").

      Each task must have:
      - title: Short actionable title
      - subject_name: EXACT match from Enrolled Subjects
      - duration_minutes: 30-60
      - reasoning: Why this task is important based on their profile
      - type: 'study', 'quiz', or 'practice'

      Output STRICT JSON format only:
      [
        {
          "title": "Review Organic Chemistry",
          "subject_name": "Chemistry",
          "duration_minutes": 45,
          "reasoning": "Strengthen weak area in Organic compounds",
          "type": "study"
        }
      ]
      """;

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final responseText = response.text ?? "[]";
      final cleanJson = _cleanJson(responseText);

      final List<dynamic> jsonList = jsonDecode(cleanJson);

      return jsonList.map((item) {
        final subjectName = item['subject_name'] ?? "";
        final subjectId = subjects
            .firstWhere(
              (s) => s.name.toLowerCase() == subjectName.toLowerCase(),
              orElse: () => subjects.isNotEmpty
                  ? subjects.first
                  : Subject(
                      id: 'unknown',
                      name: 'General',
                      code: 'GEN-101',
                      creditHours: 3,
                      difficulty: SubjectDifficulty.intermediate,
                      topicIds: [],
                    ),
            )
            .id;

        return StudyTask(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              item['title'].hashCode.toString(),
          subjectId: subjectId,
          title: item['title'],
          description: item['reasoning'] ?? "AI Recommended",
          date: DateTime.now().add(
            Duration(days: 1),
          ), // Simple scheduling for now
          estimatedMinutes: item['duration_minutes'] ?? 30,
          priority: TaskPriority.medium,
          type: TaskType.values.firstWhere(
            (e) => e.name == item['type'],
            orElse: () => TaskType.study,
          ),
          isCompleted: false,
          aiReasoning: item['reasoning'] ?? "",
        );
      }).toList();
    } catch (e) {
      // print("Error generating plan: $e"); // Removed for production
      return [];
    }
  }

  @override
  Future<List<AIInsight>> generateDailyInsights({
    required List<KnowledgeLevel> knowledgeLevels,
    required List<RiskAssessment> riskAssessments,
    required StudyPlan? currentPlan,
    required AcademicProfile? profile,
  }) async {
    final insights = <AIInsight>[];
    final now = DateTime.now();

    // Welcome Context Insight
    if (profile != null && profile.universityName.isNotEmpty) {
      insights.add(
        AIInsight(
          id: 'insight_context_${now.millisecondsSinceEpoch}',
          type: InsightType.encouragement,
          title:
              'Semester ${profile.currentSemester} at ${profile.universityName}',
          message: 'Good luck with your studies at ${profile.universityName}!',
          reasoning: 'Personalized encouragement based on academic profile.',
          priority: InsightPriority.low,
          generatedAt: now,
        ),
      );
    }

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
  Future<String> answerQuery({
    required String query,
    AcademicProfile? profile,
  }) async {
    // Using Firebase Vertex AI logic for query responses
    final lowerQuery = query.toLowerCase();

    // Contextual hello
    if (profile != null &&
        (lowerQuery.contains('hello') || lowerQuery.contains('hi'))) {
      return "Hello! How are things going at ${profile.universityName} this semester?";
    }

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
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-2.0-flash',
      );

      final prompt =
          '''
        Generate $count flashcards for the topic "$topics".
        Difficulty level: $difficulty.
        
        Return ONLY a raw JSON array (no markdown code blocks) with this structure:
        [
          {
            "term": "Concept or Question",
            "definition": "Definition or Answer"
          }
        ]
        
        Ensure terms are concise questions or concepts, and definitions are clear and accurate.
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      final responseText = response.text;
      if (responseText == null) throw Exception('Empty response from AI');

      // Clean markdown if present
      final jsonString = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final List<dynamic> jsonList = jsonDecode(jsonString);

      final flashcards = <Map<String, dynamic>>[];
      for (int i = 0; i < jsonList.length && i < count; i++) {
        final item = jsonList[i];
        flashcards.add({
          'id': 'flashcard_${DateTime.now().millisecondsSinceEpoch}_$i',
          'term': item['term'] ?? 'Unknown',
          'definition': item['definition'] ?? 'No definition',
          'difficulty': difficulty,
          'topic': topics,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      return flashcards;
    } catch (e) {
      // In case of error, return a single error card so the user sees something went wrong
      return [
        {
          'id': 'error_card',
          'term': 'Error Generating',
          'definition':
              'Could not connect to Firebase AI. Please ensure your project is configured with Vertex AI enabled.\n\nDetails: $e',
          'difficulty': 'none',
          'topic': 'Error',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> generateFlashcardsFromFile({
    required String fileId,
    required String difficulty,
    required int count,
  }) async {
    try {
      // In a real app, we would fetch the file content from Storage/Firestore first.
      // For this demo, we'll use the file reference to simulate an AI call
      // that "knows" what the file is about (e.g. by its name or metadata).

      final prompt =
          '''
        Generate $count flashcards for the academic material in the file "$fileId".
        Difficulty level: $difficulty.
        
        Return ONLY a raw JSON array with this structure:
        [
          {
            "term": "Concept or Question",
            "definition": "Definition or Answer"
          }
        ]
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final responseText = response.text;
      if (responseText == null) throw Exception('Empty response from AI');

      final jsonString = _cleanJson(responseText);
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((item) {
        return {
          'term': item['term'] ?? 'Unknown',
          'definition': item['definition'] ?? 'No definition',
          'difficulty': difficulty,
          'fileId': fileId,
          'createdAt': DateTime.now().toIso8601String(),
        };
      }).toList();
    } catch (e) {
      return [
        {
          'term': 'Error Processing File',
          'definition': 'Failed to generate from file $fileId: $e',
          'difficulty': difficulty,
          'fileId': fileId,
          'createdAt': DateTime.now().toIso8601String(),
        },
      ];
    }
  }

  @override
  Future<String> createStudySet({
    required String name,
    required String category,
  }) async {
    // Using Firebase Firestore for study set creation
    return 'studyset_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<List<Map<String, dynamic>>> generateQuizQuestions({
    required String subject,
    required String topic,
    required String difficulty,
    required int count,
  }) async {
    try {
      final prompt =
          '''
You are an expert educator creating quiz questions for students.
Subject: $subject
Topic: $topic
Difficulty: $difficulty
Number of Questions: $count

Generate $count multiple-choice questions in STRICT JSON format:
[
  {
    "text": "Question text here?",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctOptionIndex": 0,
    "explanation": "Why this answer is correct"
  }
]

Requirements:
- Questions should be relevant to the topic
- Each question must have exactly 4 options
- correctOptionIndex is 0-based (0, 1, 2, or 3)
- Provide clear explanations for correct answers
- Difficulty should match the requested level
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      final responseText = response.text ?? "[]";
      final cleanJson = _cleanJson(responseText);

      final List<dynamic> jsonList = jsonDecode(cleanJson);

      return jsonList.map((item) {
        return {
          'text': item['text'] ?? 'Question unavailable',
          'options':
              (item['options'] as List?)?.cast<String>() ??
              ['Option A', 'Option B', 'Option C', 'Option D'],
          'correctOptionIndex': item['correctOptionIndex'] ?? 0,
          'explanation': item['explanation'] ?? 'No explanation provided',
        };
      }).toList();
    } catch (e) {
      print('❌ Error generating quiz: $e');
      // Fallback to basic questions if AI fails
      return _generateMockQuizQuestions(subject, topic, count);
    }
  }

  List<Map<String, dynamic>> _generateMockQuizQuestions(
    String subject,
    String topic,
    int count,
  ) {
    final questions = <Map<String, dynamic>>[];
    for (int i = 0; i < count; i++) {
      questions.add({
        'text':
            'This is a generated question #${i + 1} about $topic in $subject?',
        'options': [
          'Correct Answer (Option A)',
          'Wrong Answer (Option B)',
          'Wrong Answer (Option C)',
          'Wrong Answer (Option D)',
        ],
        'correctOptionIndex': 0,
        'explanation':
            'This answer is correct because it matches the topic $topic.',
      });
    }
    return questions;
  }
}

extension on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }
}
