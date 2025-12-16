/// Subject Data Model.
/// DTO for serialization/deserialization of Subject entity.
/// 
/// Layer: Data
/// Responsibility: JSON conversion for local storage and API.
library;

import 'package:studnet_ai_buddy/domain/entities/subject.dart';

class SubjectModel extends Subject {
  const SubjectModel({
    required super.id,
    required super.name,
    required super.code,
    required super.creditHours,
    required super.difficulty,
    required super.topicIds,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      creditHours: json['creditHours'] as int,
      difficulty: SubjectDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
      ),
      topicIds: List<String>.from(json['topicIds'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'creditHours': creditHours,
      'difficulty': difficulty.name,
      'topicIds': topicIds,
    };
  }

  factory SubjectModel.fromEntity(Subject entity) {
    return SubjectModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      creditHours: entity.creditHours,
      difficulty: entity.difficulty,
      topicIds: entity.topicIds,
    );
  }
}
