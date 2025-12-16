/// Local Storage Service.
/// Handles persistent local storage using SharedPreferences or similar.
/// 
/// Layer: Data
/// Responsibility: Low-level key-value storage abstraction.
/// Used by: Repository implementations for caching.
library;

abstract class LocalStorageService {
  /// Stores a string value.
  Future<void> setString(String key, String value);

  /// Retrieves a string value.
  Future<String?> getString(String key);

  /// Stores a JSON object as string.
  Future<void> setJson(String key, Map<String, dynamic> value);

  /// Retrieves and parses a JSON object.
  Future<Map<String, dynamic>?> getJson(String key);

  /// Stores a list of JSON objects.
  Future<void> setJsonList(String key, List<Map<String, dynamic>> value);

  /// Retrieves a list of JSON objects.
  Future<List<Map<String, dynamic>>?> getJsonList(String key);

  /// Removes a value by key.
  Future<void> remove(String key);

  /// Clears all stored data.
  Future<void> clear();

  /// Checks if a key exists.
  Future<bool> containsKey(String key);
}
