import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:thoutha_mobile_app/core/networking/otp_service.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String contactInfo;
  final bool isEmail;
  final Function(String) onVerified;
  final Function(String)? onResend;

  const OtpVerificationDialog({
    super.key,
    required this.contactInfo,
    this.isEmail = false,
    required this.onVerified,
    this.onResend,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  final OtpService _otpService = OtpService();
  bool _isLoading = false;
  bool _isResending = false;
  String? _error;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto focus
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) _focusNode.requestFocus();
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
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        if (mounted) {
          setState(() {
            _resendCountdown--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _verifyOtp(String pin) async {
    if (pin.length != 6) {
      setState(() {
        _error = L10nBooking.verificationCodeMustBe.tr();
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _otpService.verifyOtp(widget.contactInfo, pin);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          Navigator.pop(context);
          widget.onVerified(pin);
        } else {
          setState(() {
            _error = result['error'] ?? L10nBooking.codeVerificationFailed.tr();
          });

          _otpController.clear();
          _focusNode.requestFocus();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = L10nBooking.anUnexpectedErrorOccurred.tr();
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _error = null;
    });

    try {
      final result = await _otpService.sendOtp(widget.contactInfo);

      if (mounted) {
        setState(() {
          _isResending = false;
        });

        if (result['success']) {
          _startTimer();
          widget.onResend?.call(widget.contactInfo);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10nBooking.verificationCodeHasBeen.tr(),
                  style: TextStyle(fontFamily: 'Cairo')),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _error = result['error'] ?? L10nBooking.retransmissionFailed.tr();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
          _error = L10nBooking.anUnexpectedErrorOccurred.tr();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pin Theme
    final defaultPinTheme = PinTheme(
      width: screenWidth > 600 ? 56 : (screenWidth - 80) / 6,
      height: 60,
      textStyle: TextStyle(
        fontSize: 22,
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Color(0xFF0B8FAC), width: 2),
        color: isDark ? Colors.black : Color(0xFFFFFFFF),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.redAccent, width: 2),
        color: isDark ? Color(0xFF451A1A) : Color(0xFFFEF2F2),
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Color(0xFFE0F2FE)
                      .withValues(alpha: isDark ? 0.1 : 1.0),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mark_email_read_outlined,
                    size: 32, color: Color(0xFF0B8FAC)),
              ),
              SizedBox(height: 24),
              Text(
                widget.isEmail ? L10nBooking.emailConfirmation.tr() : L10nBooking.confirmPhoneNumber.tr(),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 8),
              Text(
                "أدخل رمز التحقق المرسل إلى\n${widget.contactInfo}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32),

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
                    if (pin == null || pin.isEmpty) {
                      return L10nBooking.required.tr();
                    }
                    if (pin.length != 6) {
                      return L10nBooking.k6Numbers.tr();
                    }
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

              SizedBox(height: 32),
              _isLoading
                  ? SizedBox(
                      height: 48,
                      width: 48,
                      child: Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF0B8FAC)),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _resendCountdown > 0
                                  ? "إعادة الإرسال بعد $_resendCountdown ثانية"
                                  : 'booking.Didn\'t Receive The Code'.tr(),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Color(0xFF64748B),
                              ),
                            ),
                            if (_resendCountdown == 0)
                              _isResending
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF0B8FAC),
                                        ),
                                      ),
                                    )
                                  : TextButton(
                                      onPressed: _resendOtp,
                                      child: Text(
                                        L10nBooking.rebroadcast.tr(),
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0B8FAC),
                                        ),
                                      ),
                                    ),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            L10nBooking.cancellation.tr(),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              color:
                                  isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
