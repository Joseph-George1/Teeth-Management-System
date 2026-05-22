import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/networking/api_service.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/helpers/shared_pref_helper.dart';
import '../drawer_doctor/doctor_drawer_screen.dart';
import '../widgets/appointment_card_widget.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class DoctorConfirmedAppointmentsScreen extends StatefulWidget {
  const DoctorConfirmedAppointmentsScreen({super.key});

  @override
  State<DoctorConfirmedAppointmentsScreen> createState() =>
      _DoctorConfirmedAppointmentsScreenState();
}

class _DoctorConfirmedAppointmentsScreenState
    extends State<DoctorConfirmedAppointmentsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ApiService _apiService;
  List<Map<String, dynamic>> _confirmedAppointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _apiService = getIt<ApiService>();
    _loadCachedConfirmedAppointments();
    _fetchConfirmedAppointments();
  }

  Future<void> _loadCachedConfirmedAppointments() async {
    try {
      final cachedStr = await SharedPrefHelper.getString('cached_done_appointments');
      if (cachedStr.isNotEmpty) {
        if (mounted) {
          setState(() {
            _confirmedAppointments = List<Map<String, dynamic>>.from(json.decode(cachedStr) as List);
            _isLoading = false;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchConfirmedAppointments() async {
    try {
      setState(() {
        if (_confirmedAppointments.isEmpty) {
          _isLoading = true;
        }
        _error = null;
      });

      final result = await _apiService.getDoneAppointments();

      if (!mounted) return;

      if (result['success'] == true) {
        final fetched = List<Map<String, dynamic>>.from(result['data'] as List);
        setState(() {
          _confirmedAppointments = fetched;
          _isLoading = false;
        });
        await SharedPrefHelper.setData('cached_done_appointments', json.encode(fetched));
      } else {
        setState(() {
          _error =
              result['error']?.toString() ?? L10nDoctor.failedToLoadConfirmed.tr();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'حدث خطأ: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pushReplacementNamed(Routes.doctorHomeScreen);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: const DoctorDrawer(selectedIndex: 5),
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, size: 24),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          titleSpacing: 0,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                L10nDoctor.confirmedReservations.tr(),
                style: textTheme.titleLarge?.copyWith(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Image.asset(
                'assets/images/splash-logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        body: _buildMainContent(context),
      ),
    );
  }

  void _showBookingDetails({
    required BuildContext context,
    required String patientName,
    required String phone,
    required String date,
    required String time,
    required String service,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage('assets/images/dكتور.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      patientName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(height: 12),
              _buildDetailRow(
                context: context,
                icon: Icons.calendar_month_outlined,
                label: L10nDoctor.theDate.tr(),
                value: date,
              ),
              SizedBox(height: 14),
              _buildDetailRow(
                context: context,
                icon: Icons.access_time_outlined,
                label: L10nDoctor.theTime.tr(),
                value: time,
              ),
              SizedBox(height: 14),
              _buildDetailRow(
                context: context,
                icon: Icons.medical_services_outlined,
                label: L10nDoctor.specialization.tr(),
                value: service,
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 18,
              color: isDark ? Colors.white : Color(0xFF021433)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard({
    required BuildContext context,
    required String patientName,
    required String phone,
    required String service,
    required String time,
    required String date,
  }) {
    return AppointmentCardWidget(
      context: context,
      patientName: patientName,
      phone: phone,
      service: service,
      time: time,
      date: date,
      statusLabel: L10nDoctor.confirmed.tr(),
      statusColor: Colors.greenAccent,
      onTap: () => _showBookingDetails(
        context: context,
        patientName: patientName,
        phone: phone,
        date: date,
        time: time,
        service: service,
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchConfirmedAppointments,
              child: Text(
                L10nDoctor.retry.tr(),
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      );
    }

    if (_confirmedAppointments.isEmpty) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: isDarkMode ? Colors.white30 : Colors.grey[400],
              ),
              SizedBox(height: 16),
              Text(
                L10nDoctor.thereAreCurrentlyNo.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: isDarkMode ? Colors.white : Color(0xFF0C4A6E),
                ),
              ),
              SizedBox(height: 10),
              Text(
                L10nDoctor.patientsWillAppearHere.tr(),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  height: 1.6,
                  color: isDarkMode ? Colors.white60 : Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              L10nDoctor.confirmedReservations.tr(),
              textAlign: TextAlign.right,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 12),
          ..._confirmedAppointments.asMap().entries.map((entry) {
            final appointment = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _buildBookingCard(
                context: context,
                patientName:
                    '${appointment['patientFirstName'] ?? 'مريض'} ${appointment['patientLastName'] ?? ''}'
                        .trim(),
                phone: appointment['patientPhoneNumber'] ?? '',
                service: appointment['categoryName'] ?? '',
                time: appointment['appointmentDate'] != null
                    ? appointment['appointmentDate']
                        .toString()
                        .split('T')[1]
                        .substring(0, 5)
                    : '',
                date: appointment['appointmentDate'] != null
                    ? appointment['appointmentDate'].toString().split('T')[0]
                    : '',
              ),
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
