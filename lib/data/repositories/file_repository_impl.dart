import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:studnet_ai_buddy/domain/repositories/file_repository.dart';

class FileRepositoryImpl implements FileRepository {
  final FirebaseStorage? _storage;
  final FirebaseFirestore _firestore;

  FileRepositoryImpl({FirebaseStorage? storage, FirebaseFirestore? firestore})
    : _storage = storage,
      _firestore = firestore ?? FirebaseFirestore.instance;

  FirebaseStorage get _storageInstance => _storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadFile({
    required File file,
    required String userId,
    required String originalName,
    String? textContent,
  }) async {
    try {
      // Validate file exists
      if (!await file.exists()) {
        throw FileFailure("File does not exist");
      }

      // Check file size (max 10MB for safety)
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        throw FileFailure(
          "File too large (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB). Maximum size is 10MB",
        );
      }

      // Validate file name
      if (originalName.isEmpty) {
        throw FileFailure("File name cannot be empty");
      }

      final fileName = "${DateTime.now().millisecondsSinceEpoch}_$originalName";
      final storagePath = "users/$userId/files/$fileName";
      final ref = _storageInstance.ref().child(storagePath);

      // debugPrint('📤 Uploading file: $originalName (${(fileSize / 1024).toStringAsFixed(1)}KB)');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // debugPrint('✅ File uploaded successfully to: $storagePath');

      // Save metadata to Firestore
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('files')
          .doc();

      await docRef.set({
        'id': docRef.id,
        'name': originalName,
        'storagePath': storagePath,
        'url': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'size': fileSize,
        'type': originalName.split('.').last,
        'content': textContent, // Save extracted text
      });

      // debugPrint('💾 Metadata saved to Firestore with ID: ${docRef.id}');
      return docRef.id;
    } on FirebaseException catch (e) {
      // debugPrint('❌ Firebase error during upload: ${e.code} - ${e.message}');
      throw FileFailure("Upload failed: ${e.message ?? e.code}");
    } catch (e) {
      // debugPrint('❌ Unexpected error during upload: $e');
      throw FileFailure("Upload failed: $e");
    }
  }

  @override
  Stream<double> uploadFileWithProgress({
    required File file,
    required String userId,
    required String originalName,
    String? textContent,
  }) async* {
    // Validate file exists
    if (!await file.exists()) {
      throw FileFailure("File does not exist");
    }

    final fileSize = await file.length();
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (fileSize > maxSize) {
      throw FileFailure("File too large. Maximum size is 10MB");
    }

    // File path setup
    final fileName = "${DateTime.now().millisecondsSinceEpoch}_$originalName";
    final storagePath = "users/$userId/files/$fileName";
    final ref = _storageInstance.ref().child(storagePath);

    // Start upload
    final uploadTask = ref.putFile(file);

    // Yield progress
    await for (final snapshot in uploadTask.snapshotEvents) {
      if (snapshot.totalBytes > 0) {
        yield snapshot.bytesTransferred / snapshot.totalBytes;
      }
    }

    // Wait for completion (though loop usually covers it)
    await uploadTask;

    // Get URL
    final downloadUrl = await ref.getDownloadURL();

    // Save metadata
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('files')
        .doc();

    await docRef.set({
      'id': docRef.id,
      'name': originalName,
      'storagePath': storagePath,
      'url': downloadUrl,
      'uploadedAt': FieldValue.serverTimestamp(),
      'size': fileSize,
      'type': originalName.split('.').last,
      'content': textContent,
    });

    yield 1.0; // Ensure 100% at end
  }

  @override
  Future<List<Map<String, dynamic>>> getUserFiles(String userId) async {
    try {
      // debugPrint('📚 Fetching files for user: $userId');

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('files')
          .orderBy('uploadedAt', descending: true)
          .get();

      // debugPrint('✅ Found ${snapshot.docs.length} files');
      return snapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      // debugPrint('❌ Firebase error fetching files: ${e.code} - ${e.message}');
      throw FileFailure("Failed to fetch files: ${e.message ?? e.code}");
    } catch (e) {
      // debugPrint('❌ Unexpected error fetching files: $e');
      throw FileFailure("Failed to fetch files: $e");
    }
  }

  @override
  Future<void> deleteFile(
    String userId,
    String fileId,
    String storagePath,
  ) async {
    try {
      // debugPrint('🗑️ Deleting file: $storagePath');

      // Delete from Storage
      await _storageInstance.ref().child(storagePath).delete();
      // debugPrint('✅ File deleted from Storage');

      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('files')
          .doc(fileId)
          .delete();

      // debugPrint('✅ Metadata deleted from Firestore');
    } on FirebaseException catch (e) {
      // debugPrint('❌ Firebase error deleting file: ${e.code} - ${e.message}');
      throw FileFailure("Delete failed: ${e.message ?? e.code}");
    } catch (e) {
      // debugPrint('❌ Unexpected error deleting file: $e');
      throw FileFailure("Delete failed: $e");
    }
  }

  @override
  Future<Map<String, dynamic>?> getFile(String userId, String fileId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('files')
          .doc(fileId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      // debugPrint('Error fetching file: $e');
      return null;
    }
  }
}
