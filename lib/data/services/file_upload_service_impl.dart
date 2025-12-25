/// File Upload Service Implementation
/// Firebase Storage implementation for file uploads.
library;

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:studnet_ai_buddy/domain/services/file_upload_service.dart';

/// Firebase Storage implementation of FileUploadService.
class FileUploadServiceImpl implements FileUploadService {
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  FileUploadServiceImpl({FirebaseStorage? storage, FirebaseAuth? auth})
    : _storage = storage ?? FirebaseStorage.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? 'anonymous';

  @override
  Future<FileUploadResult> uploadFile({
    required String filePath,
    required String fileName,
    Function(FileUploadProgress)? onProgress,
  }) async {
    try {
      debugPrint('FileUploadService: Uploading $fileName from $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final fileSize = await file.length();
      final fileId = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final storagePath = 'study_materials/$_userId/$fileId';

      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: _getFileType(fileName),
          customMetadata: {
            'originalName': fileName,
            'uploadedBy': _userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Listen to upload progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(
            FileUploadProgress(
              fileId: fileId,
              progress: progress,
              bytesUploaded: snapshot.bytesTransferred,
              totalBytes: snapshot.totalBytes,
            ),
          );
        });
      }

      // Wait for upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('FileUploadService: Upload complete. URL: $downloadUrl');

      return FileUploadResult(
        fileId: fileId,
        fileName: fileName,
        fileUrl: downloadUrl,
        fileSize: fileSize,
        fileType: _getFileType(fileName),
        uploadedAt: DateTime.now(),
      );
    } on FirebaseException catch (e) {
      debugPrint(
        'FileUploadService: Firebase error uploading file: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('FileUploadService: Error uploading file: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteFile(String fileId) async {
    try {
      debugPrint('FileUploadService: Deleting file $fileId');
      final storagePath = 'study_materials/$_userId/$fileId';
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
      debugPrint('FileUploadService: File deleted successfully');
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        debugPrint('FileUploadService: File not found, may already be deleted');
        return;
      }
      debugPrint(
        'FileUploadService: Firebase error deleting file: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('FileUploadService: Error deleting file: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getFileUrl(String fileId) async {
    try {
      final storagePath = 'study_materials/$_userId/$fileId';
      final ref = _storage.ref().child(storagePath);
      final url = await ref.getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        debugPrint('FileUploadService: File not found: $fileId');
        return null;
      }
      debugPrint(
        'FileUploadService: Firebase error getting file URL: ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('FileUploadService: Error getting file URL: $e');
      return null;
    }
  }

  @override
  Future<FileUploadResult?> getFileMetadata(String fileId) async {
    try {
      final storagePath = 'study_materials/$_userId/$fileId';
      final ref = _storage.ref().child(storagePath);
      final metadata = await ref.getMetadata();
      final url = await ref.getDownloadURL();

      return FileUploadResult(
        fileId: fileId,
        fileName: metadata.customMetadata?['originalName'] ?? fileId,
        fileUrl: url,
        fileSize: metadata.size ?? 0,
        fileType: metadata.contentType ?? 'application/octet-stream',
        uploadedAt: metadata.timeCreated ?? DateTime.now(),
      );
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        debugPrint('FileUploadService: File not found: $fileId');
        return null;
      }
      debugPrint(
        'FileUploadService: Firebase error getting metadata: ${e.message}',
      );
      return null;
    } catch (e) {
      debugPrint('FileUploadService: Error getting file metadata: $e');
      return null;
    }
  }

  String _getFileType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }
}
