/// Goals Step
/// Collects study goals from user.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/chat_bubble.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/mascot_widget.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/onboarding_flow.dart';

/// Study goals collection step.
class GoalsStep extends StatefulWidget {
  const GoalsStep({super.key});

  @override
  State<GoalsStep> createState() => _GoalsStepState();
}

class _GoalsStepState extends State<GoalsStep> {
  final List<String> _selectedGoals = [];

  final List<String> _availableGoals = [
    'Improve grades',
    'Prepare for exams',
    'Master specific topics',
    'Build study habits',
    'Track progress',
  ];

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
                  text: "What are your main study goals? Select all that apply.",
                  isUser: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Goal options
          Expanded(
            child: ListView.builder(
              itemCount: _availableGoals.length,
              itemBuilder: (context, index) {
                final goal = _availableGoals[index];
                final isSelected = _selectedGoals.contains(goal);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedGoals.remove(goal);
                        } else {
                          _selectedGoals.add(goal);
                        }
                      });
                    },
                    borderRadius: StudyBuddyDecorations.borderRadiusL,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? StudyBuddyColors.primary.withValues(alpha: 0.1)
                            : StudyBuddyColors.cardBackground,
                        borderRadius: StudyBuddyDecorations.borderRadiusL,
                        border: Border.all(
                          color: isSelected
                              ? StudyBuddyColors.primary
                              : StudyBuddyColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            color: isSelected
                                ? StudyBuddyColors.primary
                                : StudyBuddyColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              goal,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected
                                    ? StudyBuddyColors.primary
                                    : StudyBuddyColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedGoals.isNotEmpty ? _handleNext : null,
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
    if (_selectedGoals.isNotEmpty) {
      final controller = OnboardingStepController.of(context);
      controller?.onUpdateData('goals', _selectedGoals);
      controller?.onNext();
    }
  }
}

