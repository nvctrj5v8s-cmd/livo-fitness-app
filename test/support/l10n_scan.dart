import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// German words that do not occur in English UI texts. Together with ä/ö/ü/ß
/// they find texts that were not moved to the translation files.
final _germanWords = RegExp(
  r'\b(und|oder|nicht|bitte|dein|deine|deinen|deiner|deinem|dich|dir|wir|'
  r'uns|ist|sind|wird|werden|wurde|noch|jetzt|heute|gestern|weiter|zurück|'
  r'speichern|abbrechen|löschen|fehler|erneut|versuche|konnte|kein|keine|'
  r'einen|einem|einer|eine|mit|für|auf|aus|bei|nach|über|zum|zur|vom|auch|'
  r'nur|schon|mehr|hier|alle|alles|wähle|tippe|melde|hast|kannst|musst|'
  r'möchtest|eintragen|hinzufügen|anmelden|abmelden|registrieren|einstellungen|'
  r'mahlzeit|mahlzeiten|rezept|rezepte|tagebuch|ziel|ziele|gewicht)\b',
  caseSensitive: false,
);
final _umlauts = RegExp('[äöüÄÖÜß]');
final _single = RegExp(r"(?<![rR])'((?:[^'\\]|\\.)*)'");
final _double = RegExp(r'(?<![rR])"((?:[^"\\]|\\.)*)"');
final _interpolation = RegExp(r'\$\{[^}]*\}|\$[A-Za-z_]\w*');

/// Fails when a Dart file under [roots] still contains a German text.
///
/// Lines that hold data instead of UI text (stored values, search synonyms,
/// halal term lists, ids) are marked with `// l10n-ignore`; whole files with
/// `// l10n-ignore-file` at the top.
void expectNoHardcodedGerman(List<String> roots) {
  final offenders = <String>[];
  for (final root in roots) {
    final entity = FileSystemEntity.typeSync(root);
    final files = entity == FileSystemEntityType.file
        ? [File(root)]
        : Directory(root)
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'));
    for (final file in files) {
      final path = file.path.replaceAll('\\', '/');
      if (path.contains('/l10n/app_localizations')) continue;
      final lines = file.readAsLinesSync();
      if (lines.any((line) => line.contains('l10n-ignore-file'))) continue;
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trimLeft();
        if (line.contains('l10n-ignore') ||
            trimmed.startsWith('//') ||
            trimmed.startsWith('import ') ||
            trimmed.startsWith('export ') ||
            trimmed.startsWith('part ') ||
            trimmed.startsWith('@')) {
          continue;
        }
        final code = line.contains(' //') ? line.split(' //').first : line;
        for (final match in [
          ..._single.allMatches(code),
          ..._double.allMatches(code),
        ]) {
          final text = match.group(1)!.replaceAll(_interpolation, ' ');
          if (_umlauts.hasMatch(text) || _germanWords.hasMatch(text)) {
            offenders.add('$path:${i + 1}: ${match.group(0)}');
          }
        }
      }
    }
  }
  expect(
    offenders,
    isEmpty,
    reason:
        '${offenders.length} German texts are not in the translation files '
        '(lib/l10n/parts):\n${offenders.take(60).join('\n')}',
  );
}
