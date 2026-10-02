import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/subscription_repository.dart';
import '../domain/entitlement.dart';

/// Holds the Lookin Premium state of the signed-in account. Reachable through
/// `AppScope.of(context).subscription`; the owning `AppController` forwards
/// its notifications so dependent widgets rebuild.
class SubscriptionController extends ChangeNotifier {
  SubscriptionController({
    required this.repository,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final SubscriptionRepository repository;
  final DateTime Function() _now;

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

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
