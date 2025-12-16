/// SharedPreferences Storage Implementation.
/// Concrete implementation of LocalStorageService using SharedPreferences.
/// 
/// Layer: Data
/// Responsibility: Persist data locally using SharedPreferences.
library;

import 'dart:convert';

import 'package:studnet_ai_buddy/data/datasources/local/local_storage_service.dart';

// TODO: Add shared_preferences package to pubspec.yaml when implementing
class SharedPreferencesStorage implements LocalStorageService {
  // SharedPreferences instance will be injected or lazy-loaded
  // final SharedPreferences _prefs;
  
  // SharedPreferencesStorage(this._prefs);

  @override
  Future<void> setString(String key, String value) async {
    // await _prefs.setString(key, value);
    throw UnimplementedError('Add shared_preferences dependency');
  }

  @override
  Future<String?> getString(String key) async {
    // return _prefs.getString(key);
    throw UnimplementedError('Add shared_preferences dependency');
  }

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await setString(key, jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  @override
  Future<void> setJsonList(String key, List<Map<String, dynamic>> value) async {
    final jsonString = jsonEncode(value);
    await setString(key, jsonString);
  }

  @override
  Future<List<Map<String, dynamic>>?> getJsonList(String key) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;
    final decoded = jsonDecode(jsonString) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> remove(String key) async {
    // await _prefs.remove(key);
    throw UnimplementedError('Add shared_preferences dependency');
  }

  @override
  Future<void> clear() async {
    // await _prefs.clear();
    throw UnimplementedError('Add shared_preferences dependency');
  }

  @override
  Future<bool> containsKey(String key) async {
    // return _prefs.containsKey(key);
    throw UnimplementedError('Add shared_preferences dependency');
  }
}
