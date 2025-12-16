/// Focus Session ViewModel.
/// Manages state for focus/study session tracking.
/// 
/// Layer: Presentation
/// Responsibility: Timer control, session tracking, distraction logging.
/// Inputs: User actions (start, pause, complete session).
/// Outputs: Session state, timer updates.
library;

import 'dart:async';

import 'package:studnet_ai_buddy/domain/entities/focus_session.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// Immutable state for focus session.
class FocusSessionState {
  final FocusSession? activeSession;
  final int remainingSeconds;
  final bool isPaused;
  final int distractionsCount;
  final String? linkedTaskId;
  final String? linkedSubjectId;

  const FocusSessionState({
    this.activeSession,
    this.remainingSeconds = 0,
    this.isPaused = false,
    this.distractionsCount = 0,
    this.linkedTaskId,
    this.linkedSubjectId,
  });

  FocusSessionState copyWith({
    FocusSession? activeSession,
    int? remainingSeconds,
    bool? isPaused,
    int? distractionsCount,
    String? linkedTaskId,
    String? linkedSubjectId,
  }) {
    return FocusSessionState(
      activeSession: activeSession ?? this.activeSession,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isPaused: isPaused ?? this.isPaused,
      distractionsCount: distractionsCount ?? this.distractionsCount,
      linkedTaskId: linkedTaskId ?? this.linkedTaskId,
      linkedSubjectId: linkedSubjectId ?? this.linkedSubjectId,
    );
  }

  bool get isActive => activeSession != null && !isPaused;
  
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (activeSession == null) return 0.0;
    final totalSeconds = activeSession!.plannedMinutes * 60;
    if (totalSeconds == 0) return 0.0;
    return 1.0 - (remainingSeconds / totalSeconds);
  }
}

class FocusSessionViewModel extends BaseViewModel {
  // TODO: Inject FocusSessionRepository
  
  FocusSessionState _state = const FocusSessionState();
  FocusSessionState get state => _state;
  
  Timer? _timer;

  Future<void> startSession({
    required int durationMinutes,
    String? taskId,
    String? subjectId,
  }) async {
    // TODO: Create session in repository
    
    final session = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      taskId: taskId,
      subjectId: subjectId,
      startTime: DateTime.now(),
      plannedMinutes: durationMinutes,
      status: FocusSessionStatus.active,
    );

    _state = FocusSessionState(
      activeSession: session,
      remainingSeconds: durationMinutes * 60,
      linkedTaskId: taskId,
      linkedSubjectId: subjectId,
    );
    notifyListeners();

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.remainingSeconds > 0 && !_state.isPaused) {
        _state = _state.copyWith(remainingSeconds: _state.remainingSeconds - 1);
        notifyListeners();
      } else if (_state.remainingSeconds <= 0) {
        _completeSession();
      }
    });
  }

  void pauseSession() {
    _state = _state.copyWith(isPaused: true);
    notifyListeners();
  }

  void resumeSession() {
    _state = _state.copyWith(isPaused: false);
    notifyListeners();
  }

  void logDistraction() {
    _state = _state.copyWith(distractionsCount: _state.distractionsCount + 1);
    notifyListeners();
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    
    if (_state.activeSession != null) {
      // ignore: unused_local_variable
      final completedSession = _state.activeSession!.copyWith(
        endTime: DateTime.now(),
        actualMinutes: _state.activeSession!.plannedMinutes,
        status: FocusSessionStatus.completed,
        distractionsCount: _state.distractionsCount,
      );
      
      // TODO: Save completed session to repository
      
      _state = const FocusSessionState();
      notifyListeners();
    }
  }

  Future<void> cancelSession() async {
    _timer?.cancel();
    
    if (_state.activeSession != null) {
      // ignore: unused_local_variable
      final cancelledSession = _state.activeSession!.copyWith(
        endTime: DateTime.now(),
        status: FocusSessionStatus.cancelled,
      );
      
      // TODO: Save cancelled session to repository
    }

    _state = const FocusSessionState();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
