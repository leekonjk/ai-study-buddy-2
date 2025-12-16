/// Risk Analysis Service.
/// AI-driven service to assess academic risk per subject.
/// 
/// Layer: Domain
/// Responsibility: Identify at-risk subjects with explainable factors.
/// Inputs: Knowledge levels, focus patterns, deadlines.
/// Outputs: RiskAssessment with contributing factors and recommendations.
library;

import 'package:studnet_ai_buddy/domain/entities/focus_session.dart';
import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';
import 'package:studnet_ai_buddy/domain/entities/risk_assessment.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';

abstract class RiskAnalysisService {
  /// Analyzes risk for a single subject.
  /// Considers knowledge gaps, study patterns, and deadlines.
  Future<RiskAssessment> analyzeSubjectRisk({
    required Subject subject,
    required KnowledgeLevel knowledgeLevel,
    required List<FocusSession> recentSessions,
    DateTime? upcomingDeadline,
  });

  /// Analyzes risk for all enrolled subjects.
  Future<List<RiskAssessment>> analyzeAllSubjects({
    required List<Subject> subjects,
    required List<KnowledgeLevel> knowledgeLevels,
    required List<FocusSession> recentSessions,
  });

  /// Generates recommended actions to mitigate risk.
  List<String> generateRecommendations({
    required RiskLevel riskLevel,
    required List<RiskFactor> factors,
  });

  /// Generates human-readable explanation of risk assessment.
  String generateRiskExplanation({
    required double riskScore,
    required List<RiskFactor> factors,
  });
}
