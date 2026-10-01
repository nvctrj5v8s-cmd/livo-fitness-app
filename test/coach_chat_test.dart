import 'dart:async';

import 'package:fitness_ai_app/features/onboarding/domain/personalization_profile.dart';
import 'package:fitness_ai_app/core/data/ai_coach_service.dart';
import 'package:fitness_ai_app/core/state/app_controller.dart';
import 'package:fitness_ai_app/features/coach/application/coach_chat_controller.dart';
import 'package:fitness_ai_app/features/coach/application/coach_context.dart';
import 'package:fitness_ai_app/features/coach/presentation/coach_page.dart';
import 'package:fitness_ai_app/features/subscription/data/subscription_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/recipe_fixtures.dart';

/// Coach backend without network: every call is answered by the test.
class FakeCoachService extends AiCoachService {
  FakeCoachService({
    this.history = const [],
    this.remaining = 50,
    this.dailyLimit = 50,
  });

  List<AiCoachMessage> history;
  int remaining;
  int dailyLimit;
  final sent = <String>[];
  final contexts = <Map<String, Object?>>[];
  int historyCalls = 0;
  int clearCalls = 0;

  /// Next answers or errors for [send]; an empty queue answers "Antwort N".
  final replies = <Object>[];
  Object? historyError;
  Object? clearError;
  Completer<void>? gate;

  @override
  Future<AiCoachReply> send({
    required String message,
    required Map<String, Object?> context,
  }) async {
    sent.add(message);
    contexts.add(context);
    if (gate case final gate?) await gate.future;
    final next = replies.isEmpty
        ? 'Antwort ${sent.length}'
        : replies.removeAt(0);
    if (next is AiCoachException) throw next;
    remaining--;
    return AiCoachReply(
      text: next as String,
      remaining: remaining,
      dailyLimit: dailyLimit,
    );
  }

  @override
  Future<AiCoachHistory> loadHistory() async {
    historyCalls++;
    if (historyError case final AiCoachException error) throw error;
    return AiCoachHistory(
      messages: history,
      remaining: remaining,
      dailyLimit: dailyLimit,
    );
  }

  @override
  Future<int> clearHistory() async {
    clearCalls++;
    if (clearError case final AiCoachException error) throw error;
    final count = history.length;
    history = const [];
    return count;
  }
}

const _network = AiCoachException(
  'Keine Verbindung zum Coach. Bitte prüfe deine Internetverbindung und '
  'versuche es erneut.',
  code: AiCoachException.networkCode,
);

const _limit = AiCoachException(
  'Dein KI-Tageslimit von 50 Anfragen ist erreicht.',
  code: AiCoachException.dailyLimitCode,
  remaining: 0,
  dailyLimit: 50,
);

const _storedChat = [
  AiCoachMessage(role: AiCoachRole.user, text: 'Was esse ich zum Frühstück?'),
  AiCoachMessage(
    role: AiCoachRole.assistant,
    text: 'Probier **Haferflocken** mit Skyr.',
  ),
];

