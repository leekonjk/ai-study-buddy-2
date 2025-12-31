/// Lottie Loading Widget
/// Animated loading indicator using Lottie.
library;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';

/// Loading widget with Lottie animation.
/// Use for initial data loading states - not for every loading spinner.
class LottieLoading extends StatelessWidget {
  final double size;
  final String? message;

  const LottieLoading({super.key, this.size = 100, this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Lottie.asset(
            'lib/assets/animations/Loading 40 _ Paperplane (3).json',
            fit: BoxFit.contain,
            repeat: true,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: const TextStyle(
              fontSize: 14,
              color: StudyBuddyColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
