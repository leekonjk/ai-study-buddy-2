/// Achievement Entity.
/// Represents a gamification badge/achievement.
///
/// Layer: Domain
/// Responsibility: Define what an achievement is.
library;

import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String iconPath; // Path to asset or icon name
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0 to 1.0
  final int xpReward;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
    this.xpReward = 100,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconPath,
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progress,
    int? xpReward,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      xpReward: xpReward ?? this.xpReward,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    iconPath,
    isUnlocked,
    unlockedAt,
    progress,
    xpReward,
  ];
}
