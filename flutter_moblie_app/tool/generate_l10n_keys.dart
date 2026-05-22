import 'dart:convert';
import 'dart:io';

/// Generates lib/core/localization/l10n_keys.dart (one top-level class per namespace).
/// Merges namespaces that share the same class name (e.g. "Privacy Policy" + privacy_policy).
/// Run: dart run tool/generate_l10n_keys.dart
void main() {
  final ar = jsonDecode(File('assets/translations/ar.json').readAsStringSync())
      as Map<String, dynamic>;

  final buckets = <String, List<({String prefix, Map<String, dynamic> node})>>{};

  for (final entry in ar.entries) {
    if (entry.value is! Map<String, dynamic>) continue;
    final className = 'L10n${_toClassName(entry.key)}';
    buckets.putIfAbsent(className, () => []).add(
          (prefix: entry.key, node: entry.value as Map<String, dynamic>),
        );
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
    ..writeln('// Run: dart run tool/generate_l10n_keys.dart')
    ..writeln('// ignore_for_file: constant_identifier_names')
    ..writeln()
    ..writeln('/// Type-safe translation keys. Use: [L10nAuth.email].tr()');

  final accessMap = <String, String>{};
  var leafCount = 0;

  for (final bucket in buckets.entries) {
    buffer.writeln('abstract final class ${bucket.key} {');
    buffer.writeln('  ${bucket.key}._();');
    buffer.writeln();

    for (final section in bucket.value) {
      _writeLeaves(
        buffer: buffer,
        node: section.node,
        keyPrefix: section.prefix,
        className: bucket.key,
        accessMap: accessMap,
        onLeaf: () => leafCount++,
        indent: '  ',
      );
    }

    buffer.writeln('}');
    buffer.writeln();
  }

  File('lib/core/localization/l10n_keys.dart')
      .writeAsStringSync(buffer.toString());
  File('tool/l10n_access_map.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(accessMap));

  stdout.writeln('Generated $leafCount keys in ${buckets.length} classes');
}

void _writeLeaves({
  required StringBuffer buffer,
  required Map<String, dynamic> node,
  required String keyPrefix,
  required String className,
  required Map<String, String> accessMap,
  required void Function() onLeaf,
  required String indent,
}) {
  final usedNames = <String>{};

  node.forEach((jsonKey, value) {
    if (value is Map<String, dynamic>) {
      _writeLeaves(
        buffer: buffer,
        node: value,
        keyPrefix: '$keyPrefix.$jsonKey',
        className: className,
        accessMap: accessMap,
        onLeaf: onLeaf,
        indent: indent,
      );
      return;
    }

    var fieldName = _toFieldName(jsonKey);
    fieldName = _dedupe(fieldName, usedNames, jsonKey);
    usedNames.add(fieldName);

    final fullKey = '$keyPrefix.$jsonKey';
    final dartAccess = '$className.$fieldName';
    accessMap[fullKey] = dartAccess;
    onLeaf();

    final escaped = fullKey.replaceAll("'", r"\'");
    buffer.writeln('$indent/// `$fullKey`');
    buffer.writeln("$indent static const $fieldName = '$escaped';");
    buffer.writeln();
  });
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
  if (_reserved.contains(name)) name = '${name}Value';
  return name;
}

String _dedupe(String name, Set<String> used, String jsonKey) {
  if (!used.contains(name)) return name;
  var i = 2;
  while (used.contains('${name}_$i')) {
    i++;
  }
  return '${name}_$i';
}

List<String> _splitWords(String raw) =>
    raw.split(RegExp(r'[^a-zA-Z0-9]+')).where((w) => w.isNotEmpty).toList();

String _capitalize(String w) =>
    w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase();

const _reserved = {
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue', 'default',
  'do', 'else', 'enum', 'extends', 'false', 'final', 'finally', 'for', 'if',
  'in', 'is', 'new', 'null', 'return', 'super', 'switch', 'this', 'throw',
  'true', 'try', 'var', 'void', 'while', 'with',
};
