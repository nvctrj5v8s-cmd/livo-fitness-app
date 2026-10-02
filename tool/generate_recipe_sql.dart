import 'dart:convert';
import 'dart:io';

import 'package:fitness_ai_app/core/data/halal_content_policy.dart';

/// Turns the reviewed Lookin recipe content (JSON) into one repeatable Supabase
/// migration. It validates structure and the halal rule before writing, so the
/// database trigger never has to skip a row silently. No keys, no network.
///
/// dart run tool/generate_recipe_sql.dart \
///   --input supabase/content/livo_recipes.json \
///   --output supabase/migrations/0010_recipe_content.sql
void main(List<String> args) {
  final options = _options(args);
  final input = options['input'] ?? 'supabase/content/livo_recipes.json';
  final output =
      options['output'] ?? 'supabase/migrations/0010_recipe_content.sql';
  final document =
      jsonDecode(File(input).readAsStringSync()) as Map<String, dynamic>;
  final foods = [
    for (final raw in document['foods'] as List? ?? const [])
      Map<String, dynamic>.from(raw as Map),
  ];
  final recipes = [
    for (final raw in document['recipes'] as List)
      Map<String, dynamic>.from(raw as Map),
  ];
  final energy = <String, (num, num)>{
    ..._existingFoods,
    for (final food in foods)
      food['slug'] as String: (
        food['calories'] as num? ?? 0,
        food['protein'] as num? ?? 0,
      ),
  };
  final retired = _strings(document['retired_recipe_slugs']);
  final errors = <String>[
    ..._validateFoods(foods),
    ..._validateRecipes(recipes, energy),
    for (final slug in retired)
      if (recipes.any((recipe) => recipe['slug'] == slug))
        'Rezept $slug ist gleichzeitig aktiv und ausgemustert',
  ];
  if (errors.isNotEmpty) {
    stderr.writeln('Rezeptdaten ungültig:\n- ${errors.join('\n- ')}');
    exitCode = 65;
    return;
  }
  File(output).writeAsStringSync(_sql(foods, recipes, retired, input));
  for (final recipe in recipes) {
    final (kcal, protein) = _perServing(recipe, energy);
    stdout.writeln(
      '  ${recipe['access_level'] == 'free' ? 'frei   ' : 'premium'} '
      '${kcal.round().toString().padLeft(4)} kcal '
      '${protein.round().toString().padLeft(3)} g P  ${recipe['title']}',
    );
  }
  final premium = recipes.where((r) => r['access_level'] == 'premium').length;
  final free = recipes.length - premium;
  stdout.writeln(
    '${recipes.length} Rezepte ($free frei = '
    '${(free * 100 / recipes.length).round()} %, $premium Premium), '
    '${foods.length} Lebensmittel → $output',
  );
}

/// The original seed foods (per 100 g): slug, name, kcal, protein, carbs,
/// fat, fiber, sugar, salt. The migration inserts them only when they are
/// missing (fresh database) and never overwrites existing rows, so diary
/// entries that already reference them keep their values.
const _baseFoods = <(String, String, num, num, num, num, num, num, num)>[
  ('oats', 'Haferflocken', 372, 13.5, 58.7, 7, 10, 0, 0),
  ('skyr', 'Skyr natur', 63, 11, 4, 0.2, 0, 0, 0),
  ('salmon', 'Lachsfilet', 208, 20, 0, 13, 0, 0, 0),
  ('rice', 'Reis, gekocht', 130, 2.7, 28, 0.3, 0.4, 0, 0),
  ('wholegrain-pasta', 'Vollkornpasta, gekocht', 149, 5.8, 27, 1.3, 4, 0, 0),
  ('egg', 'Ei', 143, 12.6, 0.7, 9.5, 0, 0, 0),
  ('avocado', 'Avocado', 160, 2, 1.8, 14.7, 6.7, 0, 0),
  ('tomato', 'Tomate', 18, 0.9, 3.9, 0.2, 1.2, 0, 0),
  ('berries', 'Beeren-Mix', 50, 1, 8, 0.4, 4, 0, 0),
];

/// kcal and protein per 100 g of the seed foods.
final _existingFoods = <String, (num, num)>{
  for (final food in _baseFoods) food.$1: (food.$3, food.$4),
};

