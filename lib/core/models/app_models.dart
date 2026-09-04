enum MealSlot { breakfast, lunch, dinner, snack }

extension MealSlotLabel on MealSlot {
  String get label => switch (this) {
    MealSlot.breakfast => 'Frühstück',
    MealSlot.lunch => 'Mittagessen',
    MealSlot.dinner => 'Abendessen',
    MealSlot.snack => 'Snack',
  };
}

class MealEntry {
  const MealEntry({
    required this.id,
    required this.name,
    required this.slot,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageAsset,
  });

  final String id;
  final String name;
  final MealSlot slot;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final String? imageAsset;
}

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.calories,
    required this.protein,
    required this.imageAsset,
    required this.tags,
  });

  final String id;
  final String title;
  final String subtitle;
  final int minutes;
  final int calories;
  final int protein;
  final String imageAsset;
  final List<String> tags;
}

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.amount,
    this.done = false,
  });

  final String id;
  final String name;
  final String amount;
  final bool done;

  ShoppingItem copyWith({bool? done}) =>
      ShoppingItem(id: id, name: name, amount: amount, done: done ?? this.done);
}

class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.amount,
  });

  final String id;
  final String name;
  final String amount;
}
