import '../domain/kitchen_planning.dart';
import '../domain/shopping_aisles.dart';

/// German number without trailing zeros: 1.5 → "1,5", 2.0 → "2".
String formatKitchenNumber(double value) {
  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) return rounded.round().toString();
  return rounded.toStringAsFixed(1).replaceAll('.', ',');
}

/// "500 g", "1,2 kg", "750 ml", "1,5 l", "2 Dosen", "1 Packung".
String formatKitchenAmount(KitchenAmount amount) {
  final value = amount.value;
  final one = value == 1;
  return switch (amount.unit) {
    KitchenUnit.gram =>
      value >= 1000
          ? '${formatKitchenNumber(value / 1000)} kg'
          : '${value.round()} g',
    KitchenUnit.milliliter =>
      value >= 1000
          ? '${formatKitchenNumber(value / 1000)} l'
          : '${value.round()} ml',
    KitchenUnit.piece => '${formatKitchenNumber(value)} Stück',
    KitchenUnit.tablespoon => '${formatKitchenNumber(value)} EL',
    KitchenUnit.teaspoon => '${formatKitchenNumber(value)} TL',
    KitchenUnit.can =>
      '${formatKitchenNumber(value)} ${one ? 'Dose' : 'Dosen'}',
    KitchenUnit.pack =>
      '${formatKitchenNumber(value)} ${one ? 'Packung' : 'Packungen'}',
    KitchenUnit.bunch => '${formatKitchenNumber(value)} Bund',
    KitchenUnit.jar =>
      '${formatKitchenNumber(value)} ${one ? 'Glas' : 'Gläser'}',
    KitchenUnit.cup => '${formatKitchenNumber(value)} Becher',
    KitchenUnit.bottle =>
      '${formatKitchenNumber(value)} ${one ? 'Flasche' : 'Flaschen'}',
    KitchenUnit.bag => '${formatKitchenNumber(value)} Beutel',
    KitchenUnit.clove =>
      '${formatKitchenNumber(value)} ${one ? 'Zehe' : 'Zehen'}',
    KitchenUnit.pinch =>
      '${formatKitchenNumber(value)} ${one ? 'Prise' : 'Prisen'}',
  };
}

/// Amount line for a pantry or shopping entry, or `null` when there is none.
String? kitchenAmountLabel(KitchenAmount? amount, String? note) {
  final parts = [
    if (note != null && note.trim().isNotEmpty) note.trim(),
    if (amount != null) formatKitchenAmount(amount),
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

const kitchenWeekdays = [
  'Montag',
  'Dienstag',
  'Mittwoch',
  'Donnerstag',
  'Freitag',
  'Samstag',
  'Sonntag',
];

const _months = [
  'Jan.',
  'Feb.',
  'März',
  'Apr.',
  'Mai',
  'Juni',
  'Juli',
  'Aug.',
  'Sep.',
  'Okt.',
  'Nov.',
  'Dez.',
];

/// "Mo., 22.9."
String formatShortDay(DateTime day) =>
    '${kitchenWeekdays[day.weekday - 1].substring(0, 2)}., '
    '${day.day}.${day.month}.';

/// "22.–28. Sep. 2026" or "29. Sep. – 5. Okt. 2026".
String formatWeekRange(DateTime monday) {
  final start = weekStartOf(monday);
  final end = DateTime(start.year, start.month, start.day + 6);
  if (start.month == end.month) {
    return '${start.day}.–${end.day}. ${_months[end.month - 1]} ${end.year}';
  }
  final startYear = start.year == end.year ? '' : ' ${start.year}';
  return '${start.day}. ${_months[start.month - 1]}$startYear – '
      '${end.day}. ${_months[end.month - 1]} ${end.year}';
}

String portionsText(int portions) =>
    portions == 1 ? '1 Portion' : '$portions Portionen';

String countText(int count, String singular, String plural) =>
    count == 1 ? '1 $singular' : '$count $plural';

String shoppingAisleLabel(ShoppingAisle aisle) => switch (aisle) {
  ShoppingAisle.produce => 'Obst & Gemüse',
  ShoppingAisle.bakery => 'Brot & Backwaren',
  ShoppingAisle.dairy => 'Kühlregal & Eier',
  ShoppingAisle.meatFish => 'Fleisch & Fisch',
  ShoppingAisle.dryGoods => 'Nudeln, Reis & Vorrat',
  ShoppingAisle.canned => 'Konserven & Gläser',
  ShoppingAisle.oilsSpices => 'Öl, Gewürze & Soßen',
  ShoppingAisle.frozen => 'Tiefkühl',
  ShoppingAisle.drinks => 'Getränke',
  ShoppingAisle.other => 'Sonstiges',
};

/// The open entries as plain text by section, for pasting into a chat.
String shoppingListAsText(Iterable<ShoppingItem> items) {
  final open = [
    for (final item in items)
      if (!item.done) item,
  ];
  final buffer = StringBuffer('Einkaufsliste');
  for (final (aisle, entries) in groupShoppingByAisle(open)) {
    buffer
      ..writeln()
      ..writeln()
      ..write(shoppingAisleLabel(aisle));
    for (final item in entries) {
      final amount = kitchenAmountLabel(item.amount, item.note);
      buffer
        ..writeln()
        ..write('• ${item.name}${amount == null ? '' : ' – $amount'}');
    }
  }
  return buffer.toString();
}
