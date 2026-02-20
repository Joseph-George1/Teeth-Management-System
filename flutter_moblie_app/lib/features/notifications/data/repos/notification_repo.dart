import 'package:thotha_mobile_app/core/networking/api_service.dart';
import 'dart:developer';

abstract class INotificationRepo {
  Future<bool> sendTokenToBackend(String token);
}

class NotificationRepo implements INotificationRepo {
  final ApiService _apiService;
  NotificationRepo(this._apiService);

  @override
  Future<bool> sendTokenToBackend(String token) async {
    try {
      log("Sending Token to Java Backend: $token");
      // Since the backend dev hasn't provided the actual endpoint yet,
      // we prepare the call structure here.
      // Example: final response = await _apiService.post('/api/save-token', {'token': token});

      // For now, simulate success as requested
      return true;
    } catch (e) {
      log("Error sending token: $e");
      return false;
    }
  }
}
