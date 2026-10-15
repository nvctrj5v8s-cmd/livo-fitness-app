import 'package:fitness_ai_app/l10n/l10n.dart';
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
        SnackBar(
          content: Text(context.l10n.sharedTheLinkCouldNotBeOpenedPlease),
        ),
      );
  }
}

/// The legal pages a user may want to read, as small text links.
enum LegalPage { privacy, terms, withdrawal, imprint, withdrawalForm }

extension on LegalPage {
  String get label => switch (this) {
    LegalPage.privacy => L10n.current.sharedPrivacy,
    LegalPage.terms => L10n.current.sharedTerms,
    LegalPage.withdrawal => L10n.current.sharedWithdrawal,
    LegalPage.imprint => L10n.current.sharedImprint,
    LegalPage.withdrawalForm => L10n.current.sharedWithdrawFromContract,
  };

  Uri get uri => switch (this) {
    LegalPage.privacy => LegalLinks.privacy,
    LegalPage.terms => LegalLinks.terms,
    LegalPage.withdrawal => LegalLinks.withdrawal,
    LegalPage.imprint => LegalLinks.imprint,
    LegalPage.withdrawalForm => LegalLinks.withdrawalForm,
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
