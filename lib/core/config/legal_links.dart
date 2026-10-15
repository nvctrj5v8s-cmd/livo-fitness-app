import '../../l10n/l10n.dart';

/// Public addresses of the legal pages (`web/legal/*.html`, published with the
/// web build). Google Play needs the privacy policy as a public URL; the app
/// links to the same pages.
///
/// The default points to the GitHub Pages site. Override it at build time
/// with `--dart-define=LEGAL_BASE_URL=https://example.com/legal/` (trailing
/// slash) as soon as there is a project domain.
abstract final class LegalLinks {
  static const baseUrl = String.fromEnvironment(
    'LEGAL_BASE_URL',
    defaultValue: 'https://app.lookin-foodtracker.de/legal/',
  );

  static String get _localizedBase => '$baseUrl${L10n.isEnglish ? 'en/' : ''}';

  static Uri get privacy => Uri.parse('${_localizedBase}datenschutz.html');
  static Uri get terms => Uri.parse('${_localizedBase}agb.html');
  static Uri get withdrawal => Uri.parse('${_localizedBase}widerruf.html');
  static Uri get imprint => Uri.parse('${_localizedBase}impressum.html');

  /// Public withdrawal form (§ 356a BGB), usable without signing in.
  static Uri get withdrawalForm =>
      Uri.parse('${_localizedBase}widerruf-erklaeren.html');

  /// Account deletion without the app, required by Google Play.
  static Uri get accountDeletion =>
      Uri.parse('${_localizedBase}konto-loeschen.html');
}
