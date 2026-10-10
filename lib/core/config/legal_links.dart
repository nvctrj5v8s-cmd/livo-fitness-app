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
    defaultValue: 'https://nvctrj5v8s-cmd.github.io/livo-fitness-app/legal/',
  );

  static Uri get privacy => Uri.parse('${baseUrl}datenschutz.html');
  static Uri get terms => Uri.parse('${baseUrl}agb.html');
  static Uri get withdrawal => Uri.parse('${baseUrl}widerruf.html');
  static Uri get imprint => Uri.parse('${baseUrl}impressum.html');

  /// Account deletion without the app, required by Google Play.
  static Uri get accountDeletion => Uri.parse('${baseUrl}konto-loeschen.html');
}
