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

  /// The store account already has this subscription, bought for another
  /// Lookin account. It stays with that account and is not moved.
  ownedByAnotherAccount,

  /// Store billing is not usable here (web, missing key, offering missing,
  /// store or network error). Nothing was charged.
  unavailable,
}

/// Outcome of asking the store for a refund from inside the app.
enum StoreRefundResult {
  /// The store received the request and decides about it.
  submitted,

  /// The person closed the store's refund sheet.
  cancelled,

  /// Not possible here (Android, web, iOS before 15 or a store error).
  unavailable,
}

/// The price and currency supplied by the store for the current storefront.
class StorePrice {
  const StorePrice({required this.formatted, required this.currencyCode});
  final String formatted;
  final String currencyCode;
}

/// Optional capability for loading store-localized prices before purchase.
abstract interface class StorePriceProvider {
  Future<Map<PremiumPlanId, StorePrice>> loadPrices();
}

/// Replaceable boundary to the app stores (Google Play and the App Store).
/// Widgets and controllers never talk to RevenueCat directly.
abstract interface class StoreBilling {
  /// Whether purchases can be started on this device at all.
  bool get isAvailable;

  /// Ties store purchases to the signed-in account (`null` = signed out).
  Future<void> bindAccount(String? userId);

  Future<StorePurchaseStatus> purchase(PremiumPlanId plan);

  Future<StorePurchaseStatus> restore();

  /// Days of free trial the store grants this account for [plan]; 0 when the
  /// store offers none or the account is not eligible (used it before). The
  /// store asks for a payment method before the trial starts.
  Future<int> freeTrialDays(PremiumPlanId plan);

  /// Opens the store's own refund request for the subscription. Only Apple
  /// can refund App Store payments, so this works on iPhones (iOS 15+);
  /// Google Play payments are refunded by us in the Play Console.
  Future<StoreRefundResult> requestRefund();

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
  Future<int> freeTrialDays(PremiumPlanId plan) async => 0;

  @override
  Future<StoreRefundResult> requestRefund() async =>
      StoreRefundResult.unavailable;

  @override
  Uri? managementUri() => null;
}

/// RevenueCat-backed billing. The account id handed to RevenueCat is the
/// Supabase user id, so the server webhook can write the entitlement for the
/// right account. Only that id leaves the device; no health or profile data.
final class RevenueCatStoreBilling implements StoreBilling, StorePriceProvider {
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
      // Never keep the previous account as the bound one: a purchase would
      // be booked on it.
      _boundUserId = null;
      debugPrint('Store billing could not be bound: ${error.runtimeType}');
    }
  });

  /// Waits for a running account change and checks that RevenueCat really
  /// works for the signed-in account. Otherwise a purchase (or restore) could
  /// be booked on the previous account.
  Future<bool> _accountReady() async {
    await _queue;
    if (!_configured || _boundUserId == null) return false;
    try {
      return await Purchases.appUserID == _boundUserId;
    } catch (_) {
      return false;
    }
  }

  Future<Package?> _package(PremiumPlanId plan) async {
    final offerings = await Purchases.getOfferings();
    final wanted = plan == PremiumPlanId.yearly
        ? PackageType.annual
        : PackageType.monthly;
    for (final candidate in offerings.current?.availablePackages ?? const []) {
      if (candidate.packageType == wanted) return candidate;
    }
    return null;
  }

  @override
  Future<Map<PremiumPlanId, StorePrice>> loadPrices() async {
    if (!await _accountReady()) return {};
    final offerings = await Purchases.getOfferings();
    final prices = <PremiumPlanId, StorePrice>{};
    for (final package
        in offerings.current?.availablePackages ?? const <Package>[]) {
      final plan = switch (package.packageType) {
        PackageType.annual => PremiumPlanId.yearly,
        PackageType.monthly => PremiumPlanId.monthly,
        _ => null,
      };
      final product = package.storeProduct;
      if (plan == null ||
          product.priceString.trim().isEmpty ||
          product.currencyCode.trim().isEmpty ||
          !product.price.isFinite ||
          product.price <= 0) {
        continue;
      }
      prices[plan] = StorePrice(
        formatted: product.priceString,
        currencyCode: product.currencyCode,
      );
    }
    return prices;
  }

  static int _days(PeriodUnit unit, int value) => switch (unit) {
    PeriodUnit.day => value,
    PeriodUnit.week => value * 7,
    PeriodUnit.month => value * 30,
    PeriodUnit.year => value * 365,
    PeriodUnit.unknown => 0,
  };

  @override
  Future<int> freeTrialDays(PremiumPlanId plan) async {
    if (!await _accountReady()) return 0;
    try {
      final product = (await _package(plan))?.storeProduct;
      if (product == null) return 0;
      // Google Play: the default option already is the best offer this
      // account may use, including its free phase.
      final freePhase = product.defaultOption?.freePhase?.billingPeriod;
      if (freePhase != null) return _days(freePhase.unit, freePhase.value);
      if (defaultTargetPlatform != TargetPlatform.iOS) return 0;
      // App Store: the introductory offer is listed for everybody; only an
      // account that never had one in this subscription group gets it.
      final intro = product.introductoryPrice;
      if (intro == null || intro.price != 0) return 0;
      final eligibility =
          await Purchases.checkTrialOrIntroductoryPriceEligibility([
            product.identifier,
          ]);
      if (eligibility[product.identifier]?.status !=
          IntroEligibilityStatus.introEligibilityStatusEligible) {
        return 0;
      }
      final cycles = intro.cycles < 1 ? 1 : intro.cycles;
      return _days(intro.periodUnit, intro.periodNumberOfUnits) * cycles;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<StoreRefundResult> requestRefund() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return StoreRefundResult.unavailable;
    }
    if (!await _accountReady()) return StoreRefundResult.unavailable;
    try {
      final status = await Purchases.beginRefundRequestForActiveEntitlement();
      return switch (status) {
        RefundRequestStatus.success => StoreRefundResult.submitted,
        RefundRequestStatus.userCancelled => StoreRefundResult.cancelled,
        RefundRequestStatus.error => StoreRefundResult.unavailable,
      };
    } catch (_) {
      return StoreRefundResult.unavailable;
    }
  }

  @override
  Future<StorePurchaseStatus> purchase(PremiumPlanId plan) async {
    if (!await _accountReady()) return StorePurchaseStatus.unavailable;
    try {
      final package = await _package(plan);
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
        PurchasesErrorCode.productAlreadyPurchasedError ||
        PurchasesErrorCode.receiptAlreadyInUseError =>
          StorePurchaseStatus.ownedByAnotherAccount,
        _ => StorePurchaseStatus.unavailable,
      };
    } catch (_) {
      return StorePurchaseStatus.unavailable;
    }
  }

  @override
  Future<StorePurchaseStatus> restore() async {
    if (!await _accountReady()) return StorePurchaseStatus.unavailable;
    try {
      final info = await Purchases.restorePurchases();
      return _hasPremium(info)
          ? StorePurchaseStatus.purchased
          : StorePurchaseStatus.nothingToRestore;
    } on PlatformException catch (error) {
      // The receipt belongs to another Lookin account: RevenueCat keeps it
      // there (project setting "Keep with original App User ID").
      return PurchasesErrorHelper.getErrorCode(error) ==
              PurchasesErrorCode.receiptAlreadyInUseError
          ? StorePurchaseStatus.ownedByAnotherAccount
          : StorePurchaseStatus.unavailable;
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
