/// Academic Repository Interface.
/// Defines contract for academic profile and subject data operations.
/// 
/// Layer: Domain
/// Responsibility: Abstract data access for academic entities.
/// Implementation: Data layer provides concrete implementation.
library;

import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';

abstract class AcademicRepository {
  /// Retrieves the current academic profile.
  Future<Result<AcademicProfile?>> getAcademicProfile();

  /// Saves or updates the academic profile.
  Future<Result<void>> saveAcademicProfile(AcademicProfile profile);

  /// Retrieves all available subjects.
  Future<Result<List<Subject>>> getAllSubjects();

  /// Retrieves subjects for the current semester.
  Future<Result<List<Subject>>> getEnrolledSubjects();

  /// Checks if onboarding has been completed.
  Future<Result<bool>> isOnboardingComplete();

  /// Marks onboarding as complete.
  Future<Result<void>> completeOnboarding();

  /// Checks if the user has completed their academic profile setup.
  /// Returns true if profile exists and has all required fields populated.
  Future<Result<bool>> hasCompletedProfile();

  /// Saves a list of subjects.
  Future<Result<void>> saveSubjects(List<Subject> subjects);
}
