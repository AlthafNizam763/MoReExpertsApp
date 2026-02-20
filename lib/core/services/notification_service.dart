import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("DEBUG: Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription? _systemNotificationSubscription;
  StreamSubscription? _chatSubscription;
  String? _currentUserId;

  static const String _notificationsEnabledKey = 'notifications_enabled';

  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
    if (!enabled) {
      await _fcm.deleteToken();
    } else {
      // Re-initialize to get token and set listeners
      await initialize();
    }
  }

  Future<void> initialize() async {
    try {
      bool enabled = await isNotificationsEnabled();
      if (!enabled) {
        log('DEBUG: Notifications are disabled by user preference');
        return;
      }
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // 1. Request Permissions
      await _requestPermissions();

      // 2. Initialize Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          log('DEBUG: Notification tapped: ${details.payload}');
        },
      );

      // Create Notification Channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 3. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('DEBUG: Foreground message received: ${message.notification?.title}');
        showRemoteNotification(message);
      });

      // 4. Handle Background/Terminated Messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('DEBUG: Message opened app: ${message.notification?.title}');
      });

      // 5. Get Token
      try {
        String? token = await _fcm.getToken();
        log('DEBUG: FCM Token: $token');
      } catch (e) {
        log('DEBUG: Error getting FCM token: $e');
      }

      // 6. Start Firestore Listener for Simulated Push (Fallback)
      if (_currentUserId != null) {
        startListening(_currentUserId!);
      }
    } catch (e) {
      log('DEBUG: Error initializing NotificationService: $e');
    }
  }

  Future<void> _requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('DEBUG: User granted notification permissions');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('DEBUG: User granted provisional notification permissions');
    } else {
      log('DEBUG: User declined or has not accepted notification permissions');
    }

    // Permission handler for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void startListening(String userId) {
    _currentUserId = userId;
    _stopListening();

    log('DEBUG: Starting Firestore Notification Listeners for user: $userId');

    // 1. Listen for new System Notifications
    // We only want notifications created AFTER now
    final startTime = DateTime.now();
    _systemNotificationSubscription = _firestore
        .collection('notifications')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(startTime))
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null) {
            _showLocalNotification(
              title: data['title'] ?? 'New Notification',
              body: data['description'] ?? '',
              payload: 'system_notification',
            );
          }
        }
      }
    });

    // 2. Listen for new Chat Messages
    _chatSubscription = _firestore
        .collection('conversations')
        .doc(userId)
        .collection('messages')
        .where('timestamp', isGreaterThan: Timestamp.fromDate(startTime))
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data != null && data['role'] != 'user') {
            // Only notify for messages NOT from the user themselves
            _showLocalNotification(
              title: 'Message from ${data['sender'] ?? 'Support'}',
              body: data['text'] ?? '',
              payload: 'chat_message',
            );
          }
        }
      }
    });
  }

  void _stopListening() {
    _systemNotificationSubscription?.cancel();
    _chatSubscription?.cancel();
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Update original show message for FCM compatibility
  Future<void> showRemoteNotification(RemoteMessage message) async {
    await _showLocalNotification(
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }
}
