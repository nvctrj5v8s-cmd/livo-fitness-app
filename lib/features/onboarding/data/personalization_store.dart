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

/// Answers given before an account exists ("questions first"). They stay on
/// this device only and move into the account right after sign-up or
/// sign-in, then this record is removed.
abstract interface class PendingPersonalizationStore {
  Future<PersonalizationRecord> load();
  Future<void> save(PersonalizationProfile profile);
  Future<void> defer();
  Future<void> clear();

  /// Whether an account has been used on this device before. Then a signed
  /// out start shows the sign-in instead of the questions again.
  Future<bool> hasSeenAccount();
  Future<void> markAccountSeen();
}

class DevicePendingPersonalizationStore implements PendingPersonalizationStore {
  const DevicePendingPersonalizationStore();

  static const _answersKey = 'livo.personalization.pending.v1';
  static const _accountSeenKey = 'livo.account_seen.v1';

  @override
  Future<PersonalizationRecord> load() async {
    final raw = await SharedPreferencesAsync().getString(_answersKey);
    if (raw == null) return const PersonalizationRecord();
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic> || data['version'] != 1) {
        return const PersonalizationRecord();
      }
      if (data['deferred'] == true) {
        return const PersonalizationRecord(deferred: true);
      }
      return PersonalizationRecord(
        profile: PersonalizationProfile.fromJson(data),
      );
    } on FormatException {
      // Unreadable leftovers are not worth blocking sign-up for.
      return const PersonalizationRecord();
    }
  }

  @override
  Future<void> save(PersonalizationProfile profile) => SharedPreferencesAsync()
      .setString(_answersKey, jsonEncode(profile.toJson()));

  @override
  Future<void> defer() => SharedPreferencesAsync().setString(
    _answersKey,
    jsonEncode({'version': 1, 'deferred': true}),
  );

  @override
  Future<void> clear() => SharedPreferencesAsync().remove(_answersKey);

  @override
  Future<bool> hasSeenAccount() async =>
      await SharedPreferencesAsync().getBool(_accountSeenKey) ?? false;

  @override
  Future<void> markAccountSeen() =>
      SharedPreferencesAsync().setBool(_accountSeenKey, true);
}
