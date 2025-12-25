/// App Theme
/// Re-exports design system and additional theme utilities.
library;

export 'studybuddy_colors.dart';
export 'studybuddy_decorations.dart';
export 'package:studnet_ai_buddy/presentation/design/design_system.dart';

import 'package:flutter/material.dart';
import 'studybuddy_colors.dart';
import 'studybuddy_decorations.dart';

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

/// Spacing constants for consistent layout.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);

  static const SizedBox gapXS = SizedBox(height: xs, width: xs);
  static const SizedBox gapSM = SizedBox(height: sm, width: sm);
  static const SizedBox gapMD = SizedBox(height: md, width: md);
  static const SizedBox gapLG = SizedBox(height: lg, width: lg);
  static const SizedBox gapXL = SizedBox(height: xl, width: xl);
}

/// Border radius constants.
class AppRadius {
  AppRadius._();

  static const double xs = StudyBuddyDecorations.radiusXS;
  static const double sm = StudyBuddyDecorations.radiusS;
  static const double md = StudyBuddyDecorations.radiusM;
  static const double lg = StudyBuddyDecorations.radiusL;
  static const double xl = StudyBuddyDecorations.radiusXL;
  static const double full = StudyBuddyDecorations.radiusFull;

  static const BorderRadius borderXS = StudyBuddyDecorations.borderRadiusXS;
  static const BorderRadius borderSM = StudyBuddyDecorations.borderRadiusS;
  static const BorderRadius borderMD = StudyBuddyDecorations.borderRadiusM;
  static const BorderRadius borderLG = StudyBuddyDecorations.borderRadiusL;
  static const BorderRadius borderXL = StudyBuddyDecorations.borderRadiusXL;
  static const BorderRadius borderFull = StudyBuddyDecorations.borderRadiusFull;
}

/// Alias for StudyBuddyColors for shorter access.
typedef AppColors = StudyBuddyColors;

