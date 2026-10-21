import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/subscription/application/subscription_controller.dart';
import 'package:fitness_ai_app/features/subscription/data/store_billing.dart';
import 'package:fitness_ai_app/features/subscription/data/subscription_repository.dart';
import 'package:fitness_ai_app/features/subscription/domain/entitlement.dart';
import 'package:fitness_ai_app/features/subscription/domain/subscription_plans.dart';
import 'package:fitness_ai_app/features/subscription/presentation/paywall_page.dart';
import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The server confirms premium on the second read: the first read happens
/// when the paywall loads, the second one after the store purchase.
class _Server implements SubscriptionRepository {
  int loads = 0;

  @override
  Future<Entitlement> loadEntitlement() async {
    loads++;
    return loads > 1
        ? Entitlement.subscription(
            expiresAt: DateTime.now().add(const Duration(days: 30)),
          )
        : const Entitlement.free();
  }
}

class _Billing implements StoreBilling {
  _Billing(this.result);

  final StorePurchaseStatus result;

  @override
  bool get isAvailable => true;

  @override
  Future<void> bindAccount(String? userId) async {}

  @override
  Future<StorePurchaseStatus> purchase(PremiumPlanId plan) async => result;

  @override
  Future<StorePurchaseStatus> restore() async => result;

  @override
  Future<int> freeTrialDays(PremiumPlanId plan) async => 0;

  @override
  Uri? managementUri() => null;
}

SubscriptionController _controller() => SubscriptionController(
  repository: _Server(),
  billing: _Billing(StorePurchaseStatus.purchased),
  confirmDelay: Duration.zero,
  confirmAttempts: 4,
);

Future<void> _pump(
  WidgetTester tester,
  SubscriptionController controller, {
  required VoidCallback onClose,
  Locale locale = const Locale('de'),
  Size size = const Size(390, 844),
  double textScale = 1,
  bool reducedMotion = false,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  L10n.use(locale);
  await controller.load();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark,
      locale: locale,
      supportedLocales: L10n.supported,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reducedMotion,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: PaywallPage(subscription: controller, onClose: onClose),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _buySelected(WidgetTester tester) async {
  final immediateStart = find.byKey(const Key('paywall-immediate-start'));
  await tester.ensureVisible(immediateStart);
  await tester.pumpAndSettle();
  await tester.tap(immediateStart);
  await tester.pumpAndSettle();
  final button = find.byKey(const Key('paywall-purchase'));
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => L10n.use(L10n.german));

  testWidgets('Kauf: Willkommens-Ansicht mit Karte und freigeschalteten '
      'Vorteilen', (tester) async {
    var closed = 0;
    final controller = _controller();
    addTearDown(controller.dispose);
    await _pump(tester, controller, onClose: () => closed++);

    await _buySelected(tester);

    expect(controller.hasPremium, isTrue);
    expect(find.byKey(const ValueKey('paywall-success')), findsOneWidget);
    // The title appears word by word.
    for (final word in ['Willkommen', 'bei', 'Lookin', 'Premium']) {
      expect(find.text(word), findsWidgets);
    }
    final subtitle = tester.widget<Text>(
      find.byKey(const Key('paywall-success-subtitle')),
    );
    expect(subtitle.data, contains('Danke für deine Unterstützung'));

    // Membership card: plan (yearly is preselected) and next renewal.
    final plan = tester.widget<Text>(
      find.byKey(const Key('premium-welcome-plan')),
    );
    expect(plan.data, contains('Jährlich'));
    expect(plan.data, contains('49,99'));
    final label = tester.widget<Text>(
      find.byKey(const Key('premium-welcome-footer-label')),
    );
    expect(label.data, 'Nächste Verlängerung');
    final value = tester.widget<Text>(
      find.byKey(const Key('premium-welcome-footer-value')),
    );
    expect(value.data, matches(RegExp(r'\d{2}\.\d{2}\.\d{4}')));
    expect(
      tester.widget<Text>(find.byKey(const Key('premium-welcome-member'))).data,
      'Premium-Mitglied',
    );

    // All three benefits are unlocked at the end; the coach count reached
    // its limit.
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(3));
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
    expect(find.textContaining('bis zu 100 Fragen pro Tag'), findsOneWidget);

    // The page stays open until the person continues.
    expect(closed, 0);
    expect(find.byType(SnackBar), findsNothing);

    // Tapping the mark throws confetti again; dragging the card tilts it and
    // it comes back; neither changes anything else.
    await tester.tap(find.byKey(const Key('premium-welcome-mark')));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('premium-welcome-card')),
      const Offset(120, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('premium-welcome-card')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final continueButton = find.byKey(const Key('paywall-success-continue'));
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(closed, 1);
  });

  testWidgets('Englisch bei 320 px und großer Schrift ohne Überlauf', (
    tester,
  ) async {
    final controller = _controller();
    addTearDown(controller.dispose);
    await _pump(
      tester,
      controller,
      onClose: () {},
      locale: L10n.english,
      size: const Size(320, 568),
      textScale: 1.6,
    );

    await _buySelected(tester);

    expect(find.text('Welcome'), findsWidgets);
    final subtitle = tester.widget<Text>(
      find.byKey(const Key('paywall-success-subtitle')),
    );
    expect(subtitle.data, contains('Thank you for your support'));
    expect(
      tester
          .widget<Text>(find.byKey(const Key('premium-welcome-footer-label')))
          .data,
      'Next renewal',
    );
    expect(find.textContaining('up to 100 questions a day'), findsOneWidget);
    final button = find.byKey(const Key('paywall-success-continue'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    expect(button, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bewegung reduzieren: alles sofort sichtbar, ohne Konfetti', (
    tester,
  ) async {
    final controller = _controller();
    addTearDown(controller.dispose);
    await _pump(tester, controller, onClose: () {}, reducedMotion: true);

    await _buySelected(tester);

    final title = tester.widget<Opacity>(
      find
          .ancestor(of: find.text('Willkommen'), matching: find.byType(Opacity))
          .first,
    );
    expect(title.opacity, 1);
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(3));
    expect(find.byKey(const Key('paywall-success-continue')), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('die Animation ist endlich und läuft nicht dauerhaft weiter', (
    tester,
  ) async {
    final controller = _controller();
    addTearDown(controller.dispose);
    await _pump(tester, controller, onClose: () {});

    await _buySelected(tester);
    await tester.pump(const Duration(seconds: 8));

    expect(tester.hasRunningAnimations, isFalse);
  });
}
