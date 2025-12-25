/// StudyBuddy Decorations
/// Box decorations, shadows, and border styles.
library;

import 'package:flutter/material.dart';
import 'studybuddy_colors.dart';

/// Decoration styles matching StudySmarter design.
class StudyBuddyDecorations {
  StudyBuddyDecorations._();

  // ─────────────────────────────────────────────────────────────────────────
  // Border Radius
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Extra small radius - 4px
  static const double radiusXS = 4;
  
  /// Small radius - 8px
  static const double radiusS = 8;
  
  /// Medium radius - 12px
  static const double radiusM = 12;
  
  /// Large radius - 16px
  static const double radiusL = 16;
  
  /// Extra large radius - 24px
  static const double radiusXL = 24;
  
  /// Full radius for pills - 999px
  static const double radiusFull = 999;

  // ─────────────────────────────────────────────────────────────────────────
  // Border Radius Objects
  // ─────────────────────────────────────────────────────────────────────────
  
  static const BorderRadius borderRadiusXS = BorderRadius.all(Radius.circular(radiusXS));
  static const BorderRadius borderRadiusS = BorderRadius.all(Radius.circular(radiusS));
  static const BorderRadius borderRadiusM = BorderRadius.all(Radius.circular(radiusM));
  static const BorderRadius borderRadiusL = BorderRadius.all(Radius.circular(radiusL));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // ─────────────────────────────────────────────────────────────────────────
  // Spacing
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Extra small spacing - 4px
  static const double spacingXS = 4;
  
  /// Small spacing - 8px
  static const double spacingS = 8;
  
  /// Medium spacing - 16px
  static const double spacingM = 16;
  
  /// Large spacing - 24px
  static const double spacingL = 24;
  
  /// Extra large spacing - 32px
  static const double spacingXL = 32;
  
  /// 2X large spacing - 48px
  static const double spacing2XL = 48;

  // ─────────────────────────────────────────────────────────────────────────
  // Card Decorations
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Default card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: StudyBuddyColors.cardBackground,
    borderRadius: borderRadiusL,
    border: Border.all(
      color: StudyBuddyColors.border,
      width: 1,
    ),
  );
  
  /// Selected card decoration
  static BoxDecoration cardDecorationSelected = BoxDecoration(
    color: StudyBuddyColors.cardBackground,
    borderRadius: borderRadiusL,
    border: Border.all(
      color: StudyBuddyColors.primary,
      width: 2,
    ),
  );
  
  /// Card with warning border (orange)
  static BoxDecoration cardDecorationWarning = BoxDecoration(
    color: StudyBuddyColors.cardBackground,
    borderRadius: borderRadiusL,
    border: Border.fromBorderSide(
      BorderSide(
        color: StudyBuddyColors.warning,
        width: 3,
      ),
    ),
  );
  
  /// Card with success border (green)
  static BoxDecoration cardDecorationSuccess = BoxDecoration(
    color: StudyBuddyColors.cardBackground,
    borderRadius: borderRadiusL,
    border: Border.fromBorderSide(
      BorderSide(
        color: StudyBuddyColors.success,
        width: 3,
      ),
    ),
  );
  
  /// Elevated card with glow
  static BoxDecoration cardDecorationElevated = BoxDecoration(
    color: StudyBuddyColors.cardBackgroundElevated,
    borderRadius: borderRadiusL,
    border: Border.all(
      color: StudyBuddyColors.borderLight,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Chat Bubble Decorations
  // ─────────────────────────────────────────────────────────────────────────
  
  /// AI message bubble
  static BoxDecoration chatBubbleAI = BoxDecoration(
    color: StudyBuddyColors.cardBackground,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(radiusL),
      topRight: Radius.circular(radiusL),
      bottomRight: Radius.circular(radiusL),
      bottomLeft: Radius.circular(radiusXS),
    ),
    border: Border.all(
      color: StudyBuddyColors.border,
      width: 1,
    ),
  );
  
  /// User message bubble
  static BoxDecoration chatBubbleUser = BoxDecoration(
    color: StudyBuddyColors.primary,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(radiusL),
      topRight: Radius.circular(radiusL),
      bottomRight: Radius.circular(radiusXS),
      bottomLeft: Radius.circular(radiusL),
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Button Decorations
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Primary button
  static BoxDecoration primaryButton = const BoxDecoration(
    color: Colors.white,
    borderRadius: borderRadiusFull,
  );
  
  /// Secondary button
  static BoxDecoration secondaryButton = BoxDecoration(
    color: StudyBuddyColors.cardBackground,
    borderRadius: borderRadiusFull,
    border: Border.all(
      color: StudyBuddyColors.border,
      width: 1,
    ),
  );
  
  /// Outline button
  static BoxDecoration outlineButton = BoxDecoration(
    color: Colors.transparent,
    borderRadius: borderRadiusFull,
    border: Border.all(
      color: StudyBuddyColors.textSecondary,
      width: 1,
    ),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Input Decorations
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Text input decoration
  static InputDecoration inputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: StudyBuddyColors.textTertiary,
        fontSize: 16,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: StudyBuddyColors.cardBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadiusFull,
        borderSide: const BorderSide(
          color: StudyBuddyColors.border,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusFull,
        borderSide: const BorderSide(
          color: StudyBuddyColors.border,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusFull,
        borderSide: const BorderSide(
          color: StudyBuddyColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadiusFull,
        borderSide: const BorderSide(
          color: StudyBuddyColors.error,
          width: 1,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Progress Bar Decorations
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Progress bar background
  static BoxDecoration progressBarBackground = BoxDecoration(
    color: StudyBuddyColors.backgroundLight,
    borderRadius: borderRadiusFull,
  );
  
  /// Progress bar fill (success)
  static BoxDecoration progressBarFillSuccess = BoxDecoration(
    color: StudyBuddyColors.success,
    borderRadius: borderRadiusFull,
  );
  
  /// Progress bar fill (error)
  static BoxDecoration progressBarFillError = BoxDecoration(
    color: StudyBuddyColors.error,
    borderRadius: borderRadiusFull,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Dividers
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Horizontal divider
  static const Divider divider = Divider(
    color: StudyBuddyColors.border,
    thickness: 1,
    height: 1,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Shadows
  // ─────────────────────────────────────────────────────────────────────────
  
  /// Small shadow
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// Medium shadow
  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  /// Large shadow
  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  /// Glow effect
  static List<BoxShadow> glowEffect(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
