/// Task Card Widget.
/// Displays a study task with completion action.
/// 
/// Layer: Presentation (Widgets)
/// Responsibility: Reusable task display component.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/core/theme/app_theme.dart';
import 'package:studnet_ai_buddy/core/utils/date_utils.dart';
import 'package:studnet_ai_buddy/domain/entities/study_task.dart';

class TaskCard extends StatelessWidget {
  final StudyTask task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final bool showReasoning;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.showReasoning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPriorityIndicator(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? AppTheme.textMuted
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (!task.isCompleted && onComplete != null)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: onComplete,
                      color: AppTheme.successColor,
                    ),
                  if (task.isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChip(
                    AppDateUtils.formatDuration(task.estimatedMinutes),
                    Icons.timer_outlined,
                  ),
                  const SizedBox(width: 8),
                  _buildChip(
                    task.type.name,
                    Icons.category_outlined,
                  ),
                ],
              ),
              if (showReasoning) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.aiReasoning,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    final color = switch (task.priority) {
      TaskPriority.critical => AppTheme.errorColor,
      TaskPriority.high => AppTheme.warningColor,
      TaskPriority.medium => AppTheme.accentColor,
      TaskPriority.low => AppTheme.textMuted,
    };

    return Container(
      width: 4,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
