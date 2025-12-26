/// Achievement Service
/// Simple service to unlock achievements based on user actions
library;

import 'package:studnet_ai_buddy/domain/repositories/achievement_repository.dart';
import 'package:studnet_ai_buddy/domain/entities/achievement.dart';

class AchievementService {
  final AchievementRepository _achievementRepository;

  AchievementService({required AchievementRepository achievementRepository})
    : _achievementRepository = achievementRepository;

  /// Check and unlock "First Task" achievement
  Future<void> checkFirstTaskCompletion(int completedTaskCount) async {
    if (completedTaskCount >= 1) {
      await _unlockAchievement('first_task');
    }
  }

  /// Check and unlock "Task Champion" achievement
  Future<void> checkTaskChampion(int completedTaskCount) async {
    if (completedTaskCount >= 5) {
      await _unlockAchievement('task_champion');
    }
  }

  /// Check and unlock "Flashcard Master" achievement
  Future<void> checkFirstStudySetCreated(int studySetCount) async {
    if (studySetCount >= 1) {
      await _unlockAchievement('flashcard_master');
    }
  }

  /// Check and unlock "Note Taker" achievement
  Future<void> checkFirstNoteCreated(int noteCount) async {
    if (noteCount >= 1) {
      await _unlockAchievement('note_taker');
    }
  }

  /// Internal method to unlock an achievement
  Future<void> _unlockAchievement(String achievementId) async {
    try {
      final achievementsResult = await _achievementRepository.getAchievements();

      achievementsResult.fold(
        onSuccess: (achievements) async {
          final achievement = achievements.firstWhere(
            (a) => a.id == achievementId,
            orElse: () => Achievement(
              id: achievementId,
              title: _getAchievementTitle(achievementId),
              description: _getAchievementDescription(achievementId),
              iconPath: _getAchievementIcon(achievementId),
              isUnlocked: false,
              unlockedAt: DateTime.now(),
            ),
          );

          if (!achievement.isUnlocked) {
            final unlockedAchievement = achievement.copyWith(
              isUnlocked: true,
              unlockedAt: DateTime.now(),
            );

            await _achievementRepository.unlockAchievement(
              unlockedAchievement.id,
            );
          }
        },
        onFailure: (_) {
          // Silently fail - don't block user flow
        },
      );
    } catch (e) {
      // Silently fail - achievements are not critical
    }
  }

  String _getAchievementTitle(String id) {
    switch (id) {
      case 'first_task':
        return 'Getting Started';
      case 'task_champion':
        return 'Task Champion';
      case 'flashcard_master':
        return 'Flashcard Master';
      case 'note_taker':
        return 'Note Taker';
      default:
        return 'Achievement';
    }
  }

  String _getAchievementDescription(String id) {
    switch (id) {
      case 'first_task':
        return 'Completed your first task';
      case 'task_champion':
        return 'Completed 5 tasks';
      case 'flashcard_master':
        return 'Created your first study set';
      case 'note_taker':
        return 'Created your first note';
      default:
        return 'Description';
    }
  }

  String _getAchievementIcon(String id) {
    switch (id) {
      case 'first_task':
        return 'task_alt';
      case 'task_champion':
        return 'emoji_events';
      case 'flashcard_master':
        return 'style';
      case 'note_taker':
        return 'note';
      default:
        return 'star';
    }
  }
}
