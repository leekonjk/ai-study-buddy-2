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
import 'dart:async'; // Added for StreamSubscription

/// Immutable state for AI Planner.
class AIPlannerState {
  final ViewState viewState;
  final StudyPlan? currentPlan;
  final List<StudyTask> tasks;
  final List<Subject> subjects;
  final String? errorMessage;
  final String aiRecommendation;
  final DateTime selectedDate;

  const AIPlannerState({
    this.viewState = ViewState.initial,
    this.currentPlan,
    this.tasks = const [],
    this.subjects = const [],
    this.errorMessage,
    this.aiRecommendation =
        "Based on your progress, let's focus on upcoming topics.",
    required this.selectedDate,
  });

  AIPlannerState copyWith({
    ViewState? viewState,
    StudyPlan? currentPlan,
    List<StudyTask>? tasks,
    List<Subject>? subjects,
    String? errorMessage,
    String? aiRecommendation,
    DateTime? selectedDate,
  }) {
    return AIPlannerState(
      viewState: viewState ?? this.viewState,
      currentPlan: currentPlan ?? this.currentPlan,
      tasks: tasks ?? this.tasks,
      subjects: subjects ?? this.subjects,
      errorMessage: errorMessage,
      aiRecommendation: aiRecommendation ?? this.aiRecommendation,
      selectedDate: selectedDate ?? this.selectedDate,
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

  AIPlannerState _state = AIPlannerState(selectedDate: DateTime.now());
  AIPlannerState get state => _state;

  /// Selects a new date and updates the task list.
  void selectDate(DateTime date) {
    if (_state.currentPlan == null) {
      _state = _state.copyWith(selectedDate: date);
      notifyListeners();
      return;
    }
    _state = _state.copyWith(
      selectedDate: date,
      tasks: _state.currentPlan!.tasksForDate(date),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _planSubscription?.cancel();
    super.dispose();
  }

  StreamSubscription? _planSubscription;

  void _startListeningToPlan() {
    if (_planSubscription != null) return;

    _planSubscription = _studyPlanRepository.getPlanStream().listen((result) {
      result.fold(
        onSuccess: (plan) {
          // If we have a plan, update state
          if (plan != null) {
            _state = _state.copyWith(
              currentPlan: plan,
              tasks: plan.tasksForDate(_state.selectedDate),
              aiRecommendation: plan.aiSummary.isNotEmpty
                  ? plan.aiSummary
                  : "Focus on your scheduled tasks for today.",
            );
            notifyListeners();
          } else {
            // Plan is null
          }
        },
        onFailure: (_) {
          // Log error
        },
      );
    });
  }

  /// Regenerates the study plan.
  Future<void> regeneratePlan() async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();
    await _generateInitialPlan(_state.subjects);
  }

  /// Loads the current study plan and tasks.
  Future<void> loadPlan() async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    // 1. Fetch Subjects (needed for task generation)
    final subjectsResult = await _academicRepository.getEnrolledSubjects();
    List<Subject> subjects = [];
    subjectsResult.fold(onSuccess: (s) => subjects = s, onFailure: (_) {});

    _state = _state.copyWith(subjects: subjects);

    // 2. Start listening to stream (this will load initial data too)
    _startListeningToPlan();

    // 3. Check if plan exists via initial fetch to trigger generation if missing
    // (Stream might return null, but we need to know strictly if we should generate)
    final planResult = await _studyPlanRepository.getCurrentWeekPlan();

    planResult.fold(
      onSuccess: (plan) async {
        if (plan == null) {
          // If no plan exists, generate one automatically
          await _generateInitialPlan(subjects);
        } else {
          // Stream will handle the update, but we can set initial loaded state
          _state = _state.copyWith(
            viewState: ViewState.loaded,
            currentPlan: plan,
            aiRecommendation: plan.aiSummary.isNotEmpty
                ? plan.aiSummary
                : "Focus on your scheduled tasks for today.",
          );
          notifyListeners();
        }
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
    );
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
            tasks: newPlan.tasksForDate(_state.selectedDate),
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
    String? description,
    TaskPriority? priority,
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
      description: description ?? "User created task",
      date: date,
      estimatedMinutes: durationMinutes,
      priority: priority ?? TaskPriority.medium,
      type: TaskType.study,
      isCompleted: false,
      aiReasoning: "Manual addition",
    );

    await _saveNewTask(newTask);
  }

  /// Suggests a task using AI and adds it to the plan.
  Future<void> suggestTask({
    required String subjectId,
    String? topic,
    required int durationMinutes,
    DateTime? date,
  }) async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    try {
      final subject = _state.subjects.firstWhere((s) => s.id == subjectId);
      final task = await _aiMentorService.suggestTask(
        subjectId: subjectId,
        subjectName: subject.name,
        topic: topic,
        durationMinutes: durationMinutes,
      );

      // Adjust date to currently selected date with next available slot logic if needed
      // Use provided date or default to selected date + default time (e.g. 9 AM or now)
      final scheduledDate =
          date ??
          _state.selectedDate.copyWith(
            hour: DateTime.now().hour + 1, // Start next hour
            minute: 0,
          );

      final scheduledTask = task.copyWith(date: scheduledDate);

      await _saveNewTask(scheduledTask);
    } catch (e) {
      _state = _state.copyWith(
        viewState: ViewState.error,
        errorMessage: "Failed to generate task: $e",
      );
      notifyListeners();
    }
  }

  Future<void> _saveNewTask(StudyTask newTask) async {
    // Create updated plan
    final updatedTasks = List<StudyTask>.from(_state.currentPlan!.tasks)
      ..add(newTask);
    final updatedPlan = _state.currentPlan!.copyWith(tasks: updatedTasks);

    // Save to repo
    final result = await _studyPlanRepository.saveStudyPlan(updatedPlan);

    result.fold(
      onSuccess: (_) {
        _state = _state.copyWith(
          viewState: ViewState.loaded,
          currentPlan: updatedPlan,
          tasks: updatedPlan.tasksForDate(
            _state.selectedDate,
          ), // Refresh with current selection
          errorMessage: null,
        );
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.loaded, // Revert loading state
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
          tasks: updatedPlan.tasksForDate(_state.selectedDate),
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
