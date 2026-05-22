import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thoutha_mobile_app/core/helpers/constants.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/routing/notification_route_handler.dart';
import 'package:thoutha_mobile_app/features/notifications/data/models/notification_payload_model.dart';
import 'package:thoutha_mobile_app/features/notifications/data/repos/notification_repo.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/features/notifications/data/models/notification_type.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

/// Firebase Cloud Messaging service for handling push notifications.
///
/// Responsibilities:
/// - Initialize Firebase Messaging and local notifications
/// - Retrieve and manage FCM tokens
/// - Handle incoming messages (foreground, background, tap)
/// - Display local notifications
/// - Register device token with Java backend on login
/// - Route users based on notification types
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService() {
    return _instance;
  }

  FirebaseMessagingService._internal();

  /// Dedup guard: tracks the last successful registration to avoid redundant calls.
  /// Key format: "userId:patientId:patientToken:fcmToken"
  String? _lastRegisteredKey;
  DateTime? _lastRegisteredAt;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  late INotificationRepo _notificationRepo;

  /// Initialize Firebase Messaging and local notifications.
  /// Must be called during app startup after dependency injection is set up.
  Future<void> initialize(INotificationRepo notificationRepo) async {
    _notificationRepo = notificationRepo;

    try {
      log('🔔 Initializing Firebase Cloud Messaging Service...');

      // Request notification permissions (required for iOS and Android 13+)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Log permission status
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          log('✅ Notifications authorized');
          break;
        case AuthorizationStatus.provisional:
          log('⚠️ Notifications provisional (iOS)');
          break;
        case AuthorizationStatus.denied:
          log('❌ Notifications denied by user');
          break;
        case AuthorizationStatus.notDetermined:
          log('❌ Notifications not determined');
          break;
      }

      // Enable foreground notification presentation (critical for iOS,
      // ensures FCM notifications with a notification payload still show
      // in the system tray while the app is open)
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _handleLocalNotificationTap,
      );

      log('✅ Local notifications initialized');

      // Create notification channel for Android
      await _createNotificationChannel();

      // Get initial FCM token
      await _getAndStoreFcmToken();

      // Listen for token refresh
      _listenForTokenRefresh();

      // Set up message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle initial message if app is launched from notification
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        await _handleInitialMessage(initialMessage);
      }

      // Sync token with backend on startup
      await registerTokenWithBackend();

      log('✅ Firebase Messaging Service initialized successfully');
    } catch (e) {
      log('❌ Error initializing Firebase Messaging Service: $e');
    }
  }

  /// Get current FCM token and save it locally
  Future<String?> _getAndStoreFcmToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null && token.isNotEmpty) {
        await SharedPrefHelper.setData(SharedPrefKeys.fcmToken, token);
        log('✅ FCM Token obtained and stored: ${token.substring(0, 20)}...');
        return token;
      }
    } catch (e) {
      log('❌ Error getting FCM token: $e');
    }
    return null;
  }

  /// Listen for FCM token refresh, update local storage, and re-register with backend
  void _listenForTokenRefresh() {
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      log('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
      await SharedPrefHelper.setData(SharedPrefKeys.fcmToken, newToken);
      // Re-register the new token with the backend so notifications keep arriving
      await registerTokenWithBackend();
    });
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    try {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()!;

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'thoutha_urgent_v1',
          'Thoutha Urgent Notifications',
          description: 'This channel is used for important appointment notifications.',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
          showBadge: true,
        ),
      );

      log('✅ Notification channel created');
    } catch (e) {
      log('⚠️ Error creating notification channel: $e');
    }
  }

  /// Handle messages received while app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('📬 Handling foreground message: ${message.messageId}');
    log('Data: ${message.data}');

    // Display local notification
    await _showLocalNotification(message);
  }

  /// Handle message when app is opened from notification
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    log('📱 App opened from notification: ${message.messageId}');

    final payload =
        NotificationPayloadModel.fromRemoteMessageData(message.data);
    await _routeFromNotification(payload);
  }

  /// Handle initial message when app is launched from notification
  Future<void> _handleInitialMessage(RemoteMessage message) async {
    log('🚀 Initial message on app launch: ${message.messageId}');

    final payload =
        NotificationPayloadModel.fromRemoteMessageData(message.data);
    await _routeFromNotification(payload);
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(
      NotificationResponse notificationResponse) {
    try {
      final payload = notificationResponse.payload;
      log('👆 Local notification tapped: $payload');

      if (payload != null && payload.isNotEmpty) {
        final notificationPayload =
            NotificationPayloadModel.fromEncodedString(payload);
        _routeFromNotification(notificationPayload);
      }
    } catch (e) {
      log('❌ Error handling notification tap: $e');
    }
  }

  /// Display local notification for foreground messages (both notification and data-only payloads)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;

      // Get title and body from notification object or data object
      String title = '';
      String body = '';

      if (notification != null) {
        // Has notification payload
        title = notification.title ?? L10nCore.newNotification.tr();
        body = notification.body ?? L10nCore.youHaveANew.tr();
        log('📲 Using notification payload: $title - $body');
      } else {
        // Data-only message with title/body in data object
        title = _safeString(message.data['title'] ?? message.data['message']);
        body = _safeString(
          message.data['body'] ??
              message.data['description'] ??
              message.data['content'],
        );
        if (title.isNotEmpty || body.isNotEmpty) {
          log('📲 Using data-only payload: $title - $body');
        }
      }

      // If title/body are still missing, derive them from type + payload
      if (title.isEmpty && body.isEmpty) {
        final derived = _deriveTitleBodyFromData(message.data);
        title = derived.title;
        body = derived.body;
      }

      // Skip if we couldn't determine title and body
      if (title.isEmpty && body.isEmpty) {
        log('⚠️ No title or body found in notification');
        return;
      }

      final payload = _encodePayload(message.data);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'thoutha_urgent_v1',
        'Thoutha Urgent Notifications',
        channelDescription: 'Important appointment notifications',
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        ticker: 'ticker',
        fullScreenIntent: true,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        id: message.hashCode.abs(),
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: payload,
      );

      log('📲 Local notification displayed: $title');
    } catch (e) {
      log('❌ Error showing local notification: $e');
    }
  }

  /// Encode notification data as query string with null safety
  String _encodePayload(Map<String, dynamic> data) {
    try {
      final entries = <String>[];
      data.forEach((key, value) {
        if (key.isNotEmpty && value != null) {
          final safeValue = value.toString();
          if (safeValue.isNotEmpty) {
            entries.add('$key=$safeValue');
          }
        }
      });
      return entries.join('&');
    } catch (e) {
      log('⚠️ Error encoding payload: $e');
      return '';
    }
  }

  String _safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  _DerivedTitleBody _deriveTitleBodyFromData(Map<String, dynamic> data) {
    final type = NotificationType.fromBackendValue(_safeString(data['type']));
    final patientName = _safeString(
      data['patientName'] ?? data['patient_name'] ?? data['name'],
    );
    final appointmentDate = _safeString(data['appointmentDate'] ?? data['date']);
    final appointmentTime = _safeString(data['appointmentTime'] ?? data['time']);

    switch (type) {
      case NotificationType.appointmentConfirmed:
        final title = 'Appointment confirmed';
        final details = patientName.isNotEmpty
            ? 'Patient $patientName confirmed an appointment'
            : 'An appointment was confirmed';
        final when = [appointmentDate, appointmentTime]
            .where((value) => value.isNotEmpty)
            .join(' ');
        final body = when.isNotEmpty ? '$details · $when' : details;
        return _DerivedTitleBody(title: title, body: body);
      case NotificationType.bookingRequestApproved:
        return const _DerivedTitleBody(
          title: 'Booking approved',
          body: 'A booking request was approved.',
        );
      case NotificationType.bookingRequestRejected:
        return const _DerivedTitleBody(
          title: 'Booking rejected',
          body: 'A booking request was rejected.',
        );
      default:
        return const _DerivedTitleBody(
          title: '',
          body: '',
        );
    }
  }

  /// Route to appropriate screen based on notification type, payload, and user role.
  /// Delegates to [NotificationRouteHandler] as the single source of truth for routing.
  Future<void> _routeFromNotification(NotificationPayloadModel payload) async {
    await NotificationRouteHandler.routeFromNotification(payload);
  }

  /// Register device token with Java backend
  /// Automatically detects if it should register for a Doctor (via userId) or Patient (via stored patientToken)
  Future<bool> registerTokenWithBackend({int? userId, int? patientId, String? patientToken}) async {
    try {
      final fcmToken = await SharedPrefHelper.getString(SharedPrefKeys.fcmToken);

      if (fcmToken.isEmpty) {
        log('⚠️ No FCM token available for registration');
        return false;
      }

      // 1. Detect user type and get the appropriate identifier
      int? effectiveUserId = userId;
      int? effectivePatientId = patientId;
      String? effectivePatientToken = patientToken;

      if (effectiveUserId == null && effectivePatientId == null && effectivePatientToken == null) {
        // Try to get doctor ID first
        final storedDoctorId = await SharedPrefHelper.getInt(SharedPrefKeys.userId);
        if (storedDoctorId != 0) {
          effectiveUserId = storedDoctorId;
        } else {
          // If not a doctor, try to get patient data
          effectivePatientId = await SharedPrefHelper.getInt(SharedPrefKeys.patientId);
          if (effectivePatientId == 0) effectivePatientId = null;

          effectivePatientToken = await SharedPrefHelper.getString(SharedPrefKeys.patientToken);
          if (effectivePatientToken == null || effectivePatientToken.isEmpty) {
            effectivePatientToken = null;
          }
        }
      }

      if (effectiveUserId == null && effectivePatientId == null && effectivePatientToken == null) {
        log('ℹ️ Identity not yet known. Skipping auto-registration until login or booking.');
        return false;
      }

      log('📤 Attempting to register device token (Doctor ID: $effectiveUserId, Patient ID: $effectivePatientId, Patient Token: $effectivePatientToken)...');

      // Dedup check: skip if same params were registered within the last 30 seconds
      final deduplicationKey = '$effectiveUserId:$effectivePatientId:$effectivePatientToken:$fcmToken';
      if (_lastRegisteredKey == deduplicationKey &&
          _lastRegisteredAt != null &&
          DateTime.now().difference(_lastRegisteredAt!).inSeconds < 30) {
        log('ℹ️ Skipping duplicate registration (already registered ${DateTime.now().difference(_lastRegisteredAt!).inSeconds}s ago)');
        return true;
      }

      final success = await _notificationRepo.registerDeviceToken(
        fcmToken: fcmToken,
        deviceType: Platform.isAndroid ? 'ANDROID' : 'IOS',
        userId: effectiveUserId,
        patientId: effectivePatientId,
        patientToken: effectivePatientToken,
        deviceModel: _getDeviceModel(),
        osVersion: Platform.operatingSystemVersion,
      );

      if (success) {
        _lastRegisteredKey = deduplicationKey;
        _lastRegisteredAt = DateTime.now();
        log('✅ Device token registered successfully with backend');
      } else {
        log('❌ Device token registration failed with backend');
      }

      return success;
    } catch (e) {
      log('❌ Error registering token with backend: $e');
      return false;
    }
  }

  /// Get device model name
  String _getDeviceModel() {
    try {
      if (Platform.isAndroid) {
        return 'Android Device';
      } else if (Platform.isIOS) {
        return 'iOS Device';
      }
    } catch (_) {}
    return 'Unknown Device';
  }
}

class _DerivedTitleBody {
  final String title;
  final String body;

  const _DerivedTitleBody({required this.title, required this.body});
}