/// Energy and protein for one serving.
(double, double) _perServing(
  Map<String, dynamic> recipe,
  Map<String, (num, num)> energy,
) {
  var kcal = 0.0;
  var protein = 0.0;
  for (final ingredient in _maps(recipe['ingredients'])) {
    final values = energy[ingredient['food_slug']];
    final grams = ingredient['grams'];
    if (values == null || grams is! num) continue;
    kcal += values.$1 * grams / 100;
    protein += values.$2 * grams / 100;
  }
  final servings = recipe['servings'] is int ? recipe['servings'] as int : 1;
  return (kcal / servings, protein / servings);
}

const _allowedTags = {
  'Frühstück',
  'Mittagessen',
  'Abendessen',
  'Snack',
  'High Protein',
  'Schnell',
  'Vegetarisch',
  'Vegan',
  'Pescetarisch',
  'Budget',
  'Meal Prep',
  'Low Carb',
};

const _difficulties = {'Einfach', 'Mittel', 'Anspruchsvoll'};

final _slugPattern = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');

Iterable<String> _validateFoods(List<Map<String, dynamic>> foods) sync* {
  final seen = <String>{};
  for (final food in foods) {
    final slug = food['slug'];
    if (slug is! String || !_slugPattern.hasMatch(slug)) {
      yield 'Lebensmittel mit ungültigem Slug: $slug';
      continue;
    }
    if (!seen.add(slug) || _existingFoods.containsKey(slug)) {
      yield 'Lebensmittel doppelt: $slug';
    }
    final name = food['name'];
    if (name is! String || name.trim().isEmpty) yield '$slug: Name fehlt';
    for (final key in const [
      'calories',
      'protein',
      'carbohydrates',
      'fat',
      'fiber',
      'sugar',
      'salt',
    ]) {
      final value = food[key];
      if (value is! num || value < 0 || value > 1000) {
        yield '$slug: $key ungültig ($value)';
      }
    }
    final macros =
        (food['protein'] as num? ?? 0) +
        (food['carbohydrates'] as num? ?? 0) +
        (food['fat'] as num? ?? 0);
    if (macros > 101) yield '$slug: Makros über 100 g je 100 g';
    if (!HalalContentPolicy.isAllowedText(
      [name, ...?(food['diet_tags'] as List?)?.cast<String>()].join(' '),
    )) {
      yield '$slug: verstößt gegen die Halal-Regel';
    }
  }
}

Iterable<String> _validateRecipes(
  List<Map<String, dynamic>> recipes,
  Map<String, (num, num)> energy,
) sync* {
  final seen = <String>{};
  for (final recipe in recipes) {
    final slug = recipe['slug'];
    if (slug is! String || !_slugPattern.hasMatch(slug)) {
      yield 'Rezept mit ungültigem Slug: $slug';
      continue;
    }
    if (!seen.add(slug)) yield 'Rezept doppelt: $slug';
    for (final key in const ['title', 'description']) {
      final value = recipe[key];
      if (value is! String || value.trim().isEmpty) yield '$slug: $key fehlt';
    }
    if (!const {'free', 'premium'}.contains(recipe['access_level'])) {
      yield '$slug: access_level ungültig';
    }
    if (!_difficulties.contains(recipe['difficulty'])) {
      yield '$slug: difficulty ungültig (${recipe['difficulty']})';
    }
    final servings = recipe['servings'];
    if (servings is! int || servings < 1 || servings > 12) {
      yield '$slug: servings ungültig';
    }
    for (final key in const [
      'preparation_minutes',
      'prep_minutes',
      'cook_minutes',
    ]) {
      final value = recipe[key];
      if (value is! int || value < 0 || value > 600) {
        yield '$slug: $key ungültig';
      }
    }
    final tags = _strings(recipe['tags']);
    for (final tag in tags) {
      if (!_allowedTags.contains(tag)) yield '$slug: unbekannter Tag "$tag"';
    }
    final ingredients = _maps(recipe['ingredients']);
    if (ingredients.isEmpty) yield '$slug: keine Zutaten';
    final usedFoods = <String>{};
    for (final ingredient in ingredients) {
      final food = ingredient['food_slug'];
      if (!energy.containsKey(food)) {
        yield '$slug: unbekanntes Lebensmittel $food';
      }
      if (!usedFoods.add('$food')) yield '$slug: $food doppelt';
      final grams = ingredient['grams'];
      if (grams is! num || grams <= 0 || grams > 5000) {
        yield '$slug: Menge für $food ungültig';
      }
    }
    final steps = _maps(recipe['steps']);
    if (steps.length < 3 || steps.length > 12) {
      yield '$slug: ${steps.length} Schritte (erwartet 3–12)';
    }
    for (final step in steps) {
      final text = step['text'];
      if (text is! String || text.trim().length < 20) {
        yield '$slug: Schritt zu kurz';
      }
      final minutes = step['minutes'] ?? 0;
      if (minutes is! int || minutes < 0 || minutes > 600) {
        yield '$slug: Timer ungültig';
      }
    }
    final premium = recipe['premium'] is Map
        ? Map<String, dynamic>.from(recipe['premium'] as Map)
        : const <String, dynamic>{};
    final tips = _strings(premium['step_tips'], keepEmpty: true);
    if (tips.length > steps.length) {
      yield '$slug: mehr Profi-Tipps als Schritte';
    }
    final text = [
      recipe['title'],
      recipe['description'],
      ...tags,
      ..._strings(recipe['equipment']),
      for (final ingredient in ingredients) ...[
        ingredient['measure'] ?? '',
        ingredient['note'] ?? '',
      ],
      for (final step in steps) ...[step['title'] ?? '', step['text']],
      ...tips,
      ..._strings(premium['common_mistakes']),
      ..._strings(premium['substitutions']),
      premium['meal_prep'] ?? '',
      ..._strings(premium['variations']),
      premium['serving_tip'] ?? '',
    ].join(' ');
    // EU Reg. 1924/2006: "high protein" needs >= 20 % energy from protein.
    final (kcal, protein) = _perServing(recipe, energy);
    final proteinShare = kcal <= 0 ? 0 : protein * 4 / kcal;
    final claimsProtein =
        tags.contains('High Protein') ||
        RegExp(
          r'proteinreich|high protein|eiweißreich',
          caseSensitive: false,
        ).hasMatch('${recipe['title']} ${recipe['description']}');
    if (claimsProtein && proteinShare < 0.2) {
      yield '$slug: "High Protein" nur ab 20 % Energie aus Protein '
          '(hier ${(proteinShare * 100).round()} %)';
    }
    final reason = HalalContentPolicy.restrictionReason(text);
    if (reason != null) yield '$slug: $reason';
  }
}

