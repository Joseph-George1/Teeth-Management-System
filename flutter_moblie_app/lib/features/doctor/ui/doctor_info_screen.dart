import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/features/booking/ui/booking_confirmation_screen.dart';
import 'package:thoutha_mobile_app/features/doctor/data/models/doctor_model.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class DoctorInfoContent extends StatefulWidget {
  final ScrollController controller;
  final DoctorModel doctor;

  const DoctorInfoContent({
    super.key,
    required this.controller,
    required this.doctor,
  });

  @override
  State<DoctorInfoContent> createState() => _DoctorInfoContentState();
}

class _DoctorInfoContentState extends State<DoctorInfoContent> {
  String? _selectedDay;
  TimeOfDay? _selectedTime;

  bool get _isBookingEnabled => _selectedDay != null && _selectedTime != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final doctor = widget.doctor;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            controller: widget.controller,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: isDark
                            ? Colors.grey[700]!
                            : Color(0xFFE5E7EB),
                        width: 1.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close,
                          size: 24, color: theme.iconTheme.color),
                    ),
                    Text(
                      L10nDoctor.doctorDetails.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color ?? colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            doctor.fullName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                              fontSize: 28,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Text(
                            doctor.categoryName,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              height: 1.5,
                              color: theme.textTheme.bodyLarge?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 24,
                              runSpacing: 8,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Color(0xFF858585),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      doctor.cityName,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        height: 1.5,
                                        color: Color(0xFF858585),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16,
                                          height: 1.5,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        children: [
                                          TextSpan(text: '4.8 '),
                                          TextSpan(
                                            text: '(124 تقييم)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          if (doctor.price != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'سعر الكشف: ${doctor.price} جنيه',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 20),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  L10nDoctor.aboutTheDoctor.tr(),
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    height: 1.5,
                                    color: isDark
                                        ? Colors.white
                                        : Color(0xFF0A0A0A),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  doctor.description ??
                                      L10nDoctor.aSpecializedDentistWith.tr(),
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    height: 1.625,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Color(0xFF858585),
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _InfoTile(
                                  icon: Icons.school_outlined,
                                  title: L10nDoctor.theUniversity.tr(),
                                  subtitle: doctor.universityName,
                                ),
                                SizedBox(height: 10),
                                _InfoTile(
                                  icon: Icons.location_on_outlined,
                                  title: L10nDoctor.theAddress.tr(),
                                  subtitle: doctor.cityName,
                                ),
                                SizedBox(height: 10),
                                if (doctor.email != null)
                                  _InfoTile(
                                    icon: Icons.mail_outline,
                                    title: L10nDoctor.email.tr(),
                                    subtitle: doctor.email!,
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                L10nDoctor.bookYourAppointment.tr(),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.calendar_today_outlined,
                                  size: 18, color: Color(0xFF0B8FAC)),
                              SizedBox(width: 6),
                            ],
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            height: 44,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              itemCount: 4,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              separatorBuilder: (_, __) => SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final days = [
                                  L10nDoctor.sunday.tr(),
                                  L10nDoctor.monday.tr(),
                                  L10nDoctor.tuesday.tr(),
                                  L10nDoctor.wednesday.tr()
                                ];
                                final label = days[index];
                                return _DayChip(
                                  label: label,
                                  selected: _selectedDay == label,
                                  onTap: () =>
                                      setState(() => _selectedDay = label),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 15),
                          Column(
                            children: [
                              _TimeListTile(
                                label: L10nDoctor.k900Am_2.tr(),
                                selected: _selectedTime?.hour == 9 &&
                                    _selectedTime?.minute == 0,
                                onTap: () => setState(() => _selectedTime =
                                    TimeOfDay(hour: 9, minute: 0)),
                              ),
                              SizedBox(height: 8),
                              _TimeListTile(
                                label: L10nDoctor.k1000Am_2.tr(),
                                selected: _selectedTime?.hour == 10 &&
                                    _selectedTime?.minute == 0,
                                onTap: () => setState(() => _selectedTime =
                                    TimeOfDay(hour: 10, minute: 0)),
                              ),
                              SizedBox(height: 8),
                              _TimeListTile(
                                label: L10nDoctor.k1200Noon_2.tr(),
                                selected: _selectedTime?.hour == 12 &&
                                    _selectedTime?.minute == 0,
                                onTap: () => setState(() => _selectedTime =
                                    TimeOfDay(hour: 12, minute: 0)),
                              ),
                              SizedBox(height: 8),
                              _TimeListTile(
                                label: L10nDoctor.k0200Pm_2.tr(),
                                selected: _selectedTime?.hour == 14 &&
                                    _selectedTime?.minute == 0,
                                onTap: () => setState(() => _selectedTime =
                                    TimeOfDay(hour: 14, minute: 0)),
                              ),
                              SizedBox(height: 8),
                              _TimeListTile(
                                label: L10nDoctor.k0400Pm_2.tr(),
                                selected: _selectedTime?.hour == 16 &&
                                    _selectedTime?.minute == 0,
                                onTap: () => setState(() => _selectedTime =
                                    TimeOfDay(hour: 16, minute: 0)),
                              ),
                              SizedBox(height: 8),
                              _TimeListTile(
                                label: L10nDoctor.k0600Pm_2.tr(),
                                selected: _selectedTime?.hour == 18 &&
                                    _selectedTime?.minute == 0,
                                onTap: () => setState(() => _selectedTime =
                                    TimeOfDay(hour: 18, minute: 0)),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.blueGrey[900]
                                  : Color(0xFFEFF7FF),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: Color(0xFFB3DAFF)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    L10nDoctor.allServicesAreCarried.tr(),
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[200]
                                          : Color(0xFF1F2937),
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                                Icon(Icons.sticky_note_2_outlined,
                                    color: Color(0xFF3B82F6), size: 20),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.grey[800]
                                          : Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        L10nBooking.cancellation.tr(),
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white
                                              : Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _isBookingEnabled
                                      ? () {
                                          final String doctorName =
                                              '${widget.doctor.firstName} ${widget.doctor.lastName}';
                                          final String date =
                                              _selectedDay ?? '';
                                          final String time =
                                              _selectedTime?.format(context) ??
                                                  '';
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                BookingConfirmationScreen(
                                                doctorName: doctorName,
                                                universityName: widget.doctor.universityName,
                                                cityName: widget.doctor.cityName,
                                                doctorPhoto: widget.doctor.photo,
                                                specialty:
                                                    widget.doctor.categoryName,
                                                date: date,
                                                time: time,
                                                requestId: null,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _isBookingEnabled
                                          ? Color(0xFF10B981)
                                          : Color(0xFF9CA3AF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        L10nBooking.bookingConfirmation.tr(),
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: _isBookingEnabled
                                              ? Colors.white
                                              : Colors.white
                                                  .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.grey[300] : Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: Color(0xFF0B8FAC), size: 24),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _DayChip({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final BorderRadius radius = BorderRadius.circular(8);
    final Widget child = Text(
      label,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: selected
            ? Colors.white
            : (isDark ? Colors.grey[200] : Color(0xFF111827)),
      ),
    );

    if (selected) {
      return InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF84E5F3), Color(0xFF8DECB4)],
            ),
            borderRadius: radius,
          ),
          child: child,
        ),
      );
    }
    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Color(0xFFF3F4F6),
          borderRadius: radius,
        ),
        child: child,
      ),
    );
  }
}

class _TimeListTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _TimeListTile({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final BorderRadius radius = BorderRadius.circular(10);
    final Color borderColor = selected
        ? Color(0xFF8DECB4)
        : (isDark ? Colors.grey[700]! : Color(0xFFE5E7EB));
    final Widget text = Text(
      label,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: selected
            ? Colors.white
            : (isDark ? Colors.grey[200] : Color(0xFF111827)),
      ),
    );

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF84E5F3), Color(0xFF8DECB4)],
                )
              : null,
          color: selected ? null : (isDark ? Colors.grey[800] : Colors.white),
          borderRadius: radius,
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.access_time,
                size: 18,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.grey[200] : Color(0xFF111827))),
            text,
          ],
        ),
      ),
    );
  }
}
