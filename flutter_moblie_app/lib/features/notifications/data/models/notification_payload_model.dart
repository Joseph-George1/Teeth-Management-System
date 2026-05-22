import 'package:thoutha_mobile_app/features/notifications/data/models/notification_type.dart';

/// Helper function to safely convert null values to empty string
String _safeString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

/// Represents a notification payload received from Firebase Messaging.
/// Structured to match microservice notification format.
class NotificationPayloadModel {
  final String? type;
  final String? title;
  final String? body;
  final String? appointmentId;
  final String? treatmentPlanId;
  final String? requestId;
  final String? doctorId;
  final String? doctorName;
  final String? appointmentDate;
  final String? appointmentTime;
  final String? patientId;
  final String? patientName;
  final String? notificationId;
  final Map<String, String> rawData;

  NotificationPayloadModel({
    this.type,
    this.title,
    this.body,
    this.appointmentId,
    this.treatmentPlanId,
    this.requestId,
    this.doctorId,
    this.doctorName,
    this.appointmentDate,
    this.appointmentTime,
    this.patientId,
    this.patientName,
    this.notificationId,
    Map<String, String>? rawData,
  }) : rawData = rawData ?? {};

  /// Parse from Firebase remote message data with null safety
  factory NotificationPayloadModel.fromRemoteMessageData(
    Map<String, dynamic> data,
  ) {
    final stringMap = <String, String>{};
    data.forEach((key, value) {
      final safeValue = _safeString(value);
      if (safeValue.isNotEmpty) {
        stringMap[key] = safeValue;
      }
    });

    return NotificationPayloadModel(
      type: _safeStringOrNull(data['type']),
      title: _safeStringOrNull(data['title']),
      body: _safeStringOrNull(data['body']),
      appointmentId: _safeStringOrNull(data['appointmentId']),
      treatmentPlanId: _safeStringOrNull(data['treatmentPlanId']),
      requestId: _safeStringOrNull(data['requestId']),
      doctorId: _safeStringOrNull(data['doctorId']),
      doctorName: _safeStringOrNull(data['doctorName']),
      appointmentDate: _safeStringOrNull(data['appointmentDate']),
      appointmentTime: _safeStringOrNull(data['appointmentTime']),
      patientId: _safeStringOrNull(data['patientId']),
      patientName: _safeStringOrNull(data['patientName']),
      notificationId: _safeStringOrNull(data['notificationId'] ?? data['id']),
      rawData: stringMap,
    );
  }

  /// Parse from encoded string with null safety (key1=value1&key2=value2)
  factory NotificationPayloadModel.fromEncodedString(String payload) {
    final Map<String, String> data = {};

    if (payload.isNotEmpty) {
      try {
        final pairs = payload.split('&');
        for (var pair in pairs) {
          if (pair.contains('=')) {
            final parts = pair.split('=');
            if (parts.length == 2 && parts[0].isNotEmpty) {
              final value = _safeString(parts[1]);
              if (value.isNotEmpty) {
                data[parts[0]] = value;
              }
            }
          }
        }
      } catch (e) {
        // Silently handle parsing errors
      }
    }

    return NotificationPayloadModel(
      type: data['type'],
      title: data['title'],
      body: data['body'],
      appointmentId: data['appointmentId'],
      treatmentPlanId: data['treatmentPlanId'],
      requestId: data['requestId'],
      doctorId: data['doctorId'],
      doctorName: data['doctorName'],
      appointmentDate: data['appointmentDate'],
      appointmentTime: data['appointmentTime'],
      patientId: data['patientId'],
      patientName: data['patientName'],
      notificationId: data['notificationId'] ?? data['id'],
      rawData: data,
    );
  }

  /// Get notification type enum
  NotificationType get notificationType =>
      NotificationType.fromBackendValue(type);

  /// Check if has valid identifiable data
  bool get hasValidData =>
      appointmentId != null ||
      treatmentPlanId != null ||
      requestId != null ||
      doctorId != null;

  /// Check if notification is about appointment
  bool get isAppointmentNotification =>
      appointmentId != null ||
      notificationType == NotificationType.appointmentConfirmed ||
      notificationType == NotificationType.appointmentCancelled ||
      notificationType == NotificationType.appointmentReminder;

  /// Check if notification is about treatment plan
  bool get isTreatmentPlanNotification =>
      treatmentPlanId != null ||
      notificationType == NotificationType.treatmentPlanCreated ||
      notificationType == NotificationType.treatmentPlanUpdated;

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'body': body,
      'appointmentId': appointmentId,
      'treatmentPlanId': treatmentPlanId,
      'requestId': requestId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'patientId': patientId,
      'patientName': patientName,
      'notificationId': notificationId,
      ...rawData,
    };
  }

  @override
  String toString() {
    return 'NotificationPayloadModel('
        'type: $type, '
        'title: $title, '
        'appointmentId: $appointmentId, '
        'treatmentPlanId: $treatmentPlanId, '
        'doctorName: $doctorName)';
  }
}

/// Helper function to safely convert values to nullable string
String? _safeStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    return value.isEmpty ? null : value;
  }
  final stringValue = value.toString();
  return stringValue.isEmpty ? null : stringValue;
}
