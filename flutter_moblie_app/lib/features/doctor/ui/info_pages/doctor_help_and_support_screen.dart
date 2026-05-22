import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thoutha_mobile_app/features/doctor/drawer_doctor/doctor_drawer_screen.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class DoctorHelpAndSupportScreen extends StatefulWidget {
  const DoctorHelpAndSupportScreen({super.key});

  @override
  State<DoctorHelpAndSupportScreen> createState() => _DoctorHelpAndSupportScreenState();
}

class _DoctorHelpAndSupportScreenState extends State<DoctorHelpAndSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSending = false;
  static const String _supportEmail = 'support@thoutha.page';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchEmail(String userMessage) async {
    final emailUri = Uri.parse(
      'mailto:$_supportEmail'
      '?subject=${Uri.encodeComponent('Support Request')}'
      '&body=${Uri.encodeComponent(userMessage)}',
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10nDoctor.theEmailApplicationCannot.tr(), style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    await _launchEmail(_messageController.text.trim());

    if (!mounted) return;
    setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: context.locale.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const DoctorDrawer(selectedIndex: 9),
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                L10nDoctor.studentSupport.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(L10nDoctor.theThouthaSupportTeam.tr(),
                  style:
                      TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.6)),
              SizedBox(height: 24),
              _buildSectionTitle(
                  theme, L10nDoctor.frequentlyAskedQuestionsFor.tr()),
              _buildFaqItem(
                  L10nDoctor.howDoIDelete.tr(), L10nDoctor.youCanDeleteThe.tr()),
              _buildFaqItem(
                  L10nDoctor.whyIsMyPhone.tr(), L10nDoctor.theNumberIsOnly.tr()),
              SizedBox(height: 24),
              _buildSectionTitle(theme, L10nDoctor.contactSupport.tr()),
              Text(
                L10nDoctor.youCanContactUs.tr(),
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: () => _launchEmail('Please describe your issue here.'),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined,
                        size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      _supportEmail,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                L10nDoctor.orYouCanSubmit.tr(),
                style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
              ),
              SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: L10nDoctor.writeYourProblemHere.tr(),
                        hintStyle: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? L10nDoctor.pleaseWriteTheMessage.tr()
                          : null,
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSending
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                L10nDoctor.submitTheRequest.tr(),
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(fontFamily: 'Cairo', fontSize: 13, color: Colors.grey)),
        ),
      ],
    );
  }
}
