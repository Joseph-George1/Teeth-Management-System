import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theming/colors.dart';
import '../../forgot_password/data/forgot_password_service.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final int expiresInSeconds;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    this.expiresInSeconds = 300,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.expiresInSeconds;
    _startTimer();
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

  // ── Timer ───────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsLeft <= 0) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  bool get _canResend => _secondsLeft <= 0;

  String get _timerLabel {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Verify ──────────────────────────────────────────────────────────────
  Future<void> _verify(String pin) async {
    if (pin.length != 6) {
      setState(() => _errorMessage = 'يرجى إدخال رمز التحقق كاملاً (6 أرقام)');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await PasswordResetService.instance.verifyOtp(
        phone: widget.phone,
        otp: pin,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Navigator.pushReplacementNamed(
          context,
          Routes.resetPasswordScreen,
          arguments: {'phone': widget.phone},
        );
      } else {
        _otpController.clear();
        _focusNode.requestFocus();
        setState(
            () => _errorMessage = result['message'] ?? L10nForgotPassword.theVerificationCodeIs.tr());
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = L10nResetPassword.anErrorOccurredTry.tr());
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  // ── Resend ──────────────────────────────────────────────────────────────
  Future<void> _resend() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    try {
      final result =
          await PasswordResetService.instance.requestReset(widget.phone);
      if (!mounted) return;

      if (result['success'] == true) {
        _otpController.clear();
        setState(() => _secondsLeft = result['expires_in'] ?? 300);
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10nResetPassword.theVerificationCodeHas.tr(),
                style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        setState(
            () => _errorMessage = result['message'] ?? L10nResetPassword.tokenResendFailed.tr());
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = L10nResetPassword.aRetransmissionErrorOccurred.tr());
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final baseFontSize = width * 0.04;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Pin Themes (same as booking dialog) ─────────────────────────────
    final defaultPinTheme = PinTheme(
      width: width > 600 ? 56 : (width - 80) / 6,
      height: 60 * (width / 390),
      textStyle: TextStyle(
        fontSize: baseFontSize * 1.375,
        color: isDark ? Colors.white : Color(0xFF1E293B),
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
        color: isDark ? Colors.black : Colors.white,
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.redAccent, width: 2),
        color: isDark ? Color(0xFF451A1A) : Color(0xFFFEF2F2),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10nResetPassword.confirmVerificationCode.tr(),
          style: TextStyle(fontFamily: 'Cairo', fontSize: baseFontSize * 1.1),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background gradients
          _gradient(Alignment(-0.7, -0.7), ColorsManager.layerBlur1),
          _gradient(Alignment(0.7, 0.7), ColorsManager.layerBlur2),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(width * 0.06),
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: width >= 600 ? 500 : double.infinity),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Icon ────────────────────────────────────────────
                      Container(
                        width: 72 * (width / 390),
                        height: 72 * (width / 390),
                        decoration: BoxDecoration(
                          color: Color(0xFFE0F2FE)
                              .withValues(alpha: isDark ? 0.1 : 1.0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.mark_email_read_outlined,
                          size: 32 * (width / 390),
                          color: Color(0xFF0B8FAC),
                        ),
                      ),
                      SizedBox(height: 24),

                      // ── Title ────────────────────────────────────────────
                      Text(
                        L10nResetPassword.enterTheVerificationCode.tr(),
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: baseFontSize * 1.25,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 8),

                      // ── Subtitle ─────────────────────────────────────────
                      Text(
                        'أدخل رمز التحقق المرسل إلى\n${widget.phone}',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: baseFontSize * 0.875,
                          color: isDark
                              ? Colors.grey[400]
                              : Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32),

                      // ── Pinput ───────────────────────────────────────────
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Pinput(
                          length: 6,
                          controller: _otpController,
                          focusNode: _focusNode,
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          errorPinTheme: errorPinTheme,
                          forceErrorState: _errorMessage != null,
                          onCompleted: _verify,
                          pinputAutovalidateMode:
                              PinputAutovalidateMode.onSubmit,
                          validator: (pin) {
                            if (pin == null || pin.isEmpty) return L10nBooking.required.tr();
                            if (pin.length != 6) return L10nBooking.k6Numbers.tr();
                            return null;
                          },
                        ),
                      ),

                      // ── Error ────────────────────────────────────────────
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            _errorMessage!,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.redAccent,
                              fontSize: baseFontSize * 0.875,
                            ),
                          ),
                        ),

                      SizedBox(height: 32),

                      // ── Verify button / loading ──────────────────────────
                      _isVerifying
                          ? SizedBox(
                              height: 48,
                              width: 48,
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF0B8FAC)),
                              ),
                            )
                          : Column(
                              children: [
                                // Timer / Resend row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _canResend
                                          ? 'booking.Didn\'t Receive The Code'.tr()
                                          : 'إعادة الإرسال بعد $_timerLabel',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: baseFontSize * 0.875,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Color(0xFF64748B),
                                      ),
                                    ),
                                    if (_canResend)
                                      _isResending
                                          ? Padding(
                                              padding:
                                                  EdgeInsets.only(right: 8),
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Color(0xFF0B8FAC),
                                                ),
                                              ),
                                            )
                                          : TextButton(
                                              onPressed: _resend,
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

                                // Back button
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    L10nResetPassword.back.tr(),
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: baseFontSize * 0.875,
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradient(Alignment center, Color color) => Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: center,
            radius: 1.5,
            colors: [
              color.withValues(alpha: 0.5),
              color.withValues(alpha: 0.1),
              Colors.transparent,
            ],
          ),
        ),
      );
}
