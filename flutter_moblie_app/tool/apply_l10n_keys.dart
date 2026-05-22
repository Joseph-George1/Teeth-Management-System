import 'dart:convert';
import 'dart:io';

/// Replaces 'namespace.key'.tr() string literals with L10n.namespace.key.tr().
/// Run after: dart run tool/generate_l10n_keys.dart
void main() {
  final map = jsonDecode(File('tool/l10n_access_map.json').readAsStringSync())
      as Map<String, dynamic>;
  final keyAccess = map.map((k, v) => MapEntry(k, v as String));

  final importLine =
      "import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';";

  final trPattern = RegExp(
    r'''['"]([a-zA-Z][\w .\-']*\.\w[\w .\-']*)['"]\.(tr(?:Safe)?)''',
  );

  var filesChanged = 0;
  var replacements = 0;

  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains('l10n_keys.dart')) continue;

    final contentProbe = entity.readAsStringSync();
    if (contentProbe.contains('part of ')) continue;

    var content = contentProbe;
    var fileReplacements = 0;

    content = content.replaceAllMapped(trPattern, (match) {
      final key = match.group(1)!;
      final method = match.group(2)!;
      final dartAccess = keyAccess[key];
      if (dartAccess == null) return match.group(0)!;
      fileReplacements++;
      return '$dartAccess.$method';
    });

    if (fileReplacements == 0) continue;

    if (!content.contains("l10n_keys.dart")) {
      final importInsert = _insertImport(content, importLine);
      if (importInsert != null) {
        content = importInsert;
      } else {
        content = '$importLine\n$content';
      }
    }

    entity.writeAsStringSync(content);
    filesChanged++;
    replacements += fileReplacements;
    stdout.writeln('${entity.path}: $fileReplacements');
  }

  stdout.writeln('Done: $replacements replacements in $filesChanged files');
}

String? _insertImport(String content, String importLine) {
  if (content.contains(importLine)) return content;

  final lines = content.split('\n');
  var insertAt = 0;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i].trimLeft();
    if (line.startsWith("import '") ||
        line.startsWith('import "') ||
        line.startsWith('export ')) {
      insertAt = i + 1;
      // Keep `show` / `hide` lines attached to their import.
      while (insertAt < lines.length) {
        final next = lines[insertAt].trimLeft();
        if (next.startsWith('show ') ||
            next.startsWith('hide ') ||
            next.startsWith("show ") ||
            next.startsWith("hide ")) {
          insertAt++;
        } else {
          break;
        }
      }
    } else if (insertAt > 0) {
      break;
    }
  }

  if (insertAt > 0) {
    lines.insert(insertAt, importLine);
    return lines.join('\n');
  }

  return '$importLine\n$content';
}
