import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';
/// Notification types based on microservice specification
enum NotificationType {
  // Appointment related
  appointmentConfirmed,
  appointmentCancelled,
  appointmentReminder,

  // Booking requests
  bookingRequestApproved,
  bookingRequestRejected,

  // Treatment plans
  treatmentPlanCreated,
  treatmentPlanUpdated,

  // Payments
  paymentSuccessful,
  paymentFailed,

  // System
  profileUpdateRequired,
  systemAlert,
  generalAnnouncement,

  unknown;

  /// Convert enum to backend API value
  /// e.g., appointmentConfirmed → "APPOINTMENT_CONFIRMED"
  String get backendValue {
    switch (this) {
      case NotificationType.appointmentConfirmed:
        return 'APPOINTMENT_CONFIRMED';
      case NotificationType.appointmentCancelled:
        return 'APPOINTMENT_CANCELLED';
      case NotificationType.appointmentReminder:
        return 'APPOINTMENT_REMINDER';
      case NotificationType.bookingRequestApproved:
        return 'BOOKING_REQUEST_APPROVED';
      case NotificationType.bookingRequestRejected:
        return 'BOOKING_REQUEST_REJECTED';
      case NotificationType.treatmentPlanCreated:
        return 'TREATMENT_PLAN_CREATED';
      case NotificationType.treatmentPlanUpdated:
        return 'TREATMENT_PLAN_UPDATED';
      case NotificationType.paymentSuccessful:
        return 'PAYMENT_SUCCESSFUL';
      case NotificationType.paymentFailed:
        return 'PAYMENT_FAILED';
      case NotificationType.profileUpdateRequired:
        return 'PROFILE_UPDATE_REQUIRED';
      case NotificationType.systemAlert:
        return 'SYSTEM_ALERT';
      case NotificationType.generalAnnouncement:
        return 'GENERAL_ANNOUNCEMENT';
      default:
        return 'UNKNOWN';
    }
  }

  /// Parse backend value to enum
  /// e.g., "APPOINTMENT_CONFIRMED" → appointmentConfirmed
  static NotificationType fromBackendValue(String? value) {
    if (value == null || value.isEmpty) {
      return NotificationType.unknown;
    }

    try {
      return NotificationType.values.firstWhere(
        (type) => type.backendValue == value.toUpperCase(),
        orElse: () => NotificationType.unknown,
      );
    } catch (_) {
      return NotificationType.unknown;
    }
  }

  /// Get user-friendly display name in Arabic
  String get displayName {
    switch (this) {
      case NotificationType.appointmentConfirmed:
        return L10nNotifications.theAppointmentHasBeen.tr();
      case NotificationType.appointmentCancelled:
        return L10nNotifications.theAppointmentHasBeen1.tr();
      case NotificationType.appointmentReminder:
        return L10nNotifications.appointmentReminder.tr();
      case NotificationType.bookingRequestApproved:
        return L10nNotifications.yourReservationRequestHas.tr();
      case NotificationType.bookingRequestRejected:
        return L10nNotifications.yourReservationRequestHas1.tr();
      case NotificationType.treatmentPlanCreated:
        return L10nNotifications.aTreatmentPlanHas.tr();
      case NotificationType.treatmentPlanUpdated:
        return L10nNotifications.theTreatmentPlanHas.tr();
      case NotificationType.paymentSuccessful:
        return L10nNotifications.paymentSucceeded.tr();
      case NotificationType.paymentFailed:
        return L10nNotifications.paymentFailed.tr();
      case NotificationType.profileUpdateRequired:
        return L10nNotifications.requiresProfileUpdate.tr();
      case NotificationType.systemAlert:
        return L10nNotifications.systemAlert.tr();
      case NotificationType.generalAnnouncement:
        return L10nNotifications.publicAnnouncement.tr();
      default:
        return L10nNotifications.newNotification.tr();
    }
  }
}
