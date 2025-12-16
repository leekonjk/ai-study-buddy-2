/// Dashboard ViewModel.
/// Manages state for the main dashboard screen.
/// 
/// Layer: Presentation
/// Responsibility: Aggregate and expose dashboard data to UI.
/// Inputs: Study plan, tasks, risk assessments, insights.
/// Outputs: Dashboard state with quick actions and status.
library;

import 'package:studnet_ai_buddy/domain/entities/ai_insight.dart';
import 'package:studnet_ai_buddy/domain/entities/risk_assessment.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// Immutable state for dashboard.
class DashboardState {
  final List<StudyTask> todaysTasks;
  final List<RiskAssessment> riskAssessments;
  final List<AIInsight> recentInsights;
  final int focusMinutesToday;
  final int tasksCompletedToday;
  final double weeklyProgress;
  final String? aiGreeting;
  final ViewState viewState;

  const DashboardState({
    this.todaysTasks = const [],
    this.riskAssessments = const [],
    this.recentInsights = const [],
    this.focusMinutesToday = 0,
    this.tasksCompletedToday = 0,
    this.weeklyProgress = 0.0,
    this.aiGreeting,
    this.viewState = ViewState.initial,
  });

  DashboardState copyWith({
    List<StudyTask>? todaysTasks,
    List<RiskAssessment>? riskAssessments,
    List<AIInsight>? recentInsights,
    int? focusMinutesToday,
    int? tasksCompletedToday,
    double? weeklyProgress,
    String? aiGreeting,
    ViewState? viewState,
  }) {
    return DashboardState(
      todaysTasks: todaysTasks ?? this.todaysTasks,
      riskAssessments: riskAssessments ?? this.riskAssessments,
      recentInsights: recentInsights ?? this.recentInsights,
      focusMinutesToday: focusMinutesToday ?? this.focusMinutesToday,
      tasksCompletedToday: tasksCompletedToday ?? this.tasksCompletedToday,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      aiGreeting: aiGreeting ?? this.aiGreeting,
      viewState: viewState ?? this.viewState,
    );
  }

  /// Returns high-risk subjects that need attention.
  List<RiskAssessment> get highRiskSubjects {
    return riskAssessments
        .where((r) => r.riskLevel == RiskLevel.high || r.riskLevel == RiskLevel.critical)
        .toList();
  }

  /// Returns pending tasks for today.
  List<StudyTask> get pendingTasks {
    return todaysTasks.where((t) => !t.isCompleted).toList();
  }
}

class DashboardViewModel extends BaseViewModel {
  // TODO: Inject repositories and services when implementing
  
  DashboardState _state = const DashboardState();
  DashboardState get state => _state;

  Future<void> loadDashboard() async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    try {
      // TODO: Load data from repositories
      // - Get today's tasks from study plan repository
      // - Get risk assessments from risk analysis service
      // - Get insights from AI mentor service
      // - Get focus stats from focus session repository
      
      _state = _state.copyWith(
        viewState: ViewState.loaded,
        aiGreeting: _generateGreeting(),
      );
      notifyListeners();
    } catch (e) {
      setError('Failed to load dashboard: $e');
      _state = _state.copyWith(viewState: ViewState.error);
      notifyListeners();
    }
  }

  Future<void> completeTask(String taskId) async {
    // TODO: Update task in repository
    final updatedTasks = _state.todaysTasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(completedAt: DateTime.now());
      }
      return task;
    }).toList();

    _state = _state.copyWith(
      todaysTasks: updatedTasks,
      tasksCompletedToday: _state.tasksCompletedToday + 1,
    );
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDashboard();
  }

  String _generateGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning! Ready to learn?';
    if (hour < 17) return 'Good afternoon! Keep up the progress.';
    return 'Good evening! Time for focused study.';
  }
}
