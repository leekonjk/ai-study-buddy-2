/// Snapshot Builder Widget
/// Provides consistent handling of async states (loading, error, data).
///
/// Layer: Presentation (Widgets)
/// Responsibility: Unified async state handling across the app.
library;

import 'package:flutter/material.dart';
import 'package:studnet_ai_buddy/presentation/theme/app_theme.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/error_view.dart';
import 'package:studnet_ai_buddy/presentation/widgets/common/loading_indicator.dart';

/// Generic snapshot builder for handling async states
class SnapshotBuilder<T> extends StatelessWidget {
  /// The async snapshot to handle
  final AsyncSnapshot<T> snapshot;

  /// Builder for successful data state
  final Widget Function(BuildContext context, T data) builder;

  /// Optional custom loading widget
  final Widget? loadingWidget;

  /// Optional loading message
  final String? loadingMessage;

  /// Optional custom error widget builder
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Optional retry callback for error state
  final VoidCallback? onRetry;

  /// Whether to show loading on initial state (connectionState.waiting)
  final bool showLoadingOnWaiting;

  /// Optional empty state builder when data is null or empty
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Function to check if data is empty
  final bool Function(T data)? isEmpty;

  const SnapshotBuilder({
    super.key,
    required this.snapshot,
    required this.builder,
    this.loadingWidget,
    this.loadingMessage,
    this.errorBuilder,
    this.onRetry,
    this.showLoadingOnWaiting = true,
    this.emptyBuilder,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    // Handle error state
    if (snapshot.hasError) {
      if (errorBuilder != null) {
        return errorBuilder!(context, snapshot.error!);
      }
      return ErrorView(
        message: _getErrorMessage(snapshot.error),
        onRetry: onRetry,
      );
    }

    // Handle loading/waiting state
    if (showLoadingOnWaiting &&
        (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none)) {
      return loadingWidget ??
          Center(
            child: LoadingIndicator(message: loadingMessage ?? 'Loading...'),
          );
    }

    // Handle data state
    if (snapshot.hasData && snapshot.data != null) {
      final data = snapshot.data as T;

      // Check if data is empty
      if (isEmpty != null && isEmpty!(data)) {
        if (emptyBuilder != null) {
          return emptyBuilder!(context);
        }
        return _buildDefaultEmptyState(context);
      }

      return builder(context, data);
    }

    // Handle null/no data state
    if (emptyBuilder != null) {
      return emptyBuilder!(context);
    }

    return _buildDefaultEmptyState(context);
  }

  String _getErrorMessage(Object? error) {
    if (error == null) return 'An unknown error occurred';
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error.toString();
  }

  Widget _buildDefaultEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              'No data available',
              textAlign: TextAlign.center,
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
                child: Text('Refresh', style: AppTypography.button),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Stream snapshot builder with similar functionality
class StreamSnapshotBuilder<T> extends StatelessWidget {
  /// The stream to listen to
  final Stream<T> stream;

  /// Builder for successful data state
  final Widget Function(BuildContext context, T data) builder;

  /// Optional initial data
  final T? initialData;

  /// Optional custom loading widget
  final Widget? loadingWidget;

  /// Optional loading message
  final String? loadingMessage;

  /// Optional custom error widget builder
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Optional retry callback for error state
  final VoidCallback? onRetry;

  /// Optional empty state builder
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Function to check if data is empty
  final bool Function(T data)? isEmpty;

  const StreamSnapshotBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.initialData,
    this.loadingWidget,
    this.loadingMessage,
    this.errorBuilder,
    this.onRetry,
    this.emptyBuilder,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) {
        return SnapshotBuilder<T>(
          snapshot: snapshot,
          builder: builder,
          loadingWidget: loadingWidget,
          loadingMessage: loadingMessage,
          errorBuilder: errorBuilder,
          onRetry: onRetry,
          emptyBuilder: emptyBuilder,
          isEmpty: isEmpty,
        );
      },
    );
  }
}

/// Future snapshot builder with similar functionality
class FutureSnapshotBuilder<T> extends StatelessWidget {
  /// The future to resolve
  final Future<T> future;

  /// Builder for successful data state
  final Widget Function(BuildContext context, T data) builder;

  /// Optional initial data
  final T? initialData;

  /// Optional custom loading widget
  final Widget? loadingWidget;

  /// Optional loading message
  final String? loadingMessage;

  /// Optional custom error widget builder
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Optional retry callback for error state
  final VoidCallback? onRetry;

  /// Optional empty state builder
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Function to check if data is empty
  final bool Function(T data)? isEmpty;

  const FutureSnapshotBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.initialData,
    this.loadingWidget,
    this.loadingMessage,
    this.errorBuilder,
    this.onRetry,
    this.emptyBuilder,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) {
        return SnapshotBuilder<T>(
          snapshot: snapshot,
          builder: builder,
          loadingWidget: loadingWidget,
          loadingMessage: loadingMessage,
          errorBuilder: errorBuilder,
          onRetry: onRetry,
          emptyBuilder: emptyBuilder,
          isEmpty: isEmpty,
        );
      },
    );
  }
}

/// Error boundary widget to catch and display errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails details)? errorBuilder;
  final void Function(FlutterErrorDetails details)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
  }

  void _handleError(FlutterErrorDetails details) {
    setState(() {
      _error = details;
    });
    widget.onError?.call(details);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!);
      }
      return ErrorView(
        message: _error!.exceptionAsString(),
        onRetry: () {
          setState(() {
            _error = null;
          });
        },
      );
    }

    return widget.child;
  }
}
