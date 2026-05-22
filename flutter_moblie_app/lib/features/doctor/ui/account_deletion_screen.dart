import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/networking/api_service.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import '../../../../core/routing/routes.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage; // ← inline error shown in UI
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _darkBlue = Color(0xFF021433);
  static const _gradientEnd = Color(0xFF0A3A7A);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await ApiService().deleteDoctor();

      if (result['success'] == true) {
        // حذف جميع البيانات من الـ cache
        await SharedPrefHelper.clearAllData(); // حذف SharedPreferences
        await SharedPrefHelper
            .clearAllSecuredData(); // حذف FlutterSecureStorage (التوكن)
        if (!mounted) return;
        _showSnack(L10nDoctor.theAccountHasBeen.tr());
        await Future.delayed(Duration(seconds: 1));
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.loginScreen,
          (Route<dynamic> route) => false,
        );
      } else {
        if (!mounted) return;
        final code = result['statusCode'] as int?;
        final backendError = result['error']?.toString();
        final String msg;
        if (backendError != null && backendError.isNotEmpty) {
          msg = backendError;
        } else if (code == 400) {
          msg = L10nDoctor.invalidRequestCheckThe.tr();
        } else if (code == 401) {
          msg = L10nDoctor.unauthorizedPleaseLogIn.tr();
        } else if (code == 403) {
          msg = L10nDoctor.accessDeniedCheckYour.tr();
        } else if (code == 404) {
          msg = L10nDoctor.theDoctorIsNot.tr();
        } else {
          msg = result['error'] ?? L10nDoctor.failedToDeleteAccount.tr();
        }
        setState(() => _errorMessage = msg);
      }
    } catch (_) {
      setState(() => _errorMessage = L10nDoctor.anErrorOccurredWhile.tr());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    if (_isLoading) return;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? Color(0xFF161B22) : Colors.white,
          title: Text(
            L10nDoctor.confirmAccountDeletion.tr(),
            style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
                fontSize: 18),
          ),
          content: Text(
            L10nDoctor.areYouSureYou1.tr(),
            style: TextStyle(fontFamily: 'Cairo', height: 1.5, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(L10nBooking.cancellation.tr(),
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(L10nDoctor.delete.tr(),
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteAccount();
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: TextStyle(fontFamily: 'Cairo', fontSize: 14)),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Color(0xFF0D1117) : Color(0xFFF5F6FA),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          slivers: [
            // ─── Custom App Bar ───────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: _darkBlue,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [_darkBlue, _gradientEnd],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -30,
                        left: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 60,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.03),
                          ),
                        ),
                      ),
                      // Content
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Warning icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    width: 2),
                              ),
                              child: Icon(
                                Icons.delete_forever_rounded,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              L10nDoctor.deleteAccount.tr(),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              L10nDoctor.thisActionCannotBe.tr(),
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              leading: Padding(
                padding: EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 16),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),

            // ─── Body Content ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(height: 4),

                        // ── Warning Card ────────────────────────────────────
                        _buildWarningCard(isDark),
                        SizedBox(height: 16),

                        // ── What Will Be Deleted ─────────────────────────
                        _buildWillBeDeletedCard(isDark),
                        SizedBox(height: 24),

                        // ── Delete Button ────────────────────────────────
                        Column(
                          children: [
                            if (_errorMessage != null)
                              Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            _buildDeleteButton(),
                          ],
                        ),
                        SizedBox(height: 12),

                        // ── Cancel Button ────────────────────────────────
                        _buildCancelButton(isDark),

                        SizedBox(
                            height:
                                MediaQuery.of(context).padding.bottom + 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Warning Card ──────────────────────────────────────────────────────────
  Widget _buildWarningCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.red.withValues(alpha: isDark ? 0.18 : 0.08),
            Colors.orange.withValues(alpha: isDark ? 0.10 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10nDoctor.importantWarning.tr(),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  L10nDoctor.accountDeletionIsPermanent.tr(),
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    height: 1.6,
                    color: isDark ? Colors.white70 : Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── What Will Be Deleted Card ─────────────────────────────────────────────
  Widget _buildWillBeDeletedCard(bool isDark) {
    final items = [
      (Icons.person_outline, L10nDoctor.profileData.tr()),
      (Icons.event_note_outlined, L10nDoctor.recordReservationsAndAppointments.tr()),
      (Icons.medical_services_outlined, L10nDoctor.medicalCaseData.tr()),
      (Icons.chat_bubble_outline, L10nDoctor.applicationChatsAndMessages.tr()),
      (Icons.notifications_none_outlined, L10nDoctor.notificationsAndAlerts.tr()),
    ];

    return _buildSectionCard(
      isDark: isDark,
      title: L10nDoctor.whatWillBeDeleted.tr(),
      icon: Icons.info_outline_rounded,
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.$1, size: 16, color: Colors.red[400]),
                ),
                SizedBox(width: 12),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Color(0xFF374151),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red[700]!, Colors.red[500]!],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: _isLoading ? null : _confirmDeleteAccount,
          child: _isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      L10nDoctor.permanentlyDeleteTheAccount.tr(),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Cancel Button ─────────────────────────────────────────────────────────
  Widget _buildCancelButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? Colors.grey[700]! : Color(0xFFD1D5DB),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          L10nDoctor.backToProfile.tr(),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isDark ? Colors.white70 : Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  // ── Section Card Helper ───────────────────────────────────────────────────
  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.grey[800]! : Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Color(0xFF021433)),
                SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Color(0xFF021433),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6),
          Divider(
              height: 1,
              color: isDark ? Colors.grey[800] : Color(0xFFE5E7EB)),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}
