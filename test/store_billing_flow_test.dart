import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/subscription/application/subscription_controller.dart';
import 'package:fitness_ai_app/features/subscription/data/store_billing.dart';
import 'package:fitness_ai_app/features/subscription/data/subscription_repository.dart';
import 'package:fitness_ai_app/features/subscription/domain/entitlement.dart';
import 'package:fitness_ai_app/features/subscription/domain/subscription_plans.dart';
import 'package:fitness_ai_app/features/subscription/presentation/paywall_page.dart';
import 'package:fitness_ai_app/features/subscription/presentation/premium_format.dart';

/// Server that learns about the purchase only after [premiumAfterLoads]
/// reads, like a webhook that arrives a moment after the store confirmed.
class _LaggingServer implements SubscriptionRepository {
  _LaggingServer({this.premiumAfterLoads = 1});

  final int premiumAfterLoads;
  int loads = 0;

  @override
  Future<Entitlement> loadEntitlement() async {
    loads++;
    return loads > premiumAfterLoads
        ? Entitlement.subscription(
            expiresAt: DateTime.now().add(const Duration(days: 30)),
          )
        : const Entitlement.free(trialUsed: false);
  }

  @override
  Future<TrialStartResult> startTrial() async =>
      const TrialStartResult(TrialStartStatus.notConfigured);
}

class _FakeBilling implements StoreBilling {
  _FakeBilling(this.result, {this.available = true});

  final StorePurchaseStatus result;
  final bool available;
  final purchased = <PremiumPlanId>[];
  int restores = 0;

  @override
  bool get isAvailable => available;

  @override
  Future<void> bindAccount(String? userId) async {}

  @override
  Future<StorePurchaseStatus> purchase(PremiumPlanId plan) async {
    purchased.add(plan);
    return result;
  }

  @override
  Future<StorePurchaseStatus> restore() async {
    restores++;
    return result;
  }

  @override
  Uri? managementUri() => Uri.https('play.google.com', '/store/account');
}

SubscriptionController _controller(
  SubscriptionRepository repository,
  StoreBilling billing, {
  int attempts = 4,
}) => SubscriptionController(
  repository: repository,
  billing: billing,
  confirmDelay: Duration.zero,
  confirmAttempts: attempts,
);

