import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_token_request.freezed.dart';
part 'device_token_request.g.dart';

@freezed
abstract class DeviceTokenRequest with _$DeviceTokenRequest {
  const factory DeviceTokenRequest({
    @JsonKey(name: 'user_id') int? userId,
    @JsonKey(name: 'patient_id') int? patientId,
    @JsonKey(name: 'patient_token') String? patientToken,
    required String fcmToken,
    required String deviceType, // 'ANDROID' or 'IOS'
    String? deviceModel,
    String? osVersion,
  }) = _DeviceTokenRequest;

  factory DeviceTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$DeviceTokenRequestFromJson(json);
}
