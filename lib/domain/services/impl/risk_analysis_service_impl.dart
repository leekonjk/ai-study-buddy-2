/// RiskAnalysisServiceImpl
/// 
/// Pure Dart implementation of academic risk analysis.
/// Uses deterministic, rule-based logic to detect at-risk subjects early.
/// 
/// Layer: Domain (Implementation)
/// Dependencies: None (pure logic, no Flutter/Firebase/repositories)
/// 
/// Risk Analysis Algorithm:
/// 1. Mastery factor: low mastery = higher risk
/// 2. Productivity factor: poor focus patterns = higher risk
/// 3. Engagement factor: missed sessions = higher risk
/// 4. Time factor: deadline proximity increases urgency
/// 5. Weighted combination produces final risk score
library;

import 'package:studnet_ai_buddy/domain/entities/focus_session.dart';
import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';
import 'package:studnet_ai_buddy/domain/entities/risk_assessment.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/domain/services/risk_analysis_service.dart';

class RiskAnalysisServiceImpl implements RiskAnalysisService {
  // Risk thresholds for classification
  static const double _lowRiskThreshold = 0.3;
  static const double _moderateRiskThreshold = 0.5;
  static const double _highRiskThreshold = 0.7;

  // Factor weights for risk calculation
  static const double _masteryWeight = 0.40;
  static const double _productivityWeight = 0.25;
  static const double _engagementWeight = 0.20;
  static const double _deadlineWeight = 0.15;

  // Minimum sessions expected per week for healthy engagement
  static const int _expectedWeeklySessions = 3;

  // Days to look back for recent session analysis
  static const int _recentDaysWindow = 7;

  @override
  Future<RiskAssessment> analyzeSubjectRisk({
    required Subject subject,
    required KnowledgeLevel knowledgeLevel,
    required List<FocusSession> recentSessions,
    DateTime? upcomingDeadline,
  }) async {
    // Filter sessions for this subject
    final subjectSessions = recentSessions
        .where((s) => s.subjectId == subject.id)
        .toList();

    // Calculate individual risk factors
    final masteryFactor = _calculateMasteryRiskFactor(knowledgeLevel);
    final productivityFactor = _calculateProductivityRiskFactor(subjectSessions);
    final engagementFactor = _calculateEngagementRiskFactor(subjectSessions);
    final deadlineFactor = _calculateDeadlineRiskFactor(upcomingDeadline);

    // Build contributing factors list
    final contributingFactors = <RiskFactor>[];

    if (masteryFactor.weight > 0.2) {
      contributingFactors.add(masteryFactor);
    }
    if (productivityFactor.weight > 0.2) {
      contributingFactors.add(productivityFactor);
    }
    if (engagementFactor.weight > 0.2) {
      contributingFactors.add(engagementFactor);
    }
    if (deadlineFactor.weight > 0.2) {
      contributingFactors.add(deadlineFactor);
    }

    // Calculate weighted risk score
    final riskScore = _calculateWeightedRiskScore(
      masteryFactor: masteryFactor,
      productivityFactor: productivityFactor,
      engagementFactor: engagementFactor,
      deadlineFactor: deadlineFactor,
    );

    // Classify risk level
    final riskLevel = _classifyRiskLevel(riskScore);

    // Generate explanation and recommendations
    final explanation = generateRiskExplanation(
      riskScore: riskScore,
      factors: contributingFactors,
    );

    final recommendations = generateRecommendations(
      riskLevel: riskLevel,
      factors: contributingFactors,
    );

    return RiskAssessment(
      id: 'risk_${subject.id}_${DateTime.now().millisecondsSinceEpoch}',
      subjectId: subject.id,
      riskScore: riskScore,
      riskLevel: riskLevel,
      contributingFactors: contributingFactors,
      aiExplanation: explanation,
      recommendedActions: recommendations,
      assessedAt: DateTime.now(),
    );
  }

  @override
  Future<List<RiskAssessment>> analyzeAllSubjects({
    required List<Subject> subjects,
    required List<KnowledgeLevel> knowledgeLevels,
    required List<FocusSession> recentSessions,
  }) async {
    final assessments = <RiskAssessment>[];

    for (final subject in subjects) {
      // Find knowledge level for this subject
      final knowledgeLevel = _findKnowledgeLevel(subject.id, knowledgeLevels);

      if (knowledgeLevel == null) {
        // No knowledge data - create assessment with unknown mastery
        final defaultLevel = KnowledgeLevel(
          subjectId: subject.id,
          masteryScore: 0.5, // Assume average if unknown
          confidenceScore: 0.0, // No confidence
          estimatedAt: DateTime.now(),
          reasoningNote: 'No assessment data available',
        );

        final assessment = await analyzeSubjectRisk(
          subject: subject,
          knowledgeLevel: defaultLevel,
          recentSessions: recentSessions,
          upcomingDeadline: null,
        );
        assessments.add(assessment);
      } else {
        final assessment = await analyzeSubjectRisk(
          subject: subject,
          knowledgeLevel: knowledgeLevel,
          recentSessions: recentSessions,
          upcomingDeadline: null,
        );
        assessments.add(assessment);
      }
    }

    // Sort by risk score (highest risk first)
    assessments.sort((a, b) => b.riskScore.compareTo(a.riskScore));

    return assessments;
  }

