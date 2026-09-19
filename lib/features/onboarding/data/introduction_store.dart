import 'package:shared_preferences/shared_preferences.dart';

/// Only stores whether this device has completed the introduction.
/// It never reads or writes auth, profile, or nutrition data.
abstract interface class IntroductionStore {
  Future<bool> isComplete();
  Future<void> complete();
}

final class DeviceIntroductionStore implements IntroductionStore {
  const DeviceIntroductionStore();

  // Show the revised five-page introduction once, without touching
  // the previous marker, authentication, or other app preferences.
  static const preferenceKey = 'livo.introduction.completed.v2';

  @override
  Future<bool> isComplete() async =>
      await SharedPreferencesAsync().getBool(preferenceKey) ?? false;

  @override
  Future<void> complete() =>
      SharedPreferencesAsync().setBool(preferenceKey, true);
}
