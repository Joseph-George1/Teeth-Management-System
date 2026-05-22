import 'dart:convert';
import 'dart:io';

/// Fills missing translation keys in ar.json / en.json from code usage.
/// Run: dart run tool/sync_missing_translations.dart
void main() {
  const arPath = 'assets/translations/ar.json';
  const enPath = 'assets/translations/en.json';

  final arRoot = jsonDecode(File(arPath).readAsStringSync()) as Map<String, dynamic>;
  final enRoot = jsonDecode(File(enPath).readAsStringSync()) as Map<String, dynamic>;

  final arFlat = flatten(arRoot);
  final enFlat = flatten(enRoot);
  final usedKeys = collectUsedKeys();

  final arNormIndex = buildNormIndex(arFlat);
  final enNormIndex = buildNormIndex(enFlat);

  var arAdded = 0;
  var enAdded = 0;

  for (final key in usedKeys) {
    if (!arFlat.containsKey(key)) {
      final value = resolveValue(
        key,
        arFlat,
        arNormIndex,
        isArabic: true,
      );
      setNested(arRoot, key, value);
      arFlat[key] = value;
      arAdded++;
    }
    if (!enFlat.containsKey(key)) {
      final value = resolveValue(
        key,
        enFlat,
        enNormIndex,
        isArabic: false,
      );
      setNested(enRoot, key, value);
      enFlat[key] = value;
      enAdded++;
    }
  }

  // Keep ar/en in sync for keys that exist in only one file.
  for (final key in {...arFlat.keys, ...enFlat.keys}) {
    if (arFlat.containsKey(key) && !enFlat.containsKey(key)) {
      final value = resolveValue(key, enFlat, enNormIndex, isArabic: false);
      setNested(enRoot, key, value);
      enFlat[key] = value;
      enAdded++;
    } else if (enFlat.containsKey(key) && !arFlat.containsKey(key)) {
      final value = resolveValue(key, arFlat, arNormIndex, isArabic: true);
      setNested(arRoot, key, value);
      arFlat[key] = value;
      arAdded++;
    }
  }

  File(arPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(arRoot));
  File(enPath).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(enRoot));

  stdout.writeln('Added $arAdded keys to ar.json');
  stdout.writeln('Added $enAdded keys to en.json');
}

Map<String, String> flatten(Map<String, dynamic> root, [String prefix = '']) {
  final out = <String, String>{};
  root.forEach((k, v) {
    final key = prefix.isEmpty ? k : '$prefix.$k';
    if (v is Map<String, dynamic>) {
      out.addAll(flatten(v, key));
    } else {
      out[key] = v.toString();
    }
  });
  return out;
}

void setNested(Map<String, dynamic> root, String dottedKey, String value) {
  final parts = dottedKey.split('.');
  var current = root;
  for (var i = 0; i < parts.length - 1; i++) {
    final part = parts[i];
    final next = current[part];
    if (next is! Map<String, dynamic>) {
      current[part] = <String, dynamic>{};
    }
    current = current[part]! as Map<String, dynamic>;
  }
  current[parts.last] = value;
}

Set<String> collectUsedKeys() {
  final trPattern = RegExp(r'''['"]([a-zA-Z][\w .\-']*\.\w[\w .\-']*)['"]\.tr''');
  final used = <String>{};
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final content = entity.readAsStringSync();
    for (final m in trPattern.allMatches(content)) {
      final key = m.group(1)!;
      if (!key.contains(r'$') && !key.startsWith('{')) {
        used.add(key);
      }
    }
  }
  return used;
}

String normalize(String input) =>
    input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

Map<String, List<MapEntry<String, String>>> buildNormIndex(
  Map<String, String> flat,
) {
  final index = <String, List<MapEntry<String, String>>>{};
  for (final entry in flat.entries) {
    final n = normalize(entry.key);
    index.putIfAbsent(n, () => []).add(entry);
    final last = entry.key.split('.').last;
    final nLast = normalize(last);
    index.putIfAbsent(nLast, () => []).add(entry);
  }
  return index;
}

