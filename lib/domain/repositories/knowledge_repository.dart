/// Knowledge Repository Interface.
/// Defines contract for knowledge level data operations.
/// 
/// Layer: Domain
/// Responsibility: Abstract data access for knowledge assessments.
/// Implementation: Data layer provides concrete implementation.
library;

import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';

abstract class KnowledgeRepository {
  /// Retrieves knowledge levels for all subjects.
  Future<Result<List<KnowledgeLevel>>> getAllKnowledgeLevels();

  /// Retrieves knowledge level for a specific subject.
  Future<Result<KnowledgeLevel?>> getKnowledgeLevelForSubject(String subjectId);

  /// Retrieves knowledge levels for topics within a subject.
  Future<Result<List<KnowledgeLevel>>> getTopicKnowledgeLevels(String subjectId);

  /// Saves or updates a knowledge level.
  Future<Result<void>> saveKnowledgeLevel(KnowledgeLevel level);

  /// Saves multiple knowledge levels (batch update after quiz).
  Future<Result<void>> saveKnowledgeLevels(List<KnowledgeLevel> levels);
}
