import 'dart:developer';
import 'dart:math' hide log;

import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/networking/api_constants.dart';
import 'package:thoutha_mobile_app/core/networking/api_service.dart';
import 'package:thoutha_mobile_app/features/notifications/data/models/notification_log_model.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import '../../../../core/helpers/constants.dart';

/// Abstract interface for notification repository operations
abstract class INotificationRepo {
  /// Register FCM token with Java backend for device identification
  /// Endpoint: POST /api/v1/device-tokens/register (on main backend port 8080)
  Future<bool> registerDeviceToken({
    required String fcmToken,
    required String deviceType,
    int? userId,
    int? patientId,
    String? patientToken,
    String? deviceModel,
    String? osVersion,
  });

  /// Deregister FCM token on logout to prevent push notification leakage
  /// Endpoint: DELETE /api/device-tokens/deregister
  Future<bool> deregisterDeviceToken({required String fcmToken});

  /// Fetch all notifications for the current user
  /// Endpoint: GET /api/v1/notifications
  Future<List<NotificationLogModel>> getNotifications();

  /// Mark a notification as read
  /// Endpoint: PATCH /api/v1/notifications/{id}/read
  Future<bool> markNotificationAsRead(int notificationId);

  /// Mark all notifications as read
  /// Endpoint: PATCH /api/v1/notifications/read-all
  Future<bool> markAllNotificationsAsRead();

  /// Delete a specific notification
  /// Endpoint: DELETE /api/v1/notifications/{id}
  Future<bool> deleteNotification(int notificationId);

  /// Delete all notifications
  /// Endpoint: DELETE /api/v1/notifications
  Future<bool> deleteAllNotifications();

  /// Fetch patient temporary token
  /// Endpoint: GET /api/v1/patient/token
  Future<String?> getPatientToken({String? phone, int? appointmentId});

  /// Fetch notifications for a patient using temporary token
  /// Endpoint: GET /api/v1/patient/notifications/{token}
  Future<List<NotificationLogModel>> getPatientNotifications(String token);

  /// Validate patient temporary token
  /// Endpoint: POST /api/v1/patient/token-validate
  Future<bool> validatePatientToken(String token);
}

/// Implementation of notification repository
/// Communicates with both Java backend and Notification microservice
class NotificationRepo implements INotificationRepo {
  final ApiService _apiService;

  NotificationRepo(this._apiService);

  @override
  Future<bool> registerDeviceToken({
    required String fcmToken,
    required String deviceType,
    int? userId,
    int? patientId,
    String? patientToken,
    String? deviceModel,
    String? osVersion,
  }) async {
    try {
      log('📱 Registering device token with Java backend...');

      final Map<String, dynamic> requestData = {
        'fcmToken': fcmToken,
        'deviceType': deviceType,
        'deviceModel': deviceModel,
        'osVersion': osVersion,
      };

      // Sending both formats to ensure compatibility with different backend versions
      if (userId != null) {
        requestData['user_id'] = userId;
        requestData['userId'] = userId;
      }

      if (patientId != null) {
        requestData['patient_id'] = patientId;
        requestData['patientId'] = patientId;
      }
      
      if (patientToken != null && patientToken.isNotEmpty && patientToken != 'GUEST_DEVICE') {
        requestData['patient_token'] = patientToken;
        requestData['patientToken'] = patientToken;
      }

      final response = await _apiService.post(
        ApiConstants.registerDeviceToken,
        data: requestData,
      );

      log('✅ Device token registration response: $response');

      // Check if registration was successful
      final success = response['success'] == true;
      if (success) {
        log('✅ Device token registered successfully');
      } else {
        // Corrected to use 'error' field from ApiService
        log('❌ Device token registration failed: ${response['error'] ?? 'Unknown Error'}');
      }
      return success;
    } on Exception catch (e, stackTrace) {
      log('❌ Error registering device token: $e\n$stackTrace');

      // Return false on error - let the app continue without token registration
      // The app will still function, just without push notifications
      return false;
    }
  }

  @override
  Future<bool> deregisterDeviceToken({required String fcmToken}) async {
    try {
      log('📱 Deregistering device token with Java backend: $fcmToken');
      final response = await _apiService.delete(
        '${ApiConstants.deregisterDeviceToken}?token=$fcmToken',
      );
      log('✅ Device token deregistration response: $response');
      return response['success'] == true;
    } on Exception catch (e, stackTrace) {
      log('❌ Error deregistering device token: $e\n$stackTrace');
      return false;
    }
  }

