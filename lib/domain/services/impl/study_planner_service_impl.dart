/// StudyPlannerServiceImpl
/// 
/// Pure Dart implementation of adaptive study plan generation.
/// Uses deterministic, rule-based logic to create personalized weekly plans.
/// 
/// Layer: Domain (Implementation)
/// Dependencies: None (pure logic, no Flutter/Firebase/repositories)
/// 
/// Planning Algorithm:
/// 1. Calculate priority score for each subject (mastery + risk + credit weight)
/// 2. Allocate time proportionally to priority
/// 3. Generate tasks based on knowledge gaps and task types
/// 4. Distribute tasks across the week with reasoning
library;

import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';
import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';
import 'package:studnet_ai_buddy/domain/entities/risk_assessment.dart';
import 'package:studnet_ai_buddy/domain/entities/study_plan.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/domain/services/study_planner_service.dart';

class StudyPlannerServiceImpl implements StudyPlannerService {
  // Default study session durations (in minutes)
  static const int _shortSessionMinutes = 25; // Pomodoro-style
  static const int _mediumSessionMinutes = 45;
  static const int _longSessionMinutes = 60;

  // Priority weights for task allocation
  static const double _masteryWeight = 0.4; // Lower mastery = higher priority
  static const double _riskWeight = 0.35; // Higher risk = higher priority
  static const double _creditWeight = 0.25; // More credits = higher priority

  // Days in a study week (Mon-Sun)
  static const int _daysInWeek = 7;

