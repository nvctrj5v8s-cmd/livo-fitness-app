import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/legal_links.dart';
import '../../core/theme/app_colors.dart';

/// Opens [uri] in the browser. Shows a short message if that fails.
Future<void> openExternalLink(
  BuildContext context,
  Uri uri, {
  Future<bool> Function(Uri uri)? opener,
}) async {
  final open =
      opener ?? (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);
  var opened = false;
  try {
    opened = await open(uri);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Der Link konnte nicht geöffnet werden. Bitte versuche es '
            'später noch einmal.',
          ),
        ),
      );
  }
}

/// The legal pages a user may want to read, as small text links.
enum LegalPage { privacy, terms, withdrawal, imprint }

extension on LegalPage {
  String get label => switch (this) {
    LegalPage.privacy => 'Datenschutz',
    LegalPage.terms => 'AGB',
    LegalPage.withdrawal => 'Widerruf',
    LegalPage.imprint => 'Impressum',
  };

  Uri get uri => switch (this) {
    LegalPage.privacy => LegalLinks.privacy,
    LegalPage.terms => LegalLinks.terms,
    LegalPage.withdrawal => LegalLinks.withdrawal,
    LegalPage.imprint => LegalLinks.imprint,
  };
}

class LegalLinksRow extends StatelessWidget {
  const LegalLinksRow({
    this.pages = LegalPage.values,
    this.alignment = WrapAlignment.center,
    this.opener,
    super.key,
  });

  final List<LegalPage> pages;
  final WrapAlignment alignment;

  /// Replaces the browser launch in tests.
  final Future<bool> Function(Uri uri)? opener;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignment,
      spacing: 2,
      children: [
        for (final page in pages)
          TextButton(
            key: Key('legal-link-${page.name}'),
            onPressed: () =>
                openExternalLink(context, page.uri, opener: opener),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              minimumSize: const Size(48, 44),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              textStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(page.label),
          ),
      ],
    );
  }
}
