import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thoutha_mobile_app/features/notifications/data/models/notification_type.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');

  // Ensure Firebase is initialized before using its services in the background.
  await Firebase.initializeApp();

  // If the message contains a notification payload, Android/iOS will automatically
  // show it in the system tray. We don't want to show a duplicate local notification.
  if (message.notification != null) {
    log('Message has a notification payload. OS will handle it.');
    return;
  }

  // If it's a data-only payload, we construct and show a local notification manually.
  // Using hardcoded fallback text since localization isn't available in background thread
  final derived = _deriveTitleBodyFromData(message.data);
  final title = derived.title.isNotEmpty ? derived.title : (message.data['title'] ?? 'New alert');
  final body = derived.body.isNotEmpty ? derived.body : (message.data['body'] ?? 'You have a new notification');

  log('📬 Data-only message detected. Creating local notification: $title - $body');

  // We must re-initialize local notifications because this runs in an isolated background thread.
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await localNotifications.initialize(settings: initSettings);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'thoutha_urgent_v1',
    'Thoutha Urgent Notifications',
    channelDescription: 'Important appointment notifications',
    icon: '@mipmap/ic_launcher',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    enableVibration: true,
    playSound: true,
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

  // Encode the data payload so it can be handled when tapped (requires handling in UI)
  String encodedPayload = _encodePayload(message.data);

  try {
    await localNotifications.show(
      id: message.hashCode.abs(),
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: encodedPayload,
    );
    log('✅ Background notification displayed successfully');
  } catch (e) {
    log('❌ Error displaying background notification: $e');
  }
}

// Helper method to safely encode the map data to a uniform query string similar to the main service
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
    log('⚠️ Error encoding background payload: $e');
    return '';
  }
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
      return const _DerivedTitleBody(title: '', body: '');
  }
}

String _safeString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

class _DerivedTitleBody {
  final String title;
  final String body;

  const _DerivedTitleBody({required this.title, required this.body});
}
