import 'dart:developer';
import 'package:thoutha_mobile_app/core/di/dependency_injection.dart';
import 'package:thoutha_mobile_app/features/notifications/logic/notifications_cubit.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/helpers/constants.dart';
import 'package:thoutha_mobile_app/core/routing/routes.dart';
import 'package:thoutha_mobile_app/core/routing/navigator_service.dart';
import 'package:thoutha_mobile_app/features/notifications/data/models/notification_payload_model.dart';

/// Handles navigation routing based on notification payload.
/// Maps notification data to existing app routes safely.
/// This is the **single source of truth** for all notification-tap routing
/// (foreground, background, and terminated-launch).
class NotificationRouteHandler {
  /// Route to appropriate screen based on notification payload and user role.
  /// Falls back to the role-appropriate notifications screen if no specific
  /// mapping exists.
  static Future<void> routeFromNotification(
      NotificationPayloadModel payload) async {
    try {
      log('NotificationRouteHandler: routing from payload: $payload');

      // Get navigator context
      final navigator = NavigatorService.navigatorKey.currentState;
      if (navigator == null) {
        log('NotificationRouteHandler: Navigator not available');
        return;
      }

      // ── 1. Determine user role ────────────────────────────────────
      final doctorToken =
          await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
      final patientToken =
          await SharedPrefHelper.getString(SharedPrefKeys.patientToken);

      final bool isDoctor =
          doctorToken.isNotEmpty && doctorToken != 'null';
      final bool isPatient = !isDoctor && patientToken.isNotEmpty;

      log('NotificationRouteHandler: isDoctor=$isDoctor, isPatient=$isPatient');

      // ── 2. Mark notification as read if we have an ID ──────────
      if (payload.notificationId != null) {
        final notificationId = int.tryParse(payload.notificationId!);
        if (notificationId != null) {
          try {
            getIt<NotificationsCubit>().markAsRead(notificationId);
            log('NotificationRouteHandler: Marked notification $notificationId as read');
          } catch (e) {
            log('NotificationRouteHandler: Could not mark as read: $e');
          }
        }
      }

      // ── 3. Decide target route ────────────────────────────────────
      String? targetRoute;
      Map<String, dynamic>? arguments;

      if (payload.appointmentId?.isNotEmpty == true) {
        // Has an appointment context → navigate to the appropriate appointments screen
        targetRoute = isDoctor
            ? Routes.doctorNextBookingScreen
            : Routes.appointmentsScreen;
        arguments = {'appointmentId': payload.appointmentId};
        log('NotificationRouteHandler: routing to appointments with ID: ${payload.appointmentId}');
      }

      // ── 4. Fallback to role-specific notifications screen ────────
      if (targetRoute == null) {
        targetRoute = isPatient
            ? Routes.patientNotificationsScreen
            : Routes.notificationsScreen;
        log('NotificationRouteHandler: routing to ${isPatient ? "patient" : "doctor"} notifications screen (default)');
      }

      // ── 5. Navigate ────────────────────────────────────────────────
      navigator.pushNamed(
        targetRoute,
        arguments: arguments,
      );
    } catch (e) {
      log('NotificationRouteHandler error: $e');
      // Last-resort fallback: open doctor notifications screen
      NavigatorService.navigatorKey.currentState?.pushNamed(
        Routes.notificationsScreen,
      );
    }
  }
}
