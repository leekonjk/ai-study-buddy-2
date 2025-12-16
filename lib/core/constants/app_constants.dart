/// Application-wide constants.
/// Contains static values used across the app (durations, limits, keys).
library;

class AppConstants {
  AppConstants._();

  static const String appName = 'Student AI Buddy';
  static const String appVersion = '1.0.0';

  // Study session defaults
  static const int defaultFocusSessionMinutes = 25;
  static const int defaultBreakMinutes = 5;

  // AI reasoning thresholds
  static const double lowKnowledgeThreshold = 0.4;
  static const double highKnowledgeThreshold = 0.75;
  static const double riskThreshold = 0.6;
}
