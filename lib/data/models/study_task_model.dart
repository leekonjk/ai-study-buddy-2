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
    required super.subjectId,
    super.topicId,
    required super.title,
    required super.description,
    required super.estimatedMinutes,
    required super.priority,
    required super.type,
    required super.scheduledDate,
    super.completedAt,
    required super.aiReasoning,
  });

  factory StudyTaskModel.fromJson(Map<String, dynamic> json) {
    return StudyTaskModel(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      topicId: json['topicId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      estimatedMinutes: json['estimatedMinutes'] as int,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
      ),
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      aiReasoning: json['aiReasoning'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'topicId': topicId,
      'title': title,
      'description': description,
      'estimatedMinutes': estimatedMinutes,
      'priority': priority.name,
      'type': type.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'aiReasoning': aiReasoning,
    };
  }

  factory StudyTaskModel.fromEntity(StudyTask entity) {
    return StudyTaskModel(
      id: entity.id,
      subjectId: entity.subjectId,
      topicId: entity.topicId,
      title: entity.title,
      description: entity.description,
      estimatedMinutes: entity.estimatedMinutes,
      priority: entity.priority,
      type: entity.type,
      scheduledDate: entity.scheduledDate,
      completedAt: entity.completedAt,
      aiReasoning: entity.aiReasoning,
    );
  }
}
