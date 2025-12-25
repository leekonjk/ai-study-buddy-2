/// Notification Service
/// Abstract interface for push notification functionality.
library;

/// Notification service interface for managing push notifications.
abstract class NotificationService {
  /// Initialize the notification service
  Future<void> initialize();

  /// Request notification permissions from the user
  Future<bool> requestPermission();

  /// Show a local notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  });

  /// Schedule a notification for a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  });

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id);

  /// Cancel all notifications
  Future<void> cancelAllNotifications();

  /// Get the FCM token for remote notifications
  Future<String?> getToken();

  /// Subscribe to a topic for targeted notifications
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic);
}
