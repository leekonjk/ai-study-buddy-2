/// Quiz ViewModel.
/// Manages state for diagnostic and adaptive quizzes.
///
/// Layer: Presentation
/// Responsibility: Handle quiz flow, answer selection, results.
/// Inputs: Quiz questions, user answers.
/// Outputs: Quiz state, completion triggers knowledge update.
///
/// Dependencies: QuizRepository, KnowledgeEstimationService
library;

import 'package:studnet_ai_buddy/domain/entities/quiz.dart';
import 'package:studnet_ai_buddy/domain/repositories/quiz_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/flashcard_repository.dart';
import 'package:studnet_ai_buddy/domain/repositories/focus_session_repository.dart'; // Added
import 'package:studnet_ai_buddy/domain/entities/focus_session.dart'; // Added
import 'package:studnet_ai_buddy/domain/services/knowledge_estimation_service.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart';

/// Immutable state for quiz screen.
class QuizState {
  final ViewState viewState;
  final Quiz? quiz;
  final int currentQuestionIndex;
  final Map<String, int> answers; // questionId -> selected option index
  final bool isSubmitting;
  final bool isCompleted;
  final QuizResult? result;
  final String? errorMessage;

  const QuizState({
    this.viewState = ViewState.initial,
    this.quiz,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.isSubmitting = false,
    this.isCompleted = false,
    this.result,
    this.errorMessage,
  });

  QuizState copyWith({
    ViewState? viewState,
    Quiz? quiz,
    int? currentQuestionIndex,
    Map<String, int>? answers,
    bool? isSubmitting,
    bool? isCompleted,
    QuizResult? result,
    String? errorMessage,
  }) {
    return QuizState(
      viewState: viewState ?? this.viewState,
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isCompleted: isCompleted ?? this.isCompleted,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }

  /// Whether the ViewModel is currently loading.
  bool get isLoading => viewState == ViewState.loading;

  /// Whether there is an error.
  bool get hasError => errorMessage != null;

  /// Current question being displayed.
  QuizQuestion? get currentQuestion {
    if (quiz == null || currentQuestionIndex >= quiz!.questions.length) {
      return null;
    }
    return quiz!.questions[currentQuestionIndex];
  }

  /// Whether current question is the last one.
  bool get isLastQuestion {
    if (quiz == null || quiz!.questions.isEmpty) return true;
    return currentQuestionIndex >= quiz!.questions.length - 1;
  }

  /// Whether current question is the first one.
  bool get isFirstQuestion => currentQuestionIndex == 0;

  /// Progress as a value between 0.0 and 1.0.
  double get progress {
    if (quiz == null || quiz!.questions.isEmpty) return 0.0;
    return (currentQuestionIndex + 1) / quiz!.questions.length;
  }

  /// Total number of questions.
  int get totalQuestions => quiz?.questions.length ?? 0;

  /// Number of answered questions.
  int get answeredCount => answers.length;

  /// Whether all questions have been answered.
  bool get allQuestionsAnswered {
    if (quiz == null) return false;
    return answers.length >= quiz!.questions.length;
  }

  /// Whether current question has been answered.
  bool get currentQuestionAnswered {
    final question = currentQuestion;
    if (question == null) return false;
    return answers.containsKey(question.id);
  }

  /// Selected answer for current question (null if not answered).
  int? get currentSelectedAnswer {
    final question = currentQuestion;
    if (question == null) return null;
    return answers[question.id];
  }

  /// Whether quiz can be submitted.
  bool get canSubmit => allQuestionsAnswered && !isSubmitting && !isCompleted;
}

/// ViewModel for quiz screen.
/// Coordinates with repository and knowledge estimation service.
class QuizViewModel extends BaseViewModel {
  final QuizRepository _quizRepository;
  final FlashcardRepository _flashcardRepository;
  final FocusSessionRepository _focusSessionRepository; // Added
  // ignore: unused_field - Reserved for future knowledge estimation integration
  final KnowledgeEstimationService _knowledgeEstimationService;

