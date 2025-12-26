/// Dashboard ViewModel.
/// Manages state for the main dashboard screen.
///
/// Layer: Presentation
/// Responsibility: Aggregate and expose dashboard data to UI.
/// Inputs: Study plan, tasks, focus sessions.
/// Outputs: Dashboard state with quick actions and status.
///
/// Dependencies: StudyPlanRepository, FocusSessionRepository, AcademicRepository
library;

import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';
import 'package:studnet_ai_buddy/domain/entities/focus_session.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/focus_session_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_plan_repository.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/services/local_storage_service.dart';

/// Subject with progress tracking for dashboard display.
class SubjectProgress {
  final String subjectId;
  final String subjectName;
  final int completedTasks;
  final int totalTasks;
  final int focusMinutes;

  const SubjectProgress({
    required this.subjectId,
    required this.subjectName,
    required this.completedTasks,
    required this.totalTasks,
    required this.focusMinutes,
  });

  /// Progress as a value between 0.0 and 1.0.
  double get progress => totalTasks > 0 ? completedTasks / totalTasks : 0.0;
}

/// Immutable state for dashboard.
class DashboardState {
  final ViewState viewState;
  final String greetingName;
  final String greetingMessage;
  final StudyTask? focusTask;
  final List<StudyTask> todayTasks;
  final List<SubjectProgress> activeSubjects;
  final int totalStudyMinutes;
  final int completedTasksCount;
  final int currentStreakDays;
  final List<FocusSession> recentSessions;
  final String tipOfTheDay;
  final String? errorMessage;
  final int weeklyStudyMinutes;
  final int weeklyGoalMinutes;
  final int dailyTaskGoal; // Added

  const DashboardState({
    this.viewState = ViewState.initial,
    this.greetingName = '',
    this.greetingMessage = '',
    this.focusTask,
    this.todayTasks = const [],
    this.activeSubjects = const [],
    this.totalStudyMinutes = 0,
    this.completedTasksCount = 0,
    this.currentStreakDays = 0,
    this.recentSessions = const [],
    this.tipOfTheDay = '',
    this.errorMessage,
    this.weeklyStudyMinutes = 0,
    this.weeklyGoalMinutes = 900, // Default 15 hours
    this.dailyTaskGoal = 5,
  });

  DashboardState copyWith({
    ViewState? viewState,
    String? greetingName,
    String? greetingMessage,
    StudyTask? focusTask,
    List<StudyTask>? todayTasks,
    List<SubjectProgress>? activeSubjects,
    int? totalStudyMinutes,
    int? completedTasksCount,
    int? currentStreakDays,
    List<FocusSession>? recentSessions,
    String? tipOfTheDay,
    String? errorMessage,
    int? weeklyStudyMinutes,
    int? weeklyGoalMinutes,
    int? dailyTaskGoal,
  }) {
    return DashboardState(
      viewState: viewState ?? this.viewState,
      greetingName: greetingName ?? this.greetingName,
      greetingMessage: greetingMessage ?? this.greetingMessage,
      focusTask: focusTask ?? this.focusTask,
      todayTasks: todayTasks ?? this.todayTasks,
      activeSubjects: activeSubjects ?? this.activeSubjects,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      completedTasksCount: completedTasksCount ?? this.completedTasksCount,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      recentSessions: recentSessions ?? this.recentSessions,
      tipOfTheDay: tipOfTheDay ?? this.tipOfTheDay,
      errorMessage: errorMessage,
      weeklyStudyMinutes: weeklyStudyMinutes ?? this.weeklyStudyMinutes,
      weeklyGoalMinutes: weeklyGoalMinutes ?? this.weeklyGoalMinutes,
      dailyTaskGoal: dailyTaskGoal ?? this.dailyTaskGoal,
    );
  }

  /// Whether the ViewModel is currently loading.
  bool get isLoading => viewState == ViewState.loading;

  /// Whether there is an error.
  bool get hasError => errorMessage != null;

  /// Pending tasks for today (not completed).
  List<StudyTask> get pendingTasks {
    return todayTasks.where((t) => !t.isCompleted).toList();
  }

  /// Completed tasks for today.
  List<StudyTask> get completedTasks {
    return todayTasks.where((t) => t.isCompleted).toList();
  }

  /// Today's completion percentage (0.0 to 1.0).
  double get todayProgress {
    if (todayTasks.isEmpty) return 0.0;
    return completedTasks.length / todayTasks.length;
  }

  /// Whether all tasks for today are complete.
  bool get allTasksComplete => todayTasks.isNotEmpty && pendingTasks.isEmpty;

  /// Total estimated minutes for today's remaining tasks.
  int get remainingMinutes {
    return pendingTasks.fold(0, (sum, task) => sum + task.estimatedMinutes);
  }
}

/// ViewModel for dashboard screen.
/// Coordinates with repositories to load and display dashboard data.
class DashboardViewModel extends BaseViewModel {
  final StudyPlanRepository _studyPlanRepository;
  final FocusSessionRepository _focusSessionRepository;
  final AcademicRepository _academicRepository;

