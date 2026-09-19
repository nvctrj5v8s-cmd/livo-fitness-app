import 'package:flutter/material.dart';
import '../../../core/state/app_controller.dart';
import '../domain/personalization_profile.dart';
import 'personalization_page.dart';

Future<void> openPersonalizationEditor(BuildContext context) async {
  final controller = AppScope.of(context);
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (routeContext) => PersonalizationPage(
        initial: controller.personalization ?? const PersonalizationProfile(),
        editing: controller.personalization != null,
        onComplete: (profile) async {
          await controller.savePersonalization(profile);
          if (routeContext.mounted) Navigator.of(routeContext).pop();
        },
        onLater: () async => Navigator.of(routeContext).pop(),
      ),
    ),
  );
}
