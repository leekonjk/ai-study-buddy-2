/// Focus Session ViewModel.
/// Manages state for focus/study session tracking.
/// 
/// Layer: Presentation
/// Responsibility: Timer control, session tracking, distraction logging.
/// Inputs: User actions (start, pause, complete session).
/// Outputs: Session state, timer updates.
/// 
/// Dependencies: FocusSessionRepository
library;

import 'dart:async';

import 'package:studnet_ai_buddy/domain/entities/focus_session.dart';
import 'package:studnet_ai_buddy/domain/repositories/focus_session_repository.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// Immutable state for focus session screen.
class FocusSessionState {
  final ViewState viewState;
  final FocusSession? activeSession;
  final int elapsedSeconds;
  final bool isRunning;
  final bool isPaused;
  final int distractionsCount;
  final List<FocusSession> recentSessions;
  final int todayFocusMinutes;
  final String? linkedTaskId;
  final String? linkedSubjectId;
  final String? errorMessage;

  const FocusSessionState({
    this.viewState = ViewState.initial,
    this.activeSession,
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
    this.distractionsCount = 0,
    this.recentSessions = const [],
    this.todayFocusMinutes = 0,
    this.linkedTaskId,
    this.linkedSubjectId,
    this.errorMessage,
  });

  FocusSessionState copyWith({
    ViewState? viewState,
    FocusSession? activeSession,
    int? elapsedSeconds,
    bool? isRunning,
    bool? isPaused,
    int? distractionsCount,
    List<FocusSession>? recentSessions,
    int? todayFocusMinutes,
    String? linkedTaskId,
    String? linkedSubjectId,
    String? errorMessage,
  }) {
    return FocusSessionState(
      viewState: viewState ?? this.viewState,
      activeSession: activeSession ?? this.activeSession,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      distractionsCount: distractionsCount ?? this.distractionsCount,
      recentSessions: recentSessions ?? this.recentSessions,
      todayFocusMinutes: todayFocusMinutes ?? this.todayFocusMinutes,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
      linkedSubjectId: linkedSubjectId ?? this.linkedSubjectId,
      errorMessage: errorMessage,
    );
  }

  /// Creates a copy with activeSession cleared.
  FocusSessionState clearSession() {
    return FocusSessionState(
      viewState: viewState,
      activeSession: null,
      elapsedSeconds: 0,
      isRunning: false,
      isPaused: false,
      distractionsCount: 0,
      recentSessions: recentSessions,
      todayFocusMinutes: todayFocusMinutes,
      linkedTaskId: null,
      linkedSubjectId: null,
      errorMessage: null,
    );
  }

  /// Whether the ViewModel is currently loading.
  bool get isLoading => viewState == ViewState.loading;

  /// Whether there is an error.
  bool get hasError => errorMessage != null;

  /// Whether a session is currently active (running or paused).
  bool get hasActiveSession => activeSession != null;

  /// Remaining seconds until session completes.
  int get remainingSeconds {
    if (activeSession == null) return 0;
    final totalSeconds = activeSession!.plannedMinutes * 60;
    return (totalSeconds - elapsedSeconds).clamp(0, totalSeconds);
  }

