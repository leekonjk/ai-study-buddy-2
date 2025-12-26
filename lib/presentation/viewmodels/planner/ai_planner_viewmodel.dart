/// AI Planner ViewModel.
/// Manages state for the AI Study Planner screen.
///
/// Layer: Presentation
/// Responsibility: Fetch and manage study plan tasks.
///
/// Dependencies: StudyPlanRepository, AcademicRepository
library;

import 'package:studnet_ai_buddy/domain/entities/study_plan.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_plan_repository.dart';
import 'package:studnet_ai_buddy/domain/services/ai_mentor_service.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/services/impl/achievement_service_impl.dart';

/// Immutable state for AI Planner.
class AIPlannerState {
  final ViewState viewState;
  final StudyPlan? currentPlan;
  final List<StudyTask> tasks;
  final List<Subject> subjects;
  final String? errorMessage;
  final String aiRecommendation;

  const AIPlannerState({
    this.viewState = ViewState.initial,
    this.currentPlan,
    this.tasks = const [],
    this.subjects = const [],
    this.errorMessage,
    this.aiRecommendation =
        "Based on your progress, let's focus on upcoming topics.",
  });

  AIPlannerState copyWith({
    ViewState? viewState,
    StudyPlan? currentPlan,
    List<StudyTask>? tasks,
    List<Subject>? subjects,
    String? errorMessage,
    String? aiRecommendation,
  }) {
    return AIPlannerState(
      viewState: viewState ?? this.viewState,
      currentPlan: currentPlan ?? this.currentPlan,
      tasks: tasks ?? this.tasks,
      subjects: subjects ?? this.subjects,
      errorMessage: errorMessage,
      aiRecommendation: aiRecommendation ?? this.aiRecommendation,
    );
  }
}

class AIPlannerViewModel extends BaseViewModel {
  final StudyPlanRepository _studyPlanRepository;
  final AcademicRepository _academicRepository;
  final AIMentorService _aiMentorService;

  AIPlannerViewModel({
    required StudyPlanRepository studyPlanRepository,
    required AcademicRepository academicRepository,
    required AIMentorService aiMentorService,
  }) : _studyPlanRepository = studyPlanRepository,
       _academicRepository = academicRepository,
       _aiMentorService = aiMentorService;

  AIPlannerState _state = const AIPlannerState();
  AIPlannerState get state => _state;

  /// Loads the current study plan and tasks.
  Future<void> loadPlan() async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    // 1. Fetch Subjects (needed for task generation if logic exists)
    final subjectsResult = await _academicRepository.getEnrolledSubjects();
    List<Subject> subjects = [];
    subjectsResult.fold(onSuccess: (s) => subjects = s, onFailure: (_) {});

    // 2. Fetch Current Plan
    final planResult = await _studyPlanRepository.getCurrentWeekPlan();

