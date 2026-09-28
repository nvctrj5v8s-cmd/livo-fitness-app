import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/kitchen_planning.dart';

/// Storage boundary for the week plan, shopping list and pantry. The app only
/// talks to this interface, so a later cloud implementation (own Supabase
/// tables with RLS) can replace the device store without touching the UI.
abstract interface class PlanningStore {
  /// `null` when nothing has been stored for [userId] yet. Throws when stored
  /// data exists but cannot be read, so it is never silently overwritten.
  Future<KitchenState?> load(String userId);
  Future<void> save(String userId, KitchenState state);
  Future<void> clear(String userId);
}

/// Keeps the lists only on this device, separated by account ID
/// (`livo.kitchen.v1.<userId>`). Nothing is uploaded or shared.
class DevicePlanningStore implements PlanningStore {
  const DevicePlanningStore({this.preferences});

  final SharedPreferencesAsync? preferences;

  SharedPreferencesAsync get _preferences =>
      preferences ?? SharedPreferencesAsync();

  static String keyFor(String userId) {
    if (userId.trim().isEmpty) throw ArgumentError('Konto fehlt.');
    return 'livo.kitchen.v1.${Uri.encodeComponent(userId)}';
  }

  @override
  Future<KitchenState?> load(String userId) async {
    final raw = await _preferences.getString(keyFor(userId));
    if (raw == null) return null;
    return KitchenState.fromJson(jsonDecode(raw));
  }

  @override
  Future<void> save(String userId, KitchenState state) =>
      _preferences.setString(keyFor(userId), jsonEncode(state.toJson()));

  @override
  Future<void> clear(String userId) => _preferences.remove(keyFor(userId));
}
