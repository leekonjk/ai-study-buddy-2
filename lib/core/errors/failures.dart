/// Domain-level failure representations.
/// Used to communicate errors from data layer to presentation layer.
library;

/// Base class for all failures in the application.
abstract class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Failure related to local storage operations.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Failure related to network/API operations.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Failure related to AI service operations.
class AIServiceFailure extends Failure {
  const AIServiceFailure({required super.message, super.code});
}

/// Failure related to validation errors.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}
