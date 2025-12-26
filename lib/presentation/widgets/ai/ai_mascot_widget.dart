import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';

class AIMascotWidget extends StatelessWidget {
  final VoidCallback onTap;

  const AIMascotWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: StudyBuddyColors.cardBackground,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: StudyBuddyColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: StudyBuddyColors.primary.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.psychology,
              size: 32,
              color: StudyBuddyColors.primary,
            ),
            // Use an actual image asset if available:
            // Image.asset('lib/assets/images/mascot.png', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
