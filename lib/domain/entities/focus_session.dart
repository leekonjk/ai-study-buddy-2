/// Focus Session Entity.
/// Represents a timed study session for productivity tracking.
/// 
/// Layer: Domain
/// Responsibility: Track focused study time per subject/task.
/// Inputs: User-initiated focus sessions.
/// Outputs: Used for productivity analysis, AI behavioral insights.
library;

class FocusSession {
  final String id;
  final String? taskId; // Optional link to a study task
  final String? subjectId;
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedMinutes;
  final int? actualMinutes;
  final FocusSessionStatus status;
  final int? distractionsCount; // Self-reported or detected

  const FocusSession({
    required this.id,
    this.taskId,
    this.subjectId,
    required this.startTime,
    this.endTime,
    required this.plannedMinutes,
    this.actualMinutes,
    required this.status,
    this.distractionsCount,
  });

  /// Returns focus efficiency as a ratio.
  double? get efficiency {
    if (actualMinutes == null || plannedMinutes == 0) return null;
    return actualMinutes! / plannedMinutes;
  }

  /// Computed getter for actual duration in minutes.
  /// Returns actualMinutes if set, otherwise calculates from start/end time.
  int get actualDurationMinutes {
    if (actualMinutes != null) return actualMinutes!;
    if (endTime == null) {
      return DateTime.now().difference(startTime).inMinutes;
    }
    return endTime!.difference(startTime).inMinutes;
  }

  /// Computed getter for distraction count (alias for distractionsCount).
  int get distractionCount => distractionsCount ?? 0;

  FocusSession copyWith({
    String? id,
    String? taskId,
    String? subjectId,
    DateTime? startTime,
    DateTime? endTime,
    int? plannedMinutes,
    int? actualMinutes,
    FocusSessionStatus? status,
    int? distractionsCount,
  }) {
    return FocusSession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      subjectId: subjectId ?? this.subjectId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      plannedMinutes: plannedMinutes ?? this.plannedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      status: status ?? this.status,
      distractionsCount: distractionsCount ?? this.distractionsCount,
    );
  }
}

enum FocusSessionStatus {
  active,
  completed,
  paused,
  cancelled,
}

/// Alias for FocusSessionStatus for UI compatibility.
typedef SessionStatus = FocusSessionStatus;
