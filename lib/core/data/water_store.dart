import 'package:shared_preferences/shared_preferences.dart';

/// Glasses of water per day, kept on this device only (never sent anywhere).
/// One value per account and day; values older than a week are removed.
class WaterStore {
  WaterStore({this.userId});

  /// Null is the account-free preview.
  final String? userId;

  static const _keepDays = 7;

  String get _scope =>
      userId == null ? 'preview' : Uri.encodeComponent(userId!);

  static String _dayKey(DateTime day) =>
      '${day.year}-${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  String _key(DateTime day) => 'lookin.water.v1.$_scope.${_dayKey(day)}';

  Future<int> load(DateTime day) async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getInt(_key(day)) ?? 0;
    return value.clamp(0, 8);
  }

  Future<void> save(DateTime day, int glasses) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_key(day), glasses.clamp(0, 8));
    await _prune(preferences, day);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    final prefix = 'lookin.water.v1.$_scope.';
    for (final key in preferences.getKeys().where(
      (key) => key.startsWith(prefix),
    )) {
      await preferences.remove(key);
    }
  }

  Future<void> _prune(SharedPreferences preferences, DateTime today) async {
    final prefix = 'lookin.water.v1.$_scope.';
    final oldest = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: _keepDays));
    for (final key in preferences.getKeys().where(
      (key) => key.startsWith(prefix),
    )) {
      final day = DateTime.tryParse(key.substring(prefix.length));
      if (day != null && day.isBefore(oldest)) await preferences.remove(key);
    }
  }
}
