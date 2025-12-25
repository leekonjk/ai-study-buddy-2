/// Error View Widget.
/// Reusable error display with retry option.
/// 
/// Layer: Presentation (Widgets)
/// Responsibility: Consistent error UI across the app.
library;

import 'package:flutter/material.dart';

import 'package:studnet_ai_buddy/presentation/theme/app_icons.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.alertCircle,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
                child: Text('Retry', style: AppTypography.button),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
