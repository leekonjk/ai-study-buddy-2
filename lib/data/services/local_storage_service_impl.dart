/// Local Storage Service Implementation
/// Concrete implementation using SharedPreferences.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studnet_ai_buddy/domain/services/local_storage_service.dart';

/// SharedPreferences-based implementation of LocalStorageService.
class LocalStorageServiceImpl implements LocalStorageService {
  SharedPreferences? _prefs;
  bool _initialized = false;

  static const String _introSeenKey = 'has_seen_intro';
  static const String _onboardedKey = 'is_onboarded';

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    debugPrint('LocalStorageService: Initializing SharedPreferences...');
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    debugPrint('LocalStorageService: Initialized');
  }

  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError(
        'LocalStorageService not initialized. Call initialize() first.',
      );
    }
    return _prefs!;
  }

  @override
  Future<bool> hasSeenIntro() async {
    return _preferences.getBool(_introSeenKey) ?? false;
  }

  @override
  Future<void> setIntroSeen(bool value) async {
    await _preferences.setBool(_introSeenKey, value);
  }

  @override
  Future<bool> isOnboarded() async {
    return _preferences.getBool(_onboardedKey) ?? false;
  }

  @override
  Future<void> setOnboarded(bool value) async {
    await _preferences.setBool(_onboardedKey, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _preferences.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _preferences.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _preferences.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  @override
  Future<double?> getDouble(String key) async {
    return _preferences.getDouble(key);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _preferences.setDouble(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  @override
  Future<void> clear() async {
    await _preferences.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _preferences.containsKey(key);
  }
}
