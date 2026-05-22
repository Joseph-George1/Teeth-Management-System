import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thoutha_mobile_app/features/home_screen/ui/drawer/drawer.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({super.key});

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSending = false;

  static const String _supportEmail = 'support@thoutha.page';

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
          content: Text(
            L10nDoctor.theEmailApplicationCannot.tr(),
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
    final textTheme = theme.textTheme;

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
          children: [
            Text(
              L10nHelpAndSupport.technicalSupport.tr(),
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
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width >= 600 ? 650 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Intro
                Text(
                  L10nHelpAndSupport.ifYouEncounterAny.tr(),
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 24),

                // ملاحظات مهمة
                Text(
                  L10nHelpAndSupport.importantNotes.tr(),
                  textAlign: TextAlign.start,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                _buildBullet(
                    theme,
                    L10nHelpAndSupport.technicalSupportIsLimited.tr()),
                _buildBullet(
                    theme,
                    L10nHelpAndSupport.theSupportTeamDoes.tr()),
                _buildBullet(theme, L10nHelpAndSupport.theApplicationsRoleIs.tr()),
                SizedBox(height: 24),

                // وسائل التواصل
                Text(
                  L10nHelpAndSupport.communicationMeans.tr(),
                  textAlign: TextAlign.start,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  L10nHelpAndSupport.youCanContactUs.tr(),
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 8),
                InkWell(
                  onTap: () => _launchEmail('Please describe your issue here.'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _supportEmail,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.email_outlined,
                          size: 22,
                          color: Colors.blue),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // نموذج التواصل
                Text(
                  L10nHelpAndSupport.communicationModel.tr(),
                  textAlign: TextAlign.start,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 16),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _messageController,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                        ),
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: L10nHelpAndSupport.writeYourMessageHere.tr(),
                          labelStyle: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                          ),
                          hintText: L10nHelpAndSupport.writeYourMessageHere.tr(),
                          hintStyle: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                          ),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: theme.colorScheme.outline, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: theme.colorScheme.outline, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return L10nHelpAndSupport.pleaseWriteYourMessage.tr();
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        height: 52,
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
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  L10nHelpAndSupport.send.tr(),
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildBullet(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Colors.blue,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.start,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Cairo',
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