  @override
  List<String> generateRecommendations({
    required RiskLevel riskLevel,
    required List<RiskFactor> factors,
  }) {
    final recommendations = <String>[];

    // Risk-level based general recommendations
    switch (riskLevel) {
      case RiskLevel.critical:
        recommendations.add('Seek immediate help from instructor or tutor');
        recommendations.add('Dedicate extra study time this week');
        break;
      case RiskLevel.high:
        recommendations.add('Increase study frequency for this subject');
        recommendations.add('Review foundational concepts');
        break;
      case RiskLevel.moderate:
        recommendations.add('Maintain consistent study schedule');
        break;
      case RiskLevel.low:
        recommendations.add('Continue current study approach');
        break;
    }

    // Factor-specific recommendations
    for (final factor in factors) {
      if (factor.name == 'Low Mastery' && factor.weight > 0.3) {
        recommendations.add('Take diagnostic quiz to identify knowledge gaps');
      }
      if (factor.name == 'Low Productivity' && factor.weight > 0.3) {
        recommendations.add('Try shorter, focused study sessions (25 min)');
        recommendations.add('Reduce distractions during study time');
      }
      if (factor.name == 'Low Engagement' && factor.weight > 0.3) {
        recommendations.add('Schedule regular study blocks in calendar');
        recommendations.add('Set daily study reminders');
      }
      if (factor.name == 'Deadline Pressure' && factor.weight > 0.3) {
        recommendations.add('Prioritize this subject in daily schedule');
        recommendations.add('Break remaining work into smaller tasks');
      }
    }

    // Remove duplicates and limit to 5 recommendations
    return recommendations.toSet().take(5).toList();
  }

  @override
  String generateRiskExplanation({
    required double riskScore,
    required List<RiskFactor> factors,
  }) {
    final buffer = StringBuffer();
    final riskLevel = _classifyRiskLevel(riskScore);
    final riskPercentage = (riskScore * 100).toStringAsFixed(0);

    // Opening statement
    buffer.write('Risk assessment: ${riskLevel.name.toUpperCase()} ($riskPercentage%). ');

    if (factors.isEmpty) {
      buffer.write('No significant risk factors detected. ');
      buffer.write('Continue maintaining your current study habits.');
      return buffer.toString();
    }

    // Explain contributing factors
    buffer.write('Contributing factors: ');

    final factorDescriptions = factors
        .map((f) => '${f.name} (${(f.weight * 100).toStringAsFixed(0)}% impact)')
        .join(', ');
    buffer.write(factorDescriptions);
    buffer.write('. ');

    // Primary concern
    final primaryFactor = factors.reduce(
      (a, b) => a.weight > b.weight ? a : b,
    );
    buffer.write('Primary concern: ${primaryFactor.description}');

    return buffer.toString();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helper Methods - Risk Factor Calculations
  // ─────────────────────────────────────────────────────────────────────────

  /// Calculates risk factor from mastery level.
  /// Lower mastery = higher risk.
  RiskFactor _calculateMasteryRiskFactor(KnowledgeLevel level) {
    // Invert mastery: 0.0 mastery = 1.0 risk, 1.0 mastery = 0.0 risk
    final riskContribution = 1.0 - level.masteryScore;

    // Adjust by confidence - low confidence adds uncertainty
    final confidenceAdjustment = (1.0 - level.confidenceScore) * 0.2;
    final adjustedRisk = (riskContribution + confidenceAdjustment).clamp(0.0, 1.0);

    String description;
    if (adjustedRisk > 0.6) {
      description = 'Knowledge gaps require immediate attention';
    } else if (adjustedRisk > 0.3) {
      description = 'Some concepts need reinforcement';
    } else {
      description = 'Mastery is adequate';
    }

    return RiskFactor(
      name: 'Low Mastery',
      weight: adjustedRisk,
      description: description,
    );
  }

  /// Calculates risk factor from focus session productivity.
  /// Low efficiency and high distractions = higher risk.
  RiskFactor _calculateProductivityRiskFactor(List<FocusSession> sessions) {
    if (sessions.isEmpty) {
      return const RiskFactor(
        name: 'Unknown Productivity',
        weight: 0.3, // Moderate risk for unknown
        description: 'No study session data available',
      );
    }

    // Calculate average efficiency
    final completedSessions = sessions
        .where((s) => s.status == FocusSessionStatus.completed)
        .toList();

    if (completedSessions.isEmpty) {
      return const RiskFactor(
        name: 'Low Productivity',
        weight: 0.5,
        description: 'No completed study sessions recently',
      );
    }

    double totalEfficiency = 0.0;
    int totalDistractions = 0;
    int sessionsWithEfficiency = 0;

    for (final session in completedSessions) {
      final efficiency = session.efficiency;
      if (efficiency != null) {
        totalEfficiency += efficiency;
        sessionsWithEfficiency++;
      }
      totalDistractions += session.distractionsCount ?? 0;
    }

    final avgEfficiency = sessionsWithEfficiency > 0
        ? totalEfficiency / sessionsWithEfficiency
        : 0.8; // Default to decent efficiency

    final avgDistractions = totalDistractions / completedSessions.length;

    // Risk increases with low efficiency and high distractions
    final efficiencyRisk = 1.0 - avgEfficiency.clamp(0.0, 1.0);
    final distractionRisk = (avgDistractions / 5.0).clamp(0.0, 1.0); // 5+ = max risk

    final combinedRisk = (efficiencyRisk * 0.6 + distractionRisk * 0.4).clamp(0.0, 1.0);

    String description;
    if (combinedRisk > 0.5) {
      description = 'Study sessions are frequently interrupted or incomplete';
    } else if (combinedRisk > 0.2) {
      description = 'Some room for improvement in focus quality';
    } else {
      description = 'Good focus during study sessions';
    }

    return RiskFactor(
      name: 'Low Productivity',
      weight: combinedRisk,
      description: description,
    );
  }

  /// Calculates risk factor from study engagement frequency.
  /// Fewer sessions than expected = higher risk.
  RiskFactor _calculateEngagementRiskFactor(List<FocusSession> sessions) {
    // Filter to recent sessions only
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: _recentDaysWindow));

