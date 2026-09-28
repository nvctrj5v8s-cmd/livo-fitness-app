import 'package:flutter/material.dart';

/// Block types of the small Markdown subset the coach may use.
enum CoachBlockKind { paragraph, bullet, numbered, heading }

@immutable
class CoachInline {
  const CoachInline(this.text, {this.bold = false, this.italic = false});

  final String text;
  final bool bold;
  final bool italic;

  @override
  bool operator ==(Object other) =>
      other is CoachInline &&
      other.text == text &&
      other.bold == bold &&
      other.italic == italic;

  @override
  int get hashCode => Object.hash(text, bold, italic);

  @override
  String toString() =>
      'CoachInline(${bold ? 'b ' : ''}${italic ? 'i ' : ''}"$text")';
}

@immutable
class CoachBlock {
  const CoachBlock(this.kind, this.spans, {this.marker = '', this.indent = 0});

  final CoachBlockKind kind;
  final List<CoachInline> spans;

  /// "1." for numbered items; empty otherwise.
  final String marker;

  /// 0 for top-level items, 1 for nested ones.
  final int indent;

  String get plainText => spans.map((span) => span.text).join();
}

final _heading = RegExp(r'^#{1,6}\s+(.*)$');
final _bullet = RegExp(r'^[-*+•·–]\s+(.*)$');
final _numbered = RegExp(r'^(\d{1,2})[.)]\s+(.*)$');
final _rule = RegExp(r'^([-*_=])\1{2,}$');
final _tableDivider = RegExp(r'^\|?[\s:|-]+\|?$');
// No lookbehind: older Safari versions (mobile web) cannot compile it.
final _inline = RegExp(
  r'\*\*(.+?)\*\*'
  r'|__(.+?)__'
  r'|(^|[^\w*])\*([^\s*](?:[^*\n]*[^\s*])?)\*(?![\w*])'
  r'|`([^`]+)`'
  r'|\[([^\]]+)\]\([^)\s]*\)',
);

/// Parses coach answers into simple blocks. Supports paragraphs, `-`/`*`
/// lists, numbered lists, `#` headings, **bold**, *italic*, `code` and
/// [links](…) (rendered as plain text). Unknown or unbalanced markers are
/// removed instead of being shown raw.
List<CoachBlock> parseCoachText(String source) {
  final blocks = <CoachBlock>[];
  final paragraph = <String>[];

  void flush() {
    if (paragraph.isEmpty) return;
    final spans = parseCoachInline(paragraph.join('\n'));
    paragraph.clear();
    if (spans.isNotEmpty) {
      blocks.add(CoachBlock(CoachBlockKind.paragraph, spans));
    }
  }

  void addBlock(CoachBlockKind kind, String text, {String marker = ''}) {
    final spans = parseCoachInline(text);
    if (spans.isEmpty) return;
    blocks.add(CoachBlock(kind, spans, marker: marker));
  }

  for (final rawLine in source.replaceAll('\r\n', '\n').split('\n')) {
    final line = rawLine.trimRight();
    final trimmed = line.trimLeft();
    final indent = line.length - trimmed.length >= 2 ? 1 : 0;
    if (trimmed.isEmpty) {
      flush();
      continue;
    }
    if (trimmed.startsWith('```') || _rule.hasMatch(trimmed)) {
      flush();
      continue;
    }
    if (_heading.firstMatch(trimmed) case final match?) {
      flush();
      addBlock(CoachBlockKind.heading, match.group(1)!);
      continue;
    }
    if (_bullet.firstMatch(trimmed) case final match?) {
      flush();
      final spans = parseCoachInline(match.group(1)!);
      if (spans.isNotEmpty) {
        blocks.add(CoachBlock(CoachBlockKind.bullet, spans, indent: indent));
      }
      continue;
    }
    if (_numbered.firstMatch(trimmed) case final match?) {
      flush();
      final spans = parseCoachInline(match.group(2)!);
      if (spans.isNotEmpty) {
        blocks.add(
          CoachBlock(
            CoachBlockKind.numbered,
            spans,
            marker: '${match.group(1)}.',
            indent: indent,
          ),
        );
      }
      continue;
    }
    if (trimmed.startsWith('|')) {
      // Tables are not rendered; keep each row readable as one line.
      flush();
      if (_tableDivider.hasMatch(trimmed)) continue;
      final cells = trimmed
          .split('|')
          .map((cell) => cell.trim())
          .where((cell) => cell.isNotEmpty);
      addBlock(CoachBlockKind.paragraph, cells.join(' · '));
      continue;
    }
    paragraph.add(
      trimmed.startsWith('>') ? trimmed.substring(1).trimLeft() : trimmed,
    );
  }
  flush();
  return blocks;
}

