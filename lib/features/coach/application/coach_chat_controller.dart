import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/data/ai_coach_service.dart';

/// What went wrong in the coach chat, so the UI can offer the right action.
enum CoachIssueKind {
  /// Offline or the request did not reach the server.
  network,

  /// No answer within the waiting time.
  timeout,

  /// Today's AI requests are used up.
  dailyLimit,

  /// The account has no active premium or trial (anymore).
  premiumRequired,

  /// The login expired.
  unauthorized,

  /// Server or AI service error.
  unavailable,

  /// The question was rejected (empty or too long).
  invalidMessage,
}

/// Which step a retry repeats.
enum CoachRetryAction { none, send, loadHistory, clearHistory }

@immutable
class CoachChatIssue {
  const CoachChatIssue({
    required this.kind,
    required this.message,
    this.retry = CoachRetryAction.none,
  });

  final CoachIssueKind kind;
  final String message;
  final CoachRetryAction retry;

  bool get canRetry => retry != CoachRetryAction.none;
}

/// One bubble in the chat.
@immutable
class CoachChatEntry {
  const CoachChatEntry({
    required this.id,
    required this.role,
    required this.text,
    this.failed = false,
    this.fresh = false,
  });

  /// Local, stable ID for widget keys; not the database ID.
  final int id;
  final AiCoachRole role;
  final String text;

  /// A question that did not reach the coach and can be sent again.
  final bool failed;

  /// Added in this session (animated in); loaded history is not animated.
  final bool fresh;

  bool get fromUser => role == AiCoachRole.user;

  CoachChatEntry copyWith({bool? failed}) => CoachChatEntry(
    id: id,
    role: role,
    text: text,
    failed: failed ?? this.failed,
    fresh: fresh,
  );
}

/// Local state of the Lookin Coach chat: history, sending, errors and quota.
///
/// The history itself lives on the server (`ai_chat_messages`, written only by
/// the `ai-coach` Edge Function). This controller keeps the visible copy for
/// the running app session, so switching tabs neither reloads the history nor
/// loses an answer that is still on its way.
class CoachChatController extends ChangeNotifier {
  CoachChatController({AiCoachService? service, DateTime Function()? now})
    : _service = service ?? AiCoachService(),
      _now = now ?? DateTime.now;

  static final Expando<CoachChatController> _byOwner = Expando(
    'coach-chat-controller',
  );

  /// The chat of one signed-in session. [owner] is the session's
  /// `AppController`, so a new login always starts with a fresh chat.
  static CoachChatController of(Object owner, {AiCoachService? service}) =>
      _byOwner[owner] ??= CoachChatController(service: service);

  /// Longest question; the Edge Function checks the same limit.
  static const maxMessageLength = AiCoachService.maxMessageLength;

  /// Retention on the server, shown in the app.
  static const historyMessageLimit = 100;
  static const historyRetentionDays = 90;

  /// Placeholder question stored for a photo analysis.
  static const photoQuestion = '📷 Lebensmittel-Foto zur Analyse';

  final AiCoachService _service;
  final DateTime Function() _now;
  final List<CoachChatEntry> _entries = [];
  int _nextId = 0;

  bool _historyLoading = false;
  bool _historyLoaded = false;
  bool _sending = false;
  bool _clearing = false;
  CoachChatIssue? _issue;
  String? _notice;
  int? _remaining;
  int? _dailyLimit;
  DateTime? _quotaDayUtc;
  int? _latestAnswerId;

  List<CoachChatEntry> get entries => List.unmodifiable(_entries);
  bool get historyLoading => _historyLoading;
  bool get historyLoaded => _historyLoaded;
  bool get sending => _sending;
  bool get clearing => _clearing;
  bool get busy => _sending || _clearing || _historyLoading;
  CoachChatIssue? get issue => _issue;

  /// Short confirmation, e.g. after deleting the history.
  String? get notice => _notice;
  int? get remaining => _remaining;
  int? get dailyLimit => _dailyLimit;

  /// ID of the newest answer that arrived in this session (for scrolling).
  int? get latestAnswerId => _latestAnswerId;
  bool get hasMessages => _entries.isNotEmpty;

  /// The daily limit resets at midnight UTC on the server.
  bool get limitReached {
    final day = _quotaDayUtc;
    return _remaining == 0 &&
        (_dailyLimit ?? 0) > 0 &&
        day != null &&
        _sameDay(day, _now().toUtc());
  }

