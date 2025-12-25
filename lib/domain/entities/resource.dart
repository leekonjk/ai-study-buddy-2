/// Resource Entity.
/// Represents an uploaded file or study material.
library;

import 'package:equatable/equatable.dart';

enum ResourceType { pdf, image, document, audio, other }

class Resource extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String url;
  final ResourceType type; // 'pdf', 'image', 'document'
  final int sizeBytes;
  final DateTime uploadedAt;

  const Resource({
    required this.id,
    required this.userId,
    required this.title,
    required this.url,
    this.type = ResourceType.other,
    this.sizeBytes = 0,
    required this.uploadedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    url,
    type,
    sizeBytes,
    uploadedAt,
  ];

  // Helper to parse string type
  static ResourceType parseType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'pdf':
      case 'application/pdf':
        return ResourceType.pdf;
      case 'image':
      case 'image/jpeg':
      case 'image/png':
        return ResourceType.image;
      case 'doc':
      case 'docx':
      case 'application/msword':
        return ResourceType.document;
      default:
        return ResourceType.other;
    }
  }

  String get typeString {
    switch (type) {
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.image:
        return 'Image';
      case ResourceType.document:
        return 'Document';
      case ResourceType.audio:
        return 'Audio';
      case ResourceType.other:
        return 'File';
    }
  }
}
