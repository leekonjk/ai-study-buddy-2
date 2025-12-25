/// Notification Service Implementation
/// Concrete implementation using flutter_local_notifications + FCM.
library;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:studnet_ai_buddy/domain/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Background message handler for FCM (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    'NotificationService: Background message received: ${message.messageId}',
  );
}

/// Implementation of NotificationService using flutter_local_notifications + FCM.
class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _notifications;
  final FirebaseMessaging _messaging;
  bool _initialized = false;

  // Notification channel for Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'study_buddy_channel',
    'Study Buddy Notifications',
    description: 'Notifications for study reminders and updates',
    importance: Importance.high,
  );

  NotificationServiceImpl({
    FlutterLocalNotificationsPlugin? notifications,
    FirebaseMessaging? messaging,
  }) : _notifications = notifications ?? FlutterLocalNotificationsPlugin(),
       _messaging = messaging ?? FirebaseMessaging.instance;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('NotificationService: Initializing...');

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Initialize FCM
    await _initializeFCM();

    _initialized = true;
    debugPrint('NotificationService: Initialized successfully');
  }

  Future<void> _initializeLocalNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Initialize the plugin
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_channel);
  }

  Future<void> _initializeFCM() async {
    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Get initial message if app was opened from notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Get FCM token
    final token = await _messaging.getToken();
    debugPrint('NotificationService: FCM Token: $token');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('NotificationService: FCM Token refreshed: $newToken');
      // Could save to backend here
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      'NotificationService: Foreground message: ${message.notification?.title}',
    );

    final notification = message.notification;
    if (notification != null) {
      // Show local notification for foreground messages
      showNotification(
        title: notification.title ?? 'Study Buddy',
        body: notification.body ?? '',
        payload: message.data['route'],
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('NotificationService: Notification tapped: ${message.data}');
    // Handle navigation based on message data
    // Could use a navigation service to route to specific screens
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
      'NotificationService: Local notification tapped with payload: ${response.payload}',
    );
    // Handle navigation based on payload
  }

  @override
  Future<bool> requestPermission() async {
    debugPrint('NotificationService: Requesting permission...');

    // Request FCM permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized;
    debugPrint('NotificationService: Permission granted: $granted');
    return granted;
  }

  @override
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('NotificationService: Showing notification - $title: $body');

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    debugPrint(
      'NotificationService: Scheduling notification $id for $scheduledTime',
    );

    // Don't schedule if the time is in the past
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint(
        'NotificationService: Scheduled time is in the past, skipping',
      );
      return;
    }

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  @override
  Future<void> cancelNotification(int id) async {
    debugPrint('NotificationService: Cancelling notification $id');
    await _notifications.cancel(id);
  }

  @override
  Future<void> cancelAllNotifications() async {
    debugPrint('NotificationService: Cancelling all notifications');
    await _notifications.cancelAll();
  }

  @override
  Future<String?> getToken() async {
    final token = await _messaging.getToken();
    debugPrint('NotificationService: FCM Token: $token');
    return token;
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    debugPrint('NotificationService: Subscribing to topic: $topic');
    await _messaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    debugPrint('NotificationService: Unsubscribing from topic: $topic');
    await _messaging.unsubscribeFromTopic(topic);
  }
}