  /// Elapsed time formatted as MM:SS.
  String get formattedElapsed {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Remaining time formatted as MM:SS.
  String get formattedRemaining {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Progress as a value between 0.0 and 1.0.
  double get progress {
    if (activeSession == null) return 0.0;
    final totalSeconds = activeSession!.plannedMinutes * 60;
    if (totalSeconds == 0) return 0.0;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  /// Whether session timer has completed.
  bool get isSessionComplete {
    if (activeSession == null) return false;
    return elapsedSeconds >= activeSession!.plannedMinutes * 60;
  }

  /// Planned duration in minutes for current session.
  int get plannedMinutes => activeSession?.plannedMinutes ?? 0;

  /// Elapsed minutes (rounded down).
  int get elapsedMinutes => elapsedSeconds ~/ 60;

  /// Alias for formattedRemaining - used by UI.
  String get formattedRemainingTime => formattedRemaining;

  /// Alias for progress - used by UI.
  double get sessionProgress => progress;

  /// Alias for activeSession - used by UI.
  FocusSession? get currentSession => activeSession;
}

/// ViewModel for focus session screen.
/// Coordinates with repository to track and persist focus sessions.
class FocusSessionViewModel extends BaseViewModel {
  final FocusSessionRepository _focusSessionRepository;

  FocusSessionViewModel({
    required FocusSessionRepository focusSessionRepository,
  }) : _focusSessionRepository = focusSessionRepository;

  FocusSessionState _state = const FocusSessionState();
  FocusSessionState get state => _state;

  Timer? _timer;

  // ─────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────

  /// Loads initial data: active session, recent sessions, today's minutes.
  Future<void> initialize() async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    // Check for active session
    final activeResult = await _focusSessionRepository.getActiveSession();

    activeResult.fold(
      onSuccess: (session) {
        if (session != null) {
          // Resume active session
          final elapsed = DateTime.now().difference(session.startTime).inSeconds;
          _state = _state.copyWith(
            activeSession: session,
            elapsedSeconds: elapsed,
            isRunning: session.status == FocusSessionStatus.active,
            isPaused: session.status == FocusSessionStatus.paused,
            linkedTaskId: session.taskId,
            linkedSubjectId: session.subjectId,
          );
          if (_state.isRunning) {
            _startTimer();
          }
        }
      },
      onFailure: (_) {},
    );

    // Load today's focus minutes
    final todayResult = await _focusSessionRepository.getTodaysFocusMinutes();

    todayResult.fold(
      onSuccess: (minutes) {
        _state = _state.copyWith(todayFocusMinutes: minutes);
      },
      onFailure: (_) {},
    );

    // Load recent sessions (last 7 days)
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentResult = await _focusSessionRepository.getSessionsInRange(weekAgo, now);

    recentResult.fold(
      onSuccess: (sessions) {
        _state = _state.copyWith(recentSessions: sessions);
      },
      onFailure: (_) {},
    );

    _state = _state.copyWith(viewState: ViewState.loaded);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Session Control
  // ─────────────────────────────────────────────────────────────────────────

  /// Starts a new focus session.
  Future<void> startSession({
    required int durationMinutes,
    String? taskId,
    String? subjectId,
  }) async {
    if (_state.hasActiveSession) return;

    final session = FocusSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      taskId: taskId,
      subjectId: subjectId,
      startTime: DateTime.now(),
      plannedMinutes: durationMinutes,
      status: FocusSessionStatus.active,
    );

    // Save to repository
    final result = await _focusSessionRepository.saveSession(session);

    result.fold(
      onSuccess: (_) {
        _state = _state.copyWith(
          activeSession: session,
          elapsedSeconds: 0,
          isRunning: true,
          isPaused: false,
          distractionsCount: 0,
          linkedTaskId: taskId,
          linkedSubjectId: subjectId,
          errorMessage: null,
        );
        notifyListeners();
        _startTimer();
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          errorMessage: 'Failed to start session: ${failure.message}',
        );
        notifyListeners();
      },
    );
  }

  /// Pauses the active session.
  void pauseSession() {
    if (!_state.isRunning) return;

    _timer?.cancel();
    _state = _state.copyWith(
      isRunning: false,
      isPaused: true,
    );
    notifyListeners();

    _updateSessionInRepository();
  }

  /// Resumes a paused session.
  void resumeSession() {
    if (!_state.isPaused) return;

    _state = _state.copyWith(
      isRunning: true,
      isPaused: false,
    );
    notifyListeners();

    _startTimer();
    _updateSessionInRepository();
  }

  /// Logs a distraction during the session.
  void logDistraction() {
    if (!_state.hasActiveSession) return;

    _state = _state.copyWith(
      distractionsCount: _state.distractionsCount + 1,
    );
    notifyListeners();
  }

  /// Completes the session (either manually or when timer ends).
  Future<void> completeSession() async {
    if (!_state.hasActiveSession) return;

    _timer?.cancel();

    final completedSession = _state.activeSession!.copyWith(
      endTime: DateTime.now(),
      actualMinutes: _state.elapsedMinutes,
      status: FocusSessionStatus.completed,
      distractionsCount: _state.distractionsCount,
    );

    final result = await _focusSessionRepository.updateSession(completedSession);

    result.fold(
      onSuccess: (_) {
        // Update today's minutes
        final newTodayMinutes = _state.todayFocusMinutes + _state.elapsedMinutes;

        // Add to recent sessions
        final updatedRecent = [completedSession, ..._state.recentSessions];

        _state = _state.clearSession().copyWith(
          todayFocusMinutes: newTodayMinutes,
          recentSessions: updatedRecent,
        );
        notifyListeners();
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          errorMessage: 'Session completed but failed to save: ${failure.message}',
        );
        notifyListeners();
      },
    );
  }

