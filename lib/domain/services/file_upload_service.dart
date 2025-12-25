/// File Upload Service
/// Interface for uploading study materials.
library;

/// File upload result.
class FileUploadResult {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final String fileType;
  final DateTime uploadedAt;

  const FileUploadResult({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.fileType,
    required this.uploadedAt,
  });
}

/// File upload progress.
class FileUploadProgress {
  final String fileId;
  final double progress; // 0.0 to 1.0
  final int bytesUploaded;
  final int totalBytes;

  const FileUploadProgress({
    required this.fileId,
    required this.progress,
    required this.bytesUploaded,
    required this.totalBytes,
  });
}

/// File upload service interface.
abstract class FileUploadService {
  /// Upload a file (PDF, DOC, PPT).
  /// Returns file ID and URL.
  Future<FileUploadResult> uploadFile({
    required String filePath,
    required String fileName,
    Function(FileUploadProgress)? onProgress,
  });

  /// Delete an uploaded file.
  Future<void> deleteFile(String fileId);

  /// Get file URL by ID.
  Future<String?> getFileUrl(String fileId);

  /// Get file metadata.
  Future<FileUploadResult?> getFileMetadata(String fileId);
}

