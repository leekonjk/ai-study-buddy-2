import 'package:flutter/material.dart';

/// Badge widget to display subject information on cards
class SubjectBadge extends StatelessWidget {
  final String subjectName;
  final Color? color;
  final bool compact;

  const SubjectBadge({
    super.key,
    required this.subjectName,
    this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? _getDefaultColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: compact ? 3 : 4),
          Text(
            subjectName,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getDefaultColor() {
    // Generate a color based on subject name for consistency
    final hash = subjectName.hashCode;
    final colors = [
      const Color(0xFF4A90E2), // Blue
      const Color(0xFF50C878), // Green
      const Color(0xFFFF6B6B), // Red
      const Color(0xFFFFB400), // Orange
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF1ABC9C), // Teal
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
    ];

    return colors[hash.abs() % colors.length];
  }
}