  @override
  Future<List<NotificationLogModel>> getNotifications() async {
    try {
      log('📨 Fetching notifications from API...');

      final response = await _apiService.get(
        ApiConstants.getNotifications,
      );

      log('🔍 Full API Response: $response');

      if (response['success'] == true) {
        final data = response['data'];
        log('📦 Response data type: ${data.runtimeType}');
        if (data is Map) {
          log('📦 Response data keys: ${(data).keys.toList()}');
        }

        // Handle both list and wrapped responses
        List? rawList = data is List
            ? data
            : (data is Map
                ? (data['notifications'] ??
                    data['content'] ??
                    data['items'] ??
                    data['data'] ??
                    data['list'] ??
                    data['results'] ??
                    []) as List?
                : null);

        if (rawList == null) {
          log('⚠️ No notifications list found in response');
          return [];
        }

        log('📋 Found ${rawList.length} raw items from API');

        final notifications = <NotificationLogModel>[];
        for (final item in rawList) {
          try {
            final map = Map<String, dynamic>.from(item as Map);
            log('📋 Raw notification data: $map');
            
            // Ensure title and body exist
            final currentTitle = map['title'];
            final titleIsEmpty = currentTitle == null ||
                (currentTitle is String && currentTitle.isEmpty);

            if (titleIsEmpty) {
              map['title'] = map['message'] ?? map['name'] ?? L10nCore.notification.tr();
            }

            final currentBody = map['body'];
            final bodyIsEmpty = currentBody == null ||
                (currentBody is String && currentBody.isEmpty);

            if (bodyIsEmpty) {
              map['body'] = map['description'] ?? map['content'] ?? map['text'] ?? '';
            }
            
            log('✅ Normalized notification data: title="${map['title']}", body="${map['body']}"');
            
            notifications.add(NotificationLogModel.fromJson(map));
          } catch (e) {
            log('⚠️ Failed to parse notification item: $e\nItem: $item');
          }
        }

        log('✅ Final: Fetched ${notifications.length} notifications');
        for (var n in notifications) {
          log('   - ID: ${n.id}, Title: ${n.title}, Body: ${n.body}, Read: ${n.readStatus}');
        }
        return notifications;
      } else {
        log('❌ Failed to fetch notifications: success is false');
        log('❌ Error: ${response['error']}');
        log('❌ Full response: $response');
        return [];
      }
    } catch (e, stackTrace) {
      log('❌ Exception in getNotifications: $e');
      log('❌ StackTrace: $stackTrace');
      return [];
    }
  }

  @override
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      log('📍 Marking notification $notificationId as read...');

      // Changed from patch to put to resolve 405 error
      final response = await _apiService.put(
        ApiConstants.markNotificationAsRead
            .replaceFirst('{id}', '$notificationId'),
      );

