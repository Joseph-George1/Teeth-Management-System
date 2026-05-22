import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoutha_mobile_app/core/di/dependency_injection.dart';
import 'package:thoutha_mobile_app/core/helpers/constants.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/services/firebase_messaging_service.dart';
import 'package:thoutha_mobile_app/features/notifications/data/models/notification_log_model.dart';
import 'package:thoutha_mobile_app/features/notifications/data/repos/notification_repo.dart';

part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final INotificationRepo _notificationRepo;

  NotificationsCubit(this._notificationRepo)
      : super(NotificationsState.initial());

  Future<void> _loadCachedNotifications() async {
    try {
      final doctorToken = await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
      final patientToken = await SharedPrefHelper.getString(SharedPrefKeys.patientToken);
      String cachedKey = "";
      if (doctorToken.isNotEmpty && doctorToken != 'null') {
        cachedKey = "cached_doctor_notifications";
      } else if (patientToken.isNotEmpty) {
        cachedKey = "cached_patient_notifications";
      }
      if (cachedKey.isNotEmpty) {
        final cachedStr = await SharedPrefHelper.getString(cachedKey);
        if (cachedStr.isNotEmpty) {
          final List decoded = json.decode(cachedStr) as List;
          final list = decoded.map((e) => NotificationLogModel.fromJson(e as Map<String, dynamic>)).toList();
          if (!isClosed) {
            emit(NotificationsState.success(list));
          }
        }
      }
    } catch (_) {}
  }

  /// Fetch all notifications from API
  Future<void> fetchNotifications({bool showLoading = true, bool forcePatient = false}) async {
    await _loadCachedNotifications();

    if (showLoading && !isClosed && (state is! SuccessState)) {
      emit(NotificationsState.loading());
    }

    try {
      final doctorToken = await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
      final patientToken = await SharedPrefHelper.getString(SharedPrefKeys.patientToken);
      
      List<NotificationLogModel> notifications = [];

      // If forcePatient is true, we ONLY look for patient notifications
      if (forcePatient) {
        if (patientToken.isNotEmpty) {
          notifications = await _notificationRepo.getPatientNotifications(patientToken);
          log('👥 Fetched ${notifications.length} patient notifications (forced)');
        }
      } else {
        // Normal logic: prioritize doctor if logged in, else patient
        if (doctorToken.isNotEmpty && doctorToken != 'null') {
          log('👨‍⚕️ Fetching doctor notifications...');
          notifications = await _notificationRepo.getNotifications();
        } else if (patientToken.isNotEmpty) {
          log('👤 Fetching patient notifications...');
          notifications = await _notificationRepo.getPatientNotifications(patientToken);
        } else {
          log('ℹ️ No user token available. Showing empty notifications.');
        }
      }

      log('📦 Total notifications to emit: ${notifications.length}');
      
      if (!isClosed) {
        emit(NotificationsState.success(notifications));
        log('✅ Emitted success state with ${notifications.length} notifications');
      }

      // Save to cache
      try {
        String cachedKey = "";
        if (forcePatient) {
          cachedKey = "cached_patient_notifications";
        } else {
          if (doctorToken.isNotEmpty && doctorToken != 'null') {
            cachedKey = "cached_doctor_notifications";
          } else if (patientToken.isNotEmpty) {
            cachedKey = "cached_patient_notifications";
          }
        }
        if (cachedKey.isNotEmpty) {
          final encoded = json.encode(notifications.map((e) => e.toJson()).toList());
          await SharedPrefHelper.setData(cachedKey, encoded);
        }
      } catch (_) {}
    } catch (e, stackTrace) {
      log('❌ Error in fetchNotifications: $e\n$stackTrace');
      if (!isClosed) {
        emit(NotificationsState.failure('Error fetching notifications: $e'));
      }
    }
  }

  Future<void> fetchPatientNotifications({String? phone, int? appointmentId}) async {
    emit(NotificationsState.loading());
    
    // Clear old patient token first to ensure fresh search
    await SharedPrefHelper.removeData(SharedPrefKeys.patientToken);
    
    final token = await _notificationRepo.getPatientToken(
      phone: phone,
      appointmentId: appointmentId,
    );
    
    if (token != null) {
      await SharedPrefHelper.setData(SharedPrefKeys.patientToken, token);

      // Register FCM token for the patient
      try {
        final firebaseService = getIt<FirebaseMessagingService>();
        await firebaseService.registerTokenWithBackend(patientToken: token);
      } catch (e) {
        log('Error registering patient token in cubit: $e');
      }

      final allNotifications = await _notificationRepo.getPatientNotifications(token);
      
      // Filter notifications to only show those for this specific booking
      List<NotificationLogModel> notifications = allNotifications;
      if (appointmentId != null) {
        notifications = allNotifications.where((n) {
          final String? notifApptIdStr = (n.appointmentId?.isNotEmpty == true) 
              ? n.appointmentId 
              : n.payload['appointmentId']?.toString();
          final int? notifApptId = int.tryParse(notifApptIdStr ?? '');
          return notifApptId == appointmentId;
        }).toList();
      }

      emit(NotificationsState.success(notifications));

      // Cache patient notifications
      try {
        final encoded = json.encode(notifications.map((e) => e.toJson()).toList());
        await SharedPrefHelper.setData("cached_patient_notifications", encoded);
      } catch (_) {}
    } else {
      emit(NotificationsState.success([]));
    }
  }

  /// Clear current notifications and state
  void clearNotifications() {
    emit(NotificationsState.initial());
  }

  /// Mark a specific notification as read
  Future<void> markAsRead(int notificationId) async {
    final success =
        await _notificationRepo.markNotificationAsRead(notificationId);
    if (success) {
      // Refresh notifications after marking as read
      await fetchNotifications();
    }
  }

  /// Mark all notifications as read sequentially by looping through their IDs
  Future<void> markAllAsRead() async {
    final currentState = state;
    if (currentState is SuccessState) {
      // 1. Filter only unread notifications
      final List<int> unreadIds = currentState.notifications
          .where((n) => !n.readStatus)
          .map((n) => n.id)
          .toList();

      if (unreadIds.isEmpty) return;

      // Optimistic Update: Mark them all as read in UI first
      final updated = currentState.notifications
          .map((notification) => notification.copyWith(readStatus: true))
          .toList();
      emit(NotificationsState.success(updated));

      // 2. Loop through them and mark as read one by one
      for (final id in unreadIds) {
        await _notificationRepo.markNotificationAsRead(id);
      }

      // 3. Sync with backend to ensure consistency
      await fetchNotifications(showLoading: false);
    }
  }

  /// Delete a specific notification
  Future<void> deleteNotification(int notificationId) async {
    final success = await _notificationRepo.deleteNotification(notificationId);
    if (success) {
      // Refresh notifications after deletion
      await fetchNotifications();
    }
  }

  /// Delete all notifications sequentially by looping through their IDs
  Future<void> deleteAllNotifications() async {
    final currentState = state;
    if (currentState is SuccessState) {
      // 1. Create a list of notification IDs
      final List<int> notificationIds =
          currentState.notifications.map((n) => n.id).toList();

      if (notificationIds.isEmpty) return;

      // Show loading while deleting
      emit(NotificationsState.loading());

      // 2. Loop through them and delete one by one
      for (final id in notificationIds) {
        await _notificationRepo.deleteNotification(id);
      }

      // 3. Refresh the list from the server
      await fetchNotifications();
    }
  }

  /// Get count of unread notifications
  int getUnreadCount() {
    if (state is SuccessState) {
      final notifications = (state as SuccessState).notifications;
      return notifications.where((n) => !n.readStatus).length;
    }
    return 0;
  }
}
