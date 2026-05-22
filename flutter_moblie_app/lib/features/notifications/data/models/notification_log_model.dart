import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_log_model.freezed.dart';
part 'notification_log_model.g.dart';

@freezed
abstract class NotificationLogModel with _$NotificationLogModel {
  const factory NotificationLogModel({
    required int id,
    required String title,
    @Default('') String body,
    @JsonKey(name: 'status') @Default('SENT') String status,
    @JsonKey(name: 'createdAt') required String createdAt,
    @JsonKey(name: 'updatedAt') String? updatedAt,
    @Default(false) bool readStatus,
    @Default({}) Map<String, dynamic> payload,
    // Optional payload fields
    @Default('') String? appointmentId,
    @Default('') String? messageId,
    @Default('') String? doctorId,
    @Default('') String? type,
    @Default('') String? time,
    @Default('') String? clinic,
    @Default('') String? doctorName,
  }) = _NotificationLogModel;

  factory NotificationLogModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationLogModelFromJson(_normalizeJson(json));

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    // Backend can send read flag under different keys, normalize to readStatus.
    final dynamic statusValue = normalized['status'];
    final bool fallbackFromStatus =
        statusValue is String && statusValue.toUpperCase() == 'READ';

    normalized['readStatus'] = normalized['readStatus'] ??
        normalized['isRead'] ??
        normalized['read'] ??
        normalized['seen'] ??
        fallbackFromStatus;

    return normalized;
  }
}
