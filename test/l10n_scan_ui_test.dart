import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/l10n_scan.dart';

void main() {
  test('all feature views use localization for German UI copy', () {
    expectNoHardcodedGerman([
      for (final feature in Directory(
        'lib/features',
      ).listSync().whereType<Directory>())
        if (Directory('${feature.path}/presentation').existsSync())
          '${feature.path}/presentation',
      'lib/shared',
    ]);
  });
}
