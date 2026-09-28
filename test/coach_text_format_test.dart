import 'package:fitness_ai_app/core/data/ai_coach_service.dart';
import 'package:fitness_ai_app/features/coach/presentation/coach_formatted_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fett, kursiv, Code und Links werden ohne Rohzeichen gelesen', () {
    final spans = parseCoachInline(
      'Iss **Skyr** mit *Beeren*, `ca. 150 g` und [Quelle](https://x.y).',
    );
    expect(spans, const [
      CoachInline('Iss '),
      CoachInline('Skyr', bold: true),
      CoachInline(' mit '),
      CoachInline('Beeren', italic: true),
      CoachInline(', ca. 150 g und Quelle.'),
    ]);
  });

  test('unausgeglichene Sternchen erscheinen nicht roh', () {
    final text = parseCoachInline(
      'Wichtig: **Protein zuerst',
    ).map((span) => span.text);
    expect(text.join(), 'Wichtig: Protein zuerst');
    expect(parseCoachInline('2 * 3 Portionen').single.text, '2 * 3 Portionen');
  });

  test('Listen, nummerierte Listen und Überschriften werden erkannt', () {
    final blocks = parseCoachText(
      '## Dein Abend\n'
      'Du hast noch **650 kcal** frei.\n\n'
      '- Lachs-Bowl\n'
      '* Linsen-Curry\n'
      '  - mit Reis\n'
      '1. Gemüse schneiden\n'
      '2) Reis kochen\n'
      '---\n'
      '| kcal | Protein |\n'
      '|---|---|\n'
      '| 520 | 35 g |',
    );
    expect(blocks.map((block) => block.kind), [
      CoachBlockKind.heading,
      CoachBlockKind.paragraph,
      CoachBlockKind.bullet,
      CoachBlockKind.bullet,
      CoachBlockKind.bullet,
      CoachBlockKind.numbered,
      CoachBlockKind.numbered,
      CoachBlockKind.paragraph,
      CoachBlockKind.paragraph,
    ]);
    expect(blocks[0].plainText, 'Dein Abend');
    expect(blocks[1].spans[1], const CoachInline('650 kcal', bold: true));
    expect(blocks[4].indent, 1);
    expect(blocks[6].marker, '2.');
    expect(blocks[7].plainText, 'kcal · Protein');
    expect(blocks[8].plainText, '520 · 35 g');
  });

  test('einfache Zeilenumbrüche bleiben im Absatz erhalten', () {
    final blocks = parseCoachText('Frühstück: Haferflocken\nMittag: Linsen');
    expect(blocks.single.plainText, 'Frühstück: Haferflocken\nMittag: Linsen');
  });

  test('leere oder unlesbare Antworten gelten als leer', () {
    expect(cleanCoachText('  \n\u0000 ** � '), isEmpty);
    expect(cleanCoachText('Hallo\r\n\r\n\r\n\r\nWelt\u0007'), 'Hallo\n\nWelt');
  });
}
