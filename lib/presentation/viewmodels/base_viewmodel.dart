/// Base ViewModel.
/// Abstract base class for all ViewModels in the application.
/// 
/// Layer: Presentation
/// Responsibility: Common state management patterns for all ViewModels.
library;

import 'package:flutter/foundation.dart';

/// Base class providing common ViewModel functionality.
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Sets loading state and notifies listeners.
  @protected
  void setLoading(bool value) {
    if (_isDisposed) return;
    _isLoading = value;
    notifyListeners();
  }

  /// Sets error message and notifies listeners.
  @protected
  void setError(String? message) {
    if (_isDisposed) return;
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears error state.
  @protected
  void clearError() {
    if (_isDisposed) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Safe notify that checks disposal state.
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

/// Represents the state of an async operation.
enum ViewState {
  initial,
  loading,
  loaded,
  error,
}
