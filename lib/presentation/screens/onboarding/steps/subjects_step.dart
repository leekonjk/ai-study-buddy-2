/// Subjects Step
/// Collects the list of subjects the student is taking.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/chat_bubble.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/mascot_widget.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/onboarding_flow.dart';

/// Subject collection step.
class SubjectsStep extends StatefulWidget {
  const SubjectsStep({super.key});

  @override
  State<SubjectsStep> createState() => _SubjectsStepState();
}

class _SubjectsStepState extends State<SubjectsStep> {
  final _subjectController = TextEditingController();
  final List<String> _subjects = [];

  @override
  void dispose() {
    _subjectController.dispose();
    super.dispose();
  }

  void _addSubject() {
    final subject = _subjectController.text.trim();
    if (subject.isNotEmpty && !_subjects.contains(subject)) {
      setState(() {
        _subjects.add(subject);
        _subjectController.clear();
      });
    }
  }

  void _removeSubject(String subject) {
    setState(() {
      _subjects.remove(subject);
    });
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
                expression: MascotExpression.thinking,
                size: MascotSize.medium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChatBubble(
                  text:
                      "What subjects are you taking this semester? Add them below so I can help you plan.",
                  isUser: false,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Added Subjects Chips
          if (_subjects.isNotEmpty)
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(bottom: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _subjects
                    .map(
                      (subject) => Chip(
                        label: Text(subject),
                        backgroundColor: StudyBuddyColors.secondary.withValues(
                          alpha: 0.2,
                        ),
                        labelStyle: const TextStyle(
                          color: StudyBuddyColors.textPrimary,
                        ),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeSubject(subject),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

          // Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _subjectController,
                  style: const TextStyle(color: StudyBuddyColors.textPrimary),
                  decoration: StudyBuddyDecorations.inputDecoration(
                    hintText: 'Add a subject (e.g. Calculus)',
                    prefixIcon: const Icon(
                      Icons.book_outlined,
                      color: StudyBuddyColors.textSecondary,
                    ),
                  ),
                  onSubmitted: (_) => _addSubject(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addSubject,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: StudyBuddyColors.accent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _subjects.isNotEmpty ? _handleNext : null,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_subjects.isNotEmpty) {
      final controller = OnboardingStepController.of(context);
      controller?.onUpdateData('subjects', _subjects);
      controller?.onNext();
    }
  }
}
