/// Name Step
/// Collects user's name in onboarding.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/chat_bubble.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/mascot_widget.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/onboarding_flow.dart';

/// Name collection step.
class NameStep extends StatefulWidget {
  const NameStep({super.key});

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
                expression: MascotExpression.speaking,
                size: MascotSize.medium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChatBubble(
                  text: "What's your name?",
                  isUser: false,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Input
          TextField(
            controller: _nameController,
            style: const TextStyle(color: StudyBuddyColors.textPrimary),
            decoration: StudyBuddyDecorations.inputDecoration(
              hintText: 'Enter your name',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: StudyBuddyColors.textSecondary,
              ),
            ),
            onSubmitted: (_) => _handleNext(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nameController.text.trim().isNotEmpty
                  ? _handleNext
                  : null,
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
        ],
      ),
    );
  }

  void _handleNext() {
    if (_nameController.text.trim().isNotEmpty) {
      final controller = OnboardingStepController.of(context);
      controller?.onUpdateData('name', _nameController.text.trim());
      controller?.onNext();
    }
  }
}

