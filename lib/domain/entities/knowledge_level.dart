/// Knowledge Level Entity.
/// Represents the estimated knowledge state for a subject or topic.
/// 
/// Layer: Domain
/// Responsibility: Captures AI-estimated mastery levels from diagnostics.
/// Inputs: Diagnostic quiz results, adaptive quiz performance.
/// Outputs: Used by study planner and risk analysis services.
library;

class KnowledgeLevel {
  final String subjectId;
  final String? topicId; // null means subject-level aggregate
  final double masteryScore; // 0.0 to 1.0
  final double confidenceScore; // AI's confidence in the estimate
  final DateTime estimatedAt;
  final String? reasoningNote; // AI explanation for the estimate

  const KnowledgeLevel({
    required this.subjectId,
    this.topicId,
    required this.masteryScore,
    required this.confidenceScore,
    required this.estimatedAt,
    this.reasoningNote,
  });

  /// Returns a human-readable mastery label.
  String get masteryLabel {
    if (masteryScore >= 0.8) return 'Strong';
    if (masteryScore >= 0.6) return 'Moderate';
    if (masteryScore >= 0.4) return 'Developing';
    return 'Needs Focus';
  }

  /// Returns true if this knowledge level indicates a learning gap.
  bool get isGap => masteryScore < 0.4;
}