  bool get canSend => !busy && !limitReached;

  /// Loads the stored history once per session.
  Future<void> ensureHistory() async {
    if (_historyLoaded || _historyLoading) return;
    await loadHistory();
  }

  Future<void> loadHistory() async {
    if (_historyLoading || _sending || _clearing) return;
    _historyLoading = true;
    if (_issue?.retry == CoachRetryAction.loadHistory) _issue = null;
    _notify();
    try {
      final history = await _service.loadHistory();
      _entries
        ..clear()
        ..addAll(history.messages.map(_entryFromMessage));
      _setQuota(history.remaining, history.dailyLimit);
      _historyLoaded = true;
    } on AiCoachException catch (error) {
      _issue = _issueFor(error, retry: CoachRetryAction.loadHistory);
    } finally {
      _historyLoading = false;
      _notify();
    }
  }

  /// Sends a question. Returns `true` when an answer arrived.
  Future<bool> send(
    String rawText, {
    required Map<String, Object?> context,
  }) async {
    if (busy) return false;
    final text = rawText.trim();
    if (text.isEmpty) return false;
    if (text.length > maxMessageLength) {
      _issue = const CoachChatIssue(
        kind: CoachIssueKind.invalidMessage,
        message:
            'Deine Frage ist zu lang. Bitte kürze sie auf höchstens '
            '$maxMessageLength Zeichen.',
      );
      _notify();
      return false;
    }
    if (limitReached) return false;
    // Questions that never reached the server are not part of the stored
    // history; drop them so the visible chat matches what the coach knows.
    _entries.removeWhere((entry) => entry.failed);
    final question = CoachChatEntry(
      id: _nextId++,
      role: AiCoachRole.user,
      text: text,
      fresh: true,
    );
    _entries.add(question);
    _notice = null;
    return _deliver(question, context);
  }

  /// Repeats the step that failed last.
  Future<bool> retry({required Map<String, Object?> context}) async {
    final issue = _issue;
    if (issue == null || busy) return false;
    switch (issue.retry) {
      case CoachRetryAction.none:
        return false;
      case CoachRetryAction.loadHistory:
        await loadHistory();
        return _issue == null;
      case CoachRetryAction.clearHistory:
        return clearHistory();
      case CoachRetryAction.send:
        final index = _entries.lastIndexWhere((entry) => entry.failed);
        if (index < 0) {
          _issue = null;
          _notify();
          return false;
        }
        if (issue.kind == CoachIssueKind.timeout &&
            await _recoverAnswer(_entries[index])) {
          return true;
        }
        final question = _entries[index].copyWith(failed: false);
        _entries[index] = question;
        return _deliver(question, context);
    }
  }

  /// Deletes the whole stored chat of this account on the server.
  Future<bool> clearHistory() async {
    if (_sending || _clearing) return false;
    _clearing = true;
    _issue = null;
    _notice = null;
    _notify();
    try {
      await _service.clearHistory();
      _entries.clear();
      _latestAnswerId = null;
      _historyLoaded = true;
      _notice = 'Dein Chatverlauf wurde gelöscht.';
      return true;
    } on AiCoachException catch (error) {
      _issue = _issueFor(error, retry: CoachRetryAction.clearHistory);
      return false;
    } finally {
      _clearing = false;
      _notify();
    }
  }

  /// Lets the coach describe a food photo (estimate only).
  Future<bool> analyzePhoto(
    Uint8List bytes, {
    required Map<String, Object?> context,
  }) async {
    if (!canSend) return false;
    _entries.removeWhere((entry) => entry.failed);
    final question = CoachChatEntry(
      id: _nextId++,
      role: AiCoachRole.user,
      text: photoQuestion,
      fresh: true,
    );
    _entries.add(question);
    _sending = true;
    _issue = null;
    _notice = null;
    _notify();
    try {
      final reply = await _service.analyzeImage(bytes: bytes, context: context);
      _addAnswer(reply.text);
      _setQuota(reply.remaining, reply.dailyLimit);
      return true;
    } on AiCoachException catch (error) {
      // The photo is not kept, so there is nothing to send again.
      _entries.removeWhere((entry) => entry.id == question.id);
      _issue = _issueFor(error, retry: CoachRetryAction.none);
      _applyErrorQuota(error);
      return false;
    } finally {
      _sending = false;
      _notify();
    }
  }

