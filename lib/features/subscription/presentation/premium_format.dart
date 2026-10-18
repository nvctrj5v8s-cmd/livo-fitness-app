import 'package:fitness_ai_app/l10n/l10n.dart';
import 'package:flutter/foundation.dart';

import '../application/subscription_controller.dart';
import '../domain/subscription_plans.dart';

const _nbsp = ' ';

/// German price format: `49,99 €`. The non-breaking space keeps the amount
/// and currency on one line.
String formatEuro(int cents) {
  if (L10n.isEnglish) return AppFormat.euro(cents);
  final euros = (cents ~/ 100).toString();
  final rest = (cents % 100).toString().padLeft(2, '0');
  final grouped = StringBuffer();
  for (var i = 0; i < euros.length; i++) {
    if (i > 0 && (euros.length - i) % 3 == 0) grouped.write('.');
    grouped.write(euros[i]);
  }
  return '$grouped,$rest$_nbsp€';
}

String _two(int value) => value.toString().padLeft(2, '0');

/// `29.09.2026, 14:30 Uhr` in local time.
String formatPremiumDateTime(DateTime value) {
  if (L10n.isEnglish) return AppFormat.dateTime(value);
  final local = value.toLocal();
  return '${_two(local.day)}.${_two(local.month)}.${local.year}, '
      '${_two(local.hour)}:${_two(local.minute)}${_nbsp}Uhr';
}

/// `29.09.` in local time.
String formatPremiumShortDate(DateTime value) {
  if (L10n.isEnglish) return AppFormat.dayMonth(value);
  final local = value.toLocal();
  return '${_two(local.day)}.${_two(local.month)}.';
}

/// Shared, honest copy so every surface names the same facts.
abstract final class PremiumCopy {
  static String get freeRecipes =>
      L10n.current.subscriptionWithoutASubscriptionValueValueOfRecipes(
        (SubscriptionPlans.freeRecipeSharePercent).toString(),
        (_nbsp).toString(),
      );
  static String get premiumRecipes =>
      L10n.current.subscriptionWithPremiumAllRecipes;

  static String get trialCta => L10n.current.subscriptionValueDayFreeTrial(
    (SubscriptionPlans.trialDays).toString(),
  );
  static String get trialPromise =>
      L10n.current.subscriptionEndsAutomaticallyNoPaymentDetailsNeededNo;
  static String get billingPending =>
      L10n.current.subscriptionPaymentsAreBeingSetUp;

  static String planTitle(PremiumPlan plan) => plan.isYearly
      ? L10n.current.subscriptionYearly
      : L10n.current.subscriptionMonthly;

  static String purchaseLabel(PremiumPlan plan) => plan.isYearly
      ? L10n.current.subscriptionSubscribeYearly
      : L10n.current.subscriptionSubscribeMonthly;

  /// Big amount that is charged per billing period.
  static String headlinePrice(PremiumPlan plan) => formatEuro(plan.chargeCents);

  /// Unit next to the charged amount.
  static String headlineUnit(PremiumPlan plan) => plan.isYearly
      ? L10n.current.subscriptionPerYear
      : L10n.current.subscriptionPerMonth;

  /// Small line directly below the charged amount.
  static String priceDetail(PremiumPlan plan) => plan.isYearly
      ? L10n.current.subscriptionEquivalentToValuePerMonth(
          (formatEuro(plan.monthlyEquivalentCents)).toString(),
        )
      : L10n.current.subscriptionCancelMonthly;

  /// How often the plan is charged, always visible below the price.
  static String billingNote(PremiumPlan plan) => plan.isYearly
      ? L10n.current.subscriptionBilledOnceAYearSaveValueCompared(
          (formatEuro(SubscriptionPlans.yearlySavingsCents)).toString(),
        )
      : L10n.current.subscriptionBilledEveryMonth;

  /// Short price summary shown in purchase buttons.
  static String purchaseSummary(PremiumPlan plan) =>
      '${headlinePrice(plan)} ${headlineUnit(plan)} (${priceDetail(plan)})';

  /// Price paragraph of the paywall terms while no purchase is possible.
  static String get priceTerms => priceTermsFor(billingAvailable: false);

  /// Price paragraph of the paywall terms. With working store billing it
  /// also names who bills and where the subscription is cancelled.
  static String priceTermsFor({required bool billingAvailable}) {
    const yearly = SubscriptionPlans.yearly;
    const monthly = SubscriptionPlans.monthly;
    final prices = L10n.current.subscriptionYearlyValueValueBilledOnceAYear(
      (headlinePrice(yearly)).toString(),
      (headlineUnit(yearly)).toString(),
      (priceDetail(yearly)).toString(),
      (headlinePrice(monthly)).toString(),
      (headlineUnit(monthly)).toString(),
    );
    if (!billingAvailable) {
      return L10n.current
          .subscriptionSubscriptionPricesValueValueASubscriptionRenews(
            (billingPending).toString(),
            (prices).toString(),
          );
    }
    return L10n.current.subscriptionSubscriptionPricesValuePaymentAndBillingAre(
      (prices).toString(),
      (_storeName).toString(),
      (_storeName).toString(),
    );
  }

  static String get _storeName =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
      ? L10n.current.subscriptionTheAppStore
      : 'Google Play';

  /// Shown under the purchase button when billing works.
  /// One line under the purchase button: who bills, renewal, how to cancel.
  static String get termsShort =>
      L10n.current.subscriptionTermsShort(_storeName);

  static String get storeNote =>
      L10n.current.subscriptionPaymentIsHandledSecurelyByTheStore;

  /// Shown under the purchase button when nothing can be bought here.
  static String get unavailableNote => kIsWeb
      ? L10n.current.subscriptionSubscribeInTheLookinAppForAndroid
      : L10n.current.subscriptionValueUntilThenNothingIsPurchasedOr(
          (billingPending).toString(),
        );

  static String get unavailableMessage => kIsWeb
      ? L10n.current.subscriptionSubscriptionsAreAvailableInTheLookinApp(
          (SubscriptionPlans.trialDays).toString(),
        )
      : L10n.current.subscriptionValueNothingWasPurchasedOrChargedTry(
          (billingPending).toString(),
          (SubscriptionPlans.trialDays).toString(),
        );

  static String get restoreUnavailableMessage =>
      L10n.current.subscriptionRestoringPurchasesIsOnlyAvailableInThe;

  static String get immediateStartNotStored =>
      L10n.current.subscriptionYourConsentCouldNotBeSavedJust;

  static String get immediateStartRequired =>
      L10n.current.subscriptionPleaseConfirmFirstThatLookinPremiumShould;

  static String get manageFailedMessage =>
      L10n.current.subscriptionSubscriptionManagementCouldNotBeOpenedOpen;

  /// What the user reads after a purchase or restore attempt.
  static String purchaseOutcomeMessage(PurchaseOutcome outcome) =>
      switch (outcome) {
        PurchaseOutcome.active =>
          L10n.current.subscriptionPremiumIsActiveThankYouForYour,
        PurchaseOutcome.activating =>
          L10n.current.subscriptionYourPurchaseHasBeenReceivedActivationIs,
        PurchaseOutcome.cancelled =>
          L10n.current.subscriptionPurchaseCancelledNothingWasCharged,
        PurchaseOutcome.pending =>
          L10n.current.subscriptionYourPaymentIsStillBeingReviewedPremium,
        PurchaseOutcome.nothingToRestore =>
          L10n.current.subscriptionNoActiveSubscriptionWasFoundForThis,
        PurchaseOutcome.unavailable =>
          L10n.current.subscriptionTheStoreIsCurrentlyUnavailableNothingWas,
      };
}
