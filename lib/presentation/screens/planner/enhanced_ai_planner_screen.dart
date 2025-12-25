/// Enhanced AI Planner Screen
/// AI-powered study planning interface.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// AI-enhanced study planner screen.
class EnhancedAIPlannerScreen extends StatefulWidget {
  const EnhancedAIPlannerScreen({super.key});

  @override
  State<EnhancedAIPlannerScreen> createState() => _EnhancedAIPlannerScreenState();
}

class _EnhancedAIPlannerScreenState extends State<EnhancedAIPlannerScreen> {
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
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
                      'AI Study Planner',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: StudyBuddyColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AI Suggestion Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              StudyBuddyColors.primary.withOpacity(0.2),
                              StudyBuddyColors.secondary.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: StudyBuddyDecorations.borderRadiusL,
                          border: Border.all(
                            color: StudyBuddyColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: StudyBuddyColors.primary.withOpacity(0.2),
                                    borderRadius: StudyBuddyDecorations.borderRadiusS,
                                  ),
                                  child: const Icon(
                                    Icons.psychology_rounded,
                                    color: StudyBuddyColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'AI Recommendation',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: StudyBuddyColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Based on your upcoming exam and current progress, I recommend focusing on Chapter 5 today. You've mastered 80% of the previous chapters!",
                              style: TextStyle(
                                fontSize: 14,
                                color: StudyBuddyColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Today's Tasks
                      const Text(
                        "Today's Study Plan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: StudyBuddyColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTaskCard(
                        title: 'Review Calculus Chapter 5',
                        time: '9:00 AM - 10:30 AM',
                        icon: Icons.menu_book_rounded,
                        color: StudyBuddyColors.primary,
                        isCompleted: true,
                      ),
                      _buildTaskCard(
                        title: 'Practice Physics Problems',
                        time: '11:00 AM - 12:00 PM',
                        icon: Icons.quiz_rounded,
                        color: StudyBuddyColors.warning,
                        isCompleted: false,
                      ),
                      _buildTaskCard(
                        title: 'Flashcard Review: Chemistry',
                        time: '2:00 PM - 2:30 PM',
                        icon: Icons.style_rounded,
                        color: StudyBuddyColors.secondary,
                        isCompleted: false,
                      ),
                      _buildTaskCard(
                        title: 'Biology Quiz Practice',
                        time: '3:00 PM - 4:00 PM',
                        icon: Icons.science_rounded,
                        color: StudyBuddyColors.success,
                        isCompleted: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add task
        },
        backgroundColor: StudyBuddyColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Task',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
    required bool isCompleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          borderRadius: StudyBuddyDecorations.borderRadiusL,
          border: Border.all(
            color: isCompleted
                ? StudyBuddyColors.success.withOpacity(0.3)
                : StudyBuddyColors.border,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? StudyBuddyColors.success
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? StudyBuddyColors.success
                      : StudyBuddyColors.border,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: StudyBuddyDecorations.borderRadiusS,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isCompleted
                          ? StudyBuddyColors.textTertiary
                          : StudyBuddyColors.textPrimary,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

