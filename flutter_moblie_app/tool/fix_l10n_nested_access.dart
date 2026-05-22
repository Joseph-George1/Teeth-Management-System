import 'dart:convert';
import 'dart:io';

/// Converts broken L10n.namespace.key to L10nNamespace.key after nested-class migration.
void main() {
  final ar = jsonDecode(File('assets/translations/ar.json').readAsStringSync())
      as Map<String, dynamic>;

  final replacements = <String, String>{};
  for (final ns in ar.keys) {
    if (ar[ns] is! Map) continue;
    final oldPrefix = 'L10n.${_toFieldName(ns)}.';
    final newPrefix = 'L10n${_toClassName(ns)}.';
    replacements[oldPrefix] = newPrefix;
  }

  final sorted = replacements.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  var total = 0;
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    var content = entity.readAsStringSync();
    var count = 0;
    for (final old in sorted) {
      final newPrefix = replacements[old]!;
      final occurrences = old.allMatches(content).length;
      if (occurrences > 0) {
        content = content.replaceAll(old, newPrefix);
        count += occurrences;
      }
    }
    if (count > 0) {
      entity.writeAsStringSync(content);
      total += count;
      stdout.writeln('${entity.path}: $count');
    }
  }
  stdout.writeln('Fixed $total references');
}

String _toClassName(String raw) {
  final words = _splitWords(raw);
  if (words.isEmpty) return 'Keys';
  return words.map(_capitalize).join();
}

String _toFieldName(String raw) {
  final words = _splitWords(raw);
  if (words.isEmpty) return 'key';
  final first = words.first.toLowerCase();
  final rest = words.skip(1).map(_capitalize).join();
  var name = '$first$rest';
  if (RegExp(r'^\d').hasMatch(name)) name = 'k$name';
  return name;
}

List<String> _splitWords(String raw) =>
    raw.split(RegExp(r'[^a-zA-Z0-9]+')).where((w) => w.isNotEmpty).toList();

String _capitalize(String w) =>
    w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase();