String _sql(
  List<Map<String, dynamic>> foods,
  List<Map<String, dynamic>> recipes,
  List<String> retired,
  String input,
) {
  final out = StringBuffer()
    ..writeln('-- Generated by tool/generate_recipe_sql.dart from $input.')
    ..writeln('-- Do not edit by hand: change the JSON and regenerate.')
    ..writeln('-- Original Lookin recipe texts. Food values per 100 g from USDA')
    ..writeln('-- FoodData Central (public domain); sources on each food row.')
    ..writeln('-- Catalog content only: no personal, health or payment data.')
    ..writeln('-- Idempotent: safe to run again after a partial failure.')
    ..writeln()
    ..writeln('-- Original seed foods: only added when missing, never changed.')
    ..writeln('insert into public.foods')
    ..writeln(
      '  (slug, name, serving_grams, calories, protein, carbohydrates, fat,',
    )
    ..writeln('   fiber, sugar, salt, source)')
    ..writeln('values')
    ..writeln(
      [
        for (final food in _baseFoods)
          '  (${[
            _text(food.$1),
            _text(food.$2),
            '100',
            for (final value in [food.$3, food.$4, food.$5, food.$6, food.$7, food.$8, food.$9]) _number(value),
            _text('curated'),
          ].join(', ')})',
      ].join(',\n'),
    )
    ..writeln('on conflict (slug) do nothing;')
    ..writeln();

  if (foods.isNotEmpty) {
    out
      ..writeln('insert into public.foods')
      ..writeln(
        '  (slug, name, serving_grams, calories, protein, carbohydrates, fat,',
      )
      ..writeln(
        '   fiber, sugar, salt, allergens, diet_tags, source, source_url,',
      )
      ..writeln('   source_license, source_attribution, data_quality)')
      ..writeln('values');
    out.writeln(
      [
        for (final food in foods)
          '  (${[
            _text(food['slug']),
            _text(food['name']),
            '100',
            for (final key in const ['calories', 'protein', 'carbohydrates', 'fat', 'fiber', 'sugar', 'salt']) _number(food[key]),
            _textArray(_strings(food['allergens'])),
            _textArray(_strings(food['diet_tags'])),
            _text('curated'),
            _text(food['source_url'] ?? 'https://fdc.nal.usda.gov/food-details/${food['fdc_id']}/nutrients'),
            _text('USDA FoodData Central (public domain, CC0 1.0)'),
            _text('USDA FoodData Central, FDC ID ${food['fdc_id']}: ${food['usda_description']}'),
            _text('imported'),
          ].join(', ')})',
      ].join(',\n'),
    );
    out
      ..writeln('on conflict (slug) do update set')
      ..writeln(
        [
          for (final column in const [
            'name',
            'serving_grams',
            'calories',
            'protein',
            'carbohydrates',
            'fat',
            'fiber',
            'sugar',
            'salt',
            'allergens',
            'diet_tags',
            'source',
            'source_url',
            'source_license',
            'source_attribution',
            'data_quality',
          ])
            '  $column = excluded.$column',
          "  updated_at = timezone('utc', now());",
        ].join(',\n'),
      )
      ..writeln();
  }

  out
    ..writeln('insert into public.recipes')
    ..writeln('  (slug, title, description, preparation_minutes, prep_minutes,')
    ..writeln(
      '   cook_minutes, difficulty, servings, tags, equipment, instructions,',
    )
    ..writeln('   step_titles, step_minutes, source, source_license,')
    ..writeln('   source_attribution, access_level)')
    ..writeln('values');
  out.writeln(
    [
      for (final recipe in recipes)
        () {
          final steps = _maps(recipe['steps']);
          return '  (${[
            _text(recipe['slug']),
            _text(recipe['title']),
            _text(recipe['description']),
            _number(recipe['preparation_minutes']),
            _number(recipe['prep_minutes']),
            _number(recipe['cook_minutes']),
            _text(recipe['difficulty']),
            _number(recipe['servings']),
            _textArray(_strings(recipe['tags'])),
            _textArray(_strings(recipe['equipment'])),
            _textArray([for (final step in steps) (step['text'] as String).trim()]),
            _textArray([for (final step in steps) ((step['title'] as String?) ?? '').trim()], keepEmpty: true),
            'array[${steps.map((step) => _number(step['minutes'] ?? 0)).join(', ')}]::integer[]',
            _text('livo_original'),
            _text('Lookin original'),
            _text('Lookin recipe team'),
            _text(recipe['access_level']),
          ].join(', ')})';
        }(),
    ].join(',\n'),
  );
  out
    ..writeln('on conflict (slug) do update set')
    ..writeln(
      [
        for (final column in const [
          'title',
          'description',
          'preparation_minutes',
          'prep_minutes',
          'cook_minutes',
          'difficulty',
          'servings',
          'tags',
          'equipment',
          'instructions',
          'step_titles',
          'step_minutes',
          'source',
          'source_license',
          'source_attribution',
          'access_level',
        ])
          '  $column = excluded.$column',
        "  updated_at = timezone('utc', now());",
      ].join(',\n'),
    )
    ..writeln();

  final slugList = recipes.map((recipe) => _text(recipe['slug'])).join(', ');
  if (retired.isNotEmpty) {
    out
      ..writeln('-- Early seed recipes replaced by the Lookin recipe set.')
      ..writeln(
        'delete from public.recipes where slug in (${retired.map(_text).join(', ')});',
      )
      ..writeln();
  }
  out
    ..writeln('-- Ingredient lists are replaced as a whole.')
    ..writeln('delete from public.recipe_ingredients')
    ..writeln(
      'where recipe_id in (select id from public.recipes where slug in ($slugList));',
    )
    ..writeln()
    ..writeln(
      'insert into public.recipe_ingredients (recipe_id, food_id, amount_grams, position, measure, note)',
    )
    ..writeln(
      'select r.id, f.id, x.amount_grams, x.position, x.measure, x.note',
    )
    ..writeln('from (values');
  var ingredientCount = 0;
  out.writeln(
    [
      for (final recipe in recipes)
        for (final (index, ingredient) in _maps(recipe['ingredients']).indexed)
          () {
            ingredientCount++;
            return '  (${[_text(recipe['slug']), _text(ingredient['food_slug']), '${_number(ingredient['grams'])}::numeric', '${index + 1}', '${_text(ingredient['measure'])}::text', '${_text(ingredient['note'])}::text'].join(', ')})';
          }(),
    ].join(',\n'),
  );
  out
    ..writeln(
      ') as x(recipe_slug, food_slug, amount_grams, position, measure, note)',
    )
    ..writeln('join public.recipes r on r.slug = x.recipe_slug')
    ..writeln('join public.foods f on f.slug = x.food_slug;')
    ..writeln();

  final premiumRecipes = recipes.where((recipe) => recipe['premium'] is Map);
  out
    ..writeln(
      'insert into public.recipe_premium_details (recipe_id, step_tips, common_mistakes,',
    )
    ..writeln('  substitutions, meal_prep, variations, serving_tip)')
    ..writeln(
      'select r.id, x.step_tips, x.common_mistakes, x.substitutions, x.meal_prep,',
    )
    ..writeln('  x.variations, x.serving_tip')
    ..writeln('from (values');
  out.writeln(
    [
      for (final recipe in premiumRecipes)
        () {
          final premium = Map<String, dynamic>.from(recipe['premium'] as Map);
          return '  (${[_text(recipe['slug']), _textArray(_strings(premium['step_tips'], keepEmpty: true), keepEmpty: true), _textArray(_strings(premium['common_mistakes'])), _textArray(_strings(premium['substitutions'])), _text((premium['meal_prep'] as String?) ?? ''), _textArray(_strings(premium['variations'])), _text((premium['serving_tip'] as String?) ?? '')].join(', ')})';
        }(),
    ].join(',\n'),
  );
  out
    ..writeln(
      ') as x(recipe_slug, step_tips, common_mistakes, substitutions, meal_prep, variations, serving_tip)',
    )
    ..writeln('join public.recipes r on r.slug = x.recipe_slug')
    ..writeln('on conflict (recipe_id) do update set')
    ..writeln('  step_tips = excluded.step_tips,')
    ..writeln('  common_mistakes = excluded.common_mistakes,')
    ..writeln('  substitutions = excluded.substitutions,')
    ..writeln('  meal_prep = excluded.meal_prep,')
    ..writeln('  variations = excluded.variations,')
    ..writeln('  serving_tip = excluded.serving_tip;')
    ..writeln()
    ..writeln(
      '-- The halal triggers skip rows silently; fail loudly instead so a',
    )
    ..writeln('-- partial import can never go live.')
    ..writeln(r'do $$')
    ..writeln('begin')
    ..writeln(
      '  if (select count(*) from public.recipes where slug in ($slugList)) <> ${recipes.length} then',
    )
    ..writeln(
      "    raise exception 'Lookin: nicht alle ${recipes.length} Rezepte wurden gespeichert';",
    )
    ..writeln('  end if;')
    ..writeln('  if (select count(*) from public.recipe_ingredients i')
    ..writeln('      join public.recipes r on r.id = i.recipe_id')
    ..writeln('      where r.slug in ($slugList)) <> $ingredientCount then')
    ..writeln(
      "    raise exception 'Lookin: nicht alle $ingredientCount Zutaten wurden gespeichert';",
    )
    ..writeln('  end if;')
    ..writeln('  if (select count(*) from public.recipe_premium_details d')
    ..writeln('      join public.recipes r on r.id = d.recipe_id')
    ..writeln(
      '      where r.slug in ($slugList)) <> ${premiumRecipes.length} then',
    )
    ..writeln(
      "    raise exception 'Lookin: nicht alle Premium-Details wurden gespeichert';",
    )
    ..writeln('  end if;')
    ..writeln('end')
    ..writeln(r'$$;');
  return out.toString();
}

