import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class NotificationPermissionHelper {
  static Future<bool?> showNotificationPermissionDialog(
      BuildContext context) async {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final baseFontSize = width * 0.04;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.notifications_active,
                color: Theme.of(context).primaryColor,
                size: 28 * (width / 390)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                L10nCore.activateNotifications.tr(),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: baseFontSize * 1.125, // 18
                ),
              ),
            ),
          ],
        ),
        content: Text(
          L10nCore.keepTrackOfYour.tr(),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: baseFontSize * 0.875, // 14
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              L10nCore.notNow.tr(),
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              L10nCore.activateNow.tr(),
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showPermanentlyDeniedDialog(
      BuildContext context, VoidCallback onSettingsPressed) async {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final baseFontSize = width * 0.04;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 28 * (width / 390)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                L10nCore.notificationsAreDisabled.tr(),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: baseFontSize * 1.125, // 18
                ),
              ),
            ),
          ],
        ),
        content: Text(
          L10nCore.notificationsHaveBeenDisabled.tr(),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: baseFontSize * 0.875, // 14
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: onSettingsPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              L10nCore.goToSettings.tr(),
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