/// Parses **bold**, *italic*, `code` and [links](…) inside one block.
List<CoachInline> parseCoachInline(
  String text, {
  bool bold = false,
  bool italic = false,
}) {
  final spans = <CoachInline>[];

  void addPlain(String value) {
    // Unbalanced markers would otherwise show up as raw `**` or `__`.
    final clean = value.replaceAll('**', '').replaceAll('__', '');
    if (clean.isEmpty) return;
    spans.add(CoachInline(clean, bold: bold, italic: italic));
  }

  final normalized = text.replaceAll('***', '**');
  var position = 0;
  for (final match in _inline.allMatches(normalized)) {
    addPlain(normalized.substring(position, match.start));
    position = match.end;
    if (match.group(1) ?? match.group(2) case final strong?) {
      spans.addAll(parseCoachInline(strong, bold: true, italic: italic));
    } else if (match.group(4) case final emphasis?) {
      addPlain(match.group(3) ?? '');
      spans.addAll(parseCoachInline(emphasis, bold: bold, italic: true));
    } else if (match.group(5) ?? match.group(6) case final literal?) {
      spans.add(CoachInline(literal, bold: bold, italic: italic));
    }
  }
  addPlain(normalized.substring(position));
  return _merge(spans);
}

List<CoachInline> _merge(List<CoachInline> spans) {
  final merged = <CoachInline>[];
  for (final span in spans) {
    if (merged.isNotEmpty &&
        merged.last.bold == span.bold &&
        merged.last.italic == span.italic) {
      final last = merged.removeLast();
      merged.add(
        CoachInline(
          last.text + span.text,
          bold: span.bold,
          italic: span.italic,
        ),
      );
    } else {
      merged.add(span);
    }
  }
  return merged;
}

/// Renders a coach answer with simple lists and emphasis instead of raw
/// Markdown characters.
class CoachFormattedText extends StatelessWidget {
  const CoachFormattedText(this.text, {required this.style, super.key});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final blocks = parseCoachText(text);
    if (blocks.isEmpty) return Text(text, style: style);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (index, block) in blocks.indexed) ...[
          if (index > 0)
            SizedBox(
              height: _isListItem(block) && _isListItem(blocks[index - 1])
                  ? 5
                  : 10,
            ),
          _BlockView(block: block, style: style),
        ],
      ],
    );
  }

  static bool _isListItem(CoachBlock block) =>
      block.kind == CoachBlockKind.bullet ||
      block.kind == CoachBlockKind.numbered;
}

class _BlockView extends StatelessWidget {
  const _BlockView({required this.block, required this.style});

  final CoachBlock block;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final baseStyle = block.kind == CoachBlockKind.heading
        ? style.copyWith(fontWeight: FontWeight.w800)
        : style;
    final content = Text.rich(
      TextSpan(
        children: [
          for (final span in block.spans)
            TextSpan(
              text: span.text,
              style: baseStyle.copyWith(
                fontWeight: span.bold ? FontWeight.w800 : null,
                fontStyle: span.italic ? FontStyle.italic : null,
              ),
            ),
        ],
      ),
      style: baseStyle,
    );
    if (block.kind != CoachBlockKind.bullet &&
        block.kind != CoachBlockKind.numbered) {
      return content;
    }
    final marker = block.kind == CoachBlockKind.bullet ? '•' : block.marker;
    return Padding(
      padding: EdgeInsets.only(left: block.indent * 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: block.kind == CoachBlockKind.bullet ? 16 : 24,
            child: Text(
              marker,
              style: style.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
