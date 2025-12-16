/// Academic Repository Implementation.
/// Concrete implementation of AcademicRepository interface using Firebase Firestore.
/// 
/// Layer: Data
/// Responsibility: Data operations for academic profile and subjects via Firestore.
/// 
/// Firestore Collections Used:
/// - students: Basic student info (studentId as document ID)
/// - academic_profiles: Academic program data (studentId as document ID)
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studnet_ai_buddy/core/errors/failures.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';

class AcademicRepositoryImpl implements AcademicRepository {
  final FirebaseFirestore _firestore;
  final String _currentStudentId;

  // Firestore collection names (per schema)
  static const String _studentsCollection = 'students';
  static const String _academicProfilesCollection = 'academic_profiles';

  AcademicRepositoryImpl({
    required FirebaseFirestore firestore,
    required String currentStudentId,
  })  : _firestore = firestore,
        _currentStudentId = currentStudentId;

  // ─────────────────────────────────────────────────────────────────────────
  // Academic Profile Operations
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<AcademicProfile?>> getAcademicProfile() async {
    try {
      final doc = await _firestore
          .collection(_academicProfilesCollection)
          .doc(_currentStudentId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return const Success(null);
      }

      final profile = _mapDocumentToAcademicProfile(doc);
      return Success(profile);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to fetch academic profile: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> saveAcademicProfile(AcademicProfile profile) async {
    try {
      final data = _mapAcademicProfileToDocument(profile);

      await _firestore
          .collection(_academicProfilesCollection)
          .doc(_currentStudentId)
          .set(data, SetOptions(merge: true));

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to save academic profile: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Subject Operations
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<List<Subject>>> getAllSubjects() async {
    try {
      // Subjects are embedded in academic_profiles per schema
      final profileResult = await getAcademicProfile();

      return profileResult.fold(
        onSuccess: (profile) {
          if (profile == null) return const Success(<Subject>[]);

          // Fetch subjects from the profile document
          return _getSubjectsFromProfile();
        },
        onFailure: (failure) => Err(failure),
      );
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<Subject>>> getEnrolledSubjects() async {
    // Per schema, all subjects in academic_profiles.subjects are enrolled
    return getAllSubjects();
  }

  /// Fetches subjects array from academic profile document.
  Future<Result<List<Subject>>> _getSubjectsFromProfile() async {
    try {
      final doc = await _firestore
          .collection(_academicProfilesCollection)
          .doc(_currentStudentId)
          .get();

      if (!doc.exists || doc.data() == null) {
        return const Success([]);
      }

      final data = doc.data()!;
      final subjectsData = data['subjects'] as List<dynamic>? ?? [];

      final subjects = subjectsData
          .map((s) => _mapDocumentToSubject(s as Map<String, dynamic>))
          .toList();

      return Success(subjects);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to fetch subjects: ${e.message}',
        code: e.code,
      ));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Onboarding Status
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<Result<bool>> isOnboardingComplete() async {
    try {
      final doc = await _firestore
          .collection(_academicProfilesCollection)
          .doc(_currentStudentId)
          .get();

      // Onboarding is complete if academic profile exists with subjects
      if (!doc.exists || doc.data() == null) {
        return const Success(false);
      }

      final data = doc.data()!;
      final subjects = data['subjects'] as List<dynamic>? ?? [];

      return Success(subjects.isNotEmpty);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to check onboarding status: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> completeOnboarding() async {
    // Onboarding completion is implicit when profile is saved with subjects
    // Update the student's lastActiveAt timestamp
    try {
      await _firestore
          .collection(_studentsCollection)
          .doc(_currentStudentId)
          .set({
        'lastActiveAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to complete onboarding: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping: Firestore Document → Domain Entity
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps Firestore document to AcademicProfile domain entity.
  /// 
  /// Firestore schema (academic_profiles):
  /// - studentId: string
  /// - degreeProgram: string
  /// - semester: int
  /// - institution: string
  /// - subjects: array of {subjectId, name, creditHours}
  /// - dailyStudyMinutes: int
  /// - createdAt: timestamp
  /// - updatedAt: timestamp
  AcademicProfile _mapDocumentToAcademicProfile(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    // Extract subject IDs from embedded subjects array
    final subjectsData = data['subjects'] as List<dynamic>? ?? [];
    final enrolledSubjectIds = subjectsData
        .map((s) => (s as Map<String, dynamic>)['subjectId'] as String)
        .toList();

    // Parse timestamps
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();

    return AcademicProfile(
      id: data['studentId'] as String? ?? doc.id,
      studentName: '', // Name is in students collection, not here
      programName: data['degreeProgram'] as String? ?? '',
      currentSemester: data['semester'] as int? ?? 1,
      enrolledSubjectIds: enrolledSubjectIds,
      enrollmentDate: createdAt,
      lastUpdated: updatedAt,
    );
  }

  /// Maps embedded subject data to Subject domain entity.
  /// 
  /// Firestore schema (subjects array item):
  /// - subjectId: string
  /// - name: string
  /// - creditHours: int
  Subject _mapDocumentToSubject(Map<String, dynamic> data) {
    return Subject(
      id: data['subjectId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      code: '', // Not in schema, can be derived or added later
      creditHours: data['creditHours'] as int? ?? 3,
      difficulty: SubjectDifficulty.intermediate, // Default, can be enhanced
      topicIds: [], // Not in current schema
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping: Domain Entity → Firestore Document
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps AcademicProfile domain entity to Firestore document data.
  Map<String, dynamic> _mapAcademicProfileToDocument(AcademicProfile profile) {
    return {
      'studentId': _currentStudentId,
      'degreeProgram': profile.programName,
      'semester': profile.currentSemester,
      'institution': '', // Can be added to entity if needed
      'dailyStudyMinutes': 120, // Default, can be made configurable
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      // Note: subjects array should be set separately via saveSubjects method
    };
  }

  /// Maps Subject domain entity to Firestore document data (for embedding).
  Map<String, dynamic> _mapSubjectToDocument(Subject subject) {
    return {
      'subjectId': subject.id,
      'name': subject.name,
      'creditHours': subject.creditHours,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Additional Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  /// Saves subjects to the academic profile.
  /// Call this during onboarding after subject selection.
  Future<Result<void>> saveSubjects(List<Subject> subjects) async {
    try {
      final subjectsData = subjects.map(_mapSubjectToDocument).toList();

      await _firestore
          .collection(_academicProfilesCollection)
          .doc(_currentStudentId)
          .set({
        'subjects': subjectsData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to save subjects: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }
}