void main() {
  group('CoachChatController', () {
    test('lädt den Verlauf und sendet mit Kontext', () async {
      final service = FakeCoachService(history: _storedChat);
      final chat = CoachChatController(service: service);
      await chat.ensureHistory();
      await chat.ensureHistory();
      expect(service.historyCalls, 1);
      expect(chat.entries, hasLength(2));
      expect(chat.entries.every((entry) => !entry.fresh), isTrue);

      expect(await chat.send(' Idee? ', context: const {'goal': 'x'}), isTrue);
      expect(service.sent.single, 'Idee?');
      expect(chat.entries.last.text, 'Antwort 1');
      expect(chat.latestAnswerId, chat.entries.last.id);
      expect(chat.remaining, 49);
    });

    test('Fehler und Wiederholen erzeugen keine doppelte Frage', () async {
      final service = FakeCoachService()..replies.add(_network);
      final chat = CoachChatController(service: service);
      expect(await chat.send('Hallo', context: const {}), isFalse);
      expect(chat.entries.single.failed, isTrue);
      expect(chat.issue?.kind, CoachIssueKind.network);
      expect(chat.issue?.canRetry, isTrue);

      expect(await chat.retry(context: const {}), isTrue);
      expect(chat.entries.map((entry) => entry.text), ['Hallo', 'Antwort 2']);
      expect(chat.entries.first.failed, isFalse);
      expect(chat.issue, isNull);
    });

    test('nicht gesendete Frage verschwindet bei neuer Frage', () async {
      final service = FakeCoachService()..replies.add(_network);
      final chat = CoachChatController(service: service);
      await chat.send('Erste', context: const {});
      await chat.send('Zweite', context: const {});
      expect(chat.entries.map((entry) => entry.text), ['Zweite', 'Antwort 2']);
    });

    test(
      'nach Zeitüberschreitung wird eine gespeicherte Antwort übernommen',
      () async {
        final service = FakeCoachService()
          ..replies.add(
            const AiCoachException(
              'Zu lange',
              code: AiCoachException.timeoutCode,
            ),
          );
        final chat = CoachChatController(service: service);
        await chat.send('Frage', context: const {});
        // Meanwhile the server answered and stored the exchange.
        service.history = const [
          AiCoachMessage(role: AiCoachRole.user, text: 'Frage'),
          AiCoachMessage(role: AiCoachRole.assistant, text: 'Späte Antwort'),
        ];
        expect(await chat.retry(context: const {}), isTrue);
        expect(service.sent, ['Frage']);
        expect(chat.entries.map((entry) => entry.text), [
          'Frage',
          'Späte Antwort',
        ]);
      },
    );

    test('Tageslimit sperrt das Senden bis zum nächsten UTC-Tag', () async {
      var now = DateTime.utc(2026, 9, 27, 20);
      final service = FakeCoachService()..replies.add(_limit);
      final chat = CoachChatController(service: service, now: () => now);
      await chat.send('Noch eine Frage', context: const {});
      expect(chat.issue?.kind, CoachIssueKind.dailyLimit);
      expect(chat.issue?.canRetry, isFalse);
      expect(chat.limitReached, isTrue);
      expect(chat.canSend, isFalse);
      expect(await chat.send('Nochmal', context: const {}), isFalse);
      expect(service.sent, hasLength(1));

      now = DateTime.utc(2026, 9, 28, 0, 5);
      expect(chat.limitReached, isFalse);
    });

    test(
      'Verlauf löschen leert den Chat erst nach Serverbestätigung',
      () async {
        final service = FakeCoachService(history: _storedChat)
          ..clearError = _network;
        final chat = CoachChatController(service: service);
        await chat.loadHistory();
        expect(await chat.clearHistory(), isFalse);
        expect(chat.entries, hasLength(2));
        expect(chat.issue?.retry, CoachRetryAction.clearHistory);

        service.clearError = null;
        expect(await chat.retry(context: const {}), isTrue);
        expect(chat.entries, isEmpty);
        expect(chat.notice, 'Dein Chatverlauf wurde gelöscht.');
        expect(service.clearCalls, 2);
      },
    );

    test('Kontext nutzt heutige Werte, nicht den geöffneten Tagebuchtag', () {
      final app = AppController(
        subscriptionRepository: const PreviewSubscriptionRepository(),
      );
      final now = DateTime.now();
      final context = coachContextFor(app, now: now);
      expect(context['calories_today'], app.consumedCalories);
      expect(context.containsKey('name'), isFalse);

      app.diaryDate = now;
      app.diaryLoading = true;
      final loading = coachContextFor(app, now: now);
      expect(loading.containsKey('calories_today'), isFalse);
      expect(loading['calorie_goal'], app.calorieGoal);
      app.dispose();
    });

    test('Kontext: pausierte Ziele, Motivation und Hürden', () {
      final app = AppController(
        subscriptionRepository: const PreviewSubscriptionRepository(),
      );
      app.personalization = const PersonalizationProfile(
        motivations: {Motivation.energy},
        obstacles: {Obstacle.cravings},
        experience: TrackingExperience.none,
        healthNotes: {HealthNote.eatingDisorder},
      );
      final context = coachContextFor(app);
      expect(context['calorie_targets_paused'], isTrue);
      expect(context.containsKey('calorie_goal'), isFalse);
      expect(context.containsKey('remaining_calories'), isFalse);
      expect(context['motivations'], ['Mehr Energie im Alltag']);
      expect(context['obstacles'], ['Heißhunger & Naschen']);
      expect(context['tracking_experience'], 'Noch nie');
      // The health reason itself never leaves the device.
      expect(context.toString(), isNot(contains('Essstörung')));
      app.dispose();
    });
  });

  group('CoachPage', () {
    testWidgets('lädt den Verlauf und zeigt Antworten formatiert', (
      tester,
    ) async {
      final service = FakeCoachService(history: _storedChat);
      await _pumpCoach(tester, service);

      expect(find.text('Was esse ich zum Frühstück?'), findsOneWidget);
      expect(find.textContaining('**'), findsNothing);
      expect(find.textContaining('Haferflocken', findRichText: true), findsOne);
      expect(find.text('50/50'), findsOneWidget);
      expect(find.byKey(const Key('coach-clear-history-inline')), findsOne);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Senden zeigt Tippen, sperrt die Eingabe und verhindert '
        'Doppelsenden', (tester) async {
      final service = FakeCoachService()..gate = Completer<void>();
      await _pumpCoach(tester, service);

      expect(_sendButton(tester).onPressed, isNull);
      await tester.enterText(find.byKey(const Key('coach-input')), 'Idee?');
      await tester.pump();
      expect(find.byKey(const Key('coach-counter')), findsOneWidget);
      expect(find.text('5/600'), findsOneWidget);

      await tester.tap(find.byKey(const Key('coach-send')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Idee?'), findsOneWidget);
      expect(find.byKey(const Key('coach-typing')), findsOneWidget);
      final input = tester.widget<TextField>(
        find.byKey(const Key('coach-input')),
      );
      expect(input.enabled, isFalse);
      expect(_sendButton(tester).onPressed, isNull);
      await tester.testTextInput.receiveAction(TextInputAction.send);
      expect(service.sent, ['Idee?']);

      service.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('coach-typing')), findsNothing);
      expect(find.text('Antwort 1', findRichText: true), findsOneWidget);
      expect(find.text('49/50'), findsOneWidget);
      expect(service.contexts.single['goal'], isNotNull);
    });

    testWidgets('Netzwerkfehler zeigt Hinweis und Erneut versuchen', (
      tester,
    ) async {
      final service = FakeCoachService()..replies.add(_network);
      await _pumpCoach(tester, service);
      await _sendText(tester, 'Hallo Coach');

      expect(find.textContaining('Internetverbindung'), findsOneWidget);
      expect(find.text('Nicht gesendet'), findsOneWidget);
      await tester.tap(find.byKey(const Key('coach-retry')));
      await tester.pumpAndSettle();

      expect(find.text('Hallo Coach'), findsOneWidget);
      expect(find.text('Nicht gesendet'), findsNothing);
      expect(find.byKey(const Key('coach-issue')), findsNothing);
      expect(find.text('Antwort 2', findRichText: true), findsOneWidget);
    });

    testWidgets('Tageslimit sperrt die Eingabe ohne Wiederholen-Knopf', (
      tester,
    ) async {
      final service = FakeCoachService()..replies.add(_limit);
      await _pumpCoach(tester, service);
      await _sendText(tester, 'Noch was?');

      expect(find.textContaining('Tageslimit von 50'), findsOneWidget);
      expect(find.byKey(const Key('coach-retry')), findsNothing);
      expect(find.text('0/50'), findsOneWidget);
      final input = tester.widget<TextField>(
        find.byKey(const Key('coach-input')),
      );
      expect(input.enabled, isFalse);
      expect(
        find.text('Tageslimit erreicht – morgen geht es weiter'),
        findsOneWidget,
      );
    });

    testWidgets('Verlauf löschen fragt nach und leert den Chat', (
      tester,
    ) async {
      final service = FakeCoachService(history: _storedChat);
      await _pumpCoach(tester, service);

      await tester.tap(find.byKey(const Key('coach-new-chat')));
      await tester.pumpAndSettle();
      expect(find.text('Neuen Chat beginnen?'), findsOneWidget);
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();
      expect(service.clearCalls, 0);

      await tester.tap(find.byKey(const Key('coach-new-chat')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('coach-confirm-clear')));
      await tester.pumpAndSettle();

      expect(service.clearCalls, 1);
      expect(find.text('Was esse ich zum Frühstück?'), findsNothing);
      expect(find.text('Dein Chatverlauf wurde gelöscht.'), findsOneWidget);
      expect(find.text('Was brauchst du heute?'), findsOneWidget);
    });

    testWidgets('Verlauf-Ladefehler bietet Erneut versuchen', (tester) async {
      final service = FakeCoachService(history: _storedChat)
        ..historyError = _network;
      await _pumpCoach(tester, service);
      expect(find.byKey(const Key('coach-retry')), findsOneWidget);

      service.historyError = null;
      await tester.tap(find.byKey(const Key('coach-retry')));
      await tester.pumpAndSettle();
      expect(find.text('Was esse ich zum Frühstück?'), findsOneWidget);
    });

    testWidgets('lange Antwort: Anfang bleibt sichtbar, kein Layoutfehler', (
      tester,
    ) async {
      final longAnswer = [
        'Erster Absatz mit dem Wichtigsten.',
        for (var i = 1; i <= 40; i++) '- Punkt $i mit einer kurzen Erklärung',
      ].join('\n');
      final service = FakeCoachService()..replies.add(longAnswer);
      await _pumpCoach(tester, service, size: const Size(320, 568));
      await _sendText(tester, 'Erklär mir alles');

      final first = find.text(
        'Erster Absatz mit dem Wichtigsten.',
        findRichText: true,
      );
      expect(first, findsOneWidget);
      final top = tester.getTopLeft(first).dy;
      final list = tester.getRect(find.byKey(const Key('coach-messages')));
      expect(top, greaterThanOrEqualTo(list.top));
      expect(top, lessThan(list.bottom));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Eingabe bleibt mit Tastatur über der Tastatur', (
      tester,
    ) async {
      final service = FakeCoachService(history: _storedChat);
      final app = await recipeTestController(plus: true);
      addTearDown(app.dispose);
      setTestScreen(tester, const Size(390, 844));
      // Same structure as the phone layout of AppShell: floating navigation
      // below an extended body.
      await tester.pumpWidget(
        recipeTestApp(
          app,
          Scaffold(
            extendBody: true,
            body: SafeArea(bottom: false, child: CoachPage(service: service)),
            bottomNavigationBar: const SizedBox(height: 90),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final withoutKeyboard = tester.getRect(
        find.byKey(const Key('coach-input')),
      );
      expect(withoutKeyboard.bottom, lessThan(844 - 90));

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      final withKeyboard = tester.getRect(find.byKey(const Key('coach-input')));
      expect(withKeyboard.bottom, lessThanOrEqualTo(844 - 300));
      expect(withKeyboard.bottom, greaterThan(844 - 300 - 90));
      expect(tester.takeException(), isNull);
    });

    testWidgets('ohne Premium: gesperrt, Verlauf trotzdem löschbar', (
      tester,
    ) async {
      final service = FakeCoachService(history: _storedChat);
      final app = AppController(
        personalizationUserId: 'user-1',
        subscriptionRepository: const PreviewSubscriptionRepository(),
      );
      await app.subscription.load();
      addTearDown(app.dispose);
      setTestScreen(tester, const Size(390, 844));
      await tester.pumpWidget(
        recipeTestApp(app, Scaffold(body: CoachPage(service: service))),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('coach-locked')), findsOneWidget);
      final delete = find.byKey(const Key('coach-locked-clear-history'));
      await tester.ensureVisible(delete);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('coach-confirm-clear')));
      await tester.pumpAndSettle();
      expect(service.clearCalls, 1);
      expect(find.text('Dein Chatverlauf wurde gelöscht.'), findsOneWidget);
    });

    testWidgets('Premium-Status nicht ladbar: Hinweis statt Paywall', (
      tester,
    ) async {
      final app = AppController(subscriptionRepository: _FailingRepository());
      await app.subscription.load();
      addTearDown(app.dispose);
      setTestScreen(tester, const Size(390, 844));
      await tester.pumpWidget(
        recipeTestApp(
          app,
          Scaffold(body: CoachPage(service: FakeCoachService())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('coach-unavailable')), findsOneWidget);
      expect(find.byKey(const Key('coach-unlock-premium')), findsNothing);
    });
  });
}

class _FailingRepository implements SubscriptionRepository {
  @override
  Future<Never> loadEntitlement() => Future.error(StateError('offline'));

  @override
  Future<Never> startTrial() => Future.error(StateError('offline'));
}

IconButton _sendButton(WidgetTester tester) =>
    tester.widget<IconButton>(find.byKey(const Key('coach-send')));

Future<void> _pumpCoach(
  WidgetTester tester,
  FakeCoachService service, {
  Size size = const Size(390, 844),
}) async {
  final app = await recipeTestController(plus: true);
  addTearDown(app.dispose);
  setTestScreen(tester, size);
  await tester.pumpWidget(
    recipeTestApp(app, Scaffold(body: CoachPage(service: service))),
  );
  await tester.pumpAndSettle();
}

Future<void> _sendText(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const Key('coach-input')), text);
  await tester.pump();
  await tester.tap(find.byKey(const Key('coach-send')));
  await tester.pumpAndSettle();
}
