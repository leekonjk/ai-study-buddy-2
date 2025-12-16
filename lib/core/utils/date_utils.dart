/// Date and time utility functions for study planning.
/// Provides helpers for week calculations, scheduling, deadlines.
library;

class AppDateUtils {
  AppDateUtils._();

  /// Returns the start of the current week (Monday).
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  /// Returns the end of the current week (Sunday 23:59:59).
  static DateTime endOfWeek(DateTime date) {
    final start = startOfWeek(date);
    return DateTime(start.year, start.month, start.day + 6, 23, 59, 59);
  }

  /// Calculates days remaining until a deadline.
  static int daysUntil(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(deadline.year, deadline.month, deadline.day);
    return target.difference(today).inDays;
  }

  /// Formats duration in minutes to human-readable string.
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $remainingMinutes min';
  }
}
