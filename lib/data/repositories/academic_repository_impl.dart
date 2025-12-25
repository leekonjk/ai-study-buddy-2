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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:studnet_ai_buddy/core/errors/failures.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/academic_profile.dart';
import 'package:studnet_ai_buddy/domain/entities/subject.dart';
import 'package:studnet_ai_buddy/domain/repositories/academic_repository.dart';

class AcademicRepositoryImpl implements AcademicRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Firestore collection names (per schema)
  static const String _studentsCollection = 'students';
  static const String _academicProfilesCollection = 'academic_profiles';

  AcademicRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  String get _currentStudentId => _auth.currentUser?.uid ?? '';

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
      final uid = _currentStudentId;
      debugPrint('saving profile for uid: "$uid"');
      if (uid.isEmpty) {
        debugPrint('ERROR: User ID is empty. Auth state: ${_auth.currentUser}');
        return const Err(NetworkFailure(message: 'User not authenticated'));
      }
      
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

  @override
  Future<Result<bool>> hasCompletedProfile() async {
    try {
      debugPrint('Checking if profile is complete...');
      final profileResult = await getAcademicProfile();

      return profileResult.fold(
        onSuccess: (profile) {
          if (profile == null) {
            debugPrint('Profile is null - incomplete');
            return const Success(false);
          }
          
          // Profile is complete if all required fields are populated
          final hasRequiredFields = profile.studentName.isNotEmpty &&
              profile.programName.isNotEmpty &&
              profile.enrolledSubjectIds.isNotEmpty;
          
          debugPrint('Profile validation:');
          debugPrint('  - studentName: "${profile.studentName}" (${profile.studentName.isNotEmpty ? "✓" : "✗"})');
          debugPrint('  - programName: "${profile.programName}" (${profile.programName.isNotEmpty ? "✓" : "✗"})');
          debugPrint('  - subjects: ${profile.enrolledSubjectIds.length} (${profile.enrolledSubjectIds.isNotEmpty ? "✓" : "✗"})');
          debugPrint('Profile complete: $hasRequiredFields');
          
          return Success(hasRequiredFields);
        },
        onFailure: (failure) {
          debugPrint('Failed to get profile: ${failure.message}');
          return const Success(false);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Exception in hasCompletedProfile: $e');
      debugPrint('StackTrace: $stackTrace');
      return const Success(false);
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
      studentName: data['studentName'] as String? ?? '', // ✅ FIX: Read from Firestore
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
    // Parse topics array
    final topics = (data['topics'] as List<dynamic>?)
            ?.map((t) => t.toString())
            .toList() ??
        [];

    return Subject(
      id: data['subjectId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      code: data['code'] as String? ?? '', 
      creditHours: data['creditHours'] as int? ?? 3,
      difficulty: SubjectDifficulty.intermediate, 
      topicIds: topics,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Mapping: Domain Entity → Firestore Document
  // ─────────────────────────────────────────────────────────────────────────

  /// Maps AcademicProfile domain entity to Firestore document data.
  Map<String, dynamic> _mapAcademicProfileToDocument(AcademicProfile profile) {
    // Build subjects array from enrolledSubjectIds
    // Note: This relies on fetching full subject data first, but for seeding 
    // we assume the logic injects full data. In a real app we'd query a master list.
    // For now, simpler mapping is acceptable as we don't have the full Subject object 
    // passed here, only the list of IDs in the entity. 
    // However, saveSubjects() passes full Subject objects.
    
    // Fallback: This method might lose data if we only rely on IDs.
    // But since saveSubjects updates the subjects array directly, 
    // we should rely on saveSubjects for subject updates.
    
    return {
      'studentId': _currentStudentId,
      'studentName': profile.studentName, 
      'degreeProgram': profile.programName,
      'semester': profile.currentSemester,
      'institution': '', 
      // 'subjects': ... // We avoid overwriting subjects here to avoid data loss
      // if we only have IDs. The profile save logic should arguably be separate
      // from subject enrollment.
      // But keeping existing logic for now.
      'dailyStudyMinutes': 120, 
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Maps Subject domain entity to Firestore document data.
  Map<String, dynamic> _mapSubjectToDocument(Subject subject) {
    return {
      'subjectId': subject.id,
      'name': subject.name,
      'code': subject.code,
      'creditHours': subject.creditHours,
      'topics': subject.topicIds,
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
