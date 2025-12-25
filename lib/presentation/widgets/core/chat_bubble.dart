/// Chat Bubble Widget
/// Message bubbles for AI and user messages matching StudySmarter design.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Chat bubble for displaying messages.
class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime? timestamp;
  final List<Widget>? quickActions;

  const ChatBubble({
    super.key,
    required this.text,
    this.isUser = false,
    this.timestamp,
    this.quickActions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[const SizedBox(width: 8)],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: isUser
                  ? StudyBuddyDecorations.chatBubbleUser
                  : StudyBuddyDecorations.chatBubbleAI,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser
                          ? Colors.white
                          : StudyBuddyColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  if (quickActions != null && quickActions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: quickActions!),
                  ],
                  if (timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(timestamp!),
                      style: TextStyle(
                        fontSize: 10,
                        color: isUser
                            ? Colors.white.withValues(alpha: 0.7)
                            : StudyBuddyColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[const SizedBox(width: 8)],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

/// Typing indicator with animated dots.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: StudyBuddyDecorations.chatBubbleAI,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final animationValue = (_controller.value + delay) % 1.0;
                    final opacity =
                        (math.sin(animationValue * math.pi * 2) + 1) / 2;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Opacity(
                        opacity: 0.3 + (opacity * 0.7),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: StudyBuddyColors.textSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
