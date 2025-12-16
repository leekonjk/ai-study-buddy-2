/// AI Mentor ViewModel.
/// Manages state for AI Mentor advisory screen.
/// 
/// Layer: Presentation
/// Responsibility: Display AI insights, handle explanations.
/// Inputs: AI insights, user queries.
/// Outputs: Mentor state with insights and explanations.
library;

import 'package:studnet_ai_buddy/domain/entities/ai_insight.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// Immutable state for AI mentor screen.
class AIMentorState {
  final List<AIInsight> insights;
  final String? currentExplanation;
  final String? selectedSubjectId;
  final ViewState viewState;

  const AIMentorState({
    this.insights = const [],
    this.currentExplanation,
    this.selectedSubjectId,
    this.viewState = ViewState.initial,
  });

  AIMentorState copyWith({
    List<AIInsight>? insights,
    String? currentExplanation,
    String? selectedSubjectId,
    ViewState? viewState,
  }) {
    return AIMentorState(
      insights: insights ?? this.insights,
      currentExplanation: currentExplanation ?? this.currentExplanation,
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
      viewState: viewState ?? this.viewState,
    );
  }

  /// Returns unread insights count.
  int get unreadCount => insights.where((i) => !i.isRead).length;

  /// Returns high priority insights.
  List<AIInsight> get priorityInsights {
    return insights.where((i) => i.priority == InsightPriority.high).toList();
  }
}

class AIMentorViewModel extends BaseViewModel {
  // TODO: Inject AIMentorService and repositories
  
  AIMentorState _state = const AIMentorState();
  AIMentorState get state => _state;

  Future<void> loadInsights() async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    try {
      // TODO: Load insights from AI mentor service
      _state = _state.copyWith(viewState: ViewState.loaded);
      notifyListeners();
    } catch (e) {
      setError('Failed to load insights: $e');
      _state = _state.copyWith(viewState: ViewState.error);
      notifyListeners();
    }
  }

  Future<void> markInsightAsRead(String insightId) async {
    final updatedInsights = _state.insights.map((insight) {
      if (insight.id == insightId) {
        return insight.markAsRead();
      }
      return insight;
    }).toList();

    _state = _state.copyWith(insights: updatedInsights);
    notifyListeners();
  }

  Future<void> requestExplanation(String subjectId) async {
    _state = _state.copyWith(
      selectedSubjectId: subjectId,
      currentExplanation: null,
    );
    setLoading(true);

    try {
      // TODO: Get explanation from AI mentor service
      final explanation = 'Explanation for subject $subjectId...';
      
      _state = _state.copyWith(currentExplanation: explanation);
      notifyListeners();
    } catch (e) {
      setError('Failed to generate explanation: $e');
    } finally {
      setLoading(false);
    }
  }

  void clearExplanation() {
    _state = _state.copyWith(
      currentExplanation: null,
      selectedSubjectId: null,
    );
    notifyListeners();
  }
}
