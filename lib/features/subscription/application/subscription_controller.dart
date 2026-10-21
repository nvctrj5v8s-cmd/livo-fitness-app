import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/store_billing.dart';
import '../data/subscription_repository.dart';
import '../domain/entitlement.dart';
import '../domain/subscription_plans.dart';

/// Holds the Lookin Premium state of the signed-in account. Reachable through
/// `AppScope.of(context).subscription`; the owning `AppController` forwards
/// its notifications so dependent widgets rebuild.
class SubscriptionController extends ChangeNotifier {
  SubscriptionController({
    required this.repository,
    this.billing = const UnavailableStoreBilling(),
    DateTime Function()? now,
    this.confirmDelay = const Duration(milliseconds: 1500),
    this.confirmAttempts = 8,
  }) : _now = now ?? DateTime.now;

  final SubscriptionRepository repository;
  final StoreBilling billing;
  final DateTime Function() _now;

  /// After a store purchase the server learns about it through a webhook.
  /// The app asks the server up to [confirmAttempts] times, [confirmDelay]
  /// apart, before telling the user the activation is still on its way.
  final Duration confirmDelay;
  final int confirmAttempts;

  Future<PurchaseOutcome>? _pendingPurchase;
  bool get isPurchasing => _pendingPurchase != null;

  /// Whether the store can be used on this device. Web builds and builds
  /// without a RevenueCat key report `false`, and the paywall says so.
  bool get storeBillingAvailable => billing.isAvailable;

  Uri? get managementUri => billing.managementUri();

  Entitlement _entitlement = const Entitlement.free();
  bool _loading = false;
  bool _loaded = false;
  bool _loadFailed = false;
  bool _disposed = false;
  Future<void>? _pendingLoad;
  final Map<PremiumPlanId, int> _storeTrialDays = {};
  Future<void>? _pendingOffer;

  Entitlement get entitlement => _entitlement;
  bool get isLoading => _loading;
  bool get hasLoaded => _loaded;
  bool get loadFailed => _loadFailed;

  DateTime now() => _now();

  /// Evaluated on every read, so an ended trial locks premium features
  /// without waiting for a timer; the server enforces the same rule.
  EntitlementAccess get access => _entitlement.accessAt(_now());
  bool get hasPremium => access != EntitlementAccess.free;
  bool get isTrialing => access == EntitlementAccess.trialing;

  /// Days of free trial the store grants this account for [plan]. The trial
  /// is a store offer: the store asks for a payment method and decides who
  /// is eligible (once per store account). 0 = no trial offered.
  int trialDaysFor(PremiumPlanId plan) =>
      hasPremium ? 0 : (_storeTrialDays[plan] ?? 0);

  /// Whether the store offers this account a free trial.
  bool get canStartTrial =>
      PremiumPlanId.values.any((p) => trialDaysFor(p) > 0);

  Future<void> load({bool force = false}) {
    if (_pendingLoad != null) return _pendingLoad!;
    if (_loaded && !force) return Future.value();
    return _pendingLoad = _read().whenComplete(() => _pendingLoad = null);
  }

  Future<void> _read() async {
    _loading = true;
    _loadFailed = false;
    _notify();
    try {
      final next = await repository.loadEntitlement().timeout(
        const Duration(seconds: 8),
      );
      if (_disposed) return;
      _entitlement = next;
      _loaded = true;
      if (!hasPremium) unawaited(refreshStoreOffer());
    } catch (_) {
      if (_disposed) return;
      // Keep the last known state; the paywall gate retries next launch.
      _loadFailed = true;
    } finally {
      _loading = false;
      _notify();
    }
  }

  /// Asks the store which free trial it offers this account. Without store
  /// billing there is no trial. Never throws.
  Future<void> refreshStoreOffer() {
    if (!billing.isAvailable) return Future.value();
    return _pendingOffer ??= _readOffer().whenComplete(
      () => _pendingOffer = null,
    );
  }

  Future<void> _readOffer() async {
    final next = <PremiumPlanId, int>{};
    for (final plan in PremiumPlanId.values) {
      try {
        next[plan] = await billing
            .freeTrialDays(plan)
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        next[plan] = 0;
      }
    }
    if (_disposed) return;
    _storeTrialDays
      ..clear()
      ..addAll(next);
    _notify();
  }

  /// Starts the store purchase for [plan]. Premium is only reported once the
  /// server entitlement confirms it; the server stays the source of truth.
  Future<PurchaseOutcome> purchase(PremiumPlanId plan) =>
      _runStoreFlow(() => billing.purchase(plan));

  /// Re-reads the store account's subscriptions (new device, reinstall).
  Future<PurchaseOutcome> restore() => _runStoreFlow(billing.restore);

  Future<PurchaseOutcome> _runStoreFlow(
    Future<StorePurchaseStatus> Function() action,
  ) {
    final pending = _pendingPurchase;
    if (pending != null) return pending;
    final future = _storeFlow(action).whenComplete(() {
      _pendingPurchase = null;
      _notify();
    });
    _pendingPurchase = future;
    _notify();
    return future;
  }

  Future<PurchaseOutcome> _storeFlow(
    Future<StorePurchaseStatus> Function() action,
  ) async {
    StorePurchaseStatus status;
    try {
      status = await action();
    } catch (_) {
      status = StorePurchaseStatus.unavailable;
    }
    switch (status) {
      case StorePurchaseStatus.purchased:
        return await _confirmWithServer()
            ? PurchaseOutcome.active
            : PurchaseOutcome.activating;
      case StorePurchaseStatus.cancelled:
        return PurchaseOutcome.cancelled;
      case StorePurchaseStatus.pending:
        return PurchaseOutcome.pending;
      case StorePurchaseStatus.nothingToRestore:
        return PurchaseOutcome.nothingToRestore;
      case StorePurchaseStatus.ownedByAnotherAccount:
        return PurchaseOutcome.ownedByAnotherAccount;
      case StorePurchaseStatus.unavailable:
        return PurchaseOutcome.unavailable;
    }
  }

  Future<bool> _confirmWithServer() async {
    for (var attempt = 0; attempt < confirmAttempts; attempt++) {
      if (attempt > 0) await Future<void>.delayed(confirmDelay);
      if (_disposed) return false;
      try {
        final next = await repository.loadEntitlement().timeout(
          const Duration(seconds: 8),
        );
        if (_disposed) return false;
        _entitlement = next;
        _loaded = true;
        _loadFailed = false;
        _notify();
        // The app trial also counts as premium; a purchase is only confirmed
        // once the server holds the subscription itself.
        if (next.hasPremiumAt(_now()) &&
            next.kind == EntitlementKind.subscription) {
          return true;
        }
      } catch (_) {
        // Try again; the webhook may simply not have arrived yet.
      }
    }
    return false;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// What the user should be told after a purchase or restore attempt.
enum PurchaseOutcome {
  /// The server confirmed premium; features are unlocked.
  active,

  /// The store confirmed the purchase but the server has not recorded it yet.
  /// Nothing is lost; premium appears as soon as the webhook arrives.
  activating,

  /// The user closed the store dialog; nothing was charged.
  cancelled,

  /// Payment is pending at the store (for example a cash payment).
  pending,

  /// Restore found no subscription for this store account.
  nothingToRestore,

  /// The store account's subscription belongs to another Lookin account.
  ownedByAnotherAccount,

  /// Store billing could not be used; nothing was charged.
  unavailable,
}
