/// Focus Session Repository Interface.
/// Defines contract for focus session data operations.
/// 
/// Layer: Domain
/// Responsibility: Abstract data access for productivity tracking.
/// Implementation: Data layer provides concrete implementation.
library;

import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/focus_session.dart';

abstract class FocusSessionRepository {
  /// Retrieves active focus session if any.
  Future<Result<FocusSession?>> getActiveSession();

  /// Saves a new focus session.
  Future<Result<void>> saveSession(FocusSession session);

  /// Updates an existing focus session.
  Future<Result<void>> updateSession(FocusSession session);

  /// Retrieves sessions for a date range (for analytics).
  Future<Result<List<FocusSession>>> getSessionsInRange(
    DateTime start,
    DateTime end,
  );

  /// Retrieves total focus time for today in minutes.
  Future<Result<int>> getTodaysFocusMinutes();

  /// Retrieves weekly focus statistics.
  Future<Result<Map<String, int>>> getWeeklyFocusStats();
}
