/// Resource Repository Implementation.
/// Concrete implementation of ResourceRepository using Firebase Firestore.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studnet_ai_buddy/core/errors/failures.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/resource.dart';
import 'package:studnet_ai_buddy/domain/repositories/resource_repository.dart';

class ResourceRepositoryImpl implements ResourceRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collection = 'resources';

  ResourceRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Future<Result<List<Resource>>> getResources() async {
    try {
      if (_userId.isEmpty) return const Success([]);

      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _userId)
          .orderBy('uploadedAt', descending: true)
          .get();

      final resources = snapshot.docs
          .map((doc) => _mapDocumentToResource(doc))
          .toList();

      return Success(resources);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: 'Failed to fetch resources: ${e.message}'),
      );
    } catch (e) {
      return Err(NetworkFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Result<void>> saveResource(Resource resource) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(resource.id)
          .set(_mapResourceToDocument(resource));

      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: 'Failed to save resource: ${e.message}'),
      );
    }
  }

  @override
  Future<Result<void>> deleteResource(String resourceId) async {
    try {
      await _firestore.collection(_collection).doc(resourceId).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: 'Failed to delete resource: ${e.message}'),
      );
    }
  }

  Resource _mapDocumentToResource(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Resource(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? 'Untitled',
      url: data['url'] as String? ?? '',
      type: Resource.parseType(data['type'] as String? ?? ''),
      sizeBytes: data['sizeBytes'] as int? ?? 0,
      uploadedAt:
          (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _mapResourceToDocument(Resource resource) {
    return {
      'userId': resource.userId,
      'title': resource.title,
      'url': resource.url,
      'type': resource
          .typeString, // Store as meaningful string or mime type? Simpler to store parsed type string for now.
      // Actually entity has typeString helper.
      'sizeBytes': resource.sizeBytes,
      'uploadedAt': Timestamp.fromDate(resource.uploadedAt),
    };
  }
}
