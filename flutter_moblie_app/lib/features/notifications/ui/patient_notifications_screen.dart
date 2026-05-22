import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoutha_mobile_app/core/di/dependency_injection.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/helpers/constants.dart';
import 'package:thoutha_mobile_app/features/notifications/logic/notifications_cubit.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:intl/intl.dart' as intl;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class PatientNotificationsScreen extends StatefulWidget {
  const PatientNotificationsScreen({super.key});

  @override
  State<PatientNotificationsScreen> createState() => _PatientNotificationsScreenState();
}

class _PatientNotificationsScreenState extends State<PatientNotificationsScreen> {
  late NotificationsCubit _cubit;
  bool _hasBooking = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<NotificationsCubit>();
    _loadBookingNotifications();
  }

  Future<void> _loadBookingNotifications() async {
    // Check if there's a saved booking ID and auto-load notifications
    final dynamic rawBookingId = await SharedPrefHelper.getInt(SharedPrefKeys.lastBookingId);
    final int savedBookingId = rawBookingId is int ? rawBookingId : 0;

    if (savedBookingId > 0) {
      setState(() => _hasBooking = true);
      _cubit.fetchPatientNotifications(appointmentId: savedBookingId);
      return;
    }

    // No booking found - show empty state
    setState(() => _hasBooking = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = context.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: Text(
          isArabic ? 'الإشعارات' : 'Notifications',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _hasBooking
          ? BlocBuilder<NotificationsCubit, NotificationsState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state is SuccessState) {
                  if (state.notifications.isEmpty) {
                    return _buildNoNotificationsYet();
                  }
                  return _buildNotificationsList(state.notifications);
                } else if (state is LoadingState) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return _buildNoBookingState();
                }
              },
            )
          : _buildNoBookingState(),
    );
  }

  /// Shown when the patient hasn't made any booking yet
  Widget _buildNoBookingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              L10nNotifications.patientNoBookingTitle.tr(),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              L10nNotifications.patientNoBookingBody.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Shown when the booking exists but has no notifications yet
  Widget _buildNoNotificationsYet() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              L10nNotifications.patientNoNotifications.tr(),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadBookingNotifications(),
              icon: const Icon(Icons.refresh),
              label: Text(L10nNotifications.patientTryAgain.tr(), style: const TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List notifications) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  L10nNotifications.patientDeviceEnabled.tr(),
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(notif.title ?? '', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif.body ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(
                        notif.createdAt != null ? intl.DateFormat('dd/MM/yyyy - hh:mm a').format(DateTime.parse(notif.createdAt)) : '',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                  leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.notifications, color: Colors.white)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
