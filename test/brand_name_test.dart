import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The old working name must never reappear in text users can see.
/// Storage keys such as `livo.reminders.<id>` are internal and stay as they
/// are, so only visible spellings are checked here.
void main() {
  test('no visible spelling of the old name remains in lib/', () {
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final visible =
            line.contains("'livo.'") ||
            line.contains('"livo."') ||
            line.contains("'livo'") ||
            line.contains('LIVO') ||
            line.contains('Livo');
        if (visible) offenders.add('${file.path}:${i + 1}: ${line.trim()}');
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('web page and manifest use the current name', () {
    for (final path in ['web/index.html', 'web/manifest.json']) {
      final text = File(path).readAsStringSync().toLowerCase();
      expect(text, contains('lookin'), reason: path);
      expect(text, isNot(contains('livo')), reason: path);
    }
  });
}