List<Map<String, dynamic>> _maps(Object? value) => [
  for (final item in (value as List?) ?? const [])
    if (item is Map) Map<String, dynamic>.from(item),
];

List<String> _strings(Object? value, {bool keepEmpty = false}) => [
  for (final item in (value as List?) ?? const [])
    if (item is String && (keepEmpty || item.trim().isNotEmpty)) item.trim(),
];

String _text(Object? value) {
  if (value == null) return 'null';
  return "'${value.toString().replaceAll("'", "''")}'";
}

String _textArray(List<String> values, {bool keepEmpty = false}) {
  final items = keepEmpty
      ? values
      : values.where((value) => value.isNotEmpty).toList();
  if (items.isEmpty) return "'{}'::text[]";
  return 'array[${items.map(_text).join(', ')}]::text[]';
}

String _number(Object? value) {
  if (value is! num) throw FormatException('Zahl erwartet, erhalten: $value');
  return value is int || value == value.roundToDouble()
      ? value.round().toString()
      : value.toString();
}

Map<String, String> _options(List<String> args) {
  final options = <String, String>{};
  for (var index = 0; index < args.length - 1; index++) {
    final key = args[index];
    if (key.startsWith('--')) options[key.substring(2)] = args[index + 1];
  }
  return options;
}
