import 'package:flutter/foundation.dart';

/// Public store-billing values for the Flutter client.
///
/// The RevenueCat SDK keys (`goog_…` for Android, `appl_…` for iOS) are
/// *public* keys meant for apps. They are still passed in at build time with
/// `--dart-define` instead of being committed. Never put a RevenueCat secret
/// key (`sk_…`), the webhook secret or a Google service-account file here.
abstract final class BillingConfig {
  static const androidApiKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  static const iosApiKey = String.fromEnvironment('REVENUECAT_IOS_KEY');

  /// Entitlement identifier configured in the RevenueCat dashboard.
  static const entitlementId = 'premium';

  /// Google Play package, used for the subscription management link.
  static const androidPackage = 'com.lookin.foodtracker';

  /// The SDK key for the running platform; empty when the platform has no
  /// store billing (web, desktop) or the key was not supplied.
  static String get apiKeyForPlatform {
    if (kIsWeb) return '';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => androidApiKey,
      TargetPlatform.iOS => iosApiKey,
      _ => '',
    };
  }
}
