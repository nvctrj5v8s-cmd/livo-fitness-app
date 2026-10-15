import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/state/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/l10n.dart';

/// Shown when the food and recipe catalog could not be loaded for a signed-in
/// person, so a missing catalog is never mistaken for an empty one. Offers a
/// reload; shows nothing when everything is fine.
class CatalogUnavailableNotice extends StatelessWidget {
  const CatalogUnavailableNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    if (!controller.catalogFailed) return const SizedBox.shrink();
    final l10n = context.l10n;
    final loading = controller.catalogLoading;
    return Container(
      key: const Key('catalog-notice'),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 20,
            color: AppColors.orange,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.sharedCatalogUnavailable,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            key: const Key('catalog-reload'),
            onPressed: loading
                ? null
                : () => unawaited(controller.loadRemoteCatalog()),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            child: Text(
              loading ? l10n.sharedCatalogReloading : l10n.sharedCatalogReload,
            ),
          ),
        ],
      ),
    );
  }
}
