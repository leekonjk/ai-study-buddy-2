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
  final String programName; // e.g., "BS Computer Science"
  final int currentSemester;
  final List<String> enrolledSubjectIds;
  final DateTime enrollmentDate;
  final DateTime? lastUpdated;

  const AcademicProfile({
    required this.id,
    required this.studentName,
    required this.programName,
    required this.currentSemester,
    required this.enrolledSubjectIds,
    required this.enrollmentDate,
    this.lastUpdated,
  });

  AcademicProfile copyWith({
    String? id,
    String? studentName,
    String? programName,
    int? currentSemester,
    List<String>? enrolledSubjectIds,
    DateTime? enrollmentDate,
    DateTime? lastUpdated,
  }) {
    return AcademicProfile(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      programName: programName ?? this.programName,
      currentSemester: currentSemester ?? this.currentSemester,
      enrolledSubjectIds: enrolledSubjectIds ?? this.enrolledSubjectIds,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
