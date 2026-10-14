// Assembles lib/l10n/app_de.arb and app_en.arb from the parts in
// lib/l10n/parts/ and then runs `flutter gen-l10n`.
//
//   dart run tool/l10n_merge.dart            merge, check and generate
//   dart run tool/l10n_merge.dart --check    only check (exit code 1 on errors)
//
// Every area of the app owns one pair of parts: `<area>_de.json` (template,
// with optional "@key" metadata) and `<area>_en.json` (only the values). Keys
// start with the area name, so two areas can never define the same key and
// parallel work on different areas never touches the same file.
import 'dart:convert';
import 'dart:io';

const partsDir = 'lib/l10n/parts';
const outputDe = 'lib/l10n/app_de.arb';
const outputEn = 'lib/l10n/app_en.arb';

/// Result of reading and checking all parts.
class L10nMerge {
  L10nMerge(this.de, this.en, this.errors);

  /// Merged messages including "@key" metadata (German template).
  final Map<String, Object?> de;

  /// Merged English messages.
  final Map<String, Object?> en;

  final List<String> errors;

  String get deArb => _encode({'@@locale': 'de', ...de});
  String get enArb => _encode({'@@locale': 'en', ...en});
}

String _encode(Map<String, Object?> map) =>
    '${const JsonEncoder.withIndent('  ').convert(map)}\n';

/// Placeholder names used in an ICU message: `{count}`, `{count, plural, …}`.
Set<String> placeholdersOf(String message) {
  final names = <String>{};
  var depth = 0;
  for (var i = 0; i < message.length; i++) {
    final char = message[i];
    if (char == '{') {
      if (depth == 0) {
        final match = RegExp(r'^\{\s*([A-Za-z_]\w*)').firstMatch(
          message.substring(i),
        );
        if (match != null) names.add(match.group(1)!);
      }
      depth++;
    } else if (char == '}') {
      depth = depth > 0 ? depth - 1 : 0;
    }
  }
  return names;
}

String _areaOf(String fileName) =>
    fileName.replaceFirst(RegExp(r'_(de|en)\.json$'), '');

Map<String, Object?> _readJson(File file, List<String> errors) {
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map<String, dynamic>) return decoded;
    errors.add('${file.path}: must be a JSON object');
  } on FormatException catch (error) {
    errors.add('${file.path}: invalid JSON (${error.message})');
  }
  return const {};
}

L10nMerge mergeParts({String directory = partsDir}) {
  final errors = <String>[];
  final de = <String, Object?>{};
  final en = <String, Object?>{};
  final owner = <String, String>{};
  final dir = Directory(directory);
  if (!dir.existsSync()) {
    return L10nMerge(de, en, ['$directory is missing']);
  }
  final files = dir.listSync().whereType<File>().where(
    (file) => file.path.endsWith('.json'),
  );
  final areas = <String>{
    for (final file in files) _areaOf(file.uri.pathSegments.last),
  }.toList()..sort();

  for (final area in areas) {
    final deFile = File('$directory/${area}_de.json');
    final enFile = File('$directory/${area}_en.json');
    if (!deFile.existsSync() || !enFile.existsSync()) {
      errors.add('$area: both ${area}_de.json and ${area}_en.json are needed');
      continue;
    }
    final dePart = _readJson(deFile, errors);
    final enPart = _readJson(enFile, errors);
    final deKeys = dePart.keys.where((key) => !key.startsWith('@')).toSet();
    final enKeys = enPart.keys.where((key) => !key.startsWith('@')).toSet();

    for (final key in deKeys.difference(enKeys)) {
      errors.add('$area: "$key" has no English text');
    }
    for (final key in enKeys.difference(deKeys)) {
      errors.add('$area: "$key" exists only in English');
    }
    for (final key in enPart.keys.where((key) => key.startsWith('@'))) {
      errors.add('$area: metadata "$key" belongs in ${area}_de.json only');
    }
    for (final key in deKeys) {
      if (!key.startsWith(area)) {
        errors.add('$area: key "$key" must start with "$area"');
      }
      if (!RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(key)) {
        errors.add('$area: key "$key" must be lowerCamelCase');
      }
      final previous = owner[key];
      if (previous != null) {
        errors.add('"$key" is defined in $previous and $area');
      }
      owner[key] = area;
      final deValue = dePart[key];
      final enValue = enPart[key];
      if (deValue is! String || deValue.trim().isEmpty) {
        errors.add('$area: "$key" needs a German text');
        continue;
      }
      if (enValue is! String || enValue.trim().isEmpty) {
        errors.add('$area: "$key" needs an English text');
        continue;
      }
      final dePlaceholders = placeholdersOf(deValue);
      final enPlaceholders = placeholdersOf(enValue);
      if (dePlaceholders.length != enPlaceholders.length ||
          !dePlaceholders.containsAll(enPlaceholders)) {
        errors.add(
          '$area: "$key" placeholders differ '
          '(de $dePlaceholders, en $enPlaceholders)',
        );
      }
      de[key] = deValue;
      final meta = dePart['@$key'];
      if (meta != null) de['@$key'] = meta;
      en[key] = enValue;
    }
  }

  final sortedDe = <String, Object?>{};
  for (final key in (de.keys.where((k) => !k.startsWith('@')).toList()
    ..sort())) {
    sortedDe[key] = de[key];
    if (de.containsKey('@$key')) sortedDe['@$key'] = de['@$key'];
  }
  final sortedEn = <String, Object?>{
    for (final key in (en.keys.toList()..sort())) key: en[key],
  };
  return L10nMerge(sortedDe, sortedEn, errors);
}

Future<void> main(List<String> args) async {
  final checkOnly = args.contains('--check');
  final merge = mergeParts();
  if (merge.errors.isNotEmpty) {
    stderr.writeln('Translation parts have errors:');
    for (final error in merge.errors) {
      stderr.writeln('  - $error');
    }
    exitCode = 1;
    return;
  }
  if (checkOnly) {
    final upToDate =
        File(outputDe).existsSync() &&
        File(outputEn).existsSync() &&
        File(outputDe).readAsStringSync().replaceAll('\r\n', '\n') ==
            merge.deArb &&
        File(outputEn).readAsStringSync().replaceAll('\r\n', '\n') ==
            merge.enArb;
    if (!upToDate) {
      stderr.writeln(
        'app_de.arb / app_en.arb are out of date: '
        'run dart run tool/l10n_merge.dart',
      );
      exitCode = 1;
      return;
    }
    stdout.writeln('${merge.en.length} messages, de and en complete.');
    return;
  }
  File(outputDe).writeAsStringSync(merge.deArb);
  File(outputEn).writeAsStringSync(merge.enArb);
  stdout.writeln('${merge.en.length} messages written. Generating code …');
  final result = await Process.run('flutter', [
    'gen-l10n',
  ], runInShell: true);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  exitCode = result.exitCode;
}
