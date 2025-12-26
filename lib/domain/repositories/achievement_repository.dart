/// Achievement Repository Interface.
/// Defines methods for accessing and updating achievements.
///
/// Layer: Domain
/// Responsibility: Abstraction for achievement data access.
library;

import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/achievement.dart';

abstract class AchievementRepository {
  /// Fetches all achievements for the current user, merging static definitions
  /// with dynamic unlock status from persistence.
  Future<Result<List<Achievement>>> getAchievements();

  /// Updates the progress of a specific achievement or unlocks it.
  Future<Result<void>> updateAchievementProgress(
    String achievementId,
    double progress,
  );

  /// Unlocks an achievement directly.
  Future<Result<void>> unlockAchievement(String achievementId);

  /// Checks and unlocks achievements based on current user stats.
  /// This is the core gamification engine method.
  Future<Result<List<Achievement>>> checkAndUnlockAchievements({
    required int totalStudyMinutes,
    required int totalNotes,
    required int totalSessions,
    required int studyStreak,
  });
}
