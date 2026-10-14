import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';
export 'app_format.dart';

/// Texts in the current language.
///
/// Widgets use `context.l10n.someKey`. Code without a `BuildContext`
/// (controllers, services, formatting) uses `L10n.current.someKey`. Both
/// follow the language the person chose; German is the fallback, so widget
/// tests without localization delegates keep working unchanged.
extension L10nContext on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      L10n.current;
}

abstract final class L10n {
  static const german = Locale('de');
  static const english = Locale('en');
  static const supported = [german, english];

  static AppLocalizations _current = lookupAppLocalizations(german);

  /// The texts of the active language.
  static AppLocalizations get current => _current;

  /// `de` or `en`.
  static String get code => _current.localeName;

  static bool get isEnglish => code == 'en';

  /// Switches the texts used outside of widgets. `LocaleController` calls
  /// this; tests may call it and must reset it with `L10n.use(L10n.german)`.
  static void use(Locale locale) {
    _current = lookupAppLocalizations(resolve(locale));
  }

  /// Maps any locale to a supported one: German stays German, everything
  /// else is shown in English.
  static Locale resolve(Locale? locale) =>
      locale?.languageCode == 'de' ? german : english;

  /// The texts of a specific language, for example to preview the other
  /// language on the language page.
  static AppLocalizations of(Locale locale) =>
      lookupAppLocalizations(resolve(locale));
}
