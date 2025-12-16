/// Knowledge Level Data Model.
/// DTO for serialization/deserialization of KnowledgeLevel entity.
/// 
/// Layer: Data
/// Responsibility: JSON conversion for local storage.
library;

import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';

class KnowledgeLevelModel extends KnowledgeLevel {
  const KnowledgeLevelModel({
    required super.subjectId,
    super.topicId,
    required super.masteryScore,
    required super.confidenceScore,
    required super.estimatedAt,
    super.reasoningNote,
  });

  factory KnowledgeLevelModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeLevelModel(
      subjectId: json['subjectId'] as String,
      topicId: json['topicId'] as String?,
      masteryScore: (json['masteryScore'] as num).toDouble(),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      estimatedAt: DateTime.parse(json['estimatedAt'] as String),
      reasoningNote: json['reasoningNote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'topicId': topicId,
      'masteryScore': masteryScore,
      'confidenceScore': confidenceScore,
      'estimatedAt': estimatedAt.toIso8601String(),
      'reasoningNote': reasoningNote,
    };
  }

  factory KnowledgeLevelModel.fromEntity(KnowledgeLevel entity) {
    return KnowledgeLevelModel(
      subjectId: entity.subjectId,
      topicId: entity.topicId,
      masteryScore: entity.masteryScore,
      confidenceScore: entity.confidenceScore,
      estimatedAt: entity.estimatedAt,
      reasoningNote: entity.reasoningNote,
    );
  }
}
