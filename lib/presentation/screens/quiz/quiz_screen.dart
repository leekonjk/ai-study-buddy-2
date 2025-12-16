/// Quiz Screen.
/// Displays diagnostic and adaptive quiz interface.
/// 
/// Layer: Presentation (UI)
/// Responsibility: Quiz flow, question display, answer selection.
/// Binds to: QuizViewModel
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/entities/quiz.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/quiz/quiz_viewmodel.dart';

class QuizScreen extends StatelessWidget {
  final String? subjectId;

  const QuizScreen({super.key, this.subjectId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuizViewModel>(
      create: (_) {
        final vm = getIt<QuizViewModel>();
        if (subjectId != null) {
          vm.loadDiagnosticQuiz(subjectId!);
        }
        return vm;
      },
      child: const _QuizContent(),
    );
  }
}

class _QuizContent extends StatelessWidget {
  const _QuizContent();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<QuizViewModel>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.quiz?.subjectId ?? 'Quiz'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          if (!state.isCompleted)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${state.answeredCount}/${state.totalQuestions}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(context, state),
    );
  }

  Widget _buildBody(BuildContext context, QuizState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () => context.read<QuizViewModel>().dismissError(),
      );
    }

    if (state.isCompleted && state.result != null) {
      return _ResultView(result: state.result!);
    }

    if (state.quiz == null) {
      return const _NoQuizView();
    }

    return _QuizView(state: state);
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost if you exit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoQuizView extends StatelessWidget {
  const _NoQuizView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No quiz available',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Please select a subject to start a quiz',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}

class _QuizView extends StatelessWidget {
  final QuizState state;

  const _QuizView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        _ProgressBar(progress: state.progress),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question number
                Text(
                  'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestions}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),

                // Question text
                if (state.currentQuestion != null)
                  _QuestionCard(question: state.currentQuestion!),

                const SizedBox(height: 24),

                // Answer options
                if (state.currentQuestion != null)
                  _AnswerOptions(
                    question: state.currentQuestion!,
                    selectedIndex: state.currentSelectedAnswer,
                  ),
              ],
            ),
          ),
        ),

        // Navigation buttons
        _NavigationButtons(
          isFirstQuestion: state.isFirstQuestion,
          isLastQuestion: state.isLastQuestion,
          canSubmit: state.canSubmit,
          isSubmitting: state.isSubmitting,
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey[200],
      minHeight: 4,
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(question.difficulty),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getDifficultyLabel(question.difficulty),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(double difficulty) {
    if (difficulty < 0.4) return Colors.green;
    if (difficulty < 0.7) return Colors.orange;
    return Colors.red;
  }

  String _getDifficultyLabel(double difficulty) {
    if (difficulty < 0.4) return 'Easy';
    if (difficulty < 0.7) return 'Medium';
    return 'Hard';
  }
}

class _AnswerOptions extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedIndex;

  const _AnswerOptions({
    required this.question,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final option = question.options[index];
        final isSelected = selectedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _OptionCard(
            label: String.fromCharCode(65 + index), // A, B, C, D
            text: option,
            isSelected: isSelected,
            onTap: () => context.read<QuizViewModel>().selectCurrentAnswer(index),
          ),
        );
      }),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : null,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  final bool isFirstQuestion;
  final bool isLastQuestion;
  final bool canSubmit;
  final bool isSubmitting;

  const _NavigationButtons({
    required this.isFirstQuestion,
    required this.isLastQuestion,
    required this.canSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirstQuestion)
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.read<QuizViewModel>().previousQuestion(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (!isFirstQuestion) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      if (isLastQuestion) {
                        if (canSubmit) {
                          context.read<QuizViewModel>().submitQuiz();
                        } else {
                          _showIncompleteDialog(context);
                        }
                      } else {
                        context.read<QuizViewModel>().nextQuestion();
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isLastQuestion ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _showIncompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Incomplete Quiz'),
        content: const Text('Please answer all questions before submitting.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final QuizResult result;

  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(result.scorePercentage);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Score circle
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withOpacity(0.1),
              border: Border.all(color: scoreColor, width: 8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${result.scorePercentage.toInt()}%',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                  ),
                  Text(
                    'Score',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Result summary
          Text(
            _getResultTitle(result.scorePercentage),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          Text(
            '${result.correctAnswers} out of ${result.totalQuestions} correct',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),

          const SizedBox(height: 32),

          // AI Feedback
          if (result.aiFeedback.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'AI Feedback',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.aiFeedback,
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),

          // Action buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Done'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                context.read<QuizViewModel>().resetQuiz();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getResultTitle(double score) {
    if (score >= 90) return 'Excellent!';
    if (score >= 80) return 'Great Job!';
    if (score >= 70) return 'Good Work!';
    if (score >= 60) return 'Not Bad!';
    return 'Keep Practicing!';
  }
}
