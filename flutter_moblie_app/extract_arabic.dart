import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';

void main() async {
  final libDir = Directory('lib');
  final dartFiles = libDir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final arabicPattern = RegExp(r'[\u0600-\u06FF]');
  // Matches simple strings '...' or "..."
  final stringPattern = RegExp(r"(['" '"])(.*?)\\1');
  
  final extractedStrings = <String>{};

  for (final file in dartFiles) {
    final content = await file.readAsString();
    final matches = stringPattern.allMatches(content);
    for (final match in matches) {
      final str = match.group(2) ?? '';
      if (arabicPattern.hasMatch(str)) {
        extractedStrings.add(str);
      }
    }
  }

  debugPrint(const JsonEncoder.withIndent('  ').convert(extractedStrings.toList()));
}
