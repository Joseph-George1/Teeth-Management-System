import 'dart:convert';
import 'dart:io';

void main() {
  var exitCode = 0;
  final ar = jsonDecode(File('assets/translations/ar.json').readAsStringSync())
      as Map<String, dynamic>;
  final en = jsonDecode(File('assets/translations/en.json').readAsStringSync())
      as Map<String, dynamic>;

  Set<String> flatten(Map<dynamic, dynamic> m, [String prefix = '']) {
    final keys = <String>{};
    m.forEach((k, v) {
      final key = prefix.isEmpty ? k.toString() : '$prefix.$k';
      if (v is Map) {
        keys.addAll(flatten(v, key));
      } else {
        keys.add(key);
      }
    });
    return keys;
  }

  final arKeys = flatten(ar);
  final enKeys = flatten(en);

  final libDir = Directory('lib');
  // Keys use namespace.segment format (e.g. auth.email).
  final trPattern = RegExp(r'''['"]([a-zA-Z][\w .\-']*\.\w[\w .\-']*)['"]\.tr''');
  final usedKeys = <String>{};
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final content = entity.readAsStringSync();
    for (final m in trPattern.allMatches(content)) {
      usedKeys.add(m.group(1)!);
    }
  }

  final missingAr = usedKeys.where((k) => !arKeys.contains(k)).toList()..sort();
  final missingEn = usedKeys.where((k) => !enKeys.contains(k)).toList()..sort();
  final onlyAr = arKeys.difference(enKeys).toList()..sort();
  final onlyEn = enKeys.difference(arKeys).toList()..sort();

  stdout.writeln('Used keys: ${usedKeys.length}');
  stdout.writeln('Missing in ar.json: ${missingAr.length}');
  File('tool/missing_ar.txt').writeAsStringSync(missingAr.join('\n'));
  for (final k in missingAr.take(50)) {
    stdout.writeln('  $k');
  }
  stdout.writeln('Missing in en.json: ${missingEn.length}');
  for (final k in missingEn.take(50)) {
    stdout.writeln('  $k');
  }
  stdout.writeln('Only in ar (not en): ${onlyAr.length}');
  for (final k in onlyAr.take(20)) {
    stdout.writeln('  $k');
  }
  stdout.writeln('Only in en (not ar): ${onlyEn.length}');
  for (final k in onlyEn.take(20)) {
    stdout.writeln('  $k');
  }

  // Warn about raw string .tr() usage (should use L10n* constants).
  final rawTr = RegExp(r'''['"]([a-zA-Z][\w .\-']*\.\w[\w .\-']*)['"]\.tr''');
  var rawCount = 0;
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains('l10n_keys.dart')) continue;
    rawCount += rawTr.allMatches(entity.readAsStringSync()).length;
  }
  stdout.writeln('Raw string .tr() literals (prefer L10n*): $rawCount');
  if (rawCount > 0) {
    exitCode = 1;
  } else if (missingAr.isNotEmpty || missingEn.isNotEmpty) {
    exitCode = 1;
  }
  exit(exitCode);
}
