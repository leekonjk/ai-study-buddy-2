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
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

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

  AIPlannerViewModel({
    required StudyPlanRepository studyPlanRepository,
    required AcademicRepository academicRepository,
  }) : _studyPlanRepository = studyPlanRepository,
       _academicRepository = academicRepository;

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

    // Mock AI Generation Logic for "New User Experience"
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);
    final weekEnd = weekStart.add(const Duration(days: 6));

    List<StudyTask> newTasks = [];

    // Generate 1-2 tasks per day for the week
    for (int i = 0; i < 5; i++) {
      // Mon-Fri
      final date = weekStart.add(Duration(days: i));
      // Simple round-robin subjects
      final subject = subjects[i % subjects.length];

      newTasks.add(
        StudyTask(
          id: "${DateTime.now().millisecondsSinceEpoch}_$i",
          subjectId: subject.id,
          title: "Review ${subject.name} - Chapter ${i + 1}",
          description: "AI Generated task for ${subject.name}",
          date: date,
          estimatedMinutes: 45,
          priority: TaskPriority.medium,
          type: TaskType.study,
          isCompleted: false,
          aiReasoning: "Regular review schedule",
        ),
      );

      if (i % 2 == 0) {
        // Add extra task on some days
        final subject2 = subjects[(i + 1) % subjects.length];
        newTasks.add(
          StudyTask(
            id: "${DateTime.now().millisecondsSinceEpoch}_${i}_2",
            subjectId: subject2.id,
            title: "Practice questions for ${subject2.name}",
            description: "Practice problems",
            date: date,
            estimatedMinutes: 30,
            priority: TaskPriority.high,
            type: TaskType.quiz,
            isCompleted: false,
            aiReasoning: "Skill reinforcement",
          ),
        );
      }
    }

    final newPlan = StudyPlan(
      id: "plan_${now.millisecondsSinceEpoch}",
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      tasks: newTasks,
      aiSummary:
          "Initial study plan generated based on your enrolled subjects.",
      keyObjectives: ["Establish routine", "Cover basics"],
      generatedAt: now,
    );

    // Save to repository
    final saveResult = await _studyPlanRepository.saveStudyPlan(newPlan);

    saveResult.fold(
      onSuccess: (_) {
        _state = _state.copyWith(
          viewState: ViewState.loaded,
          currentPlan: newPlan,
          tasks: newPlan.tasksForDate(DateTime.now()), // Today's tasks
          subjects: subjects,
        );
      },
      onFailure: (f) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: "Failed to generate plan: ${f.message}",
        );
      },
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }
}
