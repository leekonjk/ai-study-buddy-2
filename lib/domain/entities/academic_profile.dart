/// Academic Profile Entity.
/// Represents the student's academic identity and program information.
///
/// Layer: Domain
/// Responsibility: Core identity model for the student.
/// Inputs: Onboarding data (program, semester, subjects).
/// Outputs: Used by AI services to contextualize recommendations.
library;

class AcademicProfile {
  final String id;
  final String studentName;
  final String universityName;
  final String programName; // e.g., "BS Computer Science"
  final int currentSemester;
  final List<String> enrolledSubjectIds;
  final DateTime enrollmentDate;
  final DateTime? lastUpdated;
  final List<String> weakAreas; // Added for AI
  final List<String> goals; // Added for AI

  const AcademicProfile({
    required this.id,
    required this.studentName,
    required this.universityName,
    required this.programName,
    required this.currentSemester,
    required this.enrolledSubjectIds,
    required this.enrollmentDate,
    this.lastUpdated,
    this.weakAreas = const [],
    this.goals = const [],
  });

  AcademicProfile copyWith({
    String? id,
    String? studentName,
    String? universityName,
    String? programName,
    int? currentSemester,
    List<String>? enrolledSubjectIds,
    DateTime? enrollmentDate,
    DateTime? lastUpdated,
    List<String>? weakAreas,
    List<String>? goals,
  }) {
    return AcademicProfile(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      universityName: universityName ?? this.universityName,
      programName: programName ?? this.programName,
      currentSemester: currentSemester ?? this.currentSemester,
      enrolledSubjectIds: enrolledSubjectIds ?? this.enrolledSubjectIds,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      weakAreas: weakAreas ?? this.weakAreas,
      goals: goals ?? this.goals,
    );
  }
}
