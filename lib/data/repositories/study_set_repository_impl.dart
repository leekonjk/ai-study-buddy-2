/// Study Set Repository Implementation
/// Firestore implementation for study set management.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studnet_ai_buddy/core/errors/failures.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/repositories/study_set_repository.dart';

/// Firestore implementation of StudySetRepository.
class StudySetRepositoryImpl implements StudySetRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _studySetsCollection = 'study_sets';

  StudySetRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  String get _currentStudentId => _auth.currentUser?.uid ?? '';

  @override
  Future<Result<List<StudySet>>> getAllStudySets() async {
    try {
      final querySnapshot = await _firestore
          .collection(_studySetsCollection)
          .where('studentId', isEqualTo: _currentStudentId)
          .orderBy('lastUpdated', descending: true)
          .get();

      final studySets = querySnapshot.docs.map((doc) {
        return _mapDocumentToStudySet(doc);
      }).toList();

      return Success(studySets);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to fetch study sets: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<List<StudySet>>> getStudySetsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(_studySetsCollection)
          .where('studentId', isEqualTo: _currentStudentId)
          .where('lastUpdated', isGreaterThanOrEqualTo: startDate)
          .where('lastUpdated', isLessThanOrEqualTo: endDate)
          .orderBy('lastUpdated', descending: true)
          .get();

      final studySets = querySnapshot.docs.map((doc) {
        return _mapDocumentToStudySet(doc);
      }).toList();

      return Success(studySets);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to fetch study sets: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<StudySet?>> getStudySetById(String studySetId) async {
    try {
      final doc = await _firestore
          .collection(_studySetsCollection)
          .doc(studySetId)
          .get();

      if (!doc.exists) {
        return const Success(null);
      }

      final studySet = _mapDocumentToStudySet(doc);
      return Success(studySet);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to fetch study set: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<StudySet>> createStudySet({
    required String title,
    required String category,
    bool isPrivate = true,
  }) async {
    try {
      final now = DateTime.now();
      final studySetId = _firestore.collection(_studySetsCollection).doc().id;

      final studySet = StudySet(
        id: studySetId,
        title: title,
        category: category,
        studentId: _currentStudentId,
        isPrivate: isPrivate,
        createdAt: now,
        lastUpdated: now,
      );

      await _firestore
          .collection(_studySetsCollection)
          .doc(studySetId)
          .set(_mapStudySetToDocument(studySet));

      return Success(studySet);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to create study set: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> updateStudySet(StudySet studySet) async {
    try {
      await _firestore
          .collection(_studySetsCollection)
          .doc(studySet.id)
          .update(_mapStudySetToDocument(studySet));

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to update study set: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> deleteStudySet(String studySetId) async {
    try {
      await _firestore
          .collection(_studySetsCollection)
          .doc(studySetId)
          .delete();

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to delete study set: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> addTopic(String studySetId, String topicId) async {
    try {
      await _firestore
          .collection(_studySetsCollection)
          .doc(studySetId)
          .update({
        'topicIds': FieldValue.arrayUnion([topicId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to add topic: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> addFlashcard(
    String studySetId,
    String flashcardId,
  ) async {
    try {
      await _firestore
          .collection(_studySetsCollection)
          .doc(studySetId)
          .update({
        'flashcardIds': FieldValue.arrayUnion([flashcardId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to add flashcard: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> addFile(String studySetId, String fileId) async {
    try {
      await _firestore
          .collection(_studySetsCollection)
          .doc(studySetId)
          .update({
        'fileIds': FieldValue.arrayUnion([fileId]),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to add file: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Map<String, int>>> getContentCounts(String studySetId) async {
    try {
      final doc = await _firestore
          .collection(_studySetsCollection)
          .doc(studySetId)
          .get();

      if (!doc.exists) {
        return Err(NetworkFailure(message: 'Study set not found'));
      }

      final data = doc.data()!;
      final topicIds = (data['topicIds'] as List<dynamic>?) ?? [];
      final flashcardIds = (data['flashcardIds'] as List<dynamic>?) ?? [];
      final fileIds = (data['fileIds'] as List<dynamic>?) ?? [];

      return Success({
        'topics': topicIds.length,
        'flashcards': flashcardIds.length,
        'files': fileIds.length,
      });
    } on FirebaseException catch (e) {
      return Err(NetworkFailure(
        message: 'Failed to get content counts: ${e.message}',
        code: e.code,
      ));
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  StudySet _mapDocumentToStudySet(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final lastUpdated = (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now();
    final topicIds = (data['topicIds'] as List<dynamic>?) ?? [];
    final flashcardIds = (data['flashcardIds'] as List<dynamic>?) ?? [];
    final fileIds = (data['fileIds'] as List<dynamic>?) ?? [];

    return StudySet(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      studentId: data['studentId'] ?? '',
      isPrivate: data['isPrivate'] ?? true,
      topicCount: topicIds.length,
      flashcardCount: flashcardIds.length,
      fileCount: fileIds.length,
      createdAt: createdAt,
      lastUpdated: lastUpdated,
    );
  }

  Map<String, dynamic> _mapStudySetToDocument(StudySet studySet) {
    return {
      'title': studySet.title,
      'category': studySet.category,
      'studentId': studySet.studentId,
      'isPrivate': studySet.isPrivate,
      'topicIds': [],
      'flashcardIds': [],
      'fileIds': [],
      'createdAt': Timestamp.fromDate(studySet.createdAt),
      'lastUpdated': Timestamp.fromDate(studySet.lastUpdated),
    };
  }
}

