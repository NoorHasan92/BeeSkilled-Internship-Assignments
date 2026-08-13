import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level background message handler.
/// This must be a top-level function so it can run in an isolate outside of the main app context.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isPermissionGranted = false;

  bool get isPermissionGranted => _isPermissionGranted;

  /// Stream controller to notify the app when a notification is tapped.
  /// The app can listen to this and navigate accordingly.
  final _onNotificationTap = StreamController<String?>.broadcast();
  Stream<String?> get onNotificationTap => _onNotificationTap.stream;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // 1. Request permissions (required on iOS and Android 13+)
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      
      _isPermissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized || 
                             settings.authorizationStatus == AuthorizationStatus.provisional;

      // 2. Setup Local Notifications for Foreground display
      const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInitSettings);
      
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _onNotificationTap.add(response.payload);
        },
      );

      // Create high-importance Android channel for heads-up notifications
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'novacart_high_importance_channel', // id
        'NovaCart Notifications', // name
        description: 'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 3. Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 4. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          
          final notification = message.notification!;
          final android = message.notification?.android;

          // Only show local notification if we have a notification payload
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: android?.smallIcon ?? '@mipmap/ic_launcher',
              ),
            ),
            payload: message.data['orderId'] as String?,
          );
        }
      });

      // 5. Handle Notification Taps (when app is in background but opened)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final orderId = message.data['orderId'] as String?;
        _onNotificationTap.add(orderId);
      });

      // 6. Handle Initial Message (if app was terminated and launched via notification)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          final orderId = initialMessage.data['orderId'] as String?;
          _onNotificationTap.add(orderId);
        });
      }

      // 7. Get FCM token
      await _fcm.getToken();

      // Server-side integration notes:
      // A production app should not contain Firebase Admin credentials or server secrets.
      // Notifications (e.g. order shipped) would typically be triggered via 
      // Cloud Functions or another trusted backend storing these FCM tokens.
      
      _isInitialized = true;
    } catch (e, st) {
      // Non-blocking error handling. If FCM fails (e.g. emulator missing Google Play services),
      // the app will continue to function normally.
      debugPrint('Failed to initialize NotificationService: $e');
      debugPrint(st.toString());
    }
  }
}
