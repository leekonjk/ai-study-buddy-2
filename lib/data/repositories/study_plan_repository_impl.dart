/// Study Plan Repository Implementation.
/// Concrete implementation of StudyPlanRepository interface using Firebase Firestore.
/// 
/// Layer: Data
/// Responsibility: Data operations for study plans and tasks via Firestore.
/// 
/// Firestore Collections Used:
/// - study_plans: Weekly study plans with embedded tasks
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studnet_ai_buddy/core/errors/failures.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/study_plan.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_plan_repository.dart';

class StudyPlanRepositoryImpl implements StudyPlanRepository {
  final FirebaseFirestore _firestore;
  final String _currentStudentId;

  // Firestore collection name (per schema)
  static const String _studyPlansCollection = 'study_plans';

  StudyPlanRepositoryImpl({
    required FirebaseFirestore firestore,
    required String currentStudentId,
  })  : _firestore = firestore,
        _currentStudentId = currentStudentId;

  // ─────────────────────────────────────────────────────────────────────────
  // Study Plan Retrieval Operations
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<StudyPlan?>> getCurrentWeekPlan() async {
    try {
      // Get start of current week (Monday)
      final now = DateTime.now();
      final weekStart = _getWeekStart(now);

      return getPlanForWeek(weekStart);
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<StudyPlan?>> getPlanForWeek(DateTime weekStart) async {
    try {
      // Normalize to start of day
      final normalizedStart = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final weekStartTimestamp = Timestamp.fromDate(normalizedStart);

      // Query for active plan for this week
      final querySnapshot = await _firestore
          .collection(_studyPlansCollection)
          .where('studentId', isEqualTo: _currentStudentId)
          .where('weekStartDate', isEqualTo: weekStartTimestamp)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Success(null);
      }

      final doc = querySnapshot.docs.first;
      final plan = _mapDocumentToStudyPlan(doc);

      return Success(plan);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to fetch study plan: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> saveStudyPlan(StudyPlan plan) async {
    try {
      final data = _mapStudyPlanToDocument(plan);

      // Deactivate any existing plans for this week
      await _deactivateExistingPlans(plan.weekStartDate);

      // Save new plan
      await _firestore.collection(_studyPlansCollection).add(data);

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to save study plan: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Task Operations
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<List<StudyTask>>> getTodaysTasks() async {
    try {
      final planResult = await getCurrentWeekPlan();

      return planResult.fold(
        onSuccess: (plan) {
          if (plan == null) return const Success(<StudyTask>[]);

          final today = DateTime.now();
          final todaysTasks = plan.tasksForDate(today);

          return Success(todaysTasks);
        },
        onFailure: (failure) => Err(failure),
      );
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> updateTask(StudyTask task) async {
    try {
      // Find the plan containing this task
      final planResult = await getCurrentWeekPlan();

      return await planResult.fold(
        onSuccess: (plan) async {
          if (plan == null) {
            return const Err(NetworkFailure(message: 'No active plan found'));
          }

          // Find plan document
          final querySnapshot = await _firestore
              .collection(_studyPlansCollection)
              .where('studentId', isEqualTo: _currentStudentId)
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();

          if (querySnapshot.docs.isEmpty) {
            return const Err(NetworkFailure(message: 'Plan document not found'));
          }

          final docRef = querySnapshot.docs.first.reference;

          // Update the task in the tasks array
          final updatedTasks = plan.tasks.map((t) {
            if (t.id == task.id) {
              return task;
            }
            return t;
          }).toList();

          // Convert tasks to Firestore format
          final tasksData = updatedTasks.map(_mapTaskToDocument).toList();

          await docRef.update({'tasks': tasksData});

          return const Success(null);
        },
        onFailure: (failure) async => Err(failure),
      );
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to update task: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<StudyTask>>> getOverdueTasks() async {
    try {
      final planResult = await getCurrentWeekPlan();

      return planResult.fold(
        onSuccess: (plan) {
          if (plan == null) return const Success(<StudyTask>[]);

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          // Find incomplete tasks scheduled before today
          final overdueTasks = plan.tasks.where((task) {
            final taskDate = DateTime(
              task.scheduledDate.year,
              task.scheduledDate.month,
              task.scheduledDate.day,
            );
            return taskDate.isBefore(today) && !task.isCompleted;
          }).toList();

          return Success(overdueTasks);
        },
        onFailure: (failure) => Err(failure),
      );
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping: Firestore Document → Domain Entity
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps Firestore document to StudyPlan domain entity.
  /// 
  /// Firestore schema (study_plans):
  /// - planId: string
  /// - studentId: string
  /// - weekStartDate: timestamp
  /// - tasks: array of task objects
  /// - generatedAt: timestamp
  /// - isActive: bool
  StudyPlan _mapDocumentToStudyPlan(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    final tasksData = data['tasks'] as List<dynamic>? ?? [];
    final tasks = tasksData
        .map((t) => _mapDocumentToTask(t as Map<String, dynamic>))
        .toList();

    final weekStartDate = (data['weekStartDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final weekEndDate = weekStartDate.add(const Duration(days: 6));
    final generatedAt = (data['generatedAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return StudyPlan(
      id: data['planId'] as String? ?? doc.id,
      weekStartDate: weekStartDate,
      weekEndDate: weekEndDate,
      tasks: tasks,
      aiSummary: '', // Not in schema, generated by domain service
      keyObjectives: [], // Not in schema, generated by domain service
      generatedAt: generatedAt,
    );
  }

  /// Maps embedded task data to StudyTask domain entity.
  /// 
  /// Firestore schema (tasks array item):
  /// - taskId: string
  /// - subjectId: string
  /// - title: string
  /// - estimatedMinutes: int
  /// - aiReasoning: string
  /// - status: string (pending | completed | skipped)
  StudyTask _mapDocumentToTask(Map<String, dynamic> data) {
    final status = data['status'] as String? ?? 'pending';
    final isCompleted = status == 'completed';

    return StudyTask(
      id: data['taskId'] as String? ?? '',
      subjectId: data['subjectId'] as String? ?? '',
      topicId: null, // Not in schema
      title: data['title'] as String? ?? '',
      description: '', // Not in schema, can be derived from title
      estimatedMinutes: data['estimatedMinutes'] as int? ?? 30,
      priority: TaskPriority.medium, // Not in schema, default
      type: TaskType.learn, // Not in schema, default
      scheduledDate: DateTime.now(), // Not stored per-task in schema
      completedAt: isCompleted ? DateTime.now() : null,
      aiReasoning: data['aiReasoning'] as String? ?? '',
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping: Domain Entity → Firestore Document
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps StudyPlan domain entity to Firestore document data.
  Map<String, dynamic> _mapStudyPlanToDocument(StudyPlan plan) {
    final tasksData = plan.tasks.map(_mapTaskToDocument).toList();

    return {
      'planId': plan.id,
      'studentId': _currentStudentId,
      'weekStartDate': Timestamp.fromDate(plan.weekStartDate),
      'tasks': tasksData,
      'generatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    };
  }

  /// Maps StudyTask domain entity to Firestore document data.
  Map<String, dynamic> _mapTaskToDocument(StudyTask task) {
    String status;
    if (task.isCompleted) {
      status = 'completed';
    } else {
      status = 'pending';
    }

    return {
      'taskId': task.id,
      'subjectId': task.subjectId,
      'title': task.title,
      'estimatedMinutes': task.estimatedMinutes,
      'aiReasoning': task.aiReasoning,
      'status': status,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the Monday of the week containing the given date.
  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Deactivates existing plans for the given week.
  Future<void> _deactivateExistingPlans(DateTime weekStart) async {
    final normalizedStart = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final weekStartTimestamp = Timestamp.fromDate(normalizedStart);

    final querySnapshot = await _firestore
        .collection(_studyPlansCollection)
        .where('studentId', isEqualTo: _currentStudentId)
        .where('weekStartDate', isEqualTo: weekStartTimestamp)
        .where('isActive', isEqualTo: true)
        .get();

    for (final doc in querySnapshot.docs) {
      await doc.reference.update({'isActive': false});
    }
  }
}
