import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/personalization_profile.dart';

abstract interface class PersonalizationStore {
  Future<PersonalizationRecord> load(String userId);
  Future<void> save(String userId, PersonalizationProfile profile);
  Future<void> defer(String userId);
  Future<void> clear(String userId);
}

class PersonalizationRecord {
  const PersonalizationRecord({this.profile, this.deferred = false});
  final PersonalizationProfile? profile;
  final bool deferred;
  bool get hasDecision => profile != null || deferred;
}

/// Preferences are isolated per signed-in account on this device.
/// One JSON write commits answers and completion together; drafts stay in RAM.
class DevicePersonalizationStore implements PersonalizationStore {
  const DevicePersonalizationStore();
  String _key(String userId) {
    if (userId.trim().isEmpty) throw ArgumentError('Missing account');
    return 'livo.personalization.v1.${Uri.encodeComponent(userId)}';
  }

  @override
  Future<PersonalizationRecord> load(String userId) async {
    final raw = await SharedPreferencesAsync().getString(_key(userId));
    if (raw == null) return const PersonalizationRecord();
    final data = jsonDecode(raw);
    if (data is! Map<String, dynamic> || data['version'] != 1) {
      throw const FormatException('Invalid preferences');
    }
    if (data['deferred'] == true) {
      return const PersonalizationRecord(deferred: true);
    }
    return PersonalizationRecord(
      profile: PersonalizationProfile.fromJson(data),
    );
  }

  @override
  Future<void> save(String userId, PersonalizationProfile profile) =>
      SharedPreferencesAsync().setString(
        _key(userId),
        jsonEncode(profile.toJson()),
      );

  @override
  Future<void> defer(String userId) => SharedPreferencesAsync().setString(
    _key(userId),
    jsonEncode({'version': 1, 'deferred': true}),
  );

  @override
  Future<void> clear(String userId) =>
      SharedPreferencesAsync().remove(_key(userId));
}
