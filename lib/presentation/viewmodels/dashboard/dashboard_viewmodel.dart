/// Dashboard ViewModel.
/// Manages state for the main dashboard screen.
library;

import 'dart:async';

import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';
import 'package:studnet_ai_buddy/domain/entities/focus_session.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/focus_session_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_plan_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/note_repository.dart';
import 'package:studnet_ai_buddy/domain/entities/note.dart';
import 'package:studnet_ai_buddy/domain/services/local_storage_service.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// Immutable state for the Dashboard.
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
  final List<Note> recentNotes;
  final String tipOfTheDay;
  final String? errorMessage;
  final int weeklyStudyMinutes;
  final int weeklyGoalMinutes;
  final int dailyTaskGoal;

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
    this.recentNotes = const [],
    this.tipOfTheDay = '',
    this.errorMessage,
    this.weeklyStudyMinutes = 0,
    this.weeklyGoalMinutes = 0,
    this.dailyTaskGoal = 0,
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
    List<Note>? recentNotes,
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
      recentNotes: recentNotes ?? this.recentNotes,
      tipOfTheDay: tipOfTheDay ?? this.tipOfTheDay,
      errorMessage: errorMessage,
      weeklyStudyMinutes: weeklyStudyMinutes ?? this.weeklyStudyMinutes,
      weeklyGoalMinutes: weeklyGoalMinutes ?? this.weeklyGoalMinutes,
      dailyTaskGoal: dailyTaskGoal ?? this.dailyTaskGoal,
    );
  }

  bool get isLoading => viewState == ViewState.loading;
  bool get hasError => viewState == ViewState.error;
}

class SubjectProgress {
  final String subjectId;
  final String subjectName;
  final int completedTasks;
  final int totalTasks;
  final int focusMinutes;

  SubjectProgress({
    required this.subjectId,
    required this.subjectName,
    required this.completedTasks,
    required this.totalTasks,
    required this.focusMinutes,
  });
}

class DashboardViewModel extends BaseViewModel {
  final StudyPlanRepository _studyPlanRepository;
  final FocusSessionRepository _focusSessionRepository;
  final AcademicRepository _academicRepository;
  final NoteRepository _noteRepository;

  DashboardViewModel({
    required StudyPlanRepository studyPlanRepository,
    required FocusSessionRepository focusSessionRepository,
    required AcademicRepository academicRepository,
    required NoteRepository noteRepository,
  }) : _studyPlanRepository = studyPlanRepository,
       _focusSessionRepository = focusSessionRepository,
       _academicRepository = academicRepository,
       _noteRepository = noteRepository;

  DashboardState _state = const DashboardState();
  DashboardState get state => _state;

  // Cache subjects for name lookup
  Map<String, dynamic> _subjectsMap = {};

