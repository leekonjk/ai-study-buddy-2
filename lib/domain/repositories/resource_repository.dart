/// Resource Repository Interface.
/// Manages study resources (files).
library;

import 'package:studnet_ai_buddy/core/utils/result.dart';
import 'package:studnet_ai_buddy/domain/entities/resource.dart';

abstract class ResourceRepository {
  /// Uploads a file and saves its metadata.
  /// This encapsulates calling FileUploadService and then saving to Firestore.
  /// But typically repositories don't depend on services like that unless orchestrated.
  /// We will let the Presentation layer orchestrate OR have this repository use FileUploadService?
  /// Better: Repository handles data persistence. The UI or a Domain Service orchestrates upload + save.
  /// For simplicity here, we'll just have methods to Save Metadata and Get Resources.

  /// Gets all resources for the current user.
  Future<Result<List<Resource>>> getResources();

  /// Saves resource metadata to Firestore.
  Future<Result<void>> saveResource(Resource resource);

  /// Deletes a resource (metadata + storage).
  Future<Result<void>> deleteResource(String resourceId);
}
