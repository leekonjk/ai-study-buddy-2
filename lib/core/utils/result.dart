/// Functional Result type for handling success/failure without exceptions.
/// Enables explicit error handling in domain and presentation layers.
library;

import 'package:studnet_ai_buddy/core/errors/failures.dart';

/// A Result type that represents either a success value or a failure.
sealed class Result<T> {
  const Result();

  /// Returns true if this is a success result.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure result.
  bool get isFailure => this is Failure;

  /// Folds the result into a single value.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  });
}

/// Represents a successful result with a value.
final class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return onSuccess(value);
  }
}

/// Represents a failed result with a failure.
final class Err<T> extends Result<T> {
  final Failure failure;

  const Err(this.failure);

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return onFailure(failure);
  }
}
