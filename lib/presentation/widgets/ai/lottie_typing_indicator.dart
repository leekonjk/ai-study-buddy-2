/// Lottie Typing Indicator Widget
/// Animated typing indicator for AI chat responses.
library;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';

/// Animated typing indicator using Lottie animation.
/// Use this when AI is "thinking" or generating a response.
class LottieTypingIndicator extends StatelessWidget {
  final double size;

  const LottieTypingIndicator({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size * 0.6,
              child: Lottie.asset(
                'lib/assets/animations/Chat typing indicator.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AI is thinking...',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
