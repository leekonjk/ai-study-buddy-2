/// Insight Card Widget.
/// Displays an AI insight with action button.
/// 
/// Layer: Presentation (Widgets)
/// Responsibility: Reusable AI insight display component.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/core/theme/app_theme.dart';
import 'package:studnet_ai_buddy/domain/entities/ai_insight.dart';

class InsightCard extends StatelessWidget {
  final AIInsight insight;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  const InsightCard({
    super.key,
    required this.insight,
    this.onTap,
    this.onActionTap,
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
                  _buildTypeIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: insight.isRead
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (!insight.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                insight.message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
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
                      Icons.psychology_outlined,
                      size: 16,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.reasoning,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (insight.actionLabel != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onActionTap,
                    child: Text(insight.actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    final (icon, color) = switch (insight.type) {
      InsightType.encouragement => (Icons.celebration, AppTheme.successColor),
      InsightType.warning => (Icons.warning_amber, AppTheme.warningColor),
      InsightType.suggestion => (Icons.lightbulb_outline, AppTheme.accentColor),
      InsightType.milestone => (Icons.emoji_events, AppTheme.successColor),
      InsightType.reminder => (Icons.notifications_outlined, AppTheme.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