void main() {
  group('store purchase flow', () {
    test('premium is reported only after the server confirms it', () async {
      final server = _LaggingServer(premiumAfterLoads: 2);
      final billing = _FakeBilling(StorePurchaseStatus.purchased);
      final controller = _controller(server, billing);
      addTearDown(controller.dispose);

      expect(controller.hasPremium, isFalse);
      final outcome = await controller.purchase(PremiumPlanId.yearly);

      expect(outcome, PurchaseOutcome.active);
      expect(billing.purchased, [PremiumPlanId.yearly]);
      expect(server.loads, 3);
      expect(controller.hasPremium, isTrue);
      expect(controller.isPurchasing, isFalse);
    });

    test('a slow webhook ends as activating, not as failure', () async {
      final controller = _controller(
        _LaggingServer(premiumAfterLoads: 99),
        _FakeBilling(StorePurchaseStatus.purchased),
        attempts: 3,
      );
      addTearDown(controller.dispose);

      final outcome = await controller.purchase(PremiumPlanId.monthly);

      expect(outcome, PurchaseOutcome.activating);
      expect(controller.hasPremium, isFalse);
    });

    test('cancel, pending and missing store never unlock anything', () async {
      for (final (status, expected) in [
        (StorePurchaseStatus.cancelled, PurchaseOutcome.cancelled),
        (StorePurchaseStatus.pending, PurchaseOutcome.pending),
        (StorePurchaseStatus.unavailable, PurchaseOutcome.unavailable),
        (
          StorePurchaseStatus.nothingToRestore,
          PurchaseOutcome.nothingToRestore,
        ),
      ]) {
        final server = _LaggingServer(premiumAfterLoads: 0);
        final controller = _controller(server, _FakeBilling(status));
        addTearDown(controller.dispose);

        expect(await controller.purchase(PremiumPlanId.yearly), expected);
        expect(server.loads, 0, reason: 'no server read without a purchase');
        expect(controller.hasPremium, isFalse);
      }
    });

    test('restore uses the same server confirmation', () async {
      final billing = _FakeBilling(StorePurchaseStatus.purchased);
      final controller = _controller(_LaggingServer(), billing);
      addTearDown(controller.dispose);

      expect(await controller.restore(), PurchaseOutcome.active);
      expect(billing.restores, 1);
      expect(controller.hasPremium, isTrue);
    });

    test('a second tap while purchasing joins the running purchase', () async {
      final billing = _FakeBilling(StorePurchaseStatus.cancelled);
      final controller = _controller(_LaggingServer(), billing);
      addTearDown(controller.dispose);

      final first = controller.purchase(PremiumPlanId.yearly);
      final second = controller.purchase(PremiumPlanId.monthly);
      expect(controller.isPurchasing, isTrue);
      await Future.wait([first, second]);

      expect(billing.purchased, [PremiumPlanId.yearly]);
    });

    test('the default stub reports billing as unavailable', () async {
      final controller = SubscriptionController(repository: _LaggingServer());
      addTearDown(controller.dispose);

      expect(controller.storeBillingAvailable, isFalse);
      expect(
        await controller.purchase(PremiumPlanId.yearly),
        PurchaseOutcome.unavailable,
      );
      expect(controller.managementUri, isNull);
    });
  });

  group('outcome messages', () {
    test('every outcome has a message and none claims a charge', () {
      for (final outcome in PurchaseOutcome.values) {
        final message = PremiumCopy.purchaseOutcomeMessage(outcome);
        expect(message, isNotEmpty);
        expect(message.toLowerCase(), isNot(contains('berechnet wurde')));
      }
      expect(
        PremiumCopy.purchaseOutcomeMessage(PurchaseOutcome.cancelled),
        contains('nichts berechnet'),
      );
    });

    test(
      'terms name the store and the cancellation path when billing works',
      () {
        final working = PremiumCopy.priceTermsFor(billingAvailable: true);
        expect(working, contains('Abo-Einstellungen'));
        expect(working, contains('Google Play'));
        expect(working, isNot(contains(PremiumCopy.billingPending)));
        expect(
          PremiumCopy.priceTermsFor(billingAvailable: false),
          contains(PremiumCopy.billingPending),
        );
      },
    );
  });

  group('paywall with working billing', () {
    Future<SubscriptionController> pump(
      WidgetTester tester,
      StoreBilling billing,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.reset);
      final controller = _controller(
        _LaggingServer(premiumAfterLoads: 99),
        billing,
      );
      addTearDown(controller.dispose);
      await controller.load();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: PaywallPage(subscription: controller, onClose: () {}),
        ),
      );
      await tester.pumpAndSettle();
      return controller;
    }

    testWidgets('purchase starts the selected plan in the store', (
      tester,
    ) async {
      final billing = _FakeBilling(StorePurchaseStatus.cancelled);
      await pump(tester, billing);

      final button = find.byKey(const Key('paywall-purchase'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(billing.purchased, [SubscriptionPlans.recommended]);
      expect(
        find.text(
          PremiumCopy.purchaseOutcomeMessage(PurchaseOutcome.cancelled),
        ),
        findsOneWidget,
      );
      expect(find.text(PremiumCopy.billingPending), findsNothing);
    });

    testWidgets('restore and manage are offered; the soon tag is gone', (
      tester,
    ) async {
      final billing = _FakeBilling(StorePurchaseStatus.nothingToRestore);
      await pump(tester, billing);

      final restore = find.byKey(const Key('paywall-restore'));
      await tester.ensureVisible(restore);
      await tester.pumpAndSettle();
      expect(find.text('Käufe wiederherstellen'), findsOneWidget);
      expect(find.byKey(const Key('paywall-manage')), findsOneWidget);
      expect(find.textContaining('bald verfügbar'), findsNothing);

      await tester.tap(restore);
      await tester.pumpAndSettle();
      expect(billing.restores, 1);
      expect(
        find.text(
          PremiumCopy.purchaseOutcomeMessage(PurchaseOutcome.nothingToRestore),
        ),
        findsOneWidget,
      );
    });

    testWidgets('without billing nothing is bought and the paywall says so', (
      tester,
    ) async {
      final billing = _FakeBilling(
        StorePurchaseStatus.purchased,
        available: false,
      );
      await pump(tester, billing);

      final button = find.byKey(const Key('paywall-purchase'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(billing.purchased, isEmpty);
      expect(find.text(PremiumCopy.unavailableMessage), findsOneWidget);
    });
  });
}
