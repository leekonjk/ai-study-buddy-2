/// Local Storage Service Implementation
/// Concrete implementation using SharedPreferences.
library;

import 'package:flutter/foundation.dart';
import 'package:studnet_ai_buddy/domain/services/local_storage_service.dart';

/// In-memory implementation of LocalStorageService.
/// TODO: Replace with SharedPreferences once package is added.
class LocalStorageServiceImpl implements LocalStorageService {
  final Map<String, dynamic> _storage = {};
  bool _initialized = false;

  static const String _introSeenKey = 'has_seen_intro';
  static const String _onboardedKey = 'is_onboarded';

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    debugPrint('LocalStorageService: Initializing...');
    _initialized = true;
    debugPrint('LocalStorageService: Initialized');
  }

  @override
  Future<bool> hasSeenIntro() async {
    return _storage[_introSeenKey] as bool? ?? false;
  }

  @override
  Future<void> setIntroSeen(bool value) async {
    _storage[_introSeenKey] = value;
  }

  @override
  Future<bool> isOnboarded() async {
    return _storage[_onboardedKey] as bool? ?? false;
  }

  @override
  Future<void> setOnboarded(bool value) async {
    _storage[_onboardedKey] = value;
  }

  @override
  Future<String?> getString(String key) async {
    return _storage[key] as String?;
  }

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<bool?> getBool(String key) async {
    return _storage[key] as bool?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _storage[key] = value;
  }

  @override
  Future<int?> getInt(String key) async {
    return _storage[key] as int?;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _storage[key] = value;
  }

  @override
  Future<double?> getDouble(String key) async {
    return _storage[key] as double?;
  }

  @override
  Future<void> setDouble(String key, double value) async {
    _storage[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }
}

