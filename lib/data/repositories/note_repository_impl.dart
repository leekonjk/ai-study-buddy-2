import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studnet_ai_buddy/core/errors/failures.dart';
import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/note.dart';
import 'package:studnet_ai_buddy/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _collection = 'notes';

  NoteRepositoryImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  @override
  Future<Result<int>> getNoteCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      return Success(snapshot.count ?? 0);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: e.message ?? 'Firestore error', code: e.code),
      );
    } catch (e) {
      return Err(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Note>>> getNotes(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final notes = snapshot.docs.map((doc) => _mapDocToNote(doc)).toList();
      return Success(notes);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: e.message ?? 'Firestore error', code: e.code),
      );
    } catch (e) {
      return Err(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Note?>> getNoteById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (!doc.exists) return const Success(null);
      return Success(_mapDocToNote(doc));
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: e.message ?? 'Firestore error', code: e.code),
      );
    } catch (e) {
      return Err(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Note>> createNote({
    required String title,
    required String content,
    required String subject,
    required String colorHex,
    String? studySetId,
  }) async {
    try {
      final id = _firestore.collection(_collection).doc().id;
      final note = Note(
        id: id,
        userId: _currentUserId,
        title: title,
        content: content,
        subject: subject,
        createdAt: DateTime.now(),
        color: colorHex,
        studySetId: studySetId,
      );

      await _firestore.collection(_collection).doc(id).set(note.toJson());
      return Success(note);
    } on FirebaseException catch (e) {
      return Err(
        NetworkFailure(message: e.message ?? 'Firestore error', code: e.code),
      );
    } catch (e) {
      return Err(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> updateNote(Note note) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(note.id)
          .update(note.toJson());
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
  Future<Result<void>> deleteNote(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
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
  Stream<List<Note>> watchNotes(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => _mapDocToNote(doc)).toList(),
        );
  }

  Note _mapDocToNote(DocumentSnapshot<Map<String, dynamic>> doc) {
    return Note.fromJson({...doc.data()!, 'id': doc.id});
  }
}
