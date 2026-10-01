import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_ai_app/core/data/food_preferences_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'livo_food_favorite_ids_v1': <String>['old-shared-favorite'],
      'livo_recent_food_ids_v1': <String>['old-shared-recent'],
    });
  });

  test('food shortcuts are isolated by account and from preview', () async {
    final alice = FoodPreferencesStore(userId: 'alice');
    final bob = FoodPreferencesStore(userId: 'bob');
    final preview = FoodPreferencesStore();

    await alice.saveFavoriteIds({'rice'});
    await alice.saveRecentIds(['oats']);
    await bob.saveFavoriteIds({'apple'});
    await preview.saveRecentIds(['preview-food']);

    expect((await alice.load()).favoriteIds, {'rice'});
    expect((await alice.load()).recentIds, ['oats']);
    expect((await bob.load()).favoriteIds, {'apple'});
    expect((await bob.load()).recentIds, isEmpty);
    expect((await preview.load()).favoriteIds, isEmpty);
    expect((await preview.load()).recentIds, ['preview-food']);
  });

  test('old unscoped values are never exposed and can be cleared', () async {
    final alice = FoodPreferencesStore(userId: 'alice');
    expect((await alice.load()).favoriteIds, isEmpty);
    expect((await alice.load()).recentIds, isEmpty);

    await FoodPreferencesStore.clearUnscopedLegacyValues();
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.containsKey('livo_food_favorite_ids_v1'), isFalse);
    expect(preferences.containsKey('livo_recent_food_ids_v1'), isFalse);
  });

  test('clearing one account keeps the other account intact', () async {
    final alice = FoodPreferencesStore(userId: 'alice');
    final bob = FoodPreferencesStore(userId: 'bob');
    await alice.saveFavoriteIds({'rice'});
    await bob.saveFavoriteIds({'apple'});

    await alice.clear();
    expect((await alice.load()).favoriteIds, isEmpty);
    expect((await bob.load()).favoriteIds, {'apple'});
  });
}