  DashboardViewModel({
    required StudyPlanRepository studyPlanRepository,
    required FocusSessionRepository focusSessionRepository,
    required AcademicRepository academicRepository,
  }) : _studyPlanRepository = studyPlanRepository,
       _focusSessionRepository = focusSessionRepository,
       _academicRepository = academicRepository;

  DashboardState _state = const DashboardState();
  DashboardState get state => _state;

  // Cache for subjects map
  Map<String, Subject> _subjectsMap = {};

  // ─────────────────────────────────────────────────────────────────────────
  // Data Loading
  // ─────────────────────────────────────────────────────────────────────────

  /// Loads all dashboard data.
  Future<void> loadDashboard() async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    // Load profile for greeting
    final profileResult = await _academicRepository.getAcademicProfile();
    AcademicProfile? profile;

    profileResult.fold(
      onSuccess: (p) {
        profile = p;
        // developer.log('DashboardViewModel: Loaded profile for ${p?.studentName ?? 'null'}');
      },
      onFailure: (f) {
        // developer.log('DashboardViewModel: Failed to load profile: ${f.message}');
      },
    );

    // Load preferences for goals
    final prefs = getIt<LocalStorageService>();
    final weeklyGoalHours = await prefs.getInt('pref_weekly_goal') ?? 15;
    final weeklyGoalMinutes = weeklyGoalHours * 60;
    final dailyTaskGoal =
        await prefs.getInt('pref_daily_task_goal') ?? 5; // Load daily goal

    // Load subjects for mapping
    final subjectsResult = await _academicRepository.getEnrolledSubjects();

    subjectsResult.fold(
      onSuccess: (subjects) {
        _subjectsMap = {for (var s in subjects) s.id: s};
      },
      onFailure: (_) {},
    );

    // Load today's tasks
    final tasksResult = await _studyPlanRepository.getTodaysTasks();
    List<StudyTask> todayTasks = [];

