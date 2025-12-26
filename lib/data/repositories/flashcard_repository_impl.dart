/// Flashcard Repository Implementation
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studnet_ai_buddy/core/errors/failures.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/flashcard.dart';
import 'package:studnet_ai_buddy/domain/repositories/flashcard_repository.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final FirebaseFirestore _firestore;
  // ignore: unused_field - kept for future auth-based queries
  final FirebaseAuth _auth;

  static const String _collection = 'flashcards';

  FlashcardRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  @override
  Future<Result<Flashcard>> createFlashcard({
    required String studySetId,
    required String term,
    required String definition,
    String? imageUrl,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return const Err(NetworkFailure(message: 'User not logged in'));
      }

      final id = _firestore.collection(_collection).doc().id;
      final now = DateTime.now();

      final flashcard = Flashcard(
        id: id,
        studySetId: studySetId,
        term: term,
        definition: definition,
        imageUrl: imageUrl,
        creatorId: userId, // Set from auth
        createdAt: now,
        lastUpdated: now,
      );

      await _firestore.collection(_collection).doc(id).set(flashcard.toJson());
      return Success(flashcard);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: e.message ?? 'Firestore error', code: e.code),
      );
    } catch (e) {
      return Err(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Flashcard>>> createFlashcardsBatch(
    List<Flashcard> flashcards,
  ) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return const Err(NetworkFailure(message: 'User not logged in'));
      }

      final batch = _firestore.batch();
      final List<Flashcard> batchCards = [];

      for (final card in flashcards) {
        final docRef = _firestore.collection(_collection).doc(card.id);
        // Ensure creatorId is set correctly, even if passed incorrectly
        final cardWithAuth = card.copyWith(creatorId: userId);
        batch.set(docRef, cardWithAuth.toJson());
        batchCards.add(cardWithAuth);
      }

      await batch.commit();
      return Success(batchCards);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(
          message: e.message ?? 'Batch create error',
          code: e.code,
        ),
      );
    } catch (e) {
      return Err(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Flashcard>>> getFlashcardsByStudySetId(
    String studySetId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studySetId', isEqualTo: studySetId)
          // Removed orderBy to avoid index requirement "FAILED_PRECONDITION"
          // We will sort in memory below
          .get();

      final cards = snapshot.docs
          .map((doc) => Flashcard.fromJson(doc.data()))
          .toList();

      // Sort in memory
      cards.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return Success(cards);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: e.message ?? 'Firestore error', code: e.code),
      );
    } catch (e) {
      return Err(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateFlashcard(Flashcard flashcard) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(flashcard.id)
          .update(flashcard.toJson());
      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: e.message ?? 'Firestore error', code: e.code),
      );
    } catch (e) {
      return Err(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteFlashcard(String flashcardId) async {
    try {
      await _firestore.collection(_collection).doc(flashcardId).delete();
      return const Success(null);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: e.message ?? 'Firestore error', code: e.code),
      );
    } catch (e) {
      return Err(NetworkFailure(message: e.toString()));
    }
  }
}