  void showIssue(String message) {
    _issue = CoachChatIssue(kind: CoachIssueKind.unavailable, message: message);
    _notify();
  }

  void dismissIssue() {
    if (_issue == null) return;
    _issue = null;
    _notify();
  }

  void dismissNotice() {
    if (_notice == null) return;
    _notice = null;
    _notify();
  }

  Future<bool> _deliver(
    CoachChatEntry question,
    Map<String, Object?> context,
  ) async {
    _sending = true;
    _issue = null;
    _notify();
    try {
      final reply = await _service.send(
        message: question.text,
        context: context,
      );
      _addAnswer(reply.text);
      _setQuota(reply.remaining, reply.dailyLimit);
      return true;
    } on AiCoachException catch (error) {
      _markFailed(question.id);
      final retry =
          error.dailyLimitReached ||
              error.premiumRequired ||
              error.code == AiCoachException.invalidMessageCode
          ? CoachRetryAction.none
          : CoachRetryAction.send;
      _issue = _issueFor(error, retry: retry);
      _applyErrorQuota(error);
      return false;
    } finally {
      _sending = false;
      _notify();
    }
  }

  /// After a timeout the server may still have answered and stored the
  /// exchange. Reuse that answer instead of asking (and paying) twice.
  Future<bool> _recoverAnswer(CoachChatEntry failed) async {
    _sending = true;
    _issue = null;
    _notify();
    try {
      final history = await _service.loadHistory();
      final messages = history.messages;
      if (messages.length < 2) return false;
      final question = messages[messages.length - 2];
      final answer = messages.last;
      if (question.role != AiCoachRole.user ||
          question.text != failed.text ||
          answer.role != AiCoachRole.assistant) {
        return false;
      }
      _entries
        ..clear()
        ..addAll(messages.take(messages.length - 1).map(_entryFromMessage));
      _addAnswer(answer.text);
      _setQuota(history.remaining, history.dailyLimit);
      return true;
    } on AiCoachException {
      return false;
    } finally {
      _sending = false;
      _notify();
    }
  }

  void _addAnswer(String text) {
    final answer = CoachChatEntry(
      id: _nextId++,
      role: AiCoachRole.assistant,
      text: text,
      fresh: true,
    );
    _entries.add(answer);
    _latestAnswerId = answer.id;
  }

  void _markFailed(int id) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index >= 0) _entries[index] = _entries[index].copyWith(failed: true);
  }

  CoachChatEntry _entryFromMessage(AiCoachMessage message) =>
      CoachChatEntry(id: _nextId++, role: message.role, text: message.text);

  void _setQuota(int? remaining, int? dailyLimit) {
    if (remaining == null || dailyLimit == null) return;
    _remaining = remaining.clamp(0, dailyLimit < 0 ? 0 : dailyLimit);
    _dailyLimit = dailyLimit;
    _quotaDayUtc = _now().toUtc();
  }

  void _applyErrorQuota(AiCoachException error) {
    if (!error.dailyLimitReached) return;
    _setQuota(0, error.dailyLimit ?? _dailyLimit ?? 0);
  }

  CoachChatIssue _issueFor(
    AiCoachException error, {
    required CoachRetryAction retry,
  }) {
    final kind = switch (error.code) {
      AiCoachException.networkCode => CoachIssueKind.network,
      AiCoachException.timeoutCode => CoachIssueKind.timeout,
      AiCoachException.dailyLimitCode => CoachIssueKind.dailyLimit,
      AiCoachException.premiumRequiredCode => CoachIssueKind.premiumRequired,
      AiCoachException.unauthorizedCode => CoachIssueKind.unauthorized,
      AiCoachException.invalidMessageCode => CoachIssueKind.invalidMessage,
      _ => CoachIssueKind.unavailable,
    };
    final message = kind == CoachIssueKind.premiumRequired
        ? 'Der Lookin Coach ist Teil von Lookin Premium. Deine Testphase oder '
              'dein Abo ist nicht mehr aktiv.'
        : error.message;
    return CoachChatIssue(kind: kind, message: message, retry: retry);
  }

  void _notify() => notifyListeners();

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
