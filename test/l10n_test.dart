import 'dart:convert';
import 'dart:io';

import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/l10n_merge.dart';
import 'support/l10n_scan.dart';

void main() {
  test('Deutsch und Englisch sind vollständig und gleich aufgebaut', () {
    final merge = mergeParts();
    expect(merge.errors, isEmpty, reason: merge.errors.join('\n'));
    expect(
      merge.en.keys.toSet(),
      merge.de.keys.where((k) => !k.startsWith('@')).toSet(),
    );
  });

  test('app_de.arb und app_en.arb sind auf dem Stand der Teile', () {
    final merge = mergeParts();
    String read(String path) =>
        File(path).readAsStringSync().replaceAll('\r\n', '\n');
    expect(
      read(outputDe),
      merge.deArb,
      reason: 'dart run tool/l10n_merge.dart ausführen',
    );
    expect(read(outputEn), merge.enArb);
  });

  test('englische Texte enthalten keine deutschen Umlaute', () {
    final en =
        jsonDecode(File(outputEn).readAsStringSync()) as Map<String, dynamic>;
    final suspicious = [
      for (final entry in en.entries)
        if (entry.value is String &&
            RegExp('[äöüÄÖÜß]').hasMatch(entry.value as String))
          '${entry.key}: ${entry.value}',
    ];
    expect(suspicious, isEmpty, reason: suspicious.join('\n'));
  });

  test('Sprachwechsel für Code außerhalb von Widgets', () {
    addTearDown(() => L10n.use(L10n.german));
    expect(L10n.current.commonSave, 'Speichern');
    L10n.use(const Locale('en', 'US'));
    expect(L10n.code, 'en');
    expect(L10n.current.commonSave, 'Save');
    L10n.use(const Locale('fr'));
    expect(L10n.code, 'en', reason: 'other languages fall back to English');
  });

  test('Formate passen zur Sprache', () {
    final date = DateTime(2026, 10, 14, 14, 30);
    expect(AppFormat.integer(1240, code: 'de'), '1.240');
    expect(AppFormat.integer(1240, code: 'en'), '1,240');
    expect(AppFormat.decimal(2.5, code: 'de'), '2,5');
    expect(AppFormat.decimal(2.5, code: 'en'), '2.5');
    expect(AppFormat.decimal(3.0, code: 'de'), '3');
    expect(AppFormat.euro(699, code: 'de'), '6,99 €');
    expect(AppFormat.euro(4999, code: 'en'), '€49.99');
    expect(AppFormat.date(date, code: 'de'), '14.10.2026');
    expect(AppFormat.date(date, code: 'en'), '14 Oct 2026');
    expect(AppFormat.longDate(date, code: 'de'), '14. Oktober 2026');
    expect(AppFormat.longDate(date, code: 'en'), '14 October 2026');
    expect(AppFormat.time(date, code: 'de'), '14:30 Uhr');
    expect(AppFormat.time(date, code: 'en'), '14:30');
    expect(AppFormat.weekdayShort(date, code: 'de'), 'Mi');
    expect(AppFormat.weekdayShort(date, code: 'en'), 'Wed');
  });

  test('die Sprachwahl selbst enthält keine festen deutschen Texte', () {
    expectNoHardcodedGerman(['lib/l10n', 'lib/features/language', 'lib/app']);
  });
}