    tasksResult.fold(
      onSuccess: (tasks) => todayTasks = tasks,
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: failure.message,
        );
        notifyListeners();
        return;
      },
    );

    // Load focus minutes for today
    final focusResult = await _focusSessionRepository.getTodaysFocusMinutes();
    int focusMinutes = 0;

    focusResult.fold(
      onSuccess: (minutes) => focusMinutes = minutes,
      onFailure: (_) {},
    );

    // Load weekly stats for streak calculation and weekly progress
    final weeklyResult = await _focusSessionRepository.getWeeklyFocusStats();
    int streakDays = 0;
    int weeklyStudyMinutes = 0;

    weeklyResult.fold(
      onSuccess: (stats) {
        streakDays = _calculateStreak(stats);
        weeklyStudyMinutes = stats.values.fold(0, (sum, val) => sum + val);
      },
      onFailure: (_) {},
    );

    // Load recent sessions (last 30 days, take top 3)
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sessionsResult = await _focusSessionRepository.getSessionsInRange(
      thirtyDaysAgo,
      now,
    );
    List<FocusSession> recentSessions = [];

    sessionsResult.fold(
      onSuccess: (sessions) {
        // Sort by startTime descending
        sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
        // Take top 3
        recentSessions = sessions.take(3).toList();
      },
      onFailure: (_) {},
    );

    // Build subject progress list
    final subjectProgress = _buildSubjectProgress(todayTasks);

    // Identify primary focus task (first pending high-priority task)
    final focusTask = _identifyFocusTask(todayTasks);

    // Generate greeting
    final greeting = _generateGreeting(profile?.studentName);

    // Count completed tasks
    final completedCount = todayTasks.where((t) => t.isCompleted).length;

    // Get tip of the day
    final tip = _getTipOfTheDay();

    _state = _state.copyWith(
      viewState: ViewState.loaded,
      greetingName: profile?.studentName ?? 'Student',
      greetingMessage: greeting,
      focusTask: focusTask,
      todayTasks: todayTasks,
      activeSubjects: subjectProgress,
      totalStudyMinutes: focusMinutes,
      completedTasksCount: completedCount,
      currentStreakDays: streakDays,
      recentSessions: recentSessions,
      tipOfTheDay: tip,
      errorMessage: null,
      weeklyStudyMinutes: weeklyStudyMinutes,
      weeklyGoalMinutes: weeklyGoalMinutes,
      dailyTaskGoal: dailyTaskGoal,
    );
    notifyListeners();
  }

  /// Refreshes dashboard data.
  Future<void> refresh() async {
    await loadDashboard();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Task Actions
  // ─────────────────────────────────────────────────────────────────────────

  /// Marks a task as completed.
  Future<void> completeTask(String taskId) async {
    final taskIndex = _state.todayTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final task = _state.todayTasks[taskIndex];
    final completedTask = task.copyWith(isCompleted: true);

    // Update local state immediately for responsiveness
    final updatedTasks = List<StudyTask>.from(_state.todayTasks);
    updatedTasks[taskIndex] = completedTask;

    _state = _state.copyWith(
      todayTasks: updatedTasks,
      completedTasksCount: _state.completedTasksCount + 1,
      focusTask: _identifyFocusTask(updatedTasks),
    );
    notifyListeners();

    // Persist to repository
    final result = await _studyPlanRepository.updateTask(completedTask);

    result.fold(
      onSuccess: (_) {},
      onFailure: (failure) {
        // Revert on failure
        final revertedTasks = List<StudyTask>.from(_state.todayTasks);
        revertedTasks[taskIndex] = task;
        _state = _state.copyWith(
          todayTasks: revertedTasks,
          completedTasksCount: _state.completedTasksCount - 1,
          errorMessage: 'Failed to save: ${failure.message}',
        );
        notifyListeners();
      },
    );
  }

  /// Skips a task (marks as skipped, not completed).
  Future<void> skipTask(String taskId) async {
    final taskIndex = _state.todayTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    // Remove task from today's list for UI purposes
    final updatedTasks = List<StudyTask>.from(_state.todayTasks);
    updatedTasks.removeAt(taskIndex);

    _state = _state.copyWith(
      todayTasks: updatedTasks,
      focusTask: _identifyFocusTask(updatedTasks),
    );
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates time-based greeting message.
  String _generateGreeting(String? name) {
    final hour = DateTime.now().hour;
    String displayName = name?.trim() ?? '';
    if (displayName.isEmpty) {
      displayName = 'Student';
    } else {
      displayName = displayName.split(' ').first;
    }

    if (hour < 12) {
      return 'Good morning, $displayName! Ready to learn?';
    } else if (hour < 17) {
      return 'Good afternoon, $displayName! Keep up the momentum.';
    } else {
      return 'Good evening, $displayName! Time for focused study.';
    }
  }

  /// Identifies the primary focus task from today's tasks.
  /// Priority: Critical > High > Medium > Low, then by time estimate.
  StudyTask? _identifyFocusTask(List<StudyTask> tasks) {
    final pending = tasks.where((t) => !t.isCompleted).toList();
    if (pending.isEmpty) return null;

    // Sort by priority (lower index = higher priority in enum)
    pending.sort((a, b) {
      final priorityCompare = a.priority.index.compareTo(b.priority.index);
      if (priorityCompare != 0) return priorityCompare;
      // Secondary sort by duration (shorter first)
      return a.estimatedMinutes.compareTo(b.estimatedMinutes);
    });

    return pending.first;
  }

  /// Builds subject progress list from today's tasks.
  List<SubjectProgress> _buildSubjectProgress(List<StudyTask> tasks) {
    final subjectTasks = <String, List<StudyTask>>{};

    for (final task in tasks) {
      subjectTasks.putIfAbsent(task.subjectId, () => []).add(task);
    }

    return subjectTasks.entries.map((entry) {
      final subjectId = entry.key;
      final subjectTaskList = entry.value;
      final subject = _subjectsMap[subjectId];

      final completedCount = subjectTaskList.where((t) => t.isCompleted).length;
      final totalMinutes = subjectTaskList.fold(
        0,
        (sum, t) => sum + t.estimatedMinutes,
      );

      return SubjectProgress(
        subjectId: subjectId,
        subjectName: subject?.name ?? 'Unknown Subject',
        completedTasks: completedCount,
        totalTasks: subjectTaskList.length,
        focusMinutes: totalMinutes,
      );
    }).toList();
  }

  /// Calculates study streak from weekly stats.
  /// Streak = consecutive days with study activity.
  int _calculateStreak(Map<String, int> weeklyStats) {
    final dayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final today = DateTime.now().weekday - 1; // 0-indexed
    int streak = 0;

    // Count backwards from yesterday
    for (int i = today - 1; i >= 0; i--) {
      final dayName = dayOrder[i];
      if ((weeklyStats[dayName] ?? 0) > 0) {
        streak++;
      } else {
        break;
      }
    }

    // Add today if already studied
    if ((weeklyStats[dayOrder[today]] ?? 0) > 0) {
      streak++;
    }

    return streak;
  }

  /// Returns a static tip of the day.
  /// Rotates based on day of year.
  String _getTipOfTheDay() {
    final tips = [
      'Break large tasks into 25-minute focus sessions for better retention.',
      'Review yesterday\'s material before starting new topics.',
      'Take a 5-minute break every 25 minutes to stay fresh.',
      'Quiz yourself instead of re-reading notes for active recall.',
      'Study your hardest subject when your energy is highest.',
      'Explain concepts out loud to strengthen understanding.',
      'Set specific goals for each study session.',
    ];

    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year))
        .inDays;
    return tips[dayOfYear % tips.length];
  }

  /// Clears any error message.
  void dismissError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}
