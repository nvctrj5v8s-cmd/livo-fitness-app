import 'dart:io';

/// Release gate for the legal pages in `web/legal/`.
///
/// Fails (exit code 1) while a page still contains a draft banner or an
/// unfilled placeholder. Run it before every public release:
///
///   dart run tool/check_legal_pages.dart
void main() {
  final dir = Directory('web/legal');
  final pages =
      dir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.html'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (pages.isEmpty) {
    stderr.writeln('No legal pages found in web/legal/.');
    exit(2);
  }
  var open = 0;
  for (final page in pages) {
    final html = page.readAsStringSync();
    final placeholders = RegExp(
      r'BITTE (AUSFÜLLEN|WÄHLEN|PRÜFEN)',
    ).allMatches(html).length;
    final draft = html.contains('class="draft"');
    final name = page.uri.pathSegments.last;
    if (placeholders > 0 || draft) {
      open += placeholders + (draft ? 1 : 0);
      stdout.writeln(
        '$name: $placeholders offene Stellen${draft ? ', Entwurfshinweis noch vorhanden' : ''}',
      );
    } else {
      stdout.writeln('$name: ok');
    }
  }
  if (open > 0) {
    stdout.writeln('\nNicht bereit für die Veröffentlichung.');
    exit(1);
  }
  stdout.writeln('\nAlle Rechtstexte sind ausgefüllt.');
}