  /// Cancels the active session.
  Future<void> cancelSession() async {
    if (!_state.hasActiveSession) return;

    _timer?.cancel();

    final cancelledSession = _state.activeSession!.copyWith(
      endTime: DateTime.now(),
      actualMinutes: _state.elapsedMinutes,
      status: FocusSessionStatus.cancelled,
      distractionsCount: _state.distractionsCount,
    );

    final result = await _focusSessionRepository.updateSession(cancelledSession);

    result.fold(
      onSuccess: (_) {
        _state = _state.clearSession();
        notifyListeners();
      },
      onFailure: (failure) {
        // Clear locally even if save fails
        _state = _state.clearSession().copyWith(
          errorMessage: 'Session cancelled but failed to save: ${failure.message}',
        );
        notifyListeners();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Timer Management
  // ─────────────────────────────────────────────────────────────────────────

  /// Starts the internal timer.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.isRunning && !_state.isPaused) {
        _state = _state.copyWith(
          elapsedSeconds: _state.elapsedSeconds + 1,
        );
        notifyListeners();

        // Check if session is complete
        if (_state.isSessionComplete) {
          completeSession();
        }
      }
    });
  }

  /// Manually updates elapsed time (for testing or external sync).
  void tick() {
    if (_state.isRunning && !_state.isPaused) {
      _state = _state.copyWith(
        elapsedSeconds: _state.elapsedSeconds + 1,
      );
      notifyListeners();

      if (_state.isSessionComplete) {
        completeSession();
      }
    }
  }

  /// Updates session in repository (for pause/resume persistence).
  Future<void> _updateSessionInRepository() async {
    if (!_state.hasActiveSession) return;

    final updatedSession = _state.activeSession!.copyWith(
      actualMinutes: _state.elapsedMinutes,
      status: _state.isPaused
          ? FocusSessionStatus.paused
          : FocusSessionStatus.active,
      distractionsCount: _state.distractionsCount,
    );

    await _focusSessionRepository.updateSession(updatedSession);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Data Refresh
  // ─────────────────────────────────────────────────────────────────────────

  /// Refreshes today's focus minutes and recent sessions.
  Future<void> refresh() async {
    final todayResult = await _focusSessionRepository.getTodaysFocusMinutes();

    todayResult.fold(
      onSuccess: (minutes) {
        _state = _state.copyWith(todayFocusMinutes: minutes);
      },
      onFailure: (_) {},
    );

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final recentResult = await _focusSessionRepository.getSessionsInRange(weekAgo, now);

    recentResult.fold(
      onSuccess: (sessions) {
        _state = _state.copyWith(recentSessions: sessions);
      },
      onFailure: (_) {},
    );

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Clears any error message.
  void dismissError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
