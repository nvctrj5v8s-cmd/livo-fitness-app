import 'package:fitness_ai_app/features/auth/data/recovery_marker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'Passwort-Reset bleibt bis zum Abschluss für dieses Konto markiert',
    () async {
      SharedPreferences.setMockInitialValues({});
      expect(await RecoveryMarker.isSetFor('user-1'), isFalse);

      await RecoveryMarker.set('user-1');
      expect(await RecoveryMarker.isSetFor('user-1'), isTrue);
      expect(await RecoveryMarker.isSetFor('user-2'), isFalse);

      await RecoveryMarker.clear();
      expect(await RecoveryMarker.isSetFor('user-1'), isFalse);
    },
  );
}
