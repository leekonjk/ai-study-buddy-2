/// Study Task Entity.
/// Represents a scheduled study task.
library;

class StudyTask {
  final String id;
  final String title;
  final String subjectId;
  final DateTime date;
  final bool isCompleted;
  final int estimatedMinutes;
  final TaskPriority priority;
  final TaskType type;
  final String description;
  final String aiReasoning;

  const StudyTask({
    required this.id,
    required this.title,
    required this.subjectId,
    required this.date,
    this.estimatedMinutes = 60,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.type = TaskType.study,
    this.description = '',
    this.aiReasoning = '',
  });

  // Getter alias for date to satisfy legacy code
  DateTime get scheduledDate => date;

  StudyTask copyWith({
    String? id,
    String? title,
    String? subjectId,
    DateTime? date,
    int? estimatedMinutes,
    bool? isCompleted,
    TaskPriority? priority,
    TaskType? type,
    String? description,
    String? aiReasoning,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      date: date ?? this.date,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      description: description ?? this.description,
      aiReasoning: aiReasoning ?? this.aiReasoning,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subjectId': subjectId,
      'date': date.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'isCompleted': isCompleted,
      'priority': priority.name,
      'type': type.name,
      'description': description,
      'aiReasoning': aiReasoning,
    };
  }

  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      id: json['id'],
      title: json['title'],
      subjectId: json['subjectId'],
      date: DateTime.parse(json['date']),
      estimatedMinutes: json['estimatedMinutes'] ?? 60,
      isCompleted: json['isCompleted'] ?? false,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'], 
        orElse: () => TaskPriority.medium
      ),
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskType.study
      ),
      description: json['description'] ?? '',
      aiReasoning: json['aiReasoning'] ?? '',
    );
  }
}

enum TaskPriority { critical, high, medium, low }
enum TaskType { study, quiz, revision, assignment, learn, review, practice, revise }