    final recentSessions = sessions
        .where((s) => s.startTime.isAfter(cutoffDate))
        .toList();

    final sessionCount = recentSessions.length;

    // Compare to expected sessions per week
    final engagementRatio = sessionCount / _expectedWeeklySessions;
    final engagementRisk = (1.0 - engagementRatio).clamp(0.0, 1.0);

    String description;
    if (sessionCount == 0) {
      description = 'No study activity in the past week';
    } else if (engagementRisk > 0.5) {
      description = 'Study frequency is below recommended level';
    } else if (engagementRisk > 0.2) {
      description = 'Study frequency could be improved';
    } else {
      description = 'Good study engagement';
    }

    return RiskFactor(
      name: 'Low Engagement',
      weight: engagementRisk,
      description: description,
    );
  }

  /// Calculates risk factor from deadline proximity.
  /// Closer deadline with low preparation = higher risk.
  RiskFactor _calculateDeadlineRiskFactor(DateTime? deadline) {
    if (deadline == null) {
      return const RiskFactor(
        name: 'Deadline Pressure',
        weight: 0.0,
        description: 'No upcoming deadline',
      );
    }

    final now = DateTime.now();
    final daysUntilDeadline = deadline.difference(now).inDays;

    double deadlineRisk;
    String description;

    if (daysUntilDeadline <= 0) {
      deadlineRisk = 1.0;
      description = 'Deadline has passed or is today';
    } else if (daysUntilDeadline <= 3) {
      deadlineRisk = 0.9;
      description = 'Deadline within 3 days - urgent';
    } else if (daysUntilDeadline <= 7) {
      deadlineRisk = 0.6;
      description = 'Deadline within 1 week - high priority';
    } else if (daysUntilDeadline <= 14) {
      deadlineRisk = 0.3;
      description = 'Deadline within 2 weeks - plan ahead';
    } else {
      deadlineRisk = 0.1;
      description = 'Deadline is not immediate';
    }

    return RiskFactor(
      name: 'Deadline Pressure',
      weight: deadlineRisk,
      description: description,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helper Methods - Risk Calculation
  // ─────────────────────────────────────────────────────────────────────────

  /// Calculates weighted risk score from all factors.
  double _calculateWeightedRiskScore({
    required RiskFactor masteryFactor,
    required RiskFactor productivityFactor,
    required RiskFactor engagementFactor,
    required RiskFactor deadlineFactor,
  }) {
    final weightedScore = (masteryFactor.weight * _masteryWeight) +
        (productivityFactor.weight * _productivityWeight) +
        (engagementFactor.weight * _engagementWeight) +
        (deadlineFactor.weight * _deadlineWeight);

    return weightedScore.clamp(0.0, 1.0);
  }

  /// Classifies risk level from score.
  RiskLevel _classifyRiskLevel(double riskScore) {
    if (riskScore >= _highRiskThreshold) {
      return RiskLevel.critical;
    } else if (riskScore >= _moderateRiskThreshold) {
      return RiskLevel.high;
    } else if (riskScore >= _lowRiskThreshold) {
      return RiskLevel.moderate;
    } else {
      return RiskLevel.low;
    }
  }

  /// Finds knowledge level for a subject.
  KnowledgeLevel? _findKnowledgeLevel(String subjectId, List<KnowledgeLevel> levels) {
    for (final level in levels) {
      if (level.subjectId == subjectId && level.topicId == null) {
        return level;
      }
    }
    return null;
  }
}
