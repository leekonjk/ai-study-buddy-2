/// Quick Action Button
/// Blue rounded buttons for quick replies in chat.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Quick action button for chat quick replies.
class QuickActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: StudyBuddyDecorations.borderRadiusFull,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: StudyBuddyColors.primary,
          borderRadius: StudyBuddyDecorations.borderRadiusFull,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

