/// Theme Provider
/// Manages app-wide theme state using ChangeNotifier.
library;

import 'package:flutter/material.dart';

/// Provides theme mode switching functionality.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Whether dark mode is enabled
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggle between light and dark themes
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Set dark mode
  void setDarkMode() {
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  /// Set light mode
  void setLightMode() {
    _themeMode = ThemeMode.light;
    notifyListeners();
  }

  /// Set system mode
  void setSystemMode() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

