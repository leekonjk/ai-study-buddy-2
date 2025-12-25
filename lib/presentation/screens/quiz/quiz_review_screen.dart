/// Quiz Review Screen
/// Shows detailed review of quiz answers with explanations.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Demo question data for review.
class ReviewQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final int? selectedIndex;
  final String? explanation;

  const ReviewQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    this.selectedIndex,
    this.explanation,
  });

  bool get isCorrect => selectedIndex == correctIndex;
  bool get isAnswered => selectedIndex != null;
}

/// Screen to review quiz answers after completion.
class QuizReviewScreen extends StatefulWidget {
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final List<ReviewQuestion>? questions;

  const QuizReviewScreen({
    super.key,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    this.questions,
  });

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  String _filter = 'All';

  // Demo data
  late List<ReviewQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions ?? _generateDemoQuestions();
  }

  List<ReviewQuestion> _generateDemoQuestions() {
    return [
      const ReviewQuestion(
        question: 'What is the powerhouse of the cell?',
        options: ['Nucleus', 'Mitochondria', 'Ribosome', 'Golgi Apparatus'],
        correctIndex: 1,
        selectedIndex: 1,
        explanation:
            'Mitochondria are known as the powerhouse of the cell because they generate most of the cell\'s supply of ATP, used as a source of chemical energy.',
      ),
      const ReviewQuestion(
        question:
            'What is the process by which plants convert sunlight into food?',
        options: ['Respiration', 'Fermentation', 'Photosynthesis', 'Osmosis'],
        correctIndex: 2,
        selectedIndex: 2,
        explanation:
            'Photosynthesis is the process used by plants to convert light energy into chemical energy stored in glucose.',
      ),
      const ReviewQuestion(
        question: 'Which organelle contains the cell\'s genetic material?',
        options: ['Cytoplasm', 'Cell Membrane', 'Nucleus', 'Vacuole'],
        correctIndex: 2,
        selectedIndex: 0,
        explanation:
            'The nucleus contains the cell\'s DNA, which carries the genetic information that controls cell activities.',
      ),
      const ReviewQuestion(
        question: 'What type of bond holds water molecules together?',
        options: [
          'Ionic Bond',
          'Covalent Bond',
          'Hydrogen Bond',
          'Metallic Bond',
        ],
        correctIndex: 2,
        selectedIndex: 2,
        explanation:
            'Hydrogen bonds form between water molecules due to the polarity of water, creating cohesion and surface tension.',
      ),
      const ReviewQuestion(
        question: 'What is the basic unit of life?',
        options: ['Atom', 'Molecule', 'Cell', 'Organ'],
        correctIndex: 2,
        selectedIndex: 1,
        explanation:
            'The cell is the basic structural and functional unit of all living organisms.',
      ),
    ];
  }

  List<ReviewQuestion> get _filteredQuestions {
    switch (_filter) {
      case 'Correct':
        return _questions.where((q) => q.isCorrect).toList();
      case 'Incorrect':
        return _questions.where((q) => !q.isCorrect).toList();
      default:
        return _questions;
    }
  }

  int get _correctCount => _questions.where((q) => q.isCorrect).length;
  int get _incorrectCount => _questions.where((q) => !q.isCorrect).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: StudyBuddyColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Score summary
              _buildScoreSummary(),

              // Filter tabs
              _buildFilterTabs(),

              // Questions list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _filteredQuestions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(index, _filteredQuestions[index])
                        .animate()
                        .fadeIn(delay: (index * 50).ms)
                        .slideX(begin: 0.05, end: 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StudyBuddyColors.cardBackground,
                borderRadius: StudyBuddyDecorations.borderRadiusS,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: StudyBuddyColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review Answers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                Text(
                  widget.quizTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: StudyBuddyColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary() {
    final percentage = (_correctCount / _questions.length * 100).toInt();
    final color = percentage >= 70
        ? StudyBuddyColors.success
        : percentage >= 50
        ? StudyBuddyColors.warning
        : StudyBuddyColors.error;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  percentage >= 70
                      ? 'Great Job! 🎉'
                      : percentage >= 50
                      ? 'Good Effort! 💪'
                      : 'Keep Practicing! 📚',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_correctCount correct, $_incorrectCount incorrect',
                  style: const TextStyle(
                    fontSize: 14,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildFilterTab('All', _questions.length),
          const SizedBox(width: 8),
          _buildFilterTab('Correct', _correctCount, StudyBuddyColors.success),
          const SizedBox(width: 8),
          _buildFilterTab('Incorrect', _incorrectCount, StudyBuddyColors.error),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, int count, [Color? color]) {
    final isSelected = _filter == label;
    final tabColor = color ?? StudyBuddyColors.primary;

    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? tabColor.withValues(alpha: 0.2)
              : StudyBuddyColors.cardBackground,
          borderRadius: StudyBuddyDecorations.borderRadiusFull,
          border: Border.all(
            color: isSelected ? tabColor : StudyBuddyColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? tabColor : StudyBuddyColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? tabColor.withValues(alpha: 0.3)
                    : StudyBuddyColors.border,
                borderRadius: StudyBuddyDecorations.borderRadiusFull,
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? tabColor : StudyBuddyColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, ReviewQuestion question) {
    final isCorrect = question.isCorrect;
    final questionNumber = _questions.indexOf(question) + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(
          color: isCorrect
              ? StudyBuddyColors.success.withValues(alpha: 0.3)
              : StudyBuddyColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCorrect
                  ? StudyBuddyColors.success.withValues(alpha: 0.1)
                  : StudyBuddyColors.error.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? StudyBuddyColors.success
                        : StudyBuddyColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isCorrect ? Icons.check_rounded : Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Question $questionNumber',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCorrect
                        ? StudyBuddyColors.success
                        : StudyBuddyColors.error,
                  ),
                ),
              ],
            ),
          ),

          // Question text
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: StudyBuddyColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),

          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                question.options.length,
                (optionIndex) => _buildOption(question, optionIndex),
              ),
            ),
          ),

          // Explanation
          if (question.explanation != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StudyBuddyColors.primary.withValues(alpha: 0.1),
                borderRadius: StudyBuddyDecorations.borderRadiusM,
                border: Border.all(
                  color: StudyBuddyColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    size: 18,
                    color: StudyBuddyColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: StudyBuddyColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOption(ReviewQuestion question, int optionIndex) {
    final isSelected = question.selectedIndex == optionIndex;
    final isCorrectOption = question.correctIndex == optionIndex;

    Color? backgroundColor;
    Color? borderColor;
    Color textColor = StudyBuddyColors.textSecondary;
    IconData? icon;

    if (isCorrectOption) {
      backgroundColor = StudyBuddyColors.success.withValues(alpha: 0.1);
      borderColor = StudyBuddyColors.success;
      textColor = StudyBuddyColors.success;
      icon = Icons.check_rounded;
    } else if (isSelected && !isCorrectOption) {
      backgroundColor = StudyBuddyColors.error.withValues(alpha: 0.1);
      borderColor = StudyBuddyColors.error;
      textColor = StudyBuddyColors.error;
      icon = Icons.close_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: StudyBuddyDecorations.borderRadiusM,
        border: Border.all(color: borderColor ?? StudyBuddyColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  borderColor?.withValues(alpha: 0.2) ??
                  StudyBuddyColors.border.withValues(alpha: 0.3),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 14, color: borderColor)
                  : Text(
                      String.fromCharCode(65 + optionIndex), // A, B, C, D
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question.options[optionIndex],
              style: TextStyle(
                fontSize: 14,
                color: isCorrectOption || isSelected
                    ? textColor
                    : StudyBuddyColors.textSecondary,
                fontWeight: isCorrectOption ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
