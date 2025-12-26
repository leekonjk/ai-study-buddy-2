/// AI Mentor ViewModel.
/// Manages state for AI Mentor advisory screen.
///
/// Layer: Presentation
/// Responsibility: Display AI insights, handle explanations.
/// Inputs: AI insights, user queries.
/// Outputs: Mentor state with insights and explanations.
///
/// Dependencies: AIMentorService, AcademicRepository
library;

import 'package:studnet_ai_buddy/domain/entities/ai_insight.dart';
import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';
import 'package:studnet_ai_buddy/domain/entities/risk_assessment.dart';
import 'package:studnet_ai_buddy/domain/entities/study_plan.dart';
import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart'; // Added
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart'; // Added
import 'package:studnet_ai_buddy/domain/services/ai_mentor_service.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// Immutable state for AI mentor screen.
class AIMentorState {
  final ViewState viewState;
  final List<AIInsight> insights;
  final String? selectedInsightId;
  final String? selectedInsightExplanation;
  final bool isLoadingExplanation;
  final String? errorMessage;

  const AIMentorState({
    this.viewState = ViewState.initial,
    this.insights = const [],
    this.selectedInsightId,
    this.selectedInsightExplanation,
    this.isLoadingExplanation = false,
    this.errorMessage,
  });

  AIMentorState copyWith({
    ViewState? viewState,
    List<AIInsight>? insights,
    String? selectedInsightId,
    String? selectedInsightExplanation,
    bool? isLoadingExplanation,
    String? errorMessage,
  }) {
    return AIMentorState(
      viewState: viewState ?? this.viewState,
      insights: insights ?? this.insights,
      selectedInsightId: selectedInsightId,
      selectedInsightExplanation: selectedInsightExplanation,
      isLoadingExplanation: isLoadingExplanation ?? this.isLoadingExplanation,
      errorMessage: errorMessage,
    );
  }

  /// Whether the ViewModel is currently loading.
  bool get isLoading => viewState == ViewState.loading;

  /// Whether there is an error.
  bool get hasError => errorMessage != null;

  /// Returns unread insights count.
  int get unreadCount => insights.where((i) => !i.isRead).length;

  /// Returns high priority insights.
  List<AIInsight> get priorityInsights {
    return insights.where((i) => i.priority == InsightPriority.high).toList();
  }

  /// Returns medium priority insights.
  List<AIInsight> get normalInsights {
    return insights.where((i) => i.priority == InsightPriority.medium).toList();
  }

  /// Returns low priority insights.
  List<AIInsight> get lowPriorityInsights {
    return insights.where((i) => i.priority == InsightPriority.low).toList();
  }

  /// Returns currently selected insight (if any).
  AIInsight? get selectedInsight {
    if (selectedInsightId == null) return null;
    try {
      return insights.firstWhere((i) => i.id == selectedInsightId);
    } catch (_) {
      return null;
    }
  }

  /// Whether an insight is currently selected.
  bool get hasSelectedInsight => selectedInsightId != null;

  /// Returns insights grouped by type.
  Map<InsightType, List<AIInsight>> get insightsByType {
    final map = <InsightType, List<AIInsight>>{};
    for (final insight in insights) {
      map.putIfAbsent(insight.type, () => []).add(insight);
    }
    return map;
  }

  /// Total number of insights.
  int get totalInsights => insights.length;
}

/// ViewModel for AI mentor screen.
/// Coordinates with AI mentor service to generate and display insights.
class AIMentorViewModel extends BaseViewModel {
  final AIMentorService _aiMentorService;
  final AcademicRepository _academicRepository; // Added

  AIMentorViewModel({
    required AIMentorService aiMentorService,
    required AcademicRepository academicRepository, // Added
  }) : _aiMentorService = aiMentorService,
       _academicRepository = academicRepository;

  AIMentorState _state = const AIMentorState();
  AIMentorState get state => _state;

  // Cached data for insight generation
  List<KnowledgeLevel> _knowledgeLevels = [];
  List<RiskAssessment> _riskAssessments = [];
  StudyPlan? _currentPlan;
  AcademicProfile? _cachedProfile; // Added cache

  // ─────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────

