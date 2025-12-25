/// Quiz Setup Screen
/// Configure quiz settings before starting.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/screens/quiz/quiz_screen.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Screen for setting up quiz parameters.
class QuizSetupScreen extends StatefulWidget {
  final String? subjectId;

  const QuizSetupScreen({super.key, this.subjectId});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int _questionCount = 10;
  String _difficulty = 'medium';
  bool _timedMode = true;

  void _startQuiz() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(subjectId: widget.subjectId ?? ''),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: StudyBuddyColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Quiz Setup',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Question count
                const Text(
                  'Number of Questions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [5, 10, 15, 20].map((count) {
                    final isSelected = _questionCount == count;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _questionCount = count;
                            });
                          },
                          borderRadius: StudyBuddyDecorations.borderRadiusM,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? StudyBuddyColors.primary
                                  : StudyBuddyColors.cardBackground,
                              borderRadius: StudyBuddyDecorations.borderRadiusM,
                              border: Border.all(
                                color: isSelected
                                    ? StudyBuddyColors.primary
                                    : StudyBuddyColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : StudyBuddyColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Difficulty
                const Text(
                  'Difficulty',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildDifficultyOption(
                      'Easy',
                      'easy',
                      StudyBuddyColors.success,
                    ),
                    const SizedBox(width: 12),
                    _buildDifficultyOption(
                      'Medium',
                      'medium',
                      StudyBuddyColors.warning,
                    ),
                    const SizedBox(width: 12),
                    _buildDifficultyOption(
                      'Hard',
                      'hard',
                      StudyBuddyColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Timed mode
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: StudyBuddyDecorations.cardDecoration,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_rounded,
                        color: StudyBuddyColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Timed Mode',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: StudyBuddyColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Answer each question within a time limit',
                              style: TextStyle(
                                fontSize: 14,
                                color: StudyBuddyColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _timedMode,
                        onChanged: (value) {
                          setState(() {
                            _timedMode = value;
                          });
                        },
                        activeThumbColor: StudyBuddyColors.primary,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _startQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StudyBuddyColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: StudyBuddyDecorations.borderRadiusFull,
                      ),
                    ),
                    child: const Text(
                      'Start Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(String label, String value, Color color) {
    final isSelected = _difficulty == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _difficulty = value;
          });
        },
        borderRadius: StudyBuddyDecorations.borderRadiusM,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : StudyBuddyColors.cardBackground,
            borderRadius: StudyBuddyDecorations.borderRadiusM,
            border: Border.all(
              color: isSelected ? color : StudyBuddyColors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : StudyBuddyColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
