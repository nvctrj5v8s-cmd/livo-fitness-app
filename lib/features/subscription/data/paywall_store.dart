import 'package:shared_preferences/shared_preferences.dart';

/// Remembers per account on this device that the start paywall was shown.
/// Stores only a boolean flag keyed by the account ID; no purchase, health or
/// nutrition data.
abstract interface class PaywallStore {
  Future<bool> hasSeen(String userId);
  Future<void> markSeen(String userId);
}

final class DevicePaywallStore implements PaywallStore {
  const DevicePaywallStore();

  static String keyFor(String userId) => 'livo.paywall.seen.v1.$userId';

  @override
  Future<bool> hasSeen(String userId) async =>
      await SharedPreferencesAsync().getBool(keyFor(userId)) ?? false;

  @override
  Future<void> markSeen(String userId) =>
      SharedPreferencesAsync().setBool(keyFor(userId), true);
}