  /// Loads insights using provided academic data.
  Future<void> loadInsights({
    required List<KnowledgeLevel> knowledgeLevels,
    required List<RiskAssessment> riskAssessments,
    StudyPlan? currentPlan,
  }) async {
    _state = _state.copyWith(viewState: ViewState.loading, errorMessage: null);
    notifyListeners();

    // Cache data for later use
    _knowledgeLevels = knowledgeLevels;
    _riskAssessments = riskAssessments;
    _currentPlan = currentPlan;

    try {
      // Fetch Academic Profile if not cached
      if (_cachedProfile == null) {
        final profileResult = await _academicRepository.getAcademicProfile();
        profileResult.fold(
          onSuccess: (p) => _cachedProfile = p,
          onFailure: (_) {}, // Ignore error, proceed without context
        );
      }

      final insights = await _aiMentorService.generateDailyInsights(
        knowledgeLevels: knowledgeLevels,
        riskAssessments: riskAssessments,
        currentPlan: currentPlan,
        profile: _cachedProfile, // Pass profile
      );

      _state = _state.copyWith(viewState: ViewState.loaded, insights: insights);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        viewState: ViewState.error,
        errorMessage: 'Failed to load insights: $e',
      );
      notifyListeners();
    }
  }

  /// Refreshes insights with cached data.
  Future<void> refresh() async {
    if (_knowledgeLevels.isEmpty && _riskAssessments.isEmpty) {
      _state = _state.copyWith(
        errorMessage: 'No data available to generate insights',
      );
      notifyListeners();
      return;
    }

    await loadInsights(
      knowledgeLevels: _knowledgeLevels,
      riskAssessments: _riskAssessments,
      currentPlan: _currentPlan,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Insight Selection
  // ─────────────────────────────────────────────────────────────────────────

  /// Selects an insight to view details.
  void selectInsight(String insightId) {
    _state = _state.copyWith(
      selectedInsightId: insightId,
      selectedInsightExplanation: null,
    );

    // Mark as read
    markInsightAsRead(insightId);
  }

  /// Clears the selected insight.
  void clearSelection() {
    _state = _state.copyWith(
      selectedInsightId: null,
      selectedInsightExplanation: null,
    );
    notifyListeners();
  }

  /// Marks an insight as read.
  void markInsightAsRead(String insightId) {
    final updatedInsights = _state.insights.map((insight) {
      if (insight.id == insightId) {
        return insight.markAsRead();
      }
      return insight;
    }).toList();

    _state = _state.copyWith(insights: updatedInsights);
    notifyListeners();
  }

  /// Marks all insights as read.
  void markAllAsRead() {
    final updatedInsights = _state.insights.map((insight) {
      return insight.markAsRead();
    }).toList();

    _state = _state.copyWith(insights: updatedInsights);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Explanation Generation
  // ─────────────────────────────────────────────────────────────────────────

  /// Requests a detailed explanation for a subject.
  Future<void> requestExplanation(String subjectId) async {
    _state = _state.copyWith(
      isLoadingExplanation: true,
      selectedInsightExplanation: null,
    );
    notifyListeners();

    try {
      // Find knowledge level for subject
      final level = _knowledgeLevels.firstWhere(
        (l) => l.subjectId == subjectId,
        orElse: () => KnowledgeLevel(
          subjectId: subjectId,
          masteryScore: 0.5,
          confidenceScore: 0.5,
          estimatedAt: DateTime.now(),
        ),
      );

      final explanation = await _aiMentorService.explainProgress(
        subjectId: subjectId,
        level: level,
        assessments: _riskAssessments,
      );

      _state = _state.copyWith(
        isLoadingExplanation: false,
        selectedInsightExplanation: explanation,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoadingExplanation: false,
        errorMessage: 'Failed to generate explanation: $e',
      );
      notifyListeners();
    }
  }

  /// Clears the current explanation.
  void clearExplanation() {
    _state = _state.copyWith(selectedInsightExplanation: null);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Risk Warning
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates and adds a risk warning insight.
  Future<void> generateRiskWarning(RiskAssessment assessment) async {
    try {
      final warningInsight = await _aiMentorService.generateRiskWarning(
        assessment: assessment,
      );

      // Add to front of insights list
      final updatedInsights = [warningInsight, ..._state.insights];
      _state = _state.copyWith(insights: updatedInsights);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Failed to generate warning: $e');
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Completion Feedback
  // ─────────────────────────────────────────────────────────────────────────

  /// Generates and adds completion feedback insight.
  Future<void> generateCompletionFeedback({
    required String taskTitle,
    required int streakDays,
  }) async {
    try {
      final feedbackInsight = await _aiMentorService.generateCompletionFeedback(
        taskTitle: taskTitle,
        streakDays: streakDays,
      );

      // Add to front of insights list
      final updatedInsights = [feedbackInsight, ..._state.insights];
      _state = _state.copyWith(insights: updatedInsights);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Failed to generate feedback: $e');
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Updates cached academic data.
  void updateAcademicData({
    List<KnowledgeLevel>? knowledgeLevels,
    List<RiskAssessment>? riskAssessments,
    StudyPlan? currentPlan,
  }) {
    if (knowledgeLevels != null) _knowledgeLevels = knowledgeLevels;
    if (riskAssessments != null) _riskAssessments = riskAssessments;
    if (currentPlan != null) _currentPlan = currentPlan;
  }

  /// Clears any error message.
  void dismissError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  /// Clears all state.
  void clear() {
    _state = const AIMentorState();
    _knowledgeLevels = [];
    _riskAssessments = [];
    _currentPlan = null;
    notifyListeners();
  }

  /// Returns insights filtered by type.
  List<AIInsight> getInsightsByType(InsightType type) {
    return _state.insights.where((i) => i.type == type).toList();
  }

  /// Removes a dismissed insight.
  void dismissInsight(String insightId) {
    final updatedInsights = _state.insights
        .where((i) => i.id != insightId)
        .toList();

    _state = _state.copyWith(insights: updatedInsights);

    // Clear selection if dismissed insight was selected
    if (_state.selectedInsightId == insightId) {
      _state = _state.copyWith(
        selectedInsightId: null,
        selectedInsightExplanation: null,
      );
    }

    notifyListeners();
  }
}
