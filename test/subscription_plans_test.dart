import 'package:fitness_ai_app/core/theme/app_theme.dart';
import 'package:fitness_ai_app/features/subscription/application/subscription_controller.dart';
import 'package:fitness_ai_app/features/subscription/data/subscription_repository.dart';
import 'package:fitness_ai_app/features/subscription/domain/entitlement.dart';
import 'package:fitness_ai_app/features/subscription/domain/subscription_plans.dart';
import 'package:fitness_ai_app/features/subscription/presentation/paywall_page.dart';
import 'package:fitness_ai_app/features/subscription/presentation/premium_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _nbsp = ' ';

/// Signed-in account that has not used the free trial yet. No network.
class _TrialAvailableRepository implements SubscriptionRepository {
  const _TrialAvailableRepository();

  @override
  Future<Entitlement> loadEntitlement() async => const Entitlement.free();
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
    });

    test('flat prices are stored as the charge per billing period', () {
      expect(SubscriptionPlans.monthly.billingPeriodMonths, 1);
      expect(SubscriptionPlans.monthly.chargeCents, 699);
      expect(SubscriptionPlans.yearly.billingPeriodMonths, 12);
      expect(SubscriptionPlans.yearly.isYearly, isTrue);
      expect(SubscriptionPlans.yearly.chargeCents, 4999);
      expect(SubscriptionPlans.all.first.id, SubscriptionPlans.recommended);
    });

    test('the monthly equivalent is rounded up to whole cents', () {
      // 4999 / 12 = 416,58 cents -> 4,17 €, never below the real cost.
      expect(SubscriptionPlans.yearly.monthlyEquivalentCents, 417);
      expect(
        SubscriptionPlans.yearly.monthlyEquivalentCents * 12,
        greaterThanOrEqualTo(SubscriptionPlans.yearly.chargeCents),
      );
      expect(SubscriptionPlans.monthly.monthlyEquivalentCents, 699);
      expect(_yearlyPlan(4800).monthlyEquivalentCents, 400);
      expect(_yearlyPlan(4801).monthlyEquivalentCents, 401);
      expect(_yearlyPlan(4811).monthlyEquivalentCents, 401);
    });

    test('the yearly saving is derived from twelve monthly charges', () {
      expect(SubscriptionPlans.monthlyPlanYearCents, 8388);
      expect(SubscriptionPlans.yearlySavingsCents, 3389);
      // 3389 / 8388 = 40,4 % -> 40 %.
      expect(SubscriptionPlans.yearlySavingsPercent, 40);
    });
  });

  group('PremiumCopy', () {
    test('formats euro amounts in German', () {
      expect(formatEuro(4999), '49,99$_nbsp€');
      expect(formatEuro(699), '6,99$_nbsp€');
      expect(formatEuro(417), '4,17$_nbsp€');
      expect(formatEuro(123456), '1.234,56$_nbsp€');
    });

    test('uses store prices and never invents a fallback', () {
      const yearly = SubscriptionPlans.yearly;
      const monthly = SubscriptionPlans.monthly;
      expect(
        PremiumCopy.headlinePrice(yearly),
        'Preis aktuell nicht verfügbar',
      );
      expect(
        PremiumCopy.headlinePrice(yearly, storePrice: r'$59.99'),
        r'$59.99',
      );
      expect(
        PremiumCopy.purchaseSummary(monthly, storePrice: r'$7.99'),
        r'$7.99 pro Monat',
      );
      final terms = PremiumCopy.priceTermsFor(
        billingAvailable: true,
        yearlyPrice: r'$59.99',
        monthlyPrice: r'$7.99',
      );
      expect(terms, contains(r'$59.99'));
      expect(terms, contains(r'$7.99'));
      expect(terms, isNot(contains('49,99')));
    });
  });
  testWidgets('paywall shows flat prices and saving', (tester) async {
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

    // No store connection: do not show invented prices.
    expect(find.textContaining('kostenlos testen'), findsNothing);
    expect(find.text('Preis aktuell nicht verfügbar'), findsWidgets);
    expect(find.textContaining('49,99'), findsNothing);
    expect(find.textContaining('6,99'), findsNothing);
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
    expect(find.text('Preis aktuell nicht verfügbar'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('store wording follows the platform', () {
    expect(PremiumCopy.storeName, 'Google Play');
    expect(PremiumCopy.storeAccount, 'Google-Konto');
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    expect(PremiumCopy.storeName, 'dem App Store');
    expect(PremiumCopy.storeNameVia, 'den App Store');
    expect(PremiumCopy.storeAccount, 'Apple Account');
    expect(PremiumCopy.termsShortFor(trialDays: 7), contains('dem App Store'));
    expect(
      PremiumCopy.priceTermsFor(billingAvailable: true),
      contains('über den App Store'),
    );
    debugDefaultTargetPlatformOverride = null;
  });
}
