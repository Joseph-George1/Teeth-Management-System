import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:thotha_mobile_app/core/networking/otp_service.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String contactInfo;
  final bool isEmail;
  final Function(String) onVerified;

  const OtpVerificationDialog({
    Key? key,
    required this.contactInfo,
    this.isEmail = false,
    required this.onVerified,
  }) : super(key: key);

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  final OtpService _otpService = OtpService();
  bool _isLoading = false;
  String? _error;
  int _resendCountdown = 60;
  Timer? _timer;

  String get _formattedPhone {
    final raw = widget.contactInfo.trim();
    if (raw.isEmpty) return raw;
    return raw.startsWith('+') ? raw : '+$raw';
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto focus
    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp(String pin) async {
    if (widget.isEmail) {
      setState(() {
        _error = 'التحقق عبر البريد غير مدعوم هنا';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _otpService.verifyOtp(_formattedPhone, pin);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      Navigator.pop(context);
      widget.onVerified(pin);
    } else {
      setState(() {
        _error = result['error'] ?? 'رمز التحقق غير صحيح';
      });
    }
  }

  Future<void> _resendOtp() async {
    if (widget.isEmail) {
      setState(() {
        _error = 'إعادة الإرسال عبر البريد غير مدعومة هنا';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _otpService.sendOtp(_formattedPhone);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success'] != true) {
        _error = result['error'] ?? 'فشل إعادة إرسال الرمز';
      }
    });

    if (result['success'] == true) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
     // Pin Theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: TextStyle(
        fontSize: 22,
        color: const Color(0xFF1E293B),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: const Color(0xFF0B8FAC), width: 2),
        color: const Color(0xFFFFFFFF),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.redAccent, width: 2),
        color: const Color(0xFFFEF2F2),
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 32,
                color: const Color(0xFF0B8FAC)
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.isEmail ? "تأكيد البريد الإلكتروني" : "تأكيد رقم الهاتف",
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "أدخل رمز التحقق المرسل إلى\n${widget.contactInfo}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            Directionality(
              textDirection: TextDirection.ltr,
              child: Pinput(
                length: 6,
                controller: _otpController,
                focusNode: _focusNode,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                forceErrorState: _error != null,
                onCompleted: _verifyOtp,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                validator: (pin) {
                  return null;
                },
              ),
            ),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _error!,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.redAccent,
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 32),
            _isLoading
              ? SizedBox(
                  height: 48,
                  width: 48,
                  child: Center(
                    child: CircularProgressIndicator(color: const Color(0xFF0B8FAC)),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _resendCountdown > 0
                        ? "إعادة الإرسال بعد ${_resendCountdown} ثانية"
                        : "لم يصلك الرمز؟",
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    if (_resendCountdown == 0)
                      TextButton(
                        onPressed: () {
                          _resendOtp();
                        },
                        child: Text(
                          "إعادة الإرسال",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0B8FAC),
                          ),
                        ),
                      ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
