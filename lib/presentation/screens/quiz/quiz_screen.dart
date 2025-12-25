/// Quiz Screen - Minimal Design.
/// Clean, minimal quiz interface.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/domain/entities/quiz.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/quiz/quiz_viewmodel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/lottie_loading.dart';

class QuizScreen extends StatelessWidget {
  final String? subjectId;
  final String? topic;
  final int? questionCount;
  final double? difficulty;

  const QuizScreen({
    super.key,
    this.subjectId,
    this.topic,
    this.questionCount,
    this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<QuizViewModel>(
      create: (_) {
        final vm = getIt<QuizViewModel>();
        if (subjectId != null) {
          if (topic != null || difficulty != null) {
            vm.loadCustomQuiz(
              subjectId: subjectId!,
              topic: topic,
              difficulty: difficulty ?? 0.5,
              count: questionCount ?? 10,
            );
          } else {
            vm.loadDiagnosticQuiz(subjectId!);
          }
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.quiz?.templateName ?? 'Quiz',
              style: AppTypography.headline3,
            ),
            if (state.quiz?.difficulty != null)
              Text(
                state.quiz!.difficulty!.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: _getDifficultyColor(state.quiz!.difficulty!),
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: AppColors.textPrimary,
          onPressed: () => _showExitDialog(context),
        ),
        actions: [
          if (!state.isCompleted && state.quiz?.timeLimitMinutes != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: _Timer(
                  timeLimitMinutes: state.quiz!.timeLimitMinutes!,
                  startedAt: state.quiz!.startedAt ?? DateTime.now(),
                ),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '${state.answeredCount}/${state.totalQuestions}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
      return const LottieLoading(size: 100);
    }

    if (state.hasError) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () => Navigator.of(context).pop(),
      );
    }

    if (state.isCompleted && state.result != null) {
      return _ResultView(result: state.result!, quiz: state.quiz);
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
        content: const Text('Your progress will be lost.'),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

/// Minimal quiz view.
class _QuizView extends StatelessWidget {
  final QuizState state;

  const _QuizView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: state.progress,
          backgroundColor: AppColors.border,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 3,
        ),

        // Question content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${state.currentQuestionIndex + 1} of ${state.totalQuestions}',
                  style: AppTypography.body2,
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.currentQuestion != null)
                  _QuestionCard(question: state.currentQuestion!),
                const SizedBox(height: AppSpacing.lg),
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
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Row(
            children: [
              if (!state.isFirstQuestion)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        context.read<QuizViewModel>().previousQuestion(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    child: const Text('Previous'),
                  ),
                ),
              if (!state.isFirstQuestion) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          if (state.isLastQuestion) {
                            if (state.canSubmit) {
                              context.read<QuizViewModel>().submitQuiz();
                            }
                          } else {
                            context.read<QuizViewModel>().nextQuestion();
                          }
                        },
                  child: state.isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(state.isLastQuestion ? 'Submit' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Minimal question card.
class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(question.questionText, style: AppTypography.subtitle1),
    );
  }
}

/// Minimal answer options.
class _AnswerOptions extends StatelessWidget {
  final QuizQuestion question;
  final int? selectedIndex;

  const _AnswerOptions({required this.question, this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final isSelected = selectedIndex == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: InkWell(
            onTap: () =>
                context.read<QuizViewModel>().selectCurrentAnswer(index),
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: AppTypography.subtitle2.copyWith(
                          color: isSelected
                              ? AppColors.textInverse
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      question.options[index],
                      style: AppTypography.body1.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ).animate().scale(
                      begin: const Offset(0, 0),
                      end: const Offset(1, 1),
                      duration: 200.ms,
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Minimal timer.
class _Timer extends StatefulWidget {
  final int timeLimitMinutes;
  final DateTime startedAt;

  const _Timer({required this.timeLimitMinutes, required this.startedAt});

  @override
  State<_Timer> createState() => _TimerState();
}

class _TimerState extends State<_Timer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = Duration(minutes: widget.timeLimitMinutes);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _remaining =
              Duration(minutes: widget.timeLimitMinutes) -
              DateTime.now().difference(widget.startedAt);
          if (_remaining.isNegative) {
            _remaining = Duration.zero;
            context.read<QuizViewModel>().submitQuiz();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    final color = _remaining.inMinutes < 2
        ? AppColors.error
        : _remaining.inMinutes < 5
        ? AppColors.warning
        : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
        style: AppTypography.caption.copyWith(
          color: AppColors.textInverse,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Minimal result view.
class _ResultView extends StatelessWidget {
  final QuizResult result;
  final Quiz? quiz;

  const _ResultView({required this.result, this.quiz});

  @override
  Widget build(BuildContext context) {
    final score = result.scorePercentage.toInt();
    final color = score >= 80
        ? AppColors.success
        : score >= 60
        ? AppColors.warning
        : AppColors.error;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color, width: 4),
            ),
            child: Center(
              child: Text(
                '$score%',
                style: AppTypography.headline1.copyWith(color: color),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(_getTitle(score), style: AppTypography.headline2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${result.correctAnswers} of ${result.totalQuestions} correct',
            style: AppTypography.body2,
          ),
          if (quiz?.passingScore != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: score >= (quiz!.passingScore! * 100)
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: score >= (quiz!.passingScore! * 100)
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    score >= (quiz!.passingScore! * 100)
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: score >= (quiz!.passingScore! * 100)
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    score >= (quiz!.passingScore! * 100)
                        ? 'Passed'
                        : 'Not Passed',
                    style: AppTypography.body2.copyWith(
                      fontWeight: FontWeight.w600,
                      color: score >= (quiz!.passingScore! * 100)
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  String _getTitle(int score) {
    if (score >= 90) return 'Excellent!';
    if (score >= 80) return 'Great Job!';
    if (score >= 70) return 'Good Work!';
    if (score >= 60) return 'Not Bad!';
    return 'Keep Practicing!';
  }
}

/// Error view.
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTypography.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onRetry, child: const Text('Go Back')),
          ],
        ),
      ),
    );
  }
}

/// No quiz view.
class _NoQuizView extends StatelessWidget {
  const _NoQuizView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz_outlined,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No quiz available', style: AppTypography.headline2),
            const SizedBox(height: AppSpacing.sm),
            Text('Please select a subject', style: AppTypography.body2),
            const SizedBox(height: AppSpacing.lg),
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
