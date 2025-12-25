/// Study Task Data Model.
/// DTO for serialization/deserialization of StudyTask entity.
/// 
/// Layer: Data
/// Responsibility: JSON conversion for local storage.
library;

import 'package:studnet_ai_buddy/domain/entities/study_task.dart';

class StudyTaskModel extends StudyTask {
  const StudyTaskModel({
    required super.id,
    required super.title,
    required super.subjectId,
    required super.date,
    super.estimatedMinutes = 60,
    super.isCompleted = false,
    super.priority = TaskPriority.medium,
    super.type = TaskType.study,
    super.description = '',
    super.aiReasoning = '',
  });

  factory StudyTaskModel.fromJson(Map<String, dynamic> json) {
    return StudyTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subjectId: json['subjectId'] as String,
      date: json['scheduledDate'] != null
          ? DateTime.parse(json['scheduledDate'] as String)
          : DateTime.parse(json['date'] as String),
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 60,
      isCompleted: json['isCompleted'] as bool? ?? 
          (json['completedAt'] != null ? true : false),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskType.study,
      ),
      description: json['description'] as String? ?? '',
      aiReasoning: json['aiReasoning'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subjectId': subjectId,
      'date': date.toIso8601String(),
      'scheduledDate': scheduledDate.toIso8601String(), // Keep for backward compatibility
      'estimatedMinutes': estimatedMinutes,
      'isCompleted': isCompleted,
      'completedAt': isCompleted ? date.toIso8601String() : null, // For backward compatibility
      'priority': priority.name,
      'type': type.name,
      'description': description,
      'aiReasoning': aiReasoning,
    };
  }

  factory StudyTaskModel.fromEntity(StudyTask entity) {
    return StudyTaskModel(
      id: entity.id,
      title: entity.title,
      subjectId: entity.subjectId,
      date: entity.date,
      estimatedMinutes: entity.estimatedMinutes,
      isCompleted: entity.isCompleted,
      priority: entity.priority,
      type: entity.type,
      description: entity.description,
      aiReasoning: entity.aiReasoning,
    );
  }
}
