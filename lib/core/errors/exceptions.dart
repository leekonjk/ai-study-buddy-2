/// Data-layer exceptions.
/// Thrown by data sources, caught and mapped to Failures in repositories.
library;

/// Base exception for the application.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Exception for cache/local storage errors.
class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

/// Exception for network/API errors.
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});
}

/// Exception for AI service errors.
class AIServiceException extends AppException {
  const AIServiceException({required super.message, super.code});
}
