/// Quiz ViewModel.
/// Manages state for diagnostic and adaptive quizzes.
/// 
/// Layer: Presentation
/// Responsibility: Handle quiz flow, answer selection, results.
/// Inputs: Quiz questions, user answers.
/// Outputs: Quiz state, completion triggers knowledge update.
library;

import 'package:studnet_ai_buddy/domain/entities/quiz.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// Immutable state for quiz screen.
class QuizState {
  final Quiz? quiz;
  final int currentQuestionIndex;
  final Map<String, int> selectedAnswers; // questionId -> selected option index
  final bool isSubmitting;
  final QuizResult? result;
  final ViewState viewState;

  const QuizState({
    this.quiz,
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.isSubmitting = false,
    this.result,
    this.viewState = ViewState.initial,
  });

  QuizState copyWith({
    Quiz? quiz,
    int? currentQuestionIndex,
    Map<String, int>? selectedAnswers,
    bool? isSubmitting,
    QuizResult? result,
    ViewState? viewState,
  }) {
    return QuizState(
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      result: result ?? this.result,
      viewState: viewState ?? this.viewState,
    );
  }

  QuizQuestion? get currentQuestion {
    if (quiz == null || currentQuestionIndex >= quiz!.questions.length) {
      return null;
    }
    return quiz!.questions[currentQuestionIndex];
  }

  bool get isLastQuestion {
    if (quiz == null) return true;
    return currentQuestionIndex >= quiz!.questions.length - 1;
  }

  double get progress {
    if (quiz == null || quiz!.questions.isEmpty) return 0.0;
    return (currentQuestionIndex + 1) / quiz!.questions.length;
  }

  bool get isComplete => result != null;
}

class QuizViewModel extends BaseViewModel {
  // TODO: Inject QuizRepository and KnowledgeEstimationService
  
  QuizState _state = const QuizState();
  QuizState get state => _state;

  Future<void> loadDiagnosticQuiz(String subjectId) async {
    _state = _state.copyWith(viewState: ViewState.loading);
    notifyListeners();

    try {
      // TODO: Load quiz from repository
      _state = _state.copyWith(viewState: ViewState.loaded);
      notifyListeners();
    } catch (e) {
      setError('Failed to load quiz: $e');
      _state = _state.copyWith(viewState: ViewState.error);
      notifyListeners();
    }
  }

  void selectAnswer(String questionId, int optionIndex) {
    final updatedAnswers = Map<String, int>.from(_state.selectedAnswers);
    updatedAnswers[questionId] = optionIndex;
    _state = _state.copyWith(selectedAnswers: updatedAnswers);
    notifyListeners();
  }

  void nextQuestion() {
    if (!_state.isLastQuestion) {
      _state = _state.copyWith(
        currentQuestionIndex: _state.currentQuestionIndex + 1,
      );
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_state.currentQuestionIndex > 0) {
      _state = _state.copyWith(
        currentQuestionIndex: _state.currentQuestionIndex - 1,
      );
      notifyListeners();
    }
  }

  Future<void> submitQuiz() async {
    _state = _state.copyWith(isSubmitting: true);
    notifyListeners();

    try {
      // TODO: Calculate results and update knowledge levels
      // 1. Calculate score from selected answers
      // 2. Send to KnowledgeEstimationService
      // 3. Save results via repository
      
      _state = _state.copyWith(isSubmitting: false);
      notifyListeners();
    } catch (e) {
      setError('Failed to submit quiz: $e');
      _state = _state.copyWith(isSubmitting: false);
      notifyListeners();
    }
  }
}
