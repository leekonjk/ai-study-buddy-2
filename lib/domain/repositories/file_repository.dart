import 'dart:io';

/// Failure class for file operations.
class FileFailure {
  final String message;
  const FileFailure(this.message);
}

/// Repository for managing user files and storage.
///
/// Layer: Domain
abstract class FileRepository {
  /// Uploads a file to storage and saves metadata.
  Future<String> uploadFile({
    required File file,
    required String userId,
    required String originalName,
  });

  /// Fetches list of files for a user.
  Future<List<Map<String, dynamic>>> getUserFiles(String userId);

  /// Deletes a file.
  Future<void> deleteFile(String userId, String fileId, String storagePath);
}
