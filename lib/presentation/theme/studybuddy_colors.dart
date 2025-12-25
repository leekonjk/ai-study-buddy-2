/// StudyBuddy Colors
/// Color palette for the StudyBuddy app design system.
library;

import 'package:flutter/material.dart';

/// Color constants matching StudySmarter design.
class StudyBuddyColors {
  StudyBuddyColors._();

  // ─────────────────────────────────────────────────────────────────────────
  // Background Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Dark navy background
  static const Color backgroundDark = Color(0xFF0A1628);

  /// Lighter navy for contrast
  static const Color backgroundLight = Color(0xFF0F2847);

  /// Medium background for cards
  static const Color backgroundMedium = Color(0xFF1A2F4A);

  // ─────────────────────────────────────────────────────────────────────────
  // Primary Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary blue accent
  static const Color primary = Color(0xFF3B82F6);

  /// Primary light variant
  static const Color primaryLight = Color(0xFF60A5FA);

  /// Primary dark variant
  static const Color primaryDark = Color(0xFF2563EB);

  // ─────────────────────────────────────────────────────────────────────────
  // Secondary Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Secondary cyan accent
  static const Color secondary = Color(0xFF06B6D4);

  /// Secondary light variant
  static const Color secondaryLight = Color(0xFF22D3EE);

  /// Accent color (purple)
  static const Color accent = Color(0xFF8B5CF6);

  /// Highlight color (amber/gold)
  static const Color highlight = Color(0xFFF59E0B);

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Success green
  static const Color success = Color(0xFF22C55E);

  /// Warning orange
  static const Color warning = Color(0xFFF59E0B);

  /// Error red
  static const Color error = Color(0xFFEF4444);

  /// Info blue
  static const Color info = Color(0xFF0EA5E9);

  // ─────────────────────────────────────────────────────────────────────────
  // Text Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Primary text (white)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text (light gray)
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Tertiary text (darker gray)
  static const Color textTertiary = Color(0xFF64748B);

  /// Disabled text
  static const Color textDisabled = Color(0xFF475569);

  // ─────────────────────────────────────────────────────────────────────────
  // Card & Surface Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Card background
  static const Color cardBackground = Color(0xFF1E293B);

  /// Elevated card background
  static const Color cardBackgroundElevated = Color(0xFF2D3A4F);

  /// Surface color
  static const Color surface = Color(0xFF1E293B);

  /// Surface variant
  static const Color surfaceVariant = Color(0xFF334155);

  // ─────────────────────────────────────────────────────────────────────────
  // Border Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Default border
  static const Color border = Color(0xFF334155);

  /// Light border
  static const Color borderLight = Color(0xFF475569);

  /// Focus border
  static const Color borderFocus = Color(0xFF3B82F6);

  // ─────────────────────────────────────────────────────────────────────────
  // Shadow Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Shadow color
  static const Color shadow = Color(0xFF000000);

  // ─────────────────────────────────────────────────────────────────────────
  // Legacy/Alias Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Background alias
  static const Color background = backgroundDark;

  /// Text hint color
  static const Color textHint = textTertiary;

  /// Inverse text (for dark on light)
  static const Color textInverse = Color(0xFF1E293B);

  /// Text on primary color
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────────────────────────────
  // Gradient Definitions
  // ─────────────────────────────────────────────────────────────────────────

  /// Background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundLight],
  );

  /// Primary button gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );

  // ─────────────────────────────────────────────────────────────────────────
  // Icon Colors
  // ─────────────────────────────────────────────────────────────────────────

  /// Default icon color
  static const Color icon = Color(0xFF94A3B8);

  /// Active icon color
  static const Color iconActive = Color(0xFF3B82F6);

  /// Inactive icon color
  static const Color iconInactive = Color(0xFF64748B);

  // ─────────────────────────────────────────────────────────────────────────
  // Light Theme Colors (for light mode)
  // ─────────────────────────────────────────────────────────────────────────

  /// Light mode background
  static const Color lightBackground = Color(0xFFF8FAFC);

  /// Light mode card background
  static const Color lightCardBackground = Color(0xFFFFFFFF);

  /// Light mode text primary
  static const Color lightTextPrimary = Color(0xFF1E293B);

  /// Light mode text secondary
  static const Color lightTextSecondary = Color(0xFF475569);

  /// Light mode border
  static const Color lightBorder = Color(0xFFE2E8F0);
}

/// Theme-aware color extension for BuildContext.
/// Use: context.colors.background instead of StudyBuddyColors.background
extension ThemeColors on BuildContext {
  /// Get theme-aware colors based on current brightness
  AppThemeColors get colors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return AppThemeColors(isDark: isDark);
  }
}

/// Helper class for theme-aware colors
class AppThemeColors {
  final bool isDark;
  const AppThemeColors({required this.isDark});

  Color get background => isDark
      ? StudyBuddyColors.backgroundDark
      : StudyBuddyColors.lightBackground;

  Color get cardBackground => isDark
      ? StudyBuddyColors.cardBackground
      : StudyBuddyColors.lightCardBackground;

  Color get textPrimary =>
      isDark ? StudyBuddyColors.textPrimary : StudyBuddyColors.lightTextPrimary;

  Color get textSecondary => isDark
      ? StudyBuddyColors.textSecondary
      : StudyBuddyColors.lightTextSecondary;

  Color get border =>
      isDark ? StudyBuddyColors.border : StudyBuddyColors.lightBorder;

  // These colors are the same for both themes
  Color get primary => StudyBuddyColors.primary;
  Color get secondary => StudyBuddyColors.secondary;
  Color get success => StudyBuddyColors.success;
  Color get error => StudyBuddyColors.error;
  Color get warning => StudyBuddyColors.warning;
}
