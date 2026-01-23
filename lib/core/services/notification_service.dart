import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

/// Service for handling push and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Initialize notification service (non-blocking, fail-safe)
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true; // Mark as initialized immediately to prevent re-entry

    try {
      // Initialize timezone database
      tz_data.initializeTimeZones();

      // Get device timezone and set it as local
      try {
        final timezoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezoneName));
        debugPrint('Timezone set to: $timezoneName');
      } catch (e) {
        // Fallback to Europe/Istanbul for Turkey
        tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
        debugPrint('Timezone fallback to Europe/Istanbul: $e');
      }

      // Initialize local notifications first (this is safe)
      await _initializeLocalNotifications();

      // Setup FCM listeners (non-blocking)
      _setupFCMListeners();
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    }
  }

  /// Setup FCM listeners in background
  void _setupFCMListeners() {
    try {
      // Listen to token refresh
      _messaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        debugPrint('FCM Token refreshed: $token');
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Request permissions and get token in background (don't await)
      _initializeInBackground();
    } catch (e) {
      debugPrint('FCM listeners setup error: $e');
    }
  }

  /// Initialize FCM permissions and token in background
  Future<void> _initializeInBackground() async {
    try {
      // Small delay to let app finish launching
      await Future.delayed(const Duration(seconds: 2));

      // Request permissions
      await _requestPermission();

      // Get FCM token
      await _initializeFCMToken();

      // Check for initial message
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } catch (e) {
      debugPrint('Background FCM initialization error: $e');
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Permission status: ${settings.authorizationStatus}');
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Initialize FCM token with iOS APNS handling
  Future<void> _initializeFCMToken() async {
    try {
      // On iOS, we need to wait for APNS token first
      if (Platform.isIOS) {
        // Get APNS token first (may be null initially)
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNS token not available yet, will get FCM token later');
          // Token will be available via onTokenRefresh listener
          return;
        }
      }

      // Get FCM token
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      // Token will be available via onTokenRefresh listener
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Don't request permissions here, do it in background
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _localNotifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
        onDidReceiveNotificationResponse: _onLocalNotificationTap,
      );

      // Create notification channels for Android (non-blocking on iOS)
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }
    } catch (e) {
      debugPrint('Local notifications initialization error: $e');
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Main notifications channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'pairquest_notifications',
          'PairQuest Notifications',
          description: 'General notifications from PairQuest',
          importance: Importance.high,
        ),
      );

      // Daily reminder channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_reminder',
          'Daily Reminders',
          description: 'Daily reminder to play PairQuest',
          importance: Importance.defaultImportance,
        ),
      );

      // Achievement channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'achievements',
          'Achievements',
          description: 'Achievement unlock notifications',
          importance: Importance.high,
        ),
      );
    }
  }

  /// Show a local notification immediately
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'pairquest_notifications',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'achievements' ? 'Achievements' : 'PairQuest Notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  /// Show achievement unlock notification
  Future<void> showAchievementNotification({
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    await showLocalNotification(
      title: 'Achievement Unlocked!',
      body: achievementTitle,
      payload: 'achievements',
      channelId: 'achievements',
    );
  }

  /// Schedule daily reminder notification
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    // Cancel existing daily reminder
    await cancelDailyReminder();

    final scheduledTime = _nextInstanceOfTime(hour, minute);

    await _localNotifications.zonedSchedule(
      0, // ID 0 for daily reminder
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Daily Reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('Daily reminder scheduled for $hour:$minute');
  }

  /// Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    await _localNotifications.cancel(0);
  }

  /// Schedule streak warning notification
  Future<void> scheduleStreakWarning({
    required DateTime warningTime,
    required String title,
    required String body,
  }) async {
    final scheduledTime = tz.TZDateTime.from(warningTime, tz.local);

    // Only schedule if in the future
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await _localNotifications.zonedSchedule(
      1, // ID 1 for streak warning
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pairquest_notifications',
          'PairQuest Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel streak warning
  Future<void> cancelStreakWarning() async {
    await _localNotifications.cancel(1);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Handle foreground FCM message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message: ${message.notification?.title}');

    // Show local notification for foreground messages
    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'PairQuest',
        body: message.notification!.body ?? '',
        payload: message.data['route'],
      );
    }
  }

  /// Handle notification tap (FCM)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tap: ${message.data}');
    final route = message.data['route'];
    if (route != null) {
      _navigateToRoute(route);
    }
  }

  /// Handle local notification tap
  void _onLocalNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tap: ${response.payload}');
    if (response.payload != null) {
      _navigateToRoute(response.payload!);
    }
  }

  /// Navigate to a route based on payload
  void _navigateToRoute(String route) {
    // Navigation will be handled via a callback or global navigator key
    // For now, just log it
    debugPrint('Should navigate to: $route');
  }
}
