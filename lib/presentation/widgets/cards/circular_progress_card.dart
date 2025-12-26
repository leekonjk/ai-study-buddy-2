import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';

/// Modern statistic card with circular progress indicator
class CircularProgressCard extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final IconData icon;
  final Color color;
  final Color? backgroundColor;

  const CircularProgressCard({
    super.key,
    required this.label,
    required this.current,
    required this.target,
    required this.icon,
    required this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 8.0,
            percent: percentage,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 4),
                Text(
                  '${(percentage * 100).toInt()}%',
                  style: AppTypography.headline3.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            progressColor: color,
            backgroundColor: color.withValues(alpha: 0.2),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1200,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: '$current',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' / $target',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
