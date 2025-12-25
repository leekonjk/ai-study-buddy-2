/// StudyBuddy Typography
/// Text styles for the app.
library;

import 'package:flutter/material.dart';
import 'studybuddy_colors.dart';

/// Typography styles for the app.
class AppTypography {
  AppTypography._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: StudyBuddyColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: StudyBuddyColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: StudyBuddyColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: StudyBuddyColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: StudyBuddyColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: StudyBuddyColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: StudyBuddyColors.textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: StudyBuddyColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: StudyBuddyColors.textTertiary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: StudyBuddyColors.textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: StudyBuddyColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: StudyBuddyColors.textPrimary,
  );

  // Legacy aliases for backwards compatibility
  static const TextStyle headline1 = displayLarge;
  static const TextStyle headline2 = headlineLarge;
  static const TextStyle headline3 = headlineMedium;
  static const TextStyle subtitle1 = titleLarge;
  static const TextStyle subtitle2 = titleMedium;
  static const TextStyle body1 = bodyLarge;
  static const TextStyle body2 = bodyMedium;
  static const TextStyle caption = bodySmall;
}
