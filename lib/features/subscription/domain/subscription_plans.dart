import 'dart:math' as math;

/// Identifies one of the LIVO Premium subscription plans.
enum PremiumPlanId { yearly, monthly }

/// A LIVO Premium plan. All amounts are gross prices in euro cents incl. VAT;
/// formatting happens only in the UI.
class PremiumPlan {
  const PremiumPlan({
    required this.id,
    required this.storeProductId,
    required this.billingPeriodMonths,
    required this.monthlyPriceCents,
    required this.introMonthlyPriceCents,
    required this.introMonths,
  });

  final PremiumPlanId id;

  /// Planned App Store / Google Play product ID. Not connected yet.
  final String storeProductId;

  /// 1 = billed monthly, 12 = billed once per year.
  final int billingPeriodMonths;

  /// Regular price per month after the introductory offer.
  final int monthlyPriceCents;

  /// Price per month during the introductory offer.
  final int introMonthlyPriceCents;

  /// Number of months the introductory price applies.
  final int introMonths;

  bool get isYearly => billingPeriodMonths == 12;

  bool get hasIntroOffer =>
      introMonths > 0 && introMonthlyPriceCents < monthlyPriceCents;

  /// Amount charged per billing period at the regular price
  /// (7,99 € per month or 71,88 € per year).
  int get regularChargeCents => monthlyPriceCents * billingPeriodMonths;

  /// Amount actually charged for the first billing period including the
  /// introductory offer (monthly: 4,99 € in each of the first months,
  /// yearly: 65,88 € for the first year).
  int get firstChargeCents {
    if (!hasIntroOffer) return regularChargeCents;
    if (billingPeriodMonths == 1) return introMonthlyPriceCents;
    final discounted = math.min(introMonths, billingPeriodMonths);
    return introMonthlyPriceCents * discounted +
        monthlyPriceCents * (billingPeriodMonths - discounted);
  }

  /// Average monthly price in the first billing period (yearly: 5,49 €).
  int get firstPeriodMonthlyCents =>
      (firstChargeCents / billingPeriodMonths).round();
}

/// The single place for LIVO Premium prices and plan facts. Change prices
/// here; the paywall, profile and tests read them from this class.
abstract final class SubscriptionPlans {
  static const productName = 'LIVO Premium';

  /// Free, app-controlled trial. No payment data, ends automatically and can
  /// be used once per account (see `0008_premium_trial.sql`).
  static const trialDays = 3;

  /// Share of the recipe catalog marked `access_level = 'free'`. The catalog
  /// grows, so the UI names the share, never a fixed number of recipes.
  static const freeRecipeSharePercent = 30;

  static const yearly = PremiumPlan(
    id: PremiumPlanId.yearly,
    storeProductId: 'livo_premium_yearly',
    billingPeriodMonths: 12,
    monthlyPriceCents: 599,
    introMonthlyPriceCents: 399,
    introMonths: 3,
  );

  static const monthly = PremiumPlan(
    id: PremiumPlanId.monthly,
    storeProductId: 'livo_premium_monthly',
    billingPeriodMonths: 1,
    monthlyPriceCents: 799,
    introMonthlyPriceCents: 499,
    introMonths: 3,
  );

  /// Display order; the recommended plan comes first.
  static const all = [yearly, monthly];

  static const recommended = PremiumPlanId.yearly;

  static PremiumPlan byId(PremiumPlanId id) =>
      all.firstWhere((plan) => plan.id == id);

  /// Regular yearly price per month compared with the regular monthly price.
  static int get yearlySavingsPercent =>
      ((1 - yearly.monthlyPriceCents / monthly.monthlyPriceCents) * 100)
          .round();

  /// Store billing (Apple, Google or Stripe) is not connected yet. Purchase
  /// buttons must say so instead of pretending a purchase.
  static const storeBillingAvailable = false;

  // TODO(legal): Add the final privacy policy and terms URLs before billing
  // goes live. No placeholder URLs are invented here.
  static const String? privacyPolicyUrl = null;
  static const String? termsUrl = null;
}
