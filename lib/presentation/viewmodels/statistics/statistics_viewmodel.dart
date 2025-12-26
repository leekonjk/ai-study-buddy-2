/// Statistics ViewModel
/// Manages state for the statistics screen.
library;

import 'package:studnet_ai_buddy/domain/repositories/focus_session_repository.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';
import 'package:studnet_ai_buddy/domain/entities/focus_session.dart';

class StatisticsState {
  final ViewState viewState;
  final String selectedPeriod;
  final Map<String, int> weeklyStudyMinutes;
  final Map<String, double> subjectStudyHours;
  final List<FocusSession> recentSessions;
  final double totalHours;
  final double averageDailyHours;
  final String? errorMessage;

  const StatisticsState({
    this.viewState = ViewState.initial,
    this.selectedPeriod = 'Week',
    this.weeklyStudyMinutes = const {},
    this.subjectStudyHours = const {},
    this.recentSessions = const [],
    this.totalHours = 0,
    this.averageDailyHours = 0,
    this.errorMessage,
  });

  StatisticsState copyWith({
    ViewState? viewState,
    String? selectedPeriod,
    Map<String, int>? weeklyStudyMinutes,
    Map<String, double>? subjectStudyHours,
    List<FocusSession>? recentSessions,
    double? totalHours,
    double? averageDailyHours,
    String? errorMessage,
  }) {
    return StatisticsState(
      viewState: viewState ?? this.viewState,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      weeklyStudyMinutes: weeklyStudyMinutes ?? this.weeklyStudyMinutes,
      subjectStudyHours: subjectStudyHours ?? this.subjectStudyHours,
      recentSessions: recentSessions ?? this.recentSessions,
      totalHours: totalHours ?? this.totalHours,
      averageDailyHours: averageDailyHours ?? this.averageDailyHours,
      errorMessage: errorMessage,
    );
  }
}

class StatisticsViewModel extends BaseViewModel {
  final FocusSessionRepository _focusSessionRepository;

  StatisticsViewModel({required FocusSessionRepository focusSessionRepository})
    : _focusSessionRepository = focusSessionRepository;

  StatisticsState _state = const StatisticsState();
  StatisticsState get state => _state;

  Future<void> loadStats(String period) async {
    _state = _state.copyWith(
      viewState: ViewState.loading,
      selectedPeriod: period,
    );
    notifyListeners();

    // 1. Weekly Stats (Chart)
    final weeklyResult = await _focusSessionRepository.getWeeklyFocusStats();
    Map<String, int> weeklyMinutes = {};
    weeklyResult.fold(
      onSuccess: (data) => weeklyMinutes = data,
      onFailure: (_) {},
    );

    // 2. Recent Sessions (Activity & Subject Breakdown)
    // Fetch last 30 days for robust stats or just week depending on period
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    final sessionsResult = await _focusSessionRepository.getSessionsInRange(
      start,
      now,
    );

    List<FocusSession> sessions = [];
    Map<String, double> subjectHours = {};

    sessionsResult.fold(
      onSuccess: (list) {
        sessions = list;
        // aggregate for subject breakdown
        for (var session in list) {
          final hours = session.actualDurationMinutes / 60.0;
          final subject = (session.subjectId ?? '').isEmpty
              ? 'General'
              : session.subjectId!;
          // Note: In a real app we'd map ID to Name. For now we use ID or mock.
          subjectHours[subject] = (subjectHours[subject] ?? 0) + hours;
        }
        //Sort sessions by date desc
        sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
      },
      onFailure: (err) =>
          _state = _state.copyWith(errorMessage: err.toString()),
    );

    // Calc totals
    final totalMins = weeklyMinutes.values.fold(0, (sum, val) => sum + val);
    final totalHours = totalMins / 60.0;
    final avgHours = totalHours / 7; // Average over 7 days

    _state = _state.copyWith(
      viewState: ViewState.loaded,
      weeklyStudyMinutes: weeklyMinutes,
      subjectStudyHours: subjectHours,
      recentSessions: sessions.take(5).toList(), // Top 5 recent
      totalHours: totalHours,
      averageDailyHours: avgHours,
    );
    notifyListeners();
  }

  void setPeriod(String period) {
    if (_state.selectedPeriod != period) {
      loadStats(period);
    }
  }
}
