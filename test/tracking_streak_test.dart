import 'package:fitness_ai_app/core/models/tracking_streak.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateTrackingStreak', () {
    final now = DateTime(2026, 9, 17, 21, 30);

    test('zählt heute und direkt vorherige Kalendertage', () {
      expect(
        calculateTrackingStreak({
          DateTime(2026, 9, 17, 7),
          DateTime(2026, 9, 16, 23),
          DateTime(2026, 9, 15, 12),
        }, now),
        3,
      );
    });

    test('behält die Serie bis gestern bei, wenn heute noch leer ist', () {
      expect(
        calculateTrackingStreak({
          DateTime(2026, 9, 16),
          DateTime(2026, 9, 15),
        }, now),
        2,
      );
    });

    test('stoppt an einer Lücke und ignoriert Zeitanteile', () {
      expect(
        calculateTrackingStreak({
          DateTime.utc(2026, 9, 17, 23),
          DateTime.utc(2026, 9, 15, 23),
          DateTime.utc(2026, 9, 14, 23),
        }, now),
        1,
      );
    });

    test('zukünftige Tage starten keine Serie', () {
      expect(calculateTrackingStreak({DateTime(2026, 9, 18)}, now), 0);
    });
  });
}
