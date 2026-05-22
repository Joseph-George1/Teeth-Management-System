import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/features/doctor/drawer_doctor/doctor_drawer_screen.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class DoctorTermsAndConditionsScreen extends StatefulWidget {
  const DoctorTermsAndConditionsScreen({super.key});

  @override
  State<DoctorTermsAndConditionsScreen> createState() => _DoctorTermsAndConditionsScreenState();
}

class _DoctorTermsAndConditionsScreenState extends State<DoctorTermsAndConditionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const DoctorDrawer(selectedIndex: 7),
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
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              L10nDoctor.termsAndConditions.tr(),
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
      body: Directionality(
        textDirection: context.locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context,
                L10nDoctor.introductionForStudents.tr(),
                L10nDoctor.str300.tr(),
              ),
              _buildSection(
                context,
                L10nDoctor.firstMedicalLiability.tr(),
                L10nDoctor.n.tr(),
              ),
              _buildSection(
                context,
                L10nDoctor.secondCommitmentToAppointments.tr(),
                L10nDoctor.commitmentToAttendingScheduled.tr(),
              ),
              _buildSection(
                context,
                L10nDoctor.thirdPrivacyAndProfessionalism.tr(),
                L10nDoctor.n1.tr(),
              ),
              _buildSection(
                context,
                L10nDoctor.fourthApplicationDisclaimer.tr(),
                L10nDoctor.theThouthaApplicationIs.tr(),
              ),
              SizedBox(height: 24),
              Center(
                child: Text(
                  L10nDoctor.lastUpdatedApril2026.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textAlign: TextAlign.start,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          ...content.split('\n').map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  line,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
