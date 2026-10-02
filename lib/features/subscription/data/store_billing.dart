import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../core/config/billing_config.dart';
import '../domain/subscription_plans.dart';

/// Outcome of a purchase or restore attempt in the store.
enum StorePurchaseStatus {
  /// The store confirmed an active premium subscription.
  purchased,

  /// The user closed the store dialog; nothing was charged.
  cancelled,

  /// The store accepted the purchase but payment is still pending (for
  /// example a cash payment); premium unlocks once it completes.
  pending,

  /// Restore found no active subscription for this store account.
  nothingToRestore,

  /// Store billing is not usable here (web, missing key, offering missing,
  /// store or network error). Nothing was charged.
  unavailable,
}

/// Replaceable boundary to the app stores (Google Play now, App Store later).
/// Widgets and controllers never talk to RevenueCat directly.
abstract interface class StoreBilling {
  /// Whether purchases can be started on this device at all.
  bool get isAvailable;

  /// Ties store purchases to the signed-in account (`null` = signed out).
  Future<void> bindAccount(String? userId);

  Future<StorePurchaseStatus> purchase(PremiumPlanId plan);

  Future<StorePurchaseStatus> restore();

  /// Where the user manages or cancels the subscription, if known.
  Uri? managementUri();
}

/// Used on web, in tests and in builds without a RevenueCat key.
final class UnavailableStoreBilling implements StoreBilling {
  const UnavailableStoreBilling();

  @override
  bool get isAvailable => false;

  @override
  Future<void> bindAccount(String? userId) async {}

  @override
  Future<StorePurchaseStatus> purchase(PremiumPlanId plan) async =>
      StorePurchaseStatus.unavailable;

  @override
  Future<StorePurchaseStatus> restore() async =>
      StorePurchaseStatus.unavailable;

  @override
  Uri? managementUri() => null;
}

/// RevenueCat-backed billing. The account id handed to RevenueCat is the
/// Supabase user id, so the server webhook can write the entitlement for the
/// right account. Only that id leaves the device; no health or profile data.
final class RevenueCatStoreBilling implements StoreBilling {
  RevenueCatStoreBilling({required this.apiKey});

  final String apiKey;

  bool _configured = false;
  String? _boundUserId;
  Future<void> _queue = Future.value();

  @override
  bool get isAvailable => apiKey.isNotEmpty;

  /// Runs account changes strictly one after another.
  Future<void> _serial(Future<void> Function() action) {
    final next = _queue.then((_) => action());
    _queue = next.catchError((Object _) {});
    return next;
  }

  @override
  Future<void> bindAccount(String? userId) => _serial(() async {
    try {
      if (userId == null) {
        if (_configured && _boundUserId != null) await Purchases.logOut();
        _boundUserId = null;
        return;
      }
      if (!_configured) {
        await Purchases.configure(
          PurchasesConfiguration(apiKey)..appUserID = userId,
        );
        _configured = true;
      } else if (_boundUserId != userId) {
        await Purchases.logIn(userId);
      }
      _boundUserId = userId;
    } catch (error) {
      // Billing stays unusable until the next bind; the app keeps working.
      debugPrint('Store billing could not be bound: ${error.runtimeType}');
    }
  });

  @override
  Future<StorePurchaseStatus> purchase(PremiumPlanId plan) async {
    if (!_configured || _boundUserId == null) {
      return StorePurchaseStatus.unavailable;
    }
    try {
      final offerings = await Purchases.getOfferings();
      final wanted = plan == PremiumPlanId.yearly
          ? PackageType.annual
          : PackageType.monthly;
      Package? package;
      for (final candidate
          in offerings.current?.availablePackages ?? const []) {
        if (candidate.packageType == wanted) {
          package = candidate;
          break;
        }
      }
      if (package == null) return StorePurchaseStatus.unavailable;
      final result = await Purchases.purchase(PurchaseParams.package(package));
      return _hasPremium(result.customerInfo)
          ? StorePurchaseStatus.purchased
          : StorePurchaseStatus.pending;
    } on PlatformException catch (error) {
      return switch (PurchasesErrorHelper.getErrorCode(error)) {
        PurchasesErrorCode.purchaseCancelledError =>
          StorePurchaseStatus.cancelled,
        PurchasesErrorCode.paymentPendingError => StorePurchaseStatus.pending,
        _ => StorePurchaseStatus.unavailable,
      };
    } catch (_) {
      return StorePurchaseStatus.unavailable;
    }
  }

  @override
  Future<StorePurchaseStatus> restore() async {
    if (!_configured || _boundUserId == null) {
      return StorePurchaseStatus.unavailable;
    }
    try {
      final info = await Purchases.restorePurchases();
      return _hasPremium(info)
          ? StorePurchaseStatus.purchased
          : StorePurchaseStatus.nothingToRestore;
    } catch (_) {
      return StorePurchaseStatus.unavailable;
    }
  }

  @override
  Uri? managementUri() => switch (defaultTargetPlatform) {
    TargetPlatform.android => Uri.https(
      'play.google.com',
      '/store/account/subscriptions',
      {'package': BillingConfig.androidPackage},
    ),
    TargetPlatform.iOS => Uri.https('apps.apple.com', '/account/subscriptions'),
    _ => null,
  };

  static bool _hasPremium(CustomerInfo info) =>
      info.entitlements.active.containsKey(BillingConfig.entitlementId);
}

/// The billing implementation for this build: RevenueCat when the platform
/// supports it and the public key was supplied, otherwise a stub.
StoreBilling createStoreBilling() {
  final key = BillingConfig.apiKeyForPlatform;
  return key.isEmpty
      ? const UnavailableStoreBilling()
      : RevenueCatStoreBilling(apiKey: key);
}

/// One billing instance for the whole app run, so a sign-out can log the
/// store account out again. Created on first use, never at import time.
final StoreBilling sharedStoreBilling = createStoreBilling();
