import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

/// Profile images deliberately stay on this device. They are not uploaded to
/// Supabase and are separated by account ID in local app storage.
abstract interface class AvatarRepository {
  Future<Uint8List?> load(String userId);
  Future<void> save(String userId, Uint8List jpeg);
  Future<void> remove(String userId);
}

class LocalAvatarRepository implements AvatarRepository {
  const LocalAvatarRepository({this.preferences});

  final SharedPreferencesAsync? preferences;

  SharedPreferencesAsync get _preferences =>
      preferences ?? SharedPreferencesAsync();

  String _key(String userId) => 'livo.avatar.v1.$userId';

  void _validate(String userId, Uint8List jpeg) {
    if (userId.trim().isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'Konto fehlt.');
    }
    if (jpeg.length < 4 ||
        jpeg.length > 1024 * 1024 ||
        jpeg[0] != 0xff ||
        jpeg[1] != 0xd8) {
      throw ArgumentError(
        'Das Profilbild muss ein JPEG mit höchstens 1 MB sein.',
      );
    }
  }

  @override
  Future<Uint8List?> load(String userId) async {
    if (userId.trim().isEmpty) return null;
    final stored = await _preferences.getString(_key(userId));
    if (stored == null || stored.isEmpty) return null;
    try {
      final bytes = base64Decode(stored);
      _validate(userId, bytes);
      return bytes;
    } catch (_) {
      // A corrupt local value must never prevent opening the profile.
      await _preferences.remove(_key(userId));
      return null;
    }
  }

  @override
  Future<void> save(String userId, Uint8List jpeg) async {
    _validate(userId, jpeg);
    await _preferences.setString(_key(userId), base64Encode(jpeg));
  }

  @override
  Future<void> remove(String userId) async {
    if (userId.trim().isEmpty) return;
    await _preferences.remove(_key(userId));
  }
}
