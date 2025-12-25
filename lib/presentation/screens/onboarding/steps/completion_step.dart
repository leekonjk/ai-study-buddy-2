/// Completion Step
/// Final onboarding step with statistics.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/chat_bubble.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/mascot_widget.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/onboarding_flow.dart';

/// Completion step with statistics.
class CompletionStep extends StatelessWidget {
  const CompletionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Mascot and message
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MascotWidget(
                expression: MascotExpression.happy,
                size: MascotSize.medium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChatBubble(
                  text: "We are almost done, great job!",
                  isUser: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Statistics cards
          _buildStatCard(
            value: '30+ million',
            label: 'learners on StudySmarter. Join them!',
            color: StudyBuddyColors.primary,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            value: '94%',
            label: 'of users achieve better grades by using our smart learning platform',
            color: StudyBuddyColors.success,
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
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: StudyBuddyDecorations.borderRadiusFull,
                ),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: StudyBuddyColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: StudyBuddyColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

