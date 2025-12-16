/// Academic Profile Data Model.
/// DTO for serialization/deserialization of AcademicProfile entity.
/// 
/// Layer: Data
/// Responsibility: JSON conversion for local storage and API.
library;

import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';

class AcademicProfileModel extends AcademicProfile {
  const AcademicProfileModel({
    required super.id,
    required super.studentName,
    required super.programName,
    required super.currentSemester,
    required super.enrolledSubjectIds,
    required super.enrollmentDate,
    super.lastUpdated,
  });

  factory AcademicProfileModel.fromJson(Map<String, dynamic> json) {
    return AcademicProfileModel(
      id: json['id'] as String,
      studentName: json['studentName'] as String,
      programName: json['programName'] as String,
      currentSemester: json['currentSemester'] as int,
      enrolledSubjectIds: List<String>.from(json['enrolledSubjectIds'] as List),
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'programName': programName,
      'currentSemester': currentSemester,
      'enrolledSubjectIds': enrolledSubjectIds,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory AcademicProfileModel.fromEntity(AcademicProfile entity) {
    return AcademicProfileModel(
      id: entity.id,
      studentName: entity.studentName,
      programName: entity.programName,
      currentSemester: entity.currentSemester,
      enrolledSubjectIds: entity.enrolledSubjectIds,
      enrollmentDate: entity.enrollmentDate,
      lastUpdated: entity.lastUpdated,
    );
  }
}
