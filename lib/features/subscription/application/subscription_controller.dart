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
  Future<TrialStartResult>? _pendingTrial;

  Entitlement get entitlement => _entitlement;
  bool get isLoading => _loading;
  bool get hasLoaded => _loaded;
  bool get loadFailed => _loadFailed;
  bool get isStartingTrial => _pendingTrial != null;

  DateTime now() => _now();

  /// Evaluated on every read, so an ended trial locks premium features
  /// without waiting for a timer; the server enforces the same rule.
  EntitlementAccess get access => _entitlement.accessAt(_now());
  bool get hasPremium => access != EntitlementAccess.free;
  bool get isTrialing => access == EntitlementAccess.trialing;
  bool get canStartTrial => _entitlement.trialAvailableAt(_now());

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
    } catch (_) {
      if (_disposed) return;
      // Keep the last known state; the paywall gate retries next launch.
      _loadFailed = true;
    } finally {
      _loading = false;
      _notify();
    }
  }

  Future<TrialStartResult> startTrial() {
    final pending = _pendingTrial;
    if (pending != null) return pending;
    final future = _startTrial().whenComplete(() {
      _pendingTrial = null;
      _notify();
    });
    _pendingTrial = future;
    _notify();
    return future;
  }

  Future<TrialStartResult> _startTrial() async {
    TrialStartResult result;
    try {
      result = await repository.startTrial().timeout(
        const Duration(seconds: 12),
      );
    } catch (_) {
      result = const TrialStartResult(TrialStartStatus.unavailable);
    }
    if (_disposed) return result;
    switch (result.status) {
      case TrialStartStatus.started:
      case TrialStartStatus.alreadyPremium:
        if (result.entitlement case final granted?) {
          _entitlement = granted;
          _loaded = true;
        }
        // Confirm with the server, which stays the source of truth.
        try {
          final confirmed = await repository.loadEntitlement().timeout(
            const Duration(seconds: 8),
          );
          if (!_disposed) {
            _entitlement = confirmed;
            _loaded = true;
          }
        } catch (_) {
          // The RPC answer above remains valid until the next load.
        }
      case TrialStartStatus.alreadyUsed:
        _entitlement = _entitlement.copyWith(trialUsed: true);
      case TrialStartStatus.notConfigured:
      case TrialStartStatus.signedOut:
      case TrialStartStatus.previewOnly:
      case TrialStartStatus.unavailable:
        break;
    }
    return result;
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
        if (next.hasPremiumAt(_now())) return true;
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

  /// Store billing could not be used; nothing was charged.
  unavailable,
}
