import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n.dart';

/// Where the chosen language is kept (`de` or `en`).
abstract interface class LocaleStore {
  Future<String?> read();
  Future<void> write(String code);
}

/// The language belongs to the device, not to an account: it is needed
/// before anyone signs in (introduction, questions, sign-in page).
final class DeviceLocaleStore implements LocaleStore {
  const DeviceLocaleStore();

  static const key = 'lookin.locale.v1';

  @override
  Future<String?> read() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  @override
  Future<void> write(String code) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, code);
  }
}

/// Tests: nothing is stored.
final class MemoryLocaleStore implements LocaleStore {
  MemoryLocaleStore([this.code]);

  String? code;

  @override
  Future<String?> read() async => code;

  @override
  Future<void> write(String code) async => this.code = code;
}

/// The language of the app. Until the person chooses one on the first start,
/// the device language is suggested (German stays German, everything else
/// becomes English).
class LocaleController extends ChangeNotifier {
  LocaleController({this.store = const DeviceLocaleStore(), this.device});

  final LocaleStore store;

  /// Device language; `null` uses the platform setting.
  final Locale? device;

  Locale? _chosen;

  /// Called after the person picked a language (for example to tell the
  /// account, so e-mails come in the same language).
  void Function(Locale locale)? onChanged;

  bool get hasChoice => _chosen != null;

  /// Language suggested before a choice exists.
  Locale get suggested =>
      L10n.resolve(device ?? PlatformDispatcher.instance.locale);

  Locale get locale => _chosen ?? suggested;

  Future<void> load() async {
    try {
      final code = await store.read();
      if (code == 'de' || code == 'en') _chosen = Locale(code!);
    } catch (_) {
      // Private browsing or blocked storage: the language page appears.
    }
    L10n.use(locale);
  }

  Future<void> choose(Locale locale) async {
    final next = L10n.resolve(locale);
    final changed = _chosen != next;
    _chosen = next;
    L10n.use(next);
    notifyListeners();
    try {
      await store.write(next.languageCode);
    } catch (_) {
      // The choice still applies until the app is closed.
    }
    if (changed) onChanged?.call(next);
  }
}

/// Gives widgets access to the [LocaleController] (`LocaleScope.of`).
class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    required LocaleController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  /// The controller, or `null` in tests and previews without one.
  static LocaleController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LocaleScope>()?.notifier;
}