    planResult.fold(
      onSuccess: (plan) async {
        if (plan == null) {
          // If no plan exists, generate one automatically for initial experience
          await _generateInitialPlan(subjects);
        } else {
          _state = _state.copyWith(
            viewState: ViewState.loaded,
            currentPlan: plan,
            tasks: plan.tasksForDate(
              DateTime.now(),
            ), // Show today's tasks by default? Or all?
            // Actually, let's show all tasks or group by day?
            // The screen shows "Today's Study Plan".
            // Let's filter for today for now to match UI.
            subjects: subjects,
          );
        }
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: failure.message,
        );
      },
    );
    notifyListeners();
  }

  /// Generates an initial study plan if none exists.
  Future<void> _generateInitialPlan(List<Subject> subjects) async {
    if (subjects.isEmpty) {
      _state = _state.copyWith(
        viewState: ViewState.loaded,
        tasks: [],
        aiRecommendation: "Please enroll in subjects to get a study plan.",
      );
      return;
    }

    // Real AI Generation Logic
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 6));

    // Fetch Profile for personalization
    final profileResult = await _academicRepository.getAcademicProfile();
    final profile = profileResult.fold(
      onSuccess: (p) => p,
      onFailure: (_) => null,
    );

    if (profile == null) {
      _state = _state.copyWith(
        viewState: ViewState.error,
        errorMessage:
            "Please complete your academic profile to generate a plan.",
      );
      return;
    }

    try {
      final newTasks = await _aiMentorService.generateStudyPlan(
        profile: profile,
        subjects: subjects,
      );

      // Assign dates starting from tomorrow?
      // The AI returns tasks with roughly correct relative schedule or we can distribute them.
      // Current AI impl assigns 'tomorrow' for all. Let's distribute them over the week.

      final distributedTasks = _distributeTasksOverWeek(newTasks, weekStart);

      final newPlan = StudyPlan(
        id: "plan_${now.millisecondsSinceEpoch}",
        weekStartDate: weekStart,
        weekEndDate: weekEnd,
        tasks: distributedTasks,
        aiSummary:
            "Personalized study plan based on your goals and weak areas.",
        keyObjectives: profile.goals.isNotEmpty
            ? profile.goals
            : ["Master core concepts"],
        generatedAt: now,
      );

      // Save to repository
      final saveResult = await _studyPlanRepository.saveStudyPlan(newPlan);

      saveResult.fold(
        onSuccess: (_) {
          _state = _state.copyWith(
            viewState: ViewState.loaded,
            currentPlan: newPlan,
            tasks: newPlan.tasksForDate(DateTime.now()),
            subjects: subjects,
          );
        },
        onFailure: (f) {
          _state = _state.copyWith(
            viewState: ViewState.error,
            errorMessage: "Failed to save plan: ${f.message}",
          );
        },
      );
    } catch (e) {
      _state = _state.copyWith(
        viewState: ViewState.error,
        errorMessage: "AI Generation failed: $e",
      );
    }
  }

  List<StudyTask> _distributeTasksOverWeek(
    List<StudyTask> tasks,
    DateTime weekStart,
  ) {
    // Simple round-robin distribution Mon-Fri
    final distributed = <StudyTask>[];
    for (int i = 0; i < tasks.length; i++) {
      final dayOffset = i % 5; // 0=Mon, 4=Fri
      // Logic to map weekStart (which is whatever day) to Mon-Fri?
      // Assuming weekStart is Monday.
      final date = weekStart.add(Duration(days: dayOffset));

      final original = tasks[i];
      distributed.add(
        StudyTask(
          id: original.id,
          subjectId: original.subjectId,
          title: original.title,
          description: original.description,
          date: date,
          estimatedMinutes: original.estimatedMinutes,
          priority: original.priority,
          type: original.type,
          isCompleted: original.isCompleted,
          aiReasoning: original.aiReasoning,
        ),
      );
    }
    return distributed;
  }

  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Adds a new manual task to the current plan.
  Future<void> addTask({
    required String title,
    required String subjectId,
    required DateTime date,
    required int durationMinutes,
  }) async {
    if (_state.currentPlan == null) {
      _state = _state.copyWith(
        errorMessage:
            "No active study plan found. Please wait for initialization.",
      );
      notifyListeners();
      return;
    }

    final newTask = StudyTask(
      id: "manual_${DateTime.now().millisecondsSinceEpoch}",
      subjectId: subjectId,
      title: title,
      description: "User created task",
      date: date,
      estimatedMinutes: durationMinutes,
      priority: TaskPriority.medium,
      type: TaskType.study,
      isCompleted: false,
      aiReasoning: "Manual addition",
    );

    // Create updated plan
    final updatedTasks = List<StudyTask>.from(_state.currentPlan!.tasks)
      ..add(newTask);
    final updatedPlan = _state.currentPlan!.copyWith(tasks: updatedTasks);

    // Save to repo
    final result = await _studyPlanRepository.saveStudyPlan(updatedPlan);

    result.fold(
      onSuccess: (_) {
        _state = _state.copyWith(
          currentPlan: updatedPlan,
          tasks: updatedPlan.tasksForDate(DateTime.now()), // Refresh view
          errorMessage: null,
        );
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          errorMessage: "Failed to save task: ${failure.message}",
        );
      },
    );
    notifyListeners();
  }

  /// Toggles a task's completion status and persists to Firestore.
  Future<void> toggleTaskCompletion(String taskId) async {
    if (_state.currentPlan == null) return;

    // Find the task and toggle its completion
    final updatedTasks = _state.currentPlan!.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    // Update the plan with new tasks
    final updatedPlan = _state.currentPlan!.copyWith(tasks: updatedTasks);

    // Persist to Firestore
    final result = await _studyPlanRepository.saveStudyPlan(updatedPlan);

    result.fold(
      onSuccess: (_) {
        // Update local state
        _state = _state.copyWith(
          currentPlan: updatedPlan,
          tasks: updatedPlan.tasksForDate(DateTime.now()),
        );
        notifyListeners();

        // Unlock achievements based on completed tasks
        final completedCount = updatedPlan.tasks
            .where((t) => t.isCompleted)
            .length;
        final achievementService = getIt<AchievementService>();
        achievementService.checkFirstTaskCompletion(completedCount);
        achievementService.checkTaskChampion(completedCount);
      },
      onFailure: (f) {
        // If save fails, revert UI (or show error)
        _state = _state.copyWith(
          errorMessage: "Failed to update task: ${f.message}",
        );
        notifyListeners();
      },
    );
  }
}
