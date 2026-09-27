import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/subscription/application/subscription_controller.dart';
import 'package:fitness_ai_app/features/subscription/data/subscription_repository.dart';
import 'package:fitness_ai_app/features/subscription/domain/entitlement.dart';
import 'package:fitness_ai_app/features/subscription/domain/subscription_plans.dart';
import 'package:fitness_ai_app/features/subscription/presentation/paywall_page.dart';
import 'package:fitness_ai_app/features/subscription/presentation/premium_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _nbsp = ' ';

/// Signed-in account that has not used the free trial yet. No network.
class _TrialAvailableRepository implements SubscriptionRepository {
  const _TrialAvailableRepository();

  @override
  Future<Entitlement> loadEntitlement() async =>
      const Entitlement.free(trialUsed: false);

  @override
  Future<TrialStartResult> startTrial() async =>
      const TrialStartResult(TrialStartStatus.notConfigured);
}

PremiumPlan _yearlyPlan(int chargeCents) => PremiumPlan(
  id: PremiumPlanId.yearly,
  storeProductId: 'test_yearly',
  billingPeriodMonths: 12,
  chargeCents: chargeCents,
);

void main() {
  group('SubscriptionPlans', () {
    test('the free trial lasts seven days', () {
      expect(SubscriptionPlans.trialDays, 7);
      expect(PremiumCopy.trialCta, '7 Tage kostenlos testen');
    });

    test('flat prices are stored as the charge per billing period', () {
      expect(SubscriptionPlans.monthly.billingPeriodMonths, 1);
      expect(SubscriptionPlans.monthly.chargeCents, 499);
      expect(SubscriptionPlans.yearly.billingPeriodMonths, 12);
      expect(SubscriptionPlans.yearly.isYearly, isTrue);
      expect(SubscriptionPlans.yearly.chargeCents, 4988);
      expect(SubscriptionPlans.all.first.id, SubscriptionPlans.recommended);
      expect(SubscriptionPlans.storeBillingAvailable, isFalse);
    });

    test('the monthly equivalent is rounded up to whole cents', () {
      // 4988 / 12 = 415,67 cents -> 4,16 €, never below the real cost.
      expect(SubscriptionPlans.yearly.monthlyEquivalentCents, 416);
      expect(
        SubscriptionPlans.yearly.monthlyEquivalentCents * 12,
        greaterThanOrEqualTo(SubscriptionPlans.yearly.chargeCents),
      );
      expect(SubscriptionPlans.monthly.monthlyEquivalentCents, 499);
      expect(_yearlyPlan(4800).monthlyEquivalentCents, 400);
      expect(_yearlyPlan(4801).monthlyEquivalentCents, 401);
      expect(_yearlyPlan(4811).monthlyEquivalentCents, 401);
    });

    test('the yearly saving is derived from twelve monthly charges', () {
      expect(SubscriptionPlans.monthlyPlanYearCents, 5988);
      expect(SubscriptionPlans.yearlySavingsCents, 1000);
      // 1000 / 5988 = 16,7 % -> 17 %.
      expect(SubscriptionPlans.yearlySavingsPercent, 17);
    });
  });

  group('PremiumCopy', () {
    test('formats euro amounts in German', () {
      expect(formatEuro(4988), '49,88$_nbsp€');
      expect(formatEuro(499), '4,99$_nbsp€');
      expect(formatEuro(416), '4,16$_nbsp€');
      expect(formatEuro(123456), '1.234,56$_nbsp€');
    });

    test('names flat prices without introductory offers', () {
      const yearly = SubscriptionPlans.yearly;
      const monthly = SubscriptionPlans.monthly;
      expect(PremiumCopy.headlinePrice(yearly), '49,88$_nbsp€');
      expect(PremiumCopy.headlineUnit(yearly), 'pro Jahr');
      expect(
        PremiumCopy.priceDetail(yearly),
        'entspricht 4,16$_nbsp€ pro Monat',
      );
      expect(
        PremiumCopy.billingNote(yearly),
        'einmal im Jahr berechnet – du sparst 10,00$_nbsp€ gegenüber '
        'monatlich',
      );
      expect(
        PremiumCopy.purchaseSummary(yearly),
        '49,88$_nbsp€ pro Jahr (entspricht 4,16$_nbsp€ pro Monat)',
      );

      expect(PremiumCopy.headlinePrice(monthly), '4,99$_nbsp€');
      expect(PremiumCopy.headlineUnit(monthly), 'pro Monat');
      expect(PremiumCopy.priceDetail(monthly), 'monatlich kündbar');
      expect(PremiumCopy.billingNote(monthly), 'jeden Monat berechnet');
      expect(
        PremiumCopy.purchaseSummary(monthly),
        '4,99$_nbsp€ pro Monat (monatlich kündbar)',
      );

      final terms = PremiumCopy.priceTerms;
      expect(terms, contains('Jährlich 49,88$_nbsp€ pro Jahr'));
      expect(terms, contains('Monatlich 4,99$_nbsp€ pro Monat'));
      expect(terms, contains('zum selben Preis'));
      for (final old in ['7,99', '5,99', '71,88', '65,88', '3,99', '5,49']) {
        expect(terms, isNot(contains(old)));
      }
      expect(terms, isNot(contains('danach')));
      expect(terms, isNot(contains('ersten')));
    });
  });

  testWidgets('paywall shows flat prices, saving and the seven-day trial', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    final subscription = SubscriptionController(
      repository: const _TrialAvailableRepository(),
    );
    addTearDown(subscription.dispose);
    await subscription.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: PaywallPage(subscription: subscription, onClose: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('7 Tage kostenlos testen'), findsOneWidget);
    expect(find.text('Beliebt · −17$_nbsp%'), findsOneWidget);
    expect(find.text('49,88$_nbsp€'), findsOneWidget);
    expect(find.text('pro Jahr'), findsOneWidget);
    expect(find.text('entspricht 4,16$_nbsp€ pro Monat'), findsOneWidget);
    expect(
      find.text(
        'einmal im Jahr berechnet – du sparst 10,00$_nbsp€ gegenüber '
        'monatlich',
      ),
      findsOneWidget,
    );
    expect(find.text('4,99$_nbsp€'), findsOneWidget);
    expect(find.text('pro Monat'), findsOneWidget);
    expect(find.text('monatlich kündbar'), findsOneWidget);
    expect(
      find.text('49,88$_nbsp€ pro Jahr (entspricht 4,16$_nbsp€ pro Monat)'),
      findsOneWidget,
    );
    expect(find.textContaining('Kostenlose Testphase: 7 Tage'), findsOneWidget);
    for (final old in ['7,99', '71,88', '65,88', '5,49', 'im 1. Jahr']) {
      expect(find.textContaining(old), findsNothing, reason: old);
    }

    final monthlyCard = find.byKey(const ValueKey('paywall-plan-monthly'));
    await tester.ensureVisible(monthlyCard);
    await tester.pumpAndSettle();
    await tester.tap(monthlyCard);
    await tester.pumpAndSettle();

    expect(
      find.text('4,99$_nbsp€ pro Monat (monatlich kündbar)'),
      findsOneWidget,
    );
    expect(find.text('Monatlich abonnieren'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('paywall prices fit a 320 px screen with doubled text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final subscription = SubscriptionController(
      repository: const _TrialAvailableRepository(),
    );
    addTearDown(subscription.dispose);
    await subscription.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: PaywallPage(subscription: subscription, onClose: () {}),
      ),
    );
    await tester.pumpAndSettle();

    final yearlyCard = find.byKey(const ValueKey('paywall-plan-yearly'));
    await tester.ensureVisible(yearlyCard);
    await tester.pumpAndSettle();
    expect(find.text('entspricht 4,16$_nbsp€ pro Monat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
