/// Insight Card Widget.
/// Displays an AI insight with action button.
/// 
/// Layer: Presentation (Widgets)
/// Responsibility: Reusable AI insight display component.
library;

import 'package:flutter/material.dart';

import 'package:studnet_ai_buddy/domain/entities/ai_insight.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_icons.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';

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
                      style: AppTypography.subtitle1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: insight.isRead
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (!insight.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                insight.message,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      AppIcons.brain,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        insight.reasoning,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textHint,
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
      InsightType.encouragement => (AppIcons.checkAll, AppColors.success),
      InsightType.warning => (AppIcons.alertCircle, AppColors.warning),
      InsightType.suggestion => (AppIcons.lightbulb, AppColors.primary),
      InsightType.milestone => (AppIcons.trendingUp, AppColors.success),
      InsightType.reminder => (AppIcons.bell, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
