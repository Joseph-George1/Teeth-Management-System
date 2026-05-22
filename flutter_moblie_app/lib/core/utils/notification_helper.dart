import 'dart:developer';

import 'package:thoutha_mobile_app/core/di/dependency_injection.dart';
import 'package:thoutha_mobile_app/features/notifications/logic/notifications_cubit.dart';

class NotificationHelper {
  static bool hasUnreadNotifications = false;

  static int getUnreadCount() {
    try {
      final cubit = getIt<NotificationsCubit>();
      return cubit.getUnreadCount();
    } catch (e) {
      log('Error getting unread count: $e');
      return 0;
    }
  }

  /// Mark notifications as fetched (for the bell icon counter)
  static void markAsRead() {
    hasUnreadNotifications = false;
  }

  /// Update the unread state
  static void setHasUnread(bool hasUnread) {
    hasUnreadNotifications = hasUnread;
  }
}
