import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/features/doctor/drawer_doctor/doctor_drawer_screen.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class DoctorPrivacyPolicyScreen extends StatefulWidget {
  const DoctorPrivacyPolicyScreen({super.key});

  @override
  State<DoctorPrivacyPolicyScreen> createState() => _DoctorPrivacyPolicyScreenState();
}

class _DoctorPrivacyPolicyScreenState extends State<DoctorPrivacyPolicyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: context.locale.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: const DoctorDrawer(selectedIndex: 8),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        L10nDoctor.studentPrivacy.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
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
              ),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, size: 24),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSection(
                          isDark: isDark,
                          title: L10nDoctor.processedStudentData.tr(),
                          icon: Icons.person_pin_outlined,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBodyText(isDark,
                                  L10nDoctor.weCollectTheFollowing.tr()),
                              SizedBox(height: 10),
                              _buildBullet(isDark, L10nDoctor.fullNameAndProfile.tr()),
                              _buildBullet(isDark, L10nDoctor.universityData.tr()),
                              _buildBullet(isDark,
                                  L10nDoctor.historyOfReservationsAnd.tr()),
                              _buildBullet(isDark,
                                  L10nDoctor.evaluationsProvidedByPatients.tr()),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildSection(
                          isDark: isDark,
                          title: L10nDoctor.howYourDataAppears.tr(),
                          icon: Icons.visibility_outlined,
                          child: _buildBodyText(
                              isDark, L10nDoctor.howDataAppearsDesc.tr()),
                        ),
                        SizedBox(height: 12),
                        _buildSection(
                          isDark: isDark,
                          title: L10nDoctor.accountSecurity.tr(),
                          icon: Icons.security_outlined,
                          child: _buildBodyText(isDark, L10nDoctor.str297.tr()),
                        ),
                        SizedBox(height: 24),
                        _buildFooter(isDark),
                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 24),
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

  Widget _buildSection({required bool isDark, required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: isDark ? Colors.white70 : Color(0xFF021433)),
              SizedBox(width: 8),
              Text(title, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildBodyText(bool isDark, String text) {
    return Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, height: 1.6));
  }

  Widget _buildBullet(bool isDark, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text, style: TextStyle(fontFamily: 'Cairo', fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Center(
      child: Text(L10nDoctor.lastUpdatedApril2026.tr(), style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: isDark ? Colors.white54 : Colors.grey[500])),
    );
  }
}
