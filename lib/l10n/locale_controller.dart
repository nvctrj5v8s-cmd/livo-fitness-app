import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n.dart';
import 'document_locale.dart';

/// Where the language preference is kept (`de`, `en` or `system`).
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

/// Follows the device language until a manual override is selected.
/// German devices use German; all other device languages use English.
class LocaleController extends ChangeNotifier with WidgetsBindingObserver {
  LocaleController({this.store = const DeviceLocaleStore(), this.device})
    : _deviceLocale = device ?? PlatformDispatcher.instance.locale;

  final LocaleStore store;

  /// Device language; `null` uses the platform setting.
  final Locale? device;

  Locale? _chosen;
  Locale _deviceLocale;
  bool _observing = false;

  /// With no manual override, later changes to the phone language apply too.
  bool get followsDevice => _chosen == null;

  /// Called after the person picked a language (for example to tell the
  /// account, so e-mails come in the same language).
  void Function(Locale locale)? onChanged;

  bool get hasChoice => _chosen != null;

  /// Language suggested before a choice exists.
  Locale get suggested => L10n.resolve(_deviceLocale);

  Locale get locale => _chosen ?? suggested;

  Future<void> load() async {
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    try {
      final code = await store.read();
      if (code == 'de' || code == 'en') _chosen = Locale(code!);
    } catch (_) {
      // Private browsing or blocked storage: follow the device language.
    }
    L10n.use(locale);
    updateDocumentLanguage(locale.languageCode);
  }

  Future<void> choose(Locale locale) async {
    final next = L10n.resolve(locale);
    final changed = _chosen != next;
    _chosen = next;
    L10n.use(next);
    updateDocumentLanguage(next.languageCode);
    notifyListeners();
    try {
      await store.write(next.languageCode);
    } catch (_) {
      // The choice still applies until the app is closed.
    }
    if (changed) onChanged?.call(next);
  }

  Future<void> useDeviceLanguage() async {
    _chosen = null;
    L10n.use(locale);
    updateDocumentLanguage(locale.languageCode);
    notifyListeners();
    onChanged?.call(locale);
    try {
      await store.write('system');
    } catch (_) {
      // The device language still applies for this session.
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    final previous = locale;
    _deviceLocale = locales?.firstOrNull ?? PlatformDispatcher.instance.locale;
    if (followsDevice && locale != previous) {
      L10n.use(locale);
      updateDocumentLanguage(locale.languageCode);
      notifyListeners();
      onChanged?.call(locale);
    }
  }

  @override
  void dispose() {
    if (_observing) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
