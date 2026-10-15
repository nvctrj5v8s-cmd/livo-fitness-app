import 'dart:io';

/// Release gate for the legal pages in `web/legal/` and `web/legal/en/`.
///
/// Fails (exit code 1) while a page still contains a draft banner or an
/// unfilled placeholder (German or English). Run it before every public
/// release:
///
///   dart run tool/check_legal_pages.dart
void main() {
  final pages = <File>[];
  for (final path in ['web/legal', 'web/legal/en']) {
    final dir = Directory(path);
    if (!dir.existsSync()) continue;
    pages.addAll(
      dir.listSync().whereType<File>().where(
        (file) => file.path.endsWith('.html'),
      ),
    );
  }
  pages.sort((a, b) => a.path.compareTo(b.path));
  if (pages.isEmpty) {
    stderr.writeln('No legal pages found in web/legal/.');
    exit(2);
  }
  final placeholder = RegExp(
    r'(BITTE (AUSFÜLLEN|WÄHLEN|PRÜFEN)|PLEASE (FILL|CHOOSE|REVIEW|CHECK)|TODO)',
  );
  var open = 0;
  for (final page in pages) {
    final html = page.readAsStringSync();
    final placeholders = placeholder.allMatches(html).length;
    final draft = html.contains('class="draft"');
    final name = page.path
        .replaceAll(String.fromCharCode(92), '/')
        .replaceFirst('web/legal/', '');
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
