import 'package:flutter/material.dart';
import 'package:thotha_mobile_app/features/booking/ui/booking_confirmation_screen.dart';

class DoctorInfoContent extends StatefulWidget {
  final ScrollController controller;

  const DoctorInfoContent({super.key, required this.controller});

  @override
  State<DoctorInfoContent> createState() => _DoctorInfoContentState();
}

class _DoctorInfoContentState extends State<DoctorInfoContent> {
  String? _selectedDay;
  TimeOfDay? _selectedTime;

  bool get _isBookingEnabled => _selectedDay != null && _selectedTime != null;

  void _showBookingForm(BuildContext context) {
    // Format the date and time for display
    final formattedDate = _selectedDay != null ? '${_selectedDay}' : 'غير محدد';

    final formattedTime =
        _selectedTime != null ? _selectedTime!.format(context) : 'غير محدد';

    // Navigate to the booking confirmation screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => BookingConfirmationScreen(
    //       doctorName: 'د. زياد', // Using the actual doctor's name from the UI
    //       date: formattedDate,
    //       time: formattedTime,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                height: 89.06,
                padding: const EdgeInsets.symmetric(horizontal: 23.99),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close,
                          size: 24, color: Colors.black),
                    ),
                    const Text(
                      'تفاصيل الطالب',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 149.9924,
                            height: 149.9924,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/test.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 7.9876),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'ZEZO',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 28,
                                      height: 1.5,
                                      letterSpacing: 0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'تدريب جراحة وتجميل الأسنان',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                      height: 1.5,
                                      letterSpacing: 0,
                                      color: Color(0xFF858585),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 24,
                                      runSpacing: 8,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: Color(0xFF858585),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '2.5 كم',
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                height: 1.5,
                                                letterSpacing: 0,
                                                color: Color(0xFF858585),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            RichText(
                                              text: const TextSpan(
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  height: 1.5,
                                                  letterSpacing: 0,
                                                  color: Colors.black,
                                                ),
                                                children: [
                                                  TextSpan(text: '4.8 '),
                                                  TextSpan(
                                                    text: '(124 تقييم)',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                        top: 20, left: 8, right: 8, bottom: 20),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: const [
                                        SizedBox(
                                          width: 86,
                                          height: 30,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              'عن الطالب',
                                              style: TextStyle(
                                                fontFamily: 'Cairo',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                height: 1.5,
                                                color: Color(0xFF0A0A0A),
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'طالب بالسنة الخامسة متخصص في جراحة وتجميل الأسنان. أقوم بالتدريب العملي تحت إشراف أساتذة الكلية. لدي خبرة جيدة في الحشوات التجميلية وخلع الأسنان البسيط.',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            height: 1.625,
                                            color: Color(0xFF858585),
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: const [
                                        _InfoTile(
                                          icon: Icons.school_outlined,
                                          title: 'الكلية والجامعة الدراسية',
                                          subtitle:
                                              'كلية طب الأسنان - جامعة القاهرة',
                                        ),
                                        SizedBox(height: 10),
                                        _InfoTile(
                                          icon: Icons.location_on_outlined,
                                          title: 'العنوان',
                                          subtitle:
                                              'كلية طب الأسنان، جامعة القاهرة، المنيل',
                                        ),
                                        SizedBox(height: 10),
                                        _InfoTile(
                                          icon: Icons.phone_outlined,
                                          title: 'رقم الهاتف',
                                          subtitle: '01012345678',
                                        ),
                                        SizedBox(height: 10),
                                        _InfoTile(
                                          icon: Icons.mail_outline,
                                          title: 'البريد الإلكتروني',
                                          subtitle:
                                              'ahmed.mahmoud@dentistry.cu.edu.eg',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: const [
                                      Text(
                                        'احجز موعدك',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.calendar_today_outlined,
                                          size: 18, color: Color(0xFF0B8FAC)),
                                      SizedBox(width: 6),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 44,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      reverse: true,
                                      itemCount: 4,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final days = [
                                          'الأحد',
                                          'الإثنين',
                                          'الثلاثاء',
                                          'الأربعاء'
                                        ];
                                        final label = days[index];
                                        return _DayChip(
                                          label: label,
                                          selected: _selectedDay == label,
                                          onTap: () => setState(
                                              () => _selectedDay = label),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Column(
                                    children: [
                                      _TimeListTile(
                                        label: '9:00 صباحاً',
                                        selected: _selectedTime?.hour == 9 &&
                                            _selectedTime?.minute == 0,
                                        onTap: () => setState(() =>
                                            _selectedTime = const TimeOfDay(
                                                hour: 9, minute: 0)),
                                      ),
                                      const SizedBox(height: 8),
                                      _TimeListTile(
                                        label: '10:00 صباحاً',
                                        selected: _selectedTime?.hour == 10 &&
                                            _selectedTime?.minute == 0,
                                        onTap: () => setState(() =>
                                            _selectedTime = const TimeOfDay(
                                                hour: 10, minute: 0)),
                                      ),
                                      const SizedBox(height: 8),
                                      _TimeListTile(
                                        label: '12:00 ظهراً',
                                        selected: _selectedTime?.hour == 12 &&
                                            _selectedTime?.minute == 0,
                                        onTap: () => setState(() =>
                                            _selectedTime = const TimeOfDay(
                                                hour: 12, minute: 0)),
                                      ),
                                      const SizedBox(height: 8),
                                      _TimeListTile(
                                        label: '02:00 مساءً',
                                        selected: _selectedTime?.hour == 14 &&
                                            _selectedTime?.minute == 0,
                                        onTap: () => setState(() =>
                                            _selectedTime = const TimeOfDay(
                                                hour: 14, minute: 0)),
                                      ),
                                      const SizedBox(height: 8),
                                      _TimeListTile(
                                        label: '04:00 مساءً',
                                        selected: _selectedTime?.hour == 16 &&
                                            _selectedTime?.minute == 0,
                                        onTap: () => setState(() =>
                                            _selectedTime = const TimeOfDay(
                                                hour: 16, minute: 0)),
                                      ),
                                      const SizedBox(height: 8),
                                      _TimeListTile(
                                        label: '06:00 مساءً',
                                        selected: _selectedTime?.hour == 18 &&
                                            _selectedTime?.minute == 0,
                                        onTap: () => setState(() =>
                                            _selectedTime = const TimeOfDay(
                                                hour: 18, minute: 0)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF7FF),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFFB3DAFF)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Expanded(
                                          child: Text(
                                            'جميع الخدمات تتم تحت إشراف مباشر من أعضاء هيئة التدريس بالكلية',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 12,
                                              color: Color(0xFF1F2937),
                                              height: 1.6,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.sticky_note_2_outlined,
                                            color: Color(0xFF3B82F6), size: 20),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                              child: Text(
                                                'إلغاء',
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: Color(0xFF111827),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: _isBookingEnabled
                                              ? () {
                                                  final String doctorName = 'ZEZO';
                                                  final String date = _selectedDay ?? '';
                                                  final String time = _selectedTime?.format(context) ?? '';
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => BookingConfirmationScreen(
                                                        doctorName: doctorName,
                                                        date: date,
                                                        time: time,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              : null,
                                          child: Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: _isBookingEnabled
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFF9CA3AF),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'تأكيد الحجز',
                                                style: TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: _isBookingEnabled
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.7),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: const Color(0xFF0B8FAC)),
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
    final BorderRadius radius = BorderRadius.circular(8);
    final Widget child = Text(
      label,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: selected ? Colors.white : const Color(0xFF111827),
      ),
    );

    if (selected) {
      return InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
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
    final BorderRadius radius = BorderRadius.circular(10);
    final Color borderColor =
        selected ? const Color(0xFF8DECB4) : const Color(0xFFE5E7EB);
    final Widget text = Text(
      label,
      style: TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: selected ? Colors.white : const Color(0xFF111827),
      ),
    );

    return InkWell(
      borderRadius: radius,
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF84E5F3), Color(0xFF8DECB4)],
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: radius,
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.access_time,
                size: 18,
                color: selected ? Colors.white : const Color(0xFF111827)),
            text,
          ],
        ),
      ),
    );
  }
}
