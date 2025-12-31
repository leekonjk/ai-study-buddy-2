/// Study Plan Repository Interface.
/// Defines contract for study plan and task data operations.
///
/// Layer: Domain
/// Responsibility: Abstract data access for study planning.
/// Implementation: Data layer provides concrete implementation.
library;

import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/study_plan.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';

abstract class StudyPlanRepository {
  /// Retrieves the current week's study plan.
  Future<Result<StudyPlan?>> getCurrentWeekPlan();

  /// Retrieves study plan for a specific week.
  Future<Result<StudyPlan?>> getPlanForWeek(DateTime weekStart);

  /// Saves a new study plan.
  Future<Result<void>> saveStudyPlan(StudyPlan plan);

  /// Retrieves tasks for today.
  Future<Result<List<StudyTask>>> getTodaysTasks();

  /// Updates a task (e.g., mark as completed).
  Future<Result<void>> updateTask(StudyTask task);

  /// Retrieves overdue tasks.
  Future<Result<List<StudyTask>>> getOverdueTasks();

  /// Stream of current week's plan for real-time updates.
  Stream<Result<StudyPlan?>> getPlanStream();
}
