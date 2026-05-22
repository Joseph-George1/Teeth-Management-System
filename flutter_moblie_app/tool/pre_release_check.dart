import 'dart:io';

/// Run before uploading AAB: dart run tool/pre_release_check.dart
void main() {
  final steps = <_Step>[
    _Step('Translation keys', ['dart', 'run', 'tool/check_translations.dart']),
    _Step('Dart analyze', ['dart', 'analyze', 'lib']),
    _Step('Regenerate L10n', ['dart', 'run', 'tool/generate_l10n_keys.dart']),
  ];

  var failed = false;
  for (final step in steps) {
    stdout.writeln('\n==> ${step.name}');
    final result = Process.runSync(
      step.command[0],
      step.command.sublist(1),
      workingDirectory: Directory.current.path,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      failed = true;
      stderr.writeln('FAILED (${step.name}) exit ${result.exitCode}');
    } else {
      stdout.writeln('OK');
    }
  }

  if (failed) {
    stderr.writeln('\nPre-release check FAILED. Fix issues before uploading AAB.');
    exit(1);
  }
  stdout.writeln('\nPre-release check passed. Build with: flutter build appbundle --release');
}

class _Step {
  final String name;
  final List<String> command;
  _Step(this.name, this.command);
}