/// Manual overrides when fuzzy match is ambiguous.
const _manualAliases = <String, String>{
  'Sign Up.Must End With Universityedueg': 'Sign Up.Must End With University edu eg',
  'booking.Didnt Receive The Code': "booking.Didn't Receive The Code",
  'doctor.900 Am': 'doctor.9:00 am',
  'doctor.1000 Am': 'doctor.10:00 am',
  'doctor.1200 Noon': 'doctor.12:00 noon',
  'doctor.0200 Pm': 'doctor.02:00 pm',
  'doctor.0400 Pm': 'doctor.04:00 pm',
  'doctor.0600 Pm': 'doctor.06:00 pm',
  'login.Dont Already Have An': 'login.Don\'t Already Have An',
  'login.Dont Have An Account': 'login.Don\'t Have An Account',
  'chat.Dental Crownsprostheses': 'chat.Dental Crownsprostheeses',
};

const _arDefaults = <String, String>{
  'appointments.everyone': 'الكل',
  'appointments.certain': 'مؤكد',
  'appointments.on_hold': 'قيد الانتظار',
  'appointments.canceled': 'ملغى',
  'appointments.access_denied': 'مرفوض',
  'appointments.my_appointments': 'مواعيدي',
  'appointments.appointment_details': 'تفاصيل الموعد',
  'appointments.the_doctor': 'الطبيب',
  'appointments.specialization': 'التخصص',
  'appointments.the_date': 'التاريخ',
  'appointments.the_time': 'الوقت',
  'appointments.the_condition': 'الحالة',
  'appointments.closing': 'إغلاق',
  'appointments.there_are_no_current': 'لا توجد مواعيد حالية',
};

const _enDefaults = <String, String>{
  'appointments.everyone': 'All',
  'appointments.certain': 'Confirmed',
  'appointments.on_hold': 'Pending',
  'appointments.canceled': 'Canceled',
  'appointments.access_denied': 'Denied',
  'appointments.my_appointments': 'My appointments',
  'appointments.appointment_details': 'Appointment details',
  'appointments.the_doctor': 'Doctor',
  'appointments.specialization': 'Specialty',
  'appointments.the_date': 'Date',
  'appointments.the_time': 'Time',
  'appointments.the_condition': 'Status',
  'appointments.closing': 'Close',
  'appointments.there_are_no_current': 'No current appointments',
};

String resolveValue(
  String key,
  Map<String, String> flat,
  Map<String, List<MapEntry<String, String>>> normIndex, {
  required bool isArabic,
}) {
  final defaults = isArabic ? _arDefaults : _enDefaults;
  if (defaults.containsKey(key)) return defaults[key]!;

  final alias = _manualAliases[key];
  if (alias != null && flat.containsKey(alias)) {
    return flat[alias]!;
  }

  if (flat.containsKey(key)) return flat[key]!;

  final nKey = normalize(key);
  final candidates = normIndex[nKey];
  if (candidates != null && candidates.isNotEmpty) {
    final sameNs = candidates.where((e) => e.key.split('.').first == key.split('.').first);
    if (sameNs.isNotEmpty) return sameNs.first.value;
    return candidates.first.value;
  }

  final last = key.split('.').last;
  final nLast = normalize(last);
  final lastCandidates = normIndex[nLast];
  if (lastCandidates != null && lastCandidates.isNotEmpty) {
    return lastCandidates.first.value;
  }

  return humanize(key, isArabic: isArabic);
}

String humanize(String key, {required bool isArabic}) {
  final segment = key.split('.').last.replaceAll('_', ' ');
  if (!isArabic) {
    return segment.isEmpty
        ? key
        : segment[0].toUpperCase() + segment.substring(1);
  }
  return segment.isEmpty ? key : '[$segment]';
}
