import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/features/home_screen/ui/drawer/drawer.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: HomeDrawer(),
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
              L10nTermsAndConditions.termsAndConditions.tr(),
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
      body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildSection(
              context,
              L10nTermsAndConditions.firstDefinitionOfThe.tr(),
              L10nTermsAndConditions.theThouthaApplicationIs.tr(),
            ),
            _buildSection(
              context,
              L10nTermsAndConditions.secondTheRoleOf.tr(),
              L10nTermsAndConditions.theApplicationIsOnly.tr() + L10nTermsAndConditions.weDoNotGuarantee.tr() + L10nTermsAndConditions.weDoNotControl.tr() + L10nTermsAndConditions.anyAgreementConcludedIs.tr(),
            ),
            _buildSection(
              context,
              L10nTermsAndConditions.patientTermsAndConditions.tr(),
              L10nTermsAndConditions.theApplicationDoesNot.tr() + L10nTermsAndConditions.thePatientIsResponsible.tr() + L10nTermsAndConditions.theApplicationIsNot.tr() + L10nTermsAndConditions.failureToAttendOr.tr(),
            ),
            _buildSection(
              context,
              L10nTermsAndConditions.termsAndConditionsFor.tr(),
              L10nTermsAndConditions.theStudentAcknowledgesThat.tr() + L10nTermsAndConditions.theStudentBearsFull.tr() + L10nTermsAndConditions.adherenceToAppointmentsAnd.tr() + L10nTermsAndConditions.theApplicationHasThe.tr(),
            ),
            _buildSection(
              context,
              L10nTermsAndConditions.disclaimer.tr(),
              L10nTermsAndConditions.thouthaApplicationIsNot.tr(),
            ),
            _buildSection(
              context,
              L10nTermsAndConditions.approval.tr(),
              L10nTermsAndConditions.yourUseOfThe.tr(),
            ),
            SizedBox(height: 24),
            Center(
              child: Text(
                L10nTermsAndConditions.lastUpdatedFebruary2026.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, String content) {
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
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          ...content.split('\n').map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 2, right: 0),
                child: Text(
                  line,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Cairo',
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
