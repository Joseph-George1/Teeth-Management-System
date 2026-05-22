import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

class LanguageSwitchButton extends StatelessWidget {
  const LanguageSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.language),
      onPressed: () {
        final currentLocale = context.locale;
        if (currentLocale.languageCode == 'ar') {
          context.setLocale(Locale('en'));
        } else {
          context.setLocale(Locale('ar'));
        }
      },
    );
  }
}
