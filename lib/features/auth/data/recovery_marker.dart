import 'package:shared_preferences/shared_preferences.dart';

/// Remembers on this device that the signed-in session came from a password
/// reset link. As long as the mark is set, the app shows only the
/// new-password page, also after a reload. It is removed once a new password
/// was saved or the user cancelled (both sign out).
abstract final class RecoveryMarker {
  static const _key = 'lookin.password_recovery.v1';

  static Future<void> set(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, userId);
  }

  static Future<bool> isSetFor(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_key) == userId;
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
