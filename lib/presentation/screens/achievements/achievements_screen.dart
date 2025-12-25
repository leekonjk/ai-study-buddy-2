/// Achievements Screen
/// Display user achievements and badges.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_colors.dart';
import 'package:studnet_ai_buddy/presentation/theme/studybuddy_decorations.dart';

/// Achievement data model.
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final double progress;
  final String? unlockedDate;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.progress = 0.0,
    this.unlockedDate,
  });
}

/// Achievements and badges screen.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const List<Achievement> _achievements = [
    // Unlocked
    Achievement(
      id: '1',
      title: 'First Steps',
      description: 'Complete your first study session',
      icon: Icons.emoji_events_rounded,
      color: Colors.amber,
      isUnlocked: true,
      progress: 1.0,
      unlockedDate: 'Dec 20, 2024',
    ),
    Achievement(
      id: '2',
      title: 'Quiz Master',
      description: 'Score 100% on any quiz',
      icon: Icons.star_rounded,
      color: Colors.purple,
      isUnlocked: true,
      progress: 1.0,
      unlockedDate: 'Dec 22, 2024',
    ),
    Achievement(
      id: '3',
      title: 'Week Warrior',
      description: 'Maintain a 7-day study streak',
      icon: Icons.local_fire_department_rounded,
      color: Colors.orange,
      isUnlocked: true,
      progress: 1.0,
      unlockedDate: 'Dec 24, 2024',
    ),
    // In progress
    Achievement(
      id: '4',
      title: 'Flashcard Pro',
      description: 'Create 50 flashcards',
      icon: Icons.style_rounded,
      color: Colors.blue,
      progress: 0.68,
    ),
    Achievement(
      id: '5',
      title: 'Night Owl',
      description: 'Study for 10 hours after 10 PM',
      icon: Icons.nightlight_rounded,
      color: Colors.indigo,
      progress: 0.45,
    ),
    Achievement(
      id: '6',
      title: 'Knowledge Seeker',
      description: 'Complete 100 study sessions',
      icon: Icons.school_rounded,
      color: Colors.teal,
      progress: 0.32,
    ),
    // Locked
    Achievement(
      id: '7',
      title: 'Month Champion',
      description: 'Maintain a 30-day study streak',
      icon: Icons.workspace_premium_rounded,
      color: Colors.red,
    ),
    Achievement(
      id: '8',
      title: 'Speed Demon',
      description: 'Complete a quiz in under 2 minutes',
      icon: Icons.speed_rounded,
      color: Colors.green,
    ),
    Achievement(
      id: '9',
      title: 'Social Butterfly',
      description: 'Share 10 study sets with friends',
      icon: Icons.share_rounded,
      color: Colors.pink,
    ),
    Achievement(
      id: '10',
      title: 'Ultimate Scholar',
      description: 'Unlock all other achievements',
      icon: Icons.military_tech_rounded,
      color: Colors.amber,
    ),
  ];

  int get _unlockedCount => _achievements.where((a) => a.isUnlocked).length;

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
                        _achievements.where((a) => a.isUnlocked).toList(),
                      ),
                      const SizedBox(height: 24),

                      // In progress section
                      _buildSection(
                        'In Progress',
                        Icons.trending_up_rounded,
                        StudyBuddyColors.warning,
                        _achievements
                            .where((a) => !a.isUnlocked && a.progress > 0)
                            .toList(),
                      ),
                      const SizedBox(height: 24),

                      // Locked section
                      _buildSection(
                        'Locked',
                        Icons.lock_rounded,
                        StudyBuddyColors.textTertiary,
                        _achievements
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
                  '$_unlockedCount / ${_achievements.length}',
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
                  value: _unlockedCount / _achievements.length,
                  strokeWidth: 5,
                  backgroundColor: StudyBuddyColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                ),
                Center(
                  child: Text(
                    '${(_unlockedCount / _achievements.length * 100).toInt()}%',
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StudyBuddyColors.cardBackground,
        borderRadius: StudyBuddyDecorations.borderRadiusL,
        border: Border.all(
          color: achievement.isUnlocked
              ? achievement.color.withValues(alpha: 0.3)
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
                  : achievement.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              size: 28,
              color: isLocked
                  ? StudyBuddyColors.textTertiary
                  : achievement.color,
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                              achievement.color,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(achievement.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: achievement.color,
                        ),
                      ),
                    ],
                  ),
                ],
                if (achievement.isUnlocked &&
                    achievement.unlockedDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Unlocked ${achievement.unlockedDate}',
                    style: TextStyle(fontSize: 11, color: achievement.color),
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
                color: achievement.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 16,
                color: achievement.color,
              ),
            )
          else if (isLocked)
            Icon(
              Icons.lock_rounded,
              size: 20,
              color: StudyBuddyColors.textTertiary,
            ),
        ],
      ),
    );
  }
}
