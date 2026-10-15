// l10n-ignore-file: dictionary keys are canonical catalogue data.
import 'dart:convert';

import 'package:flutter/services.dart';

import 'display_text.dart';
import 'l10n.dart';

/// Local, reviewed display translations. Source names, ingredients and safety
/// data remain unchanged. A user's own text is never sent for translation.
abstract final class CatalogText {
  static Map<String, String> _english = const {};
  static Map<String, String> _usdaNames = const {};

  static Future<void> load() async {
    final maps = await Future.wait([
      rootBundle.loadString('assets/l10n/catalog_en.json'),
      rootBundle.loadString('assets/l10n/usda_names_en.json'),
    ]);
    _english = Map<String, String>.from(jsonDecode(maps[0]) as Map);
    _usdaNames = Map<String, String>.from(jsonDecode(maps[1]) as Map);
  }

  static String of(String source) =>
      L10n.isEnglish ? _english[source] ?? DisplayText.of(source) : source;

  static String foodName(String id, String source) =>
      L10n.isEnglish ? _usdaNames[id] ?? of(source) : source;

  static List<String> list(List<String> source) => source.map(of).toList();

  static String measure(String source) {
    if (!L10n.isEnglish) return source;
    final exact = _english[source];
    if (exact != null) return exact;
    final singularPepper = RegExp(
      r'^(?:ca\. )?(?:0[.,]\d+|1|[¼½¾⅓⅔])\s+Paprika$',
    ).hasMatch(source);
    return source
        .replaceFirst('ca. ', 'approx. ')
        .replaceAllMapped(RegExp(r'[A-Za-zÄÖÜäöüß]+\.?'), (match) {
          final unit = match.group(0)!;
          if (unit == 'Paprika') return singularPepper ? 'pepper' : 'peppers';
          return _units[unit] ??
              (_english[unit] ?? DisplayText.of(unit)).toLowerCase();
        })
        .replaceAllMapped(
          RegExp(r'(\d),(\d)'),
          (match) => '${match[1]}.${match[2]}',
        );
  }

  // Household units are canonical German source data, also after scaling.
  static const _units = {
    'EL': 'tbsp',
    'TL': 'tsp',
    'Stk.': 'pieces',
    'Stück': 'piece',
    'Bund': 'bunch',
    'Handvoll': 'handful',
    'Becher': 'pot',
    'Spritzer': 'splash',
    'Beutel': 'sachet',
    'Würfel': 'cube',
    'Brötchen': 'bread rolls',
    'Msp.': 'pinch',
    'Pck.': 'pack',
    'Pkg.': 'pack',
    'Prisen': 'pinches',
    'Zehen': 'cloves',
    'Filets': 'fillets',
    'Dosen': 'tins',
    'Scheiben': 'slices',
    'Tassen': 'cups',
    'Packungen': 'packs',
    'Knollen': 'bulbs',
    'Stangen': 'sticks',
    'Zweige': 'sprigs',
    'Blätter': 'leaves',
    'Eier': 'eggs',
    'Tomaten': 'tomatoes',
    'Kugeln': 'balls',
    'Schoten': 'pods',
    'Messerspitzen': 'pinches',
    'Gläser': 'glasses',
    'Bananen': 'bananas',
    'Zitronen': 'lemons',
    'Limetten': 'limes',
    'Karotten': 'carrots',
    'Möhren': 'carrots',
    'Gurken': 'cucumbers',
    'Avocados': 'avocados',
    'Äpfel': 'apples',
    'Kartoffeln': 'potatoes',
    'Süßkartoffeln': 'sweet potatoes',
    'Frühlingszwiebeln': 'spring onions',
    'Chilischoten': 'chillies',
    'Fladenbrote': 'flatbreads',
    'Portion': 'serving',
    'Portionen': 'servings',
    'kleine': 'small',
    'kleiner': 'small',
    'kleines': 'small',
    'Zwiebeln': 'onions',
  };
}
