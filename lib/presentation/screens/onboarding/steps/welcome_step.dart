/// Welcome Step
/// First step of onboarding with mascot greeting.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/mascot_widget.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/onboarding_flow.dart';

/// Welcome step for onboarding.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MascotWidget(
            expression: MascotExpression.happy,
            size: MascotSize.large,
          ),
          const SizedBox(height: 32),
          const Text(
            "Let's get started!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: StudyBuddyColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            "I'll help you set up your study profile and get you ready to learn smarter.",
            style: TextStyle(
              fontSize: 16,
              color: StudyBuddyColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final controller = OnboardingStepController.of(context);
                controller?.onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StudyBuddyColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: StudyBuddyDecorations.borderRadiusFull,
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              final controller = OnboardingStepController.of(context);
              controller?.onSkip();
            },
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 14,
                color: StudyBuddyColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

