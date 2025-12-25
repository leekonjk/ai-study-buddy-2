/// Local Storage Service
/// Abstract interface for local data persistence.
library;

/// Local storage service interface for key-value persistence.
abstract class LocalStorageService {
  /// Initialize the storage service
  Future<void> initialize();

  /// Check if intro has been seen
  Future<bool> hasSeenIntro();

  /// Mark intro as seen
  Future<void> setIntroSeen(bool value);

  /// Check if user is onboarded
  Future<bool> isOnboarded();

  /// Set onboarding status
  Future<void> setOnboarded(bool value);

  /// Get a string value
  Future<String?> getString(String key);

  /// Set a string value
  Future<void> setString(String key, String value);

  /// Get a bool value
  Future<bool?> getBool(String key);

  /// Set a bool value
  Future<void> setBool(String key, bool value);

  /// Get an int value
  Future<int?> getInt(String key);

  /// Set an int value
  Future<void> setInt(String key, int value);

  /// Get a double value
  Future<double?> getDouble(String key);

  /// Set a double value
  Future<void> setDouble(String key, double value);

  /// Remove a value
  Future<void> remove(String key);

  /// Clear all values
  Future<void> clear();

  /// Check if a key exists
  Future<bool> containsKey(String key);
}

