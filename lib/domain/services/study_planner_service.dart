/// Study Planner Service.
/// AI-driven service to generate personalized study plans.
/// 
/// Layer: Domain
/// Responsibility: Create weekly study plans based on knowledge gaps.
/// Inputs: Knowledge levels, academic calendar, risk assessments.
/// Outputs: StudyPlan with prioritized tasks and AI reasoning.
library;

import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';
import 'package:studnet_ai_buddy/domain/entities/knowledge_level.dart';
import 'package:studnet_ai_buddy/domain/entities/risk_assessment.dart';
import 'package:studnet_ai_buddy/domain/entities/study_plan.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';

abstract class StudyPlannerService {
  /// Generates a weekly study plan based on current knowledge state.
  /// Prioritizes subjects with low mastery and high risk.
  Future<StudyPlan> generateWeeklyPlan({
    required AcademicProfile profile,
    required List<Subject> subjects,
    required List<KnowledgeLevel> knowledgeLevels,
    required List<RiskAssessment> riskAssessments,
    required DateTime weekStart,
  });

  /// Adjusts existing plan based on new performance data.
  /// Called when knowledge levels are updated mid-week.
  Future<StudyPlan> adjustPlan({
    required StudyPlan currentPlan,
    required List<KnowledgeLevel> updatedLevels,
  });

  /// Generates AI summary explaining the week's plan rationale.
  String generatePlanSummary({
    required List<KnowledgeLevel> knowledgeLevels,
    required List<RiskAssessment> riskAssessments,
  });

  /// Calculates optimal study time distribution across subjects.
  Map<String, int> calculateTimeAllocation({
    required List<Subject> subjects,
    required List<KnowledgeLevel> knowledgeLevels,
    required int availableMinutesPerDay,
  });
}
