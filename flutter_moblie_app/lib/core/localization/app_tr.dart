import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Safe translation helpers — prevents raw keys from appearing in the UI.
abstract final class AppTr {
  /// Translates [key] with fallback locale and a readable last-resort label.
  static String get(
    String key, {
    Map<String, String>? namedArgs,
    BuildContext? context,
  }) {
    if (key.trExists(context: context)) {
      return key.tr(namedArgs: namedArgs, context: context);
    }

    if (kDebugMode) {
      debugPrint('[AppTr] Missing key: $key');
    }

    final translated = key.tr(namedArgs: namedArgs, context: context);
    if (translated != key) return translated;

    return _humanizeKey(key);
  }
}

extension SafeTrExtension on String {
  /// Prefer this over [tr] when adding new UI strings.
  String trSafe({
    Map<String, String>? namedArgs,
    BuildContext? context,
  }) =>
      AppTr.get(this, namedArgs: namedArgs, context: context);
}

String _humanizeKey(String key) {
  final segment = key.contains('.') ? key.split('.').last : key;
  final words = segment
      .replaceAll('_', ' ')
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .trim();
  if (words.isEmpty) return key;
  return words[0].toUpperCase() + words.substring(1);
}
