/// Achievement Repository Implementation.
/// Manages achievement data in Firestore and defines the game logic rules.
///
/// Layer: Data
/// Responsibility: Persist unlocks and define static achievement rules.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studnet_ai_buddy/core/errors/failures.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/achievement.dart';
import 'package:studnet_ai_buddy/domain/repositories/achievement_repository.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AchievementRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // ─────────────────────────────────────────────────────────────────────────
  // Static Definitions (The "Rules")
  // ─────────────────────────────────────────────────────────────────────────

  final List<Achievement> _allAchievements = [
    const Achievement(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Complete your first study session.',
      iconPath:
          'assets/images/achievements/first_steps.png', // Placeholder path
      xpReward: 50,
    ),
    const Achievement(
      id: 'note_taker',
      title: 'Note Taker',
      description: 'Create your first study note.',
      iconPath: 'assets/images/achievements/note_taker.png',
      xpReward: 50,
    ),
    const Achievement(
      id: 'dedicated_scholar',
      title: 'Dedicated Scholar',
      description: 'Reach 10 hours of total study time.',
      iconPath: 'assets/images/achievements/scholar.png',
      xpReward: 200,
    ),
    const Achievement(
      id: 'streak_master',
      title: 'Streak Master',
      description: 'Maintain a 3-day study streak.',
      iconPath: 'assets/images/achievements/fire.png',
      xpReward: 150,
    ),
    const Achievement(
      id: 'weekend_warrior',
      title: 'Weekend Warrior',
      description: 'Study on a Saturday or Sunday.',
      iconPath: 'assets/images/achievements/weekend.png',
      xpReward: 100,
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Methods
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<List<Achievement>>> getAchievements() async {
    try {
      if (_userId == null) {
        return const Err(NetworkFailure(message: 'User not logged in'));
      }

      // Fetch unlocked status from Firestore
      final snapshot = await _firestore
          .collection('students')
          .doc(_userId)
          .collection('achievements')
          .get();

      final unlockedMap = {for (var doc in snapshot.docs) doc.id: doc.data()};

      // Merge static definitions with dynamic data
      final mergedList = _allAchievements.map((achievement) {
        final data = unlockedMap[achievement.id];
        if (data != null) {
          final unlockedAtTimestamp = data['unlockedAt'] as Timestamp?;
          return achievement.copyWith(
            isUnlocked: true,
            unlockedAt: unlockedAtTimestamp?.toDate(),
            progress: 1.0,
          );
        }
        return achievement;
      }).toList();

      return Success(mergedList);
    } catch (e) {
      return Err(NetworkFailure(message: 'Failed to load achievements: $e'));
    }
  }

  @override
  Future<Result<List<Achievement>>> checkAndUnlockAchievements({
    required int totalStudyMinutes,
    required int totalNotes,
    required int totalSessions,
    required int studyStreak,
  }) async {
    if (_userId == null) {
      return const Err(NetworkFailure(message: 'User not logged in'));
    }

    final unlockedAchievements = <Achievement>[];

    // Get current status first
    final currentResult = await getAchievements();
    if (currentResult is! Success) return const Success([]); // Fail silently?
    final currentList = (currentResult as Success<List<Achievement>>).value;

    // Check Rules
    for (var achievement in currentList) {
      if (achievement.isUnlocked) continue; // Already unlocked

      bool shouldUnlock = false;

      switch (achievement.id) {
        case 'first_steps':
          if (totalSessions >= 1) shouldUnlock = true;
          break;
        case 'note_taker':
          if (totalNotes >= 1) shouldUnlock = true;
          break;
        case 'dedicated_scholar':
          if (totalStudyMinutes >= 600) shouldUnlock = true; // 10 hours
          break;
        case 'streak_master':
          if (studyStreak >= 3) shouldUnlock = true;
          break;
        case 'weekend_warrior':
          final now = DateTime.now();
          if ((now.weekday == DateTime.saturday ||
                  now.weekday == DateTime.sunday) &&
              totalSessions > 0) {
            shouldUnlock = true;
          }
          break;
      }

      if (shouldUnlock) {
        // Persist unlock
        await unlockAchievement(achievement.id);
        unlockedAchievements.add(achievement.copyWith(isUnlocked: true));
      }
    }

    return Success(unlockedAchievements);
  }

  @override
  Future<Result<void>> unlockAchievement(String achievementId) async {
    if (_userId == null) {
      return const Err(NetworkFailure(message: 'User not logged in'));
    }

    try {
      await _firestore
          .collection('students')
          .doc(_userId)
          .collection('achievements')
          .doc(achievementId)
          .set({
            'unlockedAt': FieldValue.serverTimestamp(),
            'id': achievementId,
          });
      return const Success(null);
    } catch (e) {
      return Err(NetworkFailure(message: 'Failed to unlock achievement: $e'));
    }
  }

  @override
  Future<Result<void>> updateAchievementProgress(
    String achievementId,
    double progress,
  ) async {
    // For now, simpler implementation where we just unlock or not.
    // Progress tracking can be added later if UI supports progress bars per achievement.
    return const Success(null);
  }
}
