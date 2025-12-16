/// Subject Entity.
/// Represents an academic subject/course the student is enrolled in.
/// 
/// Layer: Domain
/// Responsibility: Subject metadata and credit information.
/// Inputs: Academic catalog data.
/// Outputs: Used for scheduling, knowledge tracking, risk analysis.
library;

class Subject {
  final String id;
  final String name;
  final String code; // e.g., "CS-301"
  final int creditHours;
  final SubjectDifficulty difficulty;
  final List<String> topicIds;

  const Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.creditHours,
    required this.difficulty,
    required this.topicIds,
  });
}

/// Difficulty level assigned to subjects for AI planning.
enum SubjectDifficulty {
  introductory,
  intermediate,
  advanced,
}