  QuizViewModel({
    required QuizRepository quizRepository,
    required FlashcardRepository flashcardRepository,
    required FocusSessionRepository focusSessionRepository, // Added
    required KnowledgeEstimationService knowledgeEstimationService,
  }) : _quizRepository = quizRepository,
       _flashcardRepository = flashcardRepository,
       _focusSessionRepository = focusSessionRepository, // Added
       _knowledgeEstimationService = knowledgeEstimationService;

  QuizState _state = const QuizState();
  QuizState get state => _state;

  // ─────────────────────────────────────────────────────────────────────────
  // Quiz Loading
  // ─────────────────────────────────────────────────────────────────────────

  /// Loads a diagnostic quiz for the given subject.
  Future<void> loadDiagnosticQuiz(String subjectId) async {
    _state = _state.copyWith(viewState: ViewState.loading, errorMessage: null);
    notifyListeners();

    final result = await _quizRepository.getDiagnosticQuiz(subjectId);

    result.fold(
      onSuccess: (quiz) {
        if (quiz == null) {
          _state = _state.copyWith(
            viewState: ViewState.error,
            errorMessage: 'No quiz available for this subject',
          );
        } else {
          _state = _state.copyWith(
            viewState: ViewState.loaded,
            quiz: quiz,
            currentQuestionIndex: 0,
            answers: {},
            isCompleted: false,
            result: null,
          );
        }
        notifyListeners();
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
    );
  }

  /// Loads an adaptive quiz with questions targeting specific difficulty.
  Future<void> loadAdaptiveQuiz({
    required String subjectId,
    required double targetDifficulty,
    int questionCount = 5,
  }) async {
    _state = _state.copyWith(viewState: ViewState.loading, errorMessage: null);
    notifyListeners();

    final result = await _quizRepository.getAdaptiveQuestions(
      subjectId: subjectId,
      targetDifficulty: targetDifficulty,
      count: questionCount,
    );

    result.fold(
      onSuccess: (questions) {
        if (questions.isEmpty) {
          _state = _state.copyWith(
            viewState: ViewState.error,
            errorMessage: 'No questions available',
          );
        } else {
          // Build quiz from questions
          final quiz = Quiz(
            id: 'adaptive_${DateTime.now().millisecondsSinceEpoch}',
            subjectId: subjectId,
            type: QuizType.adaptive,
            questions: questions,
            startedAt: DateTime.now(),
          );

          _state = _state.copyWith(
            viewState: ViewState.loaded,
            quiz: quiz,
            currentQuestionIndex: 0,
            answers: {},
            isCompleted: false,
            result: null,
          );
        }
        notifyListeners();
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
    );
  }

  /// Loads a custom quiz based on user configuration.
  Future<void> loadCustomQuiz({
    required String subjectId,
    String? topic,
    required double difficulty,
    required int count,
  }) async {
    _state = _state.copyWith(viewState: ViewState.loading, errorMessage: null);
    notifyListeners();

    final result = await _quizRepository.getAdaptiveQuestions(
      subjectId: subjectId,
      targetDifficulty: difficulty,
      count: count,
      topic: topic,
    );

    result.fold(
      onSuccess: (questions) {
        if (questions.isEmpty) {
          _state = _state.copyWith(
            viewState: ViewState.error,
            errorMessage: 'No questions found for the selected criteria.',
          );
        } else {
          // Build quiz from questions
          final quiz = Quiz(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            subjectId: subjectId,
            topicId: topic,
            type: QuizType.adaptive,
            questions: questions,
            startedAt: DateTime.now(),
          );

          _state = _state.copyWith(
            viewState: ViewState.loaded,
            quiz: quiz,
            currentQuestionIndex: 0,
            answers: {},
            isCompleted: false,
            result: null,
          );
        }
        notifyListeners();
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
    );
  }

  /// Loads a quiz from a study set (Flashcards).
  Future<void> loadStudySetQuiz(String studySetId) async {
    _state = _state.copyWith(viewState: ViewState.loading, errorMessage: null);
    notifyListeners();

    final result = await _flashcardRepository.getFlashcardsByStudySetId(
      studySetId,
    );

    result.fold(
      onSuccess: (flashcards) {
        if (flashcards.isEmpty) {
          _state = _state.copyWith(
            viewState: ViewState.error,
            errorMessage: 'Study set has no flashcards',
          );
        } else {
          // Convert flashcards to questions
          final questions = <QuizQuestion>[];

          for (final card in flashcards) {
            // Create options (Correct + up to 3 distractors)
            final otherCards = flashcards
                .where((c) => c.id != card.id)
                .toList();
            otherCards.shuffle();
            final distractors = otherCards
                .take(3)
                .map((c) => c.definition)
                .toList();

            final List<String> options = [card.definition, ...distractors];
            options.shuffle();

            final correctIndex = options.indexOf(card.definition);

            questions.add(
              QuizQuestion(
                id: card.id,
                questionText: card.term,
                options: options,
                correctOptionIndex: correctIndex,
                difficulty: 0.5,
                selectedOptionIndex: null,
              ),
            );
          }

          // Build quiz
          final quiz = Quiz(
            id: 'studyset_${DateTime.now().millisecondsSinceEpoch}',
            subjectId: '', // Not tied to subject ID directly here
            type: QuizType.practice,
            questions: questions,
            startedAt: DateTime.now(),
          );

          _state = _state.copyWith(
            viewState: ViewState.loaded,
            quiz: quiz,
            currentQuestionIndex: 0,
            answers: {},
            isCompleted: false,
            result: null,
          );
        }
        notifyListeners();
      },
      onFailure: (failure) {
        _state = _state.copyWith(
          viewState: ViewState.error,
          errorMessage: failure.message,
        );
        notifyListeners();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Answer Selection
  // ─────────────────────────────────────────────────────────────────────────

  /// Selects an answer for a specific question.
  void selectAnswer(String questionId, int optionIndex) {
    final updatedAnswers = Map<String, int>.from(_state.answers);
    updatedAnswers[questionId] = optionIndex;

    _state = _state.copyWith(answers: updatedAnswers);
    notifyListeners();
  }

  /// Selects an answer for the current question.
  void selectCurrentAnswer(int optionIndex) {
    final question = _state.currentQuestion;
    if (question == null) return;

    selectAnswer(question.id, optionIndex);
  }

  /// Clears the answer for a specific question.
  void clearAnswer(String questionId) {
    final updatedAnswers = Map<String, int>.from(_state.answers);
    updatedAnswers.remove(questionId);

    _state = _state.copyWith(answers: updatedAnswers);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Navigation
  // ─────────────────────────────────────────────────────────────────────────

  /// Moves to the next question.
  void nextQuestion() {
    if (!_state.isLastQuestion) {
      _state = _state.copyWith(
        currentQuestionIndex: _state.currentQuestionIndex + 1,
      );
      notifyListeners();
    }
  }

  /// Moves to the previous question.
  void previousQuestion() {
    if (!_state.isFirstQuestion) {
      _state = _state.copyWith(
        currentQuestionIndex: _state.currentQuestionIndex - 1,
      );
      notifyListeners();
    }
  }

  /// Jumps to a specific question by index.
  void goToQuestion(int index) {
    if (_state.quiz == null) return;
    if (index < 0 || index >= _state.quiz!.questions.length) return;

    _state = _state.copyWith(currentQuestionIndex: index);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Quiz Submission
  // ─────────────────────────────────────────────────────────────────────────

  /// Submits the quiz and calculates results.
  Future<void> submitQuiz() async {
    if (_state.quiz == null || !_state.canSubmit) return;

    _state = _state.copyWith(isSubmitting: true);
    notifyListeners();

    final quiz = _state.quiz!;

    // Calculate score and track per-question results
    int correctCount = 0;
    final Map<String, bool> flashcardResults = {};

    for (final question in quiz.questions) {
      final selectedAnswer = _state.answers[question.id];
      final isCorrect = selectedAnswer == question.correctOptionIndex;
      if (isCorrect) {
        correctCount++;
      }
      // Track result for flashcard progress (question.id is the flashcard id for study set quizzes)
      flashcardResults[question.id] = isCorrect;
    }

    final totalQuestions = quiz.questions.length;
    final scorePercentage = totalQuestions > 0
        ? (correctCount / totalQuestions) * 100
        : 0.0;

    // Build result
    final quizResult = QuizResult(
      correctAnswers: correctCount,
      totalQuestions: totalQuestions,
      scorePercentage: scorePercentage,
      estimatedMastery: scorePercentage / 100,
      aiFeedback:
          'Quiz completed! Score: ${scorePercentage.toStringAsFixed(1)}%',
    );

    // Build completed quiz with result
    final completedQuiz = Quiz(
      id: quiz.id,
      subjectId: quiz.subjectId,
      topicId: quiz.topicId,
      type: quiz.type,
      questions: quiz.questions,
      startedAt: quiz.startedAt,
      completedAt: DateTime.now(),
      result: quizResult,
    );

    // Save to repository
    final saveResult = await _quizRepository.saveQuizResult(completedQuiz);

    await saveResult.fold(
      onSuccess: (_) async {
        // Update flashcard progress if this was a study set quiz
        if (quiz.id.startsWith('studyset_') && flashcardResults.isNotEmpty) {
          await _flashcardRepository.updateFlashcardsProgressBatch(
            flashcardResults,
          );
        }

        // Save as a Focus Session for stats
        final startTime = quiz.startedAt ?? DateTime.now();
        final duration = DateTime.now().difference(startTime).inMinutes;
        final actualMinutes = duration > 0 ? duration : 1; // Minimum 1 minute

        final session = FocusSession(
          id: 'quiz_${DateTime.now().millisecondsSinceEpoch}',
          subjectId: quiz.subjectId,
          startTime: startTime,
          endTime: DateTime.now(),
          plannedMinutes: 0, // Not planned
          actualMinutes: actualMinutes,
          status: FocusSessionStatus.completed,
        );

        await _focusSessionRepository.saveSession(session);

        _state = _state.copyWith(
          isSubmitting: false,
          isCompleted: true,
          result: quizResult,
          quiz: completedQuiz,
        );
        notifyListeners();
      },
      onFailure: (failure) {
        // Still mark as completed locally even if save fails
        _state = _state.copyWith(
          isSubmitting: false,
          isCompleted: true,
          result: quizResult,
          errorMessage: 'Quiz completed but failed to save: ${failure.message}',
        );
        notifyListeners();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Resets the quiz to start over.
  void resetQuiz() {
    _state = _state.copyWith(
      currentQuestionIndex: 0,
      answers: {},
      isCompleted: false,
      result: null,
      errorMessage: null,
    );
    notifyListeners();
  }

  /// Clears all state for a new quiz.
  void clear() {
    _state = const QuizState();
    notifyListeners();
  }

  /// Clears any error message.
  void dismissError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  /// Returns whether a specific question was answered correctly.
  /// Only valid after quiz is completed.
  bool? wasQuestionCorrect(String questionId) {
    if (!_state.isCompleted || _state.quiz == null) return null;

    final question = _state.quiz!.questions.firstWhere(
      (q) => q.id == questionId,
      orElse: () => throw StateError('Question not found'),
    );

    final selectedAnswer = _state.answers[questionId];
    if (selectedAnswer == null) return null;

    return selectedAnswer == question.correctOptionIndex;
  }

  /// Returns list of question indices that were answered incorrectly.
  /// Only valid after quiz is completed.
  List<int> get incorrectQuestionIndices {
    if (!_state.isCompleted || _state.quiz == null) return [];

    final indices = <int>[];
    for (int i = 0; i < _state.quiz!.questions.length; i++) {
      final question = _state.quiz!.questions[i];
      final selectedAnswer = _state.answers[question.id];
      if (selectedAnswer != question.correctOptionIndex) {
        indices.add(i);
      }
    }
    return indices;
  }
}