      final success = response['success'] == true;
      if (success) {
        log('✅ Notification $notificationId marked as read');
      } else {
        log('❌ Failed to mark notification as read: ${response['error']}');
      }
      return success;
    } catch (e, stackTrace) {
      log('❌ Error marking notification as read: $e\n$stackTrace');
      return false;
    }
  }

  @override
  Future<bool> markAllNotificationsAsRead() async {
    try {
      log('📍 Marking all notifications as read...');

      // Changed from patch to put to resolve 405 error
      final response = await _apiService.put(
        ApiConstants.markAllNotificationsAsRead,
      );

      final success = response['success'] == true;
      if (success) {
        log('✅ All notifications marked as read');
      } else {
        log('❌ Failed to mark all notifications as read: ${response['error']}');
      }
      return success;
    } catch (e, stackTrace) {
      log('❌ Error marking all notifications as read: $e\n$stackTrace');
      return false;
    }
  }

  @override
  Future<bool> deleteNotification(int notificationId) async {
    try {
      log('🗑️ Deleting notification $notificationId...');

      final response = await _apiService.delete(
        ApiConstants.deleteNotification.replaceFirst('{id}', '$notificationId'),
      );

      final success = response['success'] == true;
      if (success) {
        log('✅ Notification $notificationId deleted');
      } else {
        log('❌ Failed to delete notification: ${response['error']}');
      }
      return success;
    } catch (e, stackTrace) {
      log('❌ Error deleting notification: $e\n$stackTrace');
      return false;
    }
  }

  @override
  Future<bool> deleteAllNotifications() async {
    try {
      log('🗑️ Deleting all notifications...');

      final response = await _apiService.delete(
        ApiConstants.deleteAllNotifications,
      );

      final success = response['success'] == true;
      if (success) {
        log('✅ All notifications deleted');
      } else {
        log('❌ Failed to delete all notifications: ${response['error']}');
      }
      return success;
    } catch (e, stackTrace) {
      log('❌ Error deleting all notifications: $e\n$stackTrace');
      return false;
    }
  }

  @override
  Future<String?> getPatientToken({String? phone, int? appointmentId}) async {
    try {
      log('🎫 Fetching patient temporary token...');
      final Map<String, dynamic> query = {};
      
      // Prioritize appointment_id
      if (appointmentId != null) {
        query['appointment_id'] = appointmentId;
      } else if (phone != null) {
        // Send the phone number exactly as entered (01...)
        query['phone'] = phone.trim();
      }

      log('🔍 Search Query: $query');

      final response = await _apiService.get(ApiConstants.getPatientToken, query: query);
      
      if (response['success'] == true) {
        final data = response['data'] ?? response;
        final token = data['token'];
        
        if (token != null) {
          log('✅ Successfully fetched patient token: $token');
          
          final patientId = data['patient_id'] ?? data['patientId'];
          if (patientId != null) {
            final int? intId = patientId is int 
                ? patientId 
                : int.tryParse(patientId.toString());
            if (intId != null) {
              await SharedPrefHelper.setData(SharedPrefKeys.patientId, intId);
            }
          }
          return token.toString();
        }
      }
      
      log('⚠️ Could not find token for the provided criteria');
      return null;
    } catch (e) {
      log('❌ Error fetching patient token: $e');
      return null;
    }
  }

  @override
  Future<List<NotificationLogModel>> getPatientNotifications(String token) async {
    try {
      log('📨 Fetching patient notifications for token: ${token.substring(0, min(token.length, 10))}...');
      final response = await _apiService.get(
        ApiConstants.getPatientNotifications.replaceFirst('{token}', token),
      );

      log('🔍 Patient API Response: $response');

      if (response['success'] == true) {
        final data = response['data'];
        log('📦 Patient response data type: ${data.runtimeType}');
        if (data is Map) {
          log('📦 Patient response data keys: ${(data).keys.toList()}');
        }

        // Handle various response formats (List, or Map with notifications/content/items)
        List? rawList = data is List
            ? data
            : (data is Map
                ? (data['notifications'] ??
                    data['content'] ??
                    data['items'] ??
                    data['data'] ??
                    data['list'] ??
                    data['results'] ??
                    []) as List?
                : null);

        if (rawList == null) {
          log('⚠️ Could not find notifications list for patient');
          return [];
        }

        if (rawList.isEmpty) {
          log('⚠️ Patient notifications list is empty');
          return [];
        }

        log('📋 Found ${rawList.length} raw patient notification items');

        final notifications = <NotificationLogModel>[];
        for (final item in rawList) {
          try {
            final map = Map<String, dynamic>.from(item as Map);
            log('📋 Raw patient notification data: $map');
            
            // Ensure title and body exist
            final currentTitle = map['title'];
            final titleIsEmpty = currentTitle == null ||
                (currentTitle is String && currentTitle.isEmpty);

            if (titleIsEmpty) {
              map['title'] = map['message'] ?? map['name'] ?? L10nCore.notification.tr();
            }

            final currentBody = map['body'];
            final bodyIsEmpty = currentBody == null ||
                (currentBody is String && currentBody.isEmpty);

            if (bodyIsEmpty) {
              map['body'] = map['description'] ?? map['content'] ?? map['text'] ?? '';
            }
            
            log('✅ Normalized patient notification data: title="${map['title']}", body="${map['body']}"');

            notifications.add(NotificationLogModel.fromJson(map));
          } catch (e) {
            log('⚠️ Failed to parse patient notification item: $e');
          }
        }

        log('✅ Final: Fetched ${notifications.length} patient notifications');
        for (var n in notifications) {
          log('   - ID: ${n.id}, Title: ${n.title}, Body: ${n.body}, Read: ${n.readStatus}');
        }
        return notifications;
      } else {
        log('❌ Failed to fetch patient notifications: success is false');
        log('❌ Error: ${response['error']}');
        log('❌ Full response: $response');
        return [];
      }
    } catch (e, stackTrace) {
      log('❌ Exception in getPatientNotifications: $e');
      log('❌ StackTrace: $stackTrace');
      return [];
    }
  }

  @override
  Future<bool> validatePatientToken(String token) async {
    try {
      log('🔍 Validating patient token...');
      final response = await _apiService.post(
        ApiConstants.validatePatientToken,
        data: {'token': token},
      );
      return response['success'] == true;
    } catch (e) {
      log('❌ Error validating patient token: $e');
      return false;
    }
  }
}