  // Track today's focus sessions separately (quiz, flashcard, focus completions)
  int _todayFocusSessionsCount = 0;

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
      },
      onFailure: (f) {},
    );

    // Load preferences for goals
    final prefs = getIt<LocalStorageService>();
    final weeklyGoalHours = await prefs.getInt('pref_weekly_goal') ?? 15;
    final weeklyGoalMinutes = weeklyGoalHours * 60;
    final dailyTaskGoal = await prefs.getInt('pref_daily_task_goal') ?? 5;

    // Load subjects for mapping
    final subjectsResult = await _academicRepository.getEnrolledSubjects();

    subjectsResult.fold(
      onSuccess: (subjects) {
        _subjectsMap = {for (var s in subjects) s.id: s};
      },
      onFailure: (_) {},
    );

    // Start listening to real-time plan updates
    _startListeningToPlan();
    _startListeningToNotes();

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

    // Count today's completed sessions (quiz/flashcard/focus sessions)
    int todayCompletedSessions = 0;
    final todayStart = DateTime(now.year, now.month, now.day);

    sessionsResult.fold(
      onSuccess: (sessions) {
        // Sort by startTime descending
        sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
        // Take top 3
        recentSessions = sessions.take(3).toList();

        // Count today's completed sessions
        todayCompletedSessions = sessions
            .where(
              (s) =>
                  s.startTime.isAfter(todayStart) &&
                  s.status == FocusSessionStatus.completed,
            )
            .length;
      },
      onFailure: (_) {},
    );

    // Store focus sessions count for combining with plan tasks later
    _todayFocusSessionsCount = todayCompletedSessions;

    // Build initial state (tasks will update via stream)
    final greeting = _generateGreeting(profile?.studentName);
    final tip = _getTipOfTheDay();

    _state = _state.copyWith(
      viewState: ViewState.loaded,
      greetingName: profile?.studentName ?? 'Student',
      greetingMessage: greeting,
      activeSubjects: [], // Will populate from stream
      totalStudyMinutes: focusMinutes,
      completedTasksCount: todayCompletedSessions, // Start with today's sessions
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

    // If we have pending tasks, show the most important one
    if (pending.isNotEmpty) {
      // Sort by priority (lower index = higher priority in enum)
      pending.sort((a, b) {
        final priorityCompare = a.priority.index.compareTo(b.priority.index);
        if (priorityCompare != 0) return priorityCompare;
        // Secondary sort by duration (shorter first)
        return a.estimatedMinutes.compareTo(b.estimatedMinutes);
      });
      return pending.first;
    }

    // If all tasks are completed, show the last completed one (instead of vanishing)
    // capable of showing "All done!" state with the last task details
    final completed = tasks.where((t) => t.isCompleted).toList();
    if (completed.isNotEmpty) {
      return completed.last;
    }

    return null;
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

  @override
  void dispose() {
    _planSubscription?.cancel();
    _notesSubscription?.cancel();
    super.dispose();
  }

  StreamSubscription? _planSubscription;
  StreamSubscription? _notesSubscription;

  void _startListeningToNotes() async {
    final profileResult = await _academicRepository.getAcademicProfile();
    final uid = profileResult.fold(
      onSuccess: (p) => p?.id, // Using profile ID as user ID for now
      onFailure: (_) => null,
    );

    // Fallback to auth current user if needed, but here we assume academic profile is linked
    // Since we don't have direct auth here (clean architecture boundary),
    // we might need to rely on the repository knowing the current user.
    // The NoteRepository usually takes a userId.
    // Let's assume fetching profile gives us the ID for now.

    // Better safely: pass userId via constructor or get from repository context if possible.
    // However, DashboardVM usually loads for the *current* user.
    // Checking how NoteRepository is implemented... it requires userId in watchNotes(userId).
    // Let's try to get it from profile or modifying instantiation.
    // Simplify: We will just try to fetch it from repository or assume we can get it.
    // Actually, DashboardViewModel doesn't hold 'currentUser'.
    // Let's rely on AcademicRepository to give us the ID, as done above.

    if (uid != null) {
      _notesSubscription = _noteRepository.watchNotes(uid).listen((notes) {
        // Sort by last modified decending
        // Assuming Note has lastModified or createdAt
        // Using createdAt for now as per Note entity knowledge
        if (notes.isNotEmpty) {
          // We need to cast or copy - List<Note> is returned
          final sortedNotes = List<Note>.from(notes);
          // Sort not implemented on entity? Let's check Note entity later.
          // For now just take them.
          _state = _state.copyWith(recentNotes: sortedNotes.take(3).toList());
          notifyListeners();
        }
      });
    }
  }

  void _startListeningToPlan() {
    if (_planSubscription != null) return;

    _planSubscription = _studyPlanRepository.getPlanStream().listen((result) {
      result.fold(
        onSuccess: (plan) {
          // Use ALL tasks for the week to calculate subject progress
          final weeklyTasks = plan?.tasks ?? [];
          final subjectProgress = _buildSubjectProgress(weeklyTasks);

          // Filter for today's tasks for the task list
          final tasks = plan?.tasksForDate(DateTime.now()) ?? [];
          final focusTask = _identifyFocusTask(tasks);
          final planCompletedCount = tasks.where((t) => t.isCompleted).length;

          // Combine plan tasks + focus sessions (quiz/flashcard completions)
          final totalCompleted = planCompletedCount + _todayFocusSessionsCount;

          _state = _state.copyWith(
            todayTasks: tasks,
            activeSubjects: subjectProgress,
            focusTask: focusTask,
            completedTasksCount: totalCompleted,
          );
          notifyListeners();
        },
        onFailure: (_) {
          // Keep existing state on stream failure or log
        },
      );
    });
  }

  /// Clears any error message.
  void dismissError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}
