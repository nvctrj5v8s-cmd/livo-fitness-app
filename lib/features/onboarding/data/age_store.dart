import 'package:shared_preferences/shared_preferences.dart';

/// Only stores that this device confirmed the person is at least 18. A "no"
/// is not stored, so nothing about a possible minor is kept.
abstract interface class AgeStore {
  Future<bool> isConfirmed();
  Future<void> confirm();
}

final class DeviceAgeStore implements AgeStore {
  const DeviceAgeStore();

  static const preferenceKey = 'lookin.age.confirmed18.v1';

  @override
  Future<bool> isConfirmed() async =>
      await SharedPreferencesAsync().getBool(preferenceKey) ?? false;

  @override
  Future<void> confirm() =>
      SharedPreferencesAsync().setBool(preferenceKey, true);
}
