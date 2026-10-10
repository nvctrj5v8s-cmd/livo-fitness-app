import 'package:flutter/foundation.dart';

import '../data/consent_repository.dart';
import '../domain/consent.dart';

/// Explicit consent decisions of the signed-in account. `null` means the
/// person has not been asked yet; `false` is a decision to decline.
class ConsentController extends ChangeNotifier {
  ConsentController({required this.repository});

  final ConsentRepository repository;

  final Map<ConsentKind, bool> _decisions = {};
  bool _loaded = false;
  bool _disposed = false;
  Future<void>? _pendingLoad;

  bool get hasLoaded => _loaded;
  bool? decision(ConsentKind kind) => _decisions[kind];

  bool get healthGranted => _decisions[ConsentKind.healthData] == true;
  bool get aiGranted => _decisions[ConsentKind.aiProcessing] == true;

  /// The one-time question after sign-in is still open.
  bool get needsInitialDecision =>
      _loaded &&
      (!_decisions.containsKey(ConsentKind.healthData) ||
          !_decisions.containsKey(ConsentKind.aiProcessing));

  Future<void> load() {
    if (_loaded) return Future.value();
    return _pendingLoad ??= _read().whenComplete(() => _pendingLoad = null);
  }

  Future<void> _read() async {
    try {
      final decisions = await repository.load();
      if (_disposed) return;
      _decisions
        ..clear()
        ..addAll(decisions);
    } catch (_) {
      // Undecided stays undecided; the app asks again when needed.
    }
    _loaded = true;
    _notify();
  }

  /// Returns whether the decision was also stored as proof on the server.
  Future<bool> set(ConsentKind kind, bool granted, {String? context}) async {
    _decisions[kind] = granted;
    _notify();
    return repository.record(kind, granted, context: context);
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
