import 'package:fitness_ai_app/l10n/l10n.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/onboarding/data/personalization_store.dart';
import '../../features/consent/domain/consent.dart';
import '../../features/subscription/data/paywall_store.dart';
import 'avatar_repository.dart';
import 'food_preferences_store.dart';

/// Account export and deletion. Privileged database access stays in the
/// account-data Edge Function, which derives the account ID from a verified JWT.
class AccountDataRepository {
  AccountDataRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  String? get currentEmail => _client.auth.currentUser?.email;
  static const _sections = [
    'auth',
    'profiles',
    'entitlements',
    'premium_trials',
    'meals',
    'meal_items',
    'favorites',
    'body_measurements',
    'ai_chat_messages',
    'ai_chat_usage',
    'barcode_lookup_limits',
    'user_consents',
    'withdrawal_requests',
    'personalization_answers',
  ];

  String _requireUserId() {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError(L10n.current.corePleaseSignInFirst);
    return id;
  }

  void _checkAccount(String expectedId) {
    if (_client.auth.currentUser?.id != expectedId) {
      throw StateError(L10n.current.coreTheSignedInAccountHasChanged);
    }
  }

  Future<Map<String, dynamic>> _invoke(Map<String, Object?> body) async {
    final response = await _client.functions.invoke('account-data', body: body);
    if (response.data case final Map data) {
      return Map<String, dynamic>.from(data);
    }
    throw StateError(L10n.current.coreTheServerResponseIsInvalid);
  }

  Future<Uint8List> exportCurrentAccount() async {
    final userId = _requireUserId();
    final remote = <String, Object?>{};
    for (final section in _sections) {
      final rows = <Object?>[];
      var page = 0;
      while (true) {
        _checkAccount(userId);
        final data = await _invoke({
          'action': 'export',
          'section': section,
          'page': page,
        });
        _checkAccount(userId);
        final batch = data['rows'];
        if (batch is! List) {
          throw StateError(L10n.current.coreTheDataExportIsIncomplete);
        }
        rows.addAll(batch);
        final next = data['next_page'];
        if (next == null) break;
        if (next is! int || next != page + 1) {
          throw StateError(L10n.current.coreTheDataExportIsIncomplete);
        }
        page = next;
      }
      remote[section] = rows;
    }

    final localProfile = await const DevicePersonalizationStore().load(userId);
    final avatar = await const LocalAvatarRepository().load(userId);
    final food = await FoodPreferencesStore(userId: userId).load();
    final preferences = SharedPreferencesAsync();
    final local = <String, Object?>{
      'personalization': localProfile.profile?.toJson(),
      'personalization_deferred': localProfile.deferred,
      'avatar_jpeg_base64': avatar == null ? null : base64Encode(avatar),
      'food_favorite_ids': food.favoriteIds.toList(),
      'recent_food_ids': food.recentIds,
      'reminders_json': await preferences.getString('livo.reminders.$userId'),
      'old_kitchen_lists_json': await preferences.getString(
        'livo.kitchen.v1.${Uri.encodeComponent(userId)}',
      ),
      'paywall_seen': await const DevicePaywallStore().hasSeen(userId),
    };
    _checkAccount(userId);
    return Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'format': 'livo-account-export-v1',
          'exported_at': DateTime.now().toUtc().toIso8601String(),
          'account_id': userId,
          'server': remote,
          'this_device': local,
        }),
      ),
    );
  }

  Future<void> deleteCurrentAccount(String password) async {
    final userId = _requireUserId();
    if (password.isEmpty) {
      throw ArgumentError(L10n.current.corePleaseEnterYourPassword);
    }
    final data = await _invoke({
      'action': 'delete',
      'confirmation': 'DELETE',
      'password': password,
    });
    if (data['deleted'] != true) {
      throw StateError(L10n.current.coreYourAccountCouldNotBeDeleted);
    }
    // The server has already removed the account. Remove per-account device
    // data before discarding the local session.
    Object? cleanupError;
    try {
      await clearLocalAccountData(userId);
    } catch (error) {
      cleanupError = error;
    }
    await _client.auth.signOut(scope: SignOutScope.local);
    if (cleanupError != null) {
      throw StateError(L10n.current.coreYourAccountWasDeletedButSomeLocal);
    }
  }

  Future<void> signOut() => _client.auth.signOut(scope: SignOutScope.local);

  static Future<void> clearLocalAccountData(String userId) async {
    await const DevicePersonalizationStore().clear(userId);
    await const LocalAvatarRepository().remove(userId);
    await FoodPreferencesStore(userId: userId).clear();
    await FoodPreferencesStore.clearUnscopedLegacyValues();
    final preferences = SharedPreferencesAsync();
    await preferences.remove('livo.reminders.$userId');
    await preferences.remove('livo.kitchen.v1.${Uri.encodeComponent(userId)}');
    await preferences.remove(DevicePaywallStore.keyFor(userId));
    for (final kind in ConsentKind.values) {
      await preferences.remove(
        'lookin.consent.v1.${kind.wire}.${Uri.encodeComponent(userId)}',
      );
    }
  }
}
