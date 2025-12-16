/// Risk Assessment Entity.
/// Represents AI-analyzed academic risk for a subject.
/// 
/// Layer: Domain
/// Responsibility: Captures risk level with explainable factors.
/// Inputs: Knowledge levels, focus session data, deadlines.
/// Outputs: Displayed on dashboard, triggers AI mentor advice.
library;

class RiskAssessment {
  final String id;
  final String subjectId;
  final double riskScore; // 0.0 (safe) to 1.0 (critical)
  final RiskLevel riskLevel;
  final List<RiskFactor> contributingFactors;
  final String aiExplanation; // Human-readable risk reasoning
  final List<String> recommendedActions;
  final DateTime assessedAt;

  const RiskAssessment({
    required this.id,
    required this.subjectId,
    required this.riskScore,
    required this.riskLevel,
    required this.contributingFactors,
    required this.aiExplanation,
    required this.recommendedActions,
    required this.assessedAt,
  });
}

enum RiskLevel {
  low, // On track
  moderate, // Needs attention
  high, // At risk
  critical, // Immediate intervention needed
}

/// Individual factor contributing to risk score.
class RiskFactor {
  final String name;
  final double weight; // How much this factor contributes
  final String description;

  const RiskFactor({
    required this.name,
    required this.weight,
    required this.description,
  });
}