  @override
  Future<StudyPlan> generateWeeklyPlan({
    required AcademicProfile profile,
    required List<Subject> subjects,
    required List<KnowledgeLevel> knowledgeLevels,
    required List<RiskAssessment> riskAssessments,
    required DateTime weekStart,
  }) async {
    // Filter to enrolled subjects only
    final enrolledSubjects = subjects
        .where((s) => profile.enrolledSubjectIds.contains(s.id))
        .toList();

    if (enrolledSubjects.isEmpty) {
      return _createEmptyPlan(weekStart);
    }

    // Calculate time allocation per subject
    final timeAllocation = calculateTimeAllocation(
      subjects: enrolledSubjects,
      knowledgeLevels: knowledgeLevels,
      availableMinutesPerDay: 120, // Default 2 hours/day
    );

    // Generate tasks for each subject
    final allTasks = <StudyTask>[];
    int taskIdCounter = 0;

    for (final subject in enrolledSubjects) {
      final knowledgeLevel = _findKnowledgeLevel(subject.id, knowledgeLevels);
      final riskAssessment = _findRiskAssessment(subject.id, riskAssessments);
      final allocatedMinutes = timeAllocation[subject.id] ?? 0;

      if (allocatedMinutes <= 0) continue;

      final subjectTasks = _generateSubjectTasks(
        subject: subject,
        knowledgeLevel: knowledgeLevel,
        riskAssessment: riskAssessment,
        totalMinutes: allocatedMinutes,
        weekStart: weekStart,
        startingTaskId: taskIdCounter,
      );

      allTasks.addAll(subjectTasks);
      taskIdCounter += subjectTasks.length;
    }

    // Sort tasks by priority and distribute across days
    final distributedTasks = _distributeTasksAcrossWeek(allTasks, weekStart);

    // Generate plan summary and objectives
    final summary = generatePlanSummary(
      knowledgeLevels: knowledgeLevels,
      riskAssessments: riskAssessments,
    );

    final objectives = _generateKeyObjectives(
      subjects: enrolledSubjects,
      knowledgeLevels: knowledgeLevels,
      riskAssessments: riskAssessments,
    );

    final weekEnd = weekStart.add(const Duration(days: 6));

    return StudyPlan(
      id: 'plan_${weekStart.millisecondsSinceEpoch}',
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      tasks: distributedTasks,
      aiSummary: summary,
      keyObjectives: objectives,
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<StudyPlan> adjustPlan({
    required StudyPlan currentPlan,
    required List<KnowledgeLevel> updatedLevels,
  }) async {
    // Identify tasks that may need adjustment based on new knowledge levels
    final adjustedTasks = <StudyTask>[];

    for (final task in currentPlan.tasks) {
      // Skip completed tasks
      if (task.isCompleted) {
        adjustedTasks.add(task);
        continue;
      }

      final updatedLevel = _findKnowledgeLevel(task.subjectId, updatedLevels);

      if (updatedLevel == null) {
        adjustedTasks.add(task);
        continue;
      }

      // Adjust task based on new knowledge level
      final adjustedTask = _adjustTaskForNewLevel(task, updatedLevel);
      adjustedTasks.add(adjustedTask);
    }

    // Re-sort by priority
    adjustedTasks.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    return StudyPlan(
      id: currentPlan.id,
      weekStartDate: currentPlan.weekStartDate,
      weekEndDate: currentPlan.weekEndDate,
      tasks: adjustedTasks,
      aiSummary: '${currentPlan.aiSummary} [Adjusted based on recent progress]',
      keyObjectives: currentPlan.keyObjectives,
      generatedAt: DateTime.now(),
    );
  }

  @override
  String generatePlanSummary({
    required List<KnowledgeLevel> knowledgeLevels,
    required List<RiskAssessment> riskAssessments,
  }) {
    final buffer = StringBuffer();

    // Identify weak areas
    final weakSubjects = knowledgeLevels
        .where((k) => k.masteryScore < 0.4)
        .map((k) => k.subjectId)
        .toList();

    // Identify high-risk subjects
    final highRiskSubjects = riskAssessments
        .where((r) => r.riskLevel == RiskLevel.high || r.riskLevel == RiskLevel.critical)
        .map((r) => r.subjectId)
        .toList();

    // Opening statement
    buffer.write('This week\'s plan focuses on ');

    if (weakSubjects.isNotEmpty) {
      buffer.write('strengthening ${weakSubjects.length} subject(s) with knowledge gaps');
      if (highRiskSubjects.isNotEmpty) {
        buffer.write(' and addressing ${highRiskSubjects.length} high-risk area(s)');
      }
      buffer.write('. ');
    } else if (highRiskSubjects.isNotEmpty) {
      buffer.write('addressing ${highRiskSubjects.length} high-risk subject(s). ');
    } else {
      buffer.write('maintaining strong progress across all subjects. ');
    }

    // Calculate average mastery
    if (knowledgeLevels.isNotEmpty) {
      final avgMastery = knowledgeLevels
              .map((k) => k.masteryScore)
              .reduce((a, b) => a + b) /
          knowledgeLevels.length;
      buffer.write('Overall mastery is at ${(avgMastery * 100).toStringAsFixed(0)}%. ');
    }

    // Motivational closing
    if (weakSubjects.isEmpty && highRiskSubjects.isEmpty) {
      buffer.write('Keep up the excellent work!');
    } else {
      buffer.write('Consistent effort this week will improve your standing.');
    }

    return buffer.toString();
  }

  @override
  Map<String, int> calculateTimeAllocation({
    required List<Subject> subjects,
    required List<KnowledgeLevel> knowledgeLevels,
    required int availableMinutesPerDay,
  }) {
    if (subjects.isEmpty) return {};

    final totalWeeklyMinutes = availableMinutesPerDay * _daysInWeek;
    final priorityScores = <String, double>{};
    double totalPriority = 0.0;

    // Calculate priority score for each subject
    for (final subject in subjects) {
      final knowledgeLevel = _findKnowledgeLevel(subject.id, knowledgeLevels);

      // Mastery factor: lower mastery = higher priority (inverted)
      final masteryFactor = 1.0 - (knowledgeLevel?.masteryScore ?? 0.5);

      // Credit factor: more credits = more time needed
      final creditFactor = subject.creditHours / 4.0; // Normalize to ~1.0

      // Difficulty factor: harder subjects need more time
      final difficultyFactor = _getDifficultyMultiplier(subject.difficulty);

      // Risk factor: if we have risk data, factor it in
      // Higher risk = higher priority for time allocation
      final riskFactor = 0.0; // Will be enhanced when risk data is passed

      // Combined priority score
      final priority = (masteryFactor * _masteryWeight) +
          (riskFactor * _riskWeight) +
          (creditFactor * _creditWeight) +
          (difficultyFactor * 0.1);

      priorityScores[subject.id] = priority;
      totalPriority += priority;
    }

    // Allocate time proportionally
    final allocation = <String, int>{};

    for (final subject in subjects) {
      final priority = priorityScores[subject.id] ?? 0.0;
      final proportion = totalPriority > 0 ? priority / totalPriority : 0.0;
      final minutes = (totalWeeklyMinutes * proportion).round();

      // Ensure minimum allocation for each subject
      allocation[subject.id] = minutes.clamp(30, totalWeeklyMinutes ~/ 2);
    }

    return allocation;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates an empty plan when no subjects are enrolled.
  StudyPlan _createEmptyPlan(DateTime weekStart) {
    return StudyPlan(
      id: 'plan_empty_${weekStart.millisecondsSinceEpoch}',
      weekStartDate: weekStart,
      weekEndDate: weekStart.add(const Duration(days: 6)),
      tasks: [],
      aiSummary: 'No enrolled subjects found. Please complete onboarding to generate a study plan.',
      keyObjectives: [],
      generatedAt: DateTime.now(),
    );
  }

  /// Finds knowledge level for a subject, returns null if not found.
  KnowledgeLevel? _findKnowledgeLevel(String subjectId, List<KnowledgeLevel> levels) {
    for (final level in levels) {
      if (level.subjectId == subjectId && level.topicId == null) {
        return level;
      }
    }
    return null;
  }

  /// Finds risk assessment for a subject, returns null if not found.
  RiskAssessment? _findRiskAssessment(String subjectId, List<RiskAssessment> assessments) {
    for (final assessment in assessments) {
      if (assessment.subjectId == subjectId) {
        return assessment;
      }
    }
    return null;
  }

  /// Returns difficulty multiplier for time allocation.
  double _getDifficultyMultiplier(SubjectDifficulty difficulty) {
    return switch (difficulty) {
      SubjectDifficulty.introductory => 0.8,
      SubjectDifficulty.intermediate => 1.0,
      SubjectDifficulty.advanced => 1.3,
    };
  }

  /// Generates tasks for a single subject based on knowledge and risk.
  List<StudyTask> _generateSubjectTasks({
    required Subject subject,
    required KnowledgeLevel? knowledgeLevel,
    required RiskAssessment? riskAssessment,
    required int totalMinutes,
    required DateTime weekStart,
    required int startingTaskId,
  }) {
    final tasks = <StudyTask>[];
    int remainingMinutes = totalMinutes;
    int taskId = startingTaskId;

    final mastery = knowledgeLevel?.masteryScore ?? 0.5;
    final riskLevel = riskAssessment?.riskLevel ?? RiskLevel.low;

    // Determine task types based on mastery level
    final taskTypes = _determineTaskTypes(mastery, riskLevel);

    for (final taskType in taskTypes) {
      if (remainingMinutes <= 0) break;

      final duration = _getTaskDuration(taskType, mastery);
      if (duration > remainingMinutes) continue;

      final priority = _calculateTaskPriority(mastery, riskLevel, taskType);
      final reasoning = _generateTaskReasoning(
        subject: subject,
        taskType: taskType,
        mastery: mastery,
        riskLevel: riskLevel,
        duration: duration,
      );

      final task = StudyTask(
        id: 'task_${weekStart.millisecondsSinceEpoch}_$taskId',
        subjectId: subject.id,
        title: _generateTaskTitle(subject, taskType),
        description: _generateTaskDescription(taskType, subject),
        estimatedMinutes: duration,
        priority: priority,
        type: taskType,
        date: weekStart, // Will be redistributed later
        aiReasoning: reasoning,
      );

      tasks.add(task);
      remainingMinutes -= duration;
      taskId++;
    }

    return tasks;
  }

  /// Determines which task types to generate based on mastery and risk.
  List<TaskType> _determineTaskTypes(double mastery, RiskLevel riskLevel) {
    final types = <TaskType>[];

    if (mastery < 0.4) {
      // Low mastery: focus on learning and review
      types.addAll([TaskType.learn, TaskType.review, TaskType.practice]);
      if (riskLevel == RiskLevel.high || riskLevel == RiskLevel.critical) {
        types.add(TaskType.quiz); // Diagnostic to track progress
      }
    } else if (mastery < 0.75) {
      // Medium mastery: balance practice and review
      types.addAll([TaskType.practice, TaskType.review, TaskType.quiz]);
    } else {
      // High mastery: maintenance and advancement
      types.addAll([TaskType.review, TaskType.practice]);
      if (riskLevel != RiskLevel.low) {
        types.add(TaskType.revise);
      }
    }

    return types;
  }

  /// Determines task duration based on type and mastery.
  int _getTaskDuration(TaskType type, double mastery) {
    return switch (type) {
      TaskType.study => mastery < 0.4 ? _longSessionMinutes : _mediumSessionMinutes,
      TaskType.learn => mastery < 0.4 ? _longSessionMinutes : _mediumSessionMinutes,
      TaskType.review => _shortSessionMinutes,
      TaskType.practice => _mediumSessionMinutes,
      TaskType.quiz => _shortSessionMinutes,
      TaskType.revise => _mediumSessionMinutes,
      TaskType.revision => _mediumSessionMinutes,
      TaskType.assignment => _longSessionMinutes,
    };
  }

  /// Calculates task priority based on subject state.
  TaskPriority _calculateTaskPriority(double mastery, RiskLevel riskLevel, TaskType taskType) {
    // Critical risk or very low mastery = critical priority
    if (riskLevel == RiskLevel.critical || mastery < 0.2) {
      return TaskPriority.critical;
    }

    // High risk or low mastery = high priority
    if (riskLevel == RiskLevel.high || mastery < 0.4) {
      return TaskPriority.high;
    }

    // Moderate risk or medium mastery = medium priority
    if (riskLevel == RiskLevel.moderate || mastery < 0.75) {
      return TaskPriority.medium;
    }

    // Everything else = low priority (maintenance)
    return TaskPriority.low;
  }

  /// Generates human-readable task title.
  String _generateTaskTitle(Subject subject, TaskType type) {
    final action = switch (type) {
      TaskType.study => 'Study',
      TaskType.learn => 'Learn',
      TaskType.review => 'Review',
      TaskType.practice => 'Practice',
      TaskType.quiz => 'Quiz',
      TaskType.revise => 'Revise',
      TaskType.revision => 'Revision',
      TaskType.assignment => 'Assignment',
    };
    return '$action: ${subject.name}';
  }

  /// Generates task description.
  String _generateTaskDescription(TaskType type, Subject subject) {
    return switch (type) {
      TaskType.study => 'Study new concepts in ${subject.name}. Focus on understanding core principles.',
      TaskType.learn => 'Study new concepts in ${subject.name}. Focus on understanding core principles.',
      TaskType.review => 'Review previously covered material in ${subject.name} to reinforce memory.',
      TaskType.practice => 'Complete practice problems for ${subject.name} to build proficiency.',
      TaskType.quiz => 'Take an adaptive quiz to assess current understanding of ${subject.name}.',
      TaskType.revise => 'Intensive revision of ${subject.name} key topics and formulas.',
      TaskType.revision => 'Intensive revision of ${subject.name} key topics and formulas.',
      TaskType.assignment => 'Complete assignment for ${subject.name}.',
    };
  }

  /// Generates AI reasoning explaining why this task was created.
  String _generateTaskReasoning({
    required Subject subject,
    required TaskType taskType,
    required double mastery,
    required RiskLevel riskLevel,
    required int duration,
  }) {
    final buffer = StringBuffer();

    // Mastery context
    final masteryLabel = mastery >= 0.75 ? 'strong' : (mastery >= 0.4 ? 'developing' : 'needs focus');
    buffer.write('${subject.name} mastery is $masteryLabel (${(mastery * 100).toStringAsFixed(0)}%). ');

    // Risk context
    if (riskLevel != RiskLevel.low) {
      buffer.write('Risk level: ${riskLevel.name}. ');
    }

    // Task type justification
    switch (taskType) {
      case TaskType.study:
        buffer.write('Study session recommended to build foundational knowledge. ');
        break;
      case TaskType.learn:
        buffer.write('New learning recommended to build foundational knowledge. ');
        break;
      case TaskType.review:
        buffer.write('Review session scheduled to prevent knowledge decay. ');
        break;
      case TaskType.practice:
        buffer.write('Practice problems assigned to strengthen application skills. ');
        break;
      case TaskType.quiz:
        buffer.write('Assessment quiz to measure progress and identify gaps. ');
        break;
      case TaskType.revise:
        buffer.write('Intensive revision to consolidate learning before assessment. ');
        break;
      case TaskType.revision:
        buffer.write('Intensive revision to consolidate learning before assessment. ');
        break;
      case TaskType.assignment:
        buffer.write('Assignment work to complete course requirements. ');
        break;
    }

    // Duration justification
    buffer.write('Duration: $duration min (');
    if (duration == _shortSessionMinutes) {
      buffer.write('focused session');
    } else if (duration == _mediumSessionMinutes) {
      buffer.write('standard session');
    } else {
      buffer.write('extended session for depth');
    }
    buffer.write(').');

    return buffer.toString();
  }

  /// Distributes tasks across the week days.
  List<StudyTask> _distributeTasksAcrossWeek(List<StudyTask> tasks, DateTime weekStart) {
    if (tasks.isEmpty) return [];

    // Sort by priority (critical first)
    final sortedTasks = List<StudyTask>.from(tasks)
      ..sort((a, b) => a.priority.index.compareTo(b.priority.index));

    // Track minutes per day to balance load
    final minutesPerDay = List.filled(_daysInWeek, 0);
    final maxMinutesPerDay = 150; // Cap at 2.5 hours per day

    final distributedTasks = <StudyTask>[];

    for (final task in sortedTasks) {
      // Find day with lowest load that can accommodate this task
      int bestDay = 0;
      int lowestLoad = minutesPerDay[0];

      for (int day = 1; day < _daysInWeek; day++) {
        if (minutesPerDay[day] < lowestLoad &&
            minutesPerDay[day] + task.estimatedMinutes <= maxMinutesPerDay) {
          bestDay = day;
          lowestLoad = minutesPerDay[day];
        }
      }

      // Assign task to best day
      final scheduledDate = weekStart.add(Duration(days: bestDay));
      final scheduledTask = task.copyWith(date: scheduledDate);
      distributedTasks.add(scheduledTask);
      minutesPerDay[bestDay] += task.estimatedMinutes;
    }

    // Sort by date for output
    distributedTasks.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    return distributedTasks;
  }

  /// Generates key objectives for the week.
  List<String> _generateKeyObjectives({
    required List<Subject> subjects,
    required List<KnowledgeLevel> knowledgeLevels,
    required List<RiskAssessment> riskAssessments,
  }) {
    final objectives = <String>[];

    // Find subjects needing most attention
    final weakSubjects = <Subject>[];
    final riskSubjects = <Subject>[];

    for (final subject in subjects) {
      final level = _findKnowledgeLevel(subject.id, knowledgeLevels);
      final risk = _findRiskAssessment(subject.id, riskAssessments);

      if (level != null && level.masteryScore < 0.4) {
        weakSubjects.add(subject);
      }
      if (risk != null && (risk.riskLevel == RiskLevel.high || risk.riskLevel == RiskLevel.critical)) {
        riskSubjects.add(subject);
      }
    }

    // Generate objectives
    for (final subject in weakSubjects.take(2)) {
      objectives.add('Improve ${subject.name} fundamentals');
    }

    for (final subject in riskSubjects.take(2)) {
      if (!weakSubjects.contains(subject)) {
        objectives.add('Address ${subject.name} risk factors');
      }
    }

    // Add general objectives if needed
    if (objectives.isEmpty) {
      objectives.add('Maintain consistent study schedule');
      objectives.add('Complete all scheduled review sessions');
    } else if (objectives.length < 3) {
      objectives.add('Track daily progress');
    }

    return objectives.take(4).toList();
  }

  /// Adjusts a task based on updated knowledge level.
  StudyTask _adjustTaskForNewLevel(StudyTask task, KnowledgeLevel newLevel) {
    final newMastery = newLevel.masteryScore;
    final currentPriority = task.priority;

    // If mastery improved significantly, lower priority
    TaskPriority adjustedPriority;
    if (newMastery >= 0.75 && currentPriority == TaskPriority.high) {
      adjustedPriority = TaskPriority.medium;
    } else if (newMastery >= 0.6 && currentPriority == TaskPriority.critical) {
      adjustedPriority = TaskPriority.high;
    } else {
      adjustedPriority = currentPriority;
    }

    // Update reasoning to reflect adjustment
    final adjustedReasoning = '${task.aiReasoning} [Adjusted: mastery now at ${(newMastery * 100).toStringAsFixed(0)}%]';

    return task.copyWith(
      priority: adjustedPriority,
      aiReasoning: adjustedReasoning,
    );
  }
}
