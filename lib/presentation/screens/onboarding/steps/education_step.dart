/// Education Step
/// Collects university and program information.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/chat_bubble.dart';
import 'package:studnet_ai_buddy/presentation/widgets/core/mascot_widget.dart';
import 'package:studnet_ai_buddy/presentation/screens/onboarding/onboarding_flow.dart';

/// Education information collection step.
class EducationStep extends StatefulWidget {
  const EducationStep({super.key});

  @override
  State<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends State<EducationStep> {
  final _universityController = TextEditingController();
  final _programController = TextEditingController();
  int? _selectedSemester;

  @override
  void initState() {
    super.initState();
    _universityController.addListener(_updateState);
    _programController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _universityController.removeListener(_updateState);
    _programController.removeListener(_updateState);
    _universityController.dispose();
    _programController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
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
                            text:
                                "Tell me about your education. What university are you studying at, and what's your program?",
                            isUser: false,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Inputs
                    TextField(
                      controller: _universityController,
                      style: const TextStyle(
                        color: StudyBuddyColors.textPrimary,
                      ),
                      decoration: StudyBuddyDecorations.inputDecoration(
                        hintText: 'University/Institution',
                        prefixIcon: const Icon(
                          Icons.school_outlined,
                          color: StudyBuddyColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _programController,
                      style: const TextStyle(
                        color: StudyBuddyColors.textPrimary,
                      ),
                      decoration: StudyBuddyDecorations.inputDecoration(
                        hintText: 'Program/Major',
                        prefixIcon: const Icon(
                          Icons.menu_book_outlined,
                          color: StudyBuddyColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Semester Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedSemester,
                      decoration: StudyBuddyDecorations.inputDecoration(
                        hintText: 'Current Semester',
                        prefixIcon: const Icon(
                          Icons.calendar_today_rounded,
                          color: StudyBuddyColors.textSecondary,
                        ),
                      ),
                      items: List.generate(8, (index) => index + 1)
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                'Semester $s',
                                style: const TextStyle(
                                  color: StudyBuddyColors.textPrimary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSemester = val;
                        });
                      },
                      dropdownColor: StudyBuddyColors.cardBackground,
                      icon: const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: StudyBuddyColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _universityController.text.trim().isNotEmpty &&
                                _programController.text.trim().isNotEmpty
                            ? _handleNext
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StudyBuddyColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                StudyBuddyDecorations.borderRadiusFull,
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
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleNext() {
    if (_universityController.text.trim().isNotEmpty &&
        _programController.text.trim().isNotEmpty &&
        _selectedSemester != null) {
      final controller = OnboardingStepController.of(context);
      controller?.onUpdateData('university', _universityController.text.trim());
      controller?.onUpdateData('program', _programController.text.trim());
      controller?.onUpdateData('semester', _selectedSemester);
      controller?.onNext();
    }
  }
}
