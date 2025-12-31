import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';

/// Enhanced statistics card with gradient background
class EnhancedStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color primaryColor;
  final Color? secondaryColor;

  const EnhancedStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final gradientEnd = secondaryColor ?? primaryColor.withValues(alpha: 0.6);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 200),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withValues(alpha: 0.15),
              gradientEnd.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: primaryColor, size: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: AppTypography.headline2.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.body2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
