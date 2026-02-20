import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'constants.dart';
import 'shared_pref_helper.dart';
import '../routing/routes.dart';
import '../routing/navigator_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("Handling a background message: ${message.messageId}");
}

class NotificationHelper {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // تصحيح: استخدام المعاملات المسماة (Named Parameters)
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        log("Notification clicked with payload: ${details.payload}");
        NavigatorService.navigatorKey.currentState?.pushNamed(
          Routes.notificationsScreen,
          arguments: details.payload,
        );
      },
    );

    _getFcmToken();

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'حجوزات المرضى',
      description: 'هذه القناة مخصصة لإشعارات الحجوزات الجديدة',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: android.smallIcon,
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });
  }

  static Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  static Future<void> _getFcmToken() async {
    String? token = await _fcm.getToken();
    if (token != null) {
      log("FCM Token: $token");
      await SharedPrefHelper.setData(SharedPrefKeys.fcmToken, token);
      // Here we would typically call our repository to send the token to the backend
    }
  }
}
