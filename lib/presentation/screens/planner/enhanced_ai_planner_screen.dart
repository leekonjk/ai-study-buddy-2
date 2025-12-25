/// Enhanced AI Planner Screen
/// AI-powered study planning interface.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studnet_ai_buddy/di/service_locator.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/viewmodels/base_viewmodel.dart'; // For ViewState
import 'package:studnet_ai_buddy/presentation/viewmodels/planner/ai_planner_viewmodel.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';
import 'package:intl/intl.dart';

/// AI-enhanced study planner screen.
class EnhancedAIPlannerScreen extends StatefulWidget {
  const EnhancedAIPlannerScreen({super.key});

  @override
  State<EnhancedAIPlannerScreen> createState() =>
      _EnhancedAIPlannerScreenState();
}

class _EnhancedAIPlannerScreenState extends State<EnhancedAIPlannerScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AIPlannerViewModel>(
      create: (_) => getIt<AIPlannerViewModel>()..loadPlan(),
      child: const _PlannerContent(),
    );
  }
}

class _PlannerContent extends StatelessWidget {
  const _PlannerContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AIPlannerViewModel>();
    final state = viewModel.state;

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

              if (state.viewState == ViewState.loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.viewState == ViewState.error)
                Expanded(
                  child: Center(
                    child: Text(
                      'Error: ${state.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else
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
                                StudyBuddyColors.primary.withValues(alpha: 0.2),
                                StudyBuddyColors.secondary.withValues(
                                  alpha: 0.1,
                                ),
                              ],
                            ),
                            borderRadius: StudyBuddyDecorations.borderRadiusL,
                            border: Border.all(
                              color: StudyBuddyColors.primary.withValues(
                                alpha: 0.3,
                              ),
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
                                      color: StudyBuddyColors.primary
                                          .withValues(alpha: 0.2),
                                      borderRadius:
                                          StudyBuddyDecorations.borderRadiusS,
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
                              Text(
                                state.aiRecommendation,
                                style: const TextStyle(
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

                        if (state.tasks.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text("No tasks for today. Good job!"),
                            ),
                          )
                        else
                          ...state.tasks.map((task) => _buildTaskCard(task)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: StudyBuddyColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: StudyBuddyColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Study Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: StudyBuddyColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Task Title',
                labelStyle: const TextStyle(
                  color: StudyBuddyColors.textSecondary,
                ),
                filled: true,
                fillColor: StudyBuddyColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task added to your study plan!'),
                      backgroundColor: StudyBuddyColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: StudyBuddyColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Task',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(StudyTask task) {
    Color color = StudyBuddyColors.primary;
    IconData icon = Icons.menu_book_rounded;

    // Pick color/icon based on priority/type if feasible
    if (task.type == TaskType.quiz) {
      color = StudyBuddyColors.warning;
      icon = Icons.quiz_rounded;
    } else if (task.priority == TaskPriority.high) {
      color = StudyBuddyColors.error;
    }

    final timeString = DateFormat('h:mm a').format(task.date);
    // Estimated end time?
    final end = task.date.add(Duration(minutes: task.estimatedMinutes));
    final timeRange = "$timeString - ${DateFormat('h:mm a').format(end)}";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          borderRadius: StudyBuddyDecorations.borderRadiusL,
          border: Border.all(
            color: task.isCompleted
                ? StudyBuddyColors.success.withValues(alpha: 0.3)
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
                color: task.isCompleted
                    ? StudyBuddyColors.success
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted
                      ? StudyBuddyColors.success
                      : StudyBuddyColors.border,
                  width: 2,
                ),
              ),
              child: task.isCompleted
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
                color: color.withValues(alpha: 0.1),
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
                    task.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: task.isCompleted
                          ? StudyBuddyColors.textTertiary
                          : StudyBuddyColors.textPrimary,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeRange,
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
