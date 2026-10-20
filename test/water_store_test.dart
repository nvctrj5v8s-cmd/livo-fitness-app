import 'package:fitness_ai_app/core/data/water_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final today = DateTime(2026, 10, 20);

  test('Wasser wird pro Konto und Tag gespeichert und begrenzt', () async {
    final a = WaterStore(userId: 'a');
    final b = WaterStore(userId: 'b');
    await a.save(today, 5);
    await b.save(today, 2);
    expect(await a.load(today), 5);
    expect(await b.load(today), 2);
    await a.save(today, 99);
    expect(await a.load(today), 8);
    expect(await a.load(today.add(const Duration(days: 1))), 0);
  });

  test('Werte älter als eine Woche werden beim Speichern entfernt', () async {
    final store = WaterStore(userId: 'a');
    final old = today.subtract(const Duration(days: 10));
    await store.save(old, 3);
    await store.save(today, 1);
    expect(await store.load(old), 0);
    expect(await store.load(today), 1);
  });

  test('clear entfernt nur die Werte dieses Kontos', () async {
    final a = WaterStore(userId: 'a');
    final b = WaterStore(userId: 'b');
    await a.save(today, 4);
    await b.save(today, 6);
    await a.clear();
    expect(await a.load(today), 0);
    expect(await b.load(today), 6);
  });
}
