/// Achievements Screen
/// Display user achievements and badges.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

import 'package:studnet_ai_buddy/domain/entities/achievement.dart'; // Added

/// Achievements and badges screen.
class AchievementsScreen extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsScreen({super.key, required this.achievements});

  int get _unlockedCount => achievements.where((a) => a.isUnlocked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: StudyBuddyColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Stats
              _buildStats(),

              // Achievements list
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unlocked section
                      _buildSection(
                        'Unlocked',
                        Icons.lock_open_rounded,
                        StudyBuddyColors.success,
                        achievements.where((a) => a.isUnlocked).toList(),
                      ),
                      const SizedBox(height: 24),

                      // In progress section
                      _buildSection(
                        'In Progress',
                        Icons.trending_up_rounded,
                        StudyBuddyColors.warning,
                        achievements
                            .where((a) => !a.isUnlocked && a.progress > 0)
                            .toList(),
                      ),
                      const SizedBox(height: 24),

                      // Locked section
                      _buildSection(
                        'Locked',
                        Icons.lock_rounded,
                        StudyBuddyColors.textTertiary,
                        achievements
                            .where((a) => !a.isUnlocked && a.progress == 0)
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StudyBuddyColors.cardBackground,
                borderRadius: StudyBuddyDecorations.borderRadiusS,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: StudyBuddyColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Achievements',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: StudyBuddyColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: 0.2),
            Colors.orange.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.amber,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_unlockedCount / ${achievements.length}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: StudyBuddyColors.textPrimary,
                  ),
                ),
                const Text(
                  'Achievements Unlocked',
                  style: TextStyle(
                    fontSize: 14,
                    color: StudyBuddyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Progress ring
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: achievements.isEmpty
                      ? 0
                      : _unlockedCount / achievements.length,
                  strokeWidth: 5,
                  backgroundColor: StudyBuddyColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
                Center(
                  child: Text(
                    '${achievements.isEmpty ? 0 : (_unlockedCount / achievements.length * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildSection(
    String title,
    IconData icon,
    Color color,
    List<Achievement> achievements,
  ) {
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: StudyBuddyDecorations.borderRadiusFull,
              ),
              child: Text(
                '${achievements.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...achievements.asMap().entries.map((entry) {
          final index = entry.key;
          final achievement = entry.value;
          return _buildAchievementCard(achievement)
              .animate()
              .fadeIn(delay: (200 + index * 50).ms)
              .slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isLocked = !achievement.isUnlocked && achievement.progress == 0;
    final color = _getColor(achievement);
    final icon = _getIcon(achievement);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(
          color: achievement.isUnlocked
              ? color.withValues(alpha: 0.3)
              : StudyBuddyColors.border,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isLocked
                  ? StudyBuddyColors.border.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isLocked ? StudyBuddyColors.textTertiary : color,
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isLocked
                        ? StudyBuddyColors.textTertiary
                        : StudyBuddyColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isLocked
                        ? StudyBuddyColors.textTertiary.withValues(alpha: 0.7)
                        : StudyBuddyColors.textSecondary,
                  ),
                ),
                if (!achievement.isUnlocked && achievement.progress > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: StudyBuddyDecorations.borderRadiusFull,
                          child: LinearProgressIndicator(
                            value: achievement.progress,
                            minHeight: 6,
                            backgroundColor: StudyBuddyColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(achievement.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
                if (achievement.isUnlocked &&
                    achievement.unlockedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                ],
              ],
            ),
          ),
          // Status
          if (achievement.isUnlocked)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_rounded, size: 16, color: color),
            )
          else if (isLocked)
            const Icon(
              Icons.lock_rounded,
              size: 20,
              color: StudyBuddyColors.textTertiary,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getColor(Achievement achievement) {
    switch (achievement.id) {
      case 'first_steps':
        return Colors.amber;
      case 'note_taker':
        return Colors.blue;
      case 'dedicated_scholar':
        return Colors.purple;
      case 'streak_master':
        return Colors.orange;
      case 'weekend_warrior':
        return Colors.teal;
      default:
        return StudyBuddyColors.primary;
    }
  }

  IconData _getIcon(Achievement achievement) {
    switch (achievement.id) {
      case 'first_steps':
        return Icons.emoji_events_rounded;
      case 'note_taker':
        return Icons.note_alt_rounded;
      case 'dedicated_scholar':
        return Icons.school_rounded;
      case 'streak_master':
        return Icons.local_fire_department_rounded;
      case 'weekend_warrior':
        return Icons.weekend_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
