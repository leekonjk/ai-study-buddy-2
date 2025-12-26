/// Focus Session Repository Implementation.
/// Concrete implementation of FocusSessionRepository interface using Firebase Firestore.
///
/// Layer: Data
/// Responsibility: Data operations for focus sessions via Firestore.
///
/// Firestore Collections Used:
/// - focus_sessions: Individual study session records
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studnet_ai_buddy/core/errors/failures.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/focus_session.dart';
import 'package:studnet_ai_buddy/domain/repositories/focus_session_repository.dart';

class FocusSessionRepositoryImpl implements FocusSessionRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Firestore collection name (per schema)
  static const String _focusSessionsCollection = 'focus_sessions';

  FocusSessionRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  String get _currentStudentId => _auth.currentUser?.uid ?? '';

  // ─────────────────────────────────────────────────────────────────────────
  // Session Retrieval Operations
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<FocusSession?>> getActiveSession() async {
    try {
      // Active session = started but not ended
      // Query for sessions without endedAt (or with status 'active')
      final querySnapshot = await _firestore
          .collection(_focusSessionsCollection)
          .where('studentId', isEqualTo: _currentStudentId)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Success(null);
      }

      final doc = querySnapshot.docs.first;
      final session = _mapDocumentToFocusSession(doc);

      return Success(session);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(
          message: 'Failed to fetch active session: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<FocusSession>>> getSessionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_focusSessionsCollection)
          .where('studentId', isEqualTo: _currentStudentId)
          // Removed date range filter to avoid index requirement "FAILED_PRECONDITION"
          // We will filter in memory below
          .get();

      final sessions = querySnapshot.docs
          .map((doc) => _mapDocumentToFocusSession(doc))
          .where((s) => s.startTime.isAfter(start) && s.startTime.isBefore(end))
          .toList();

      // Sort in memory by startedAt descending
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));

      return Success(sessions);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(
          message: 'Failed to fetch sessions: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Session Write Operations
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<void>> saveSession(FocusSession session) async {
    try {
      final data = _mapFocusSessionToDocument(session);

      await _firestore.collection(_focusSessionsCollection).add(data);

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(
          message: 'Failed to save session: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> updateSession(FocusSession session) async {
    try {
      // Find the session document by sessionId
      final querySnapshot = await _firestore
          .collection(_focusSessionsCollection)
          .where('sessionId', isEqualTo: session.id)
          .where('studentId', isEqualTo: _currentStudentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return const Err(NetworkFailure(message: 'Session not found'));
      }

      final docRef = querySnapshot.docs.first.reference;
      final updateData = _mapFocusSessionToUpdateDocument(session);

      await docRef.update(updateData);

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(
          message: 'Failed to update session: ${e.message}',
          code: e.code,
        ),
      );
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Analytics Operations
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<int>> getTodaysFocusMinutes() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final sessionsResult = await getSessionsInRange(todayStart, todayEnd);

      return sessionsResult.fold(
        onSuccess: (sessions) {
          int totalMinutes = 0;

          for (final session in sessions) {
            // Only count completed sessions
            if (session.status == FocusSessionStatus.completed) {
              totalMinutes += session.actualMinutes ?? 0;
            }
          }

          return Success(totalMinutes);
        },
        onFailure: (failure) => Err(failure),
      );
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Map<String, int>>> getWeeklyFocusStats() async {
    try {
      // Get start of current week (Monday)
      final now = DateTime.now();
      final weekStart = _getWeekStart(now);
      final weekEnd = weekStart.add(const Duration(days: 7));

      final sessionsResult = await getSessionsInRange(weekStart, weekEnd);

      return sessionsResult.fold(
        onSuccess: (sessions) {
          // Initialize stats map with day names
          final stats = <String, int>{
            'Monday': 0,
            'Tuesday': 0,
            'Wednesday': 0,
            'Thursday': 0,
            'Friday': 0,
            'Saturday': 0,
            'Sunday': 0,
          };

          final dayNames = [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ];

          for (final session in sessions) {
            if (session.status == FocusSessionStatus.completed) {
              final dayIndex = session.startTime.weekday - 1; // 0-indexed
              final dayName = dayNames[dayIndex];
              stats[dayName] = stats[dayName]! + (session.actualMinutes ?? 0);
            }
          }

          return Success(stats);
        },
        onFailure: (failure) => Err(failure),
      );
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping: Firestore Document → Domain Entity
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps Firestore document to FocusSession domain entity.
  ///
  /// Firestore schema (focus_sessions):
  /// - sessionId: string
  /// - studentId: string
  /// - subjectId: string
  /// - plannedMinutes: int
  /// - actualMinutes: int
  /// - status: string (completed | cancelled)
  /// - startedAt: timestamp
  /// - endedAt: timestamp
  FocusSession _mapDocumentToFocusSession(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    final startedAt =
        (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final endedAt = (data['endedAt'] as Timestamp?)?.toDate();
    final statusString = data['status'] as String? ?? 'completed';

    return FocusSession(
      id: data['sessionId'] as String? ?? doc.id,
      taskId: null, // Not in schema
      subjectId: data['subjectId'] as String?,
      startTime: startedAt,
      endTime: endedAt,
      plannedMinutes: data['plannedMinutes'] as int? ?? 0,
      actualMinutes: data['actualMinutes'] as int?,
      status: _mapStringToStatus(statusString),
      distractionsCount: null, // Not in schema
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping: Domain Entity → Firestore Document
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps FocusSession domain entity to Firestore document data (for create).
  Map<String, dynamic> _mapFocusSessionToDocument(FocusSession session) {
    return {
      'sessionId': session.id,
      'studentId': _currentStudentId,
      'subjectId': session.subjectId ?? '',
      'plannedMinutes': session.plannedMinutes,
      'actualMinutes': session.actualMinutes ?? 0,
      'status': _mapStatusToString(session.status),
      'startedAt': Timestamp.fromDate(session.startTime),
      'endedAt': session.endTime != null
          ? Timestamp.fromDate(session.endTime!)
          : null,
    };
  }

  /// Maps FocusSession domain entity to Firestore update data.
  Map<String, dynamic> _mapFocusSessionToUpdateDocument(FocusSession session) {
    final updateData = <String, dynamic>{
      'actualMinutes': session.actualMinutes ?? 0,
      'status': _mapStatusToString(session.status),
    };

    if (session.endTime != null) {
      updateData['endedAt'] = Timestamp.fromDate(session.endTime!);
    }

    return updateData;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps status string to FocusSessionStatus enum.
  FocusSessionStatus _mapStringToStatus(String status) {
    return switch (status) {
      'active' => FocusSessionStatus.active,
      'completed' => FocusSessionStatus.completed,
      'paused' => FocusSessionStatus.paused,
      'cancelled' => FocusSessionStatus.cancelled,
      _ => FocusSessionStatus.completed,
    };
  }

  /// Maps FocusSessionStatus enum to string.
  String _mapStatusToString(FocusSessionStatus status) {
    return switch (status) {
      FocusSessionStatus.active => 'active',
      FocusSessionStatus.completed => 'completed',
      FocusSessionStatus.paused => 'paused',
      FocusSessionStatus.cancelled => 'cancelled',
    };
  }

  /// Returns the Monday of the week containing the given date.
  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }
}
