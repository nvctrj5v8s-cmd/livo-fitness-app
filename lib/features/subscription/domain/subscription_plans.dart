/// Identifies one of the Lookin Premium subscription plans.
enum PremiumPlanId { yearly, monthly }

/// A Lookin Premium plan with one flat price. All amounts are gross prices in
/// euro cents incl. VAT; formatting happens only in the UI.
class PremiumPlan {
  const PremiumPlan({
    required this.id,
    required this.storeProductId,
    required this.billingPeriodMonths,
    required this.chargeCents,
  });

  final PremiumPlanId id;

  /// Planned App Store / Google Play product ID. Not connected yet.
  final String storeProductId;

  /// 1 = billed monthly, 12 = billed once per year.
  final int billingPeriodMonths;

  /// Amount charged once per billing period (monthly: 6,99 € every month,
  /// yearly: 49,99 € once per year). This is the only amount that is ever
  /// charged; every other amount is derived for display.
  final int chargeCents;

  bool get isYearly => billingPeriodMonths == 12;

  /// Monthly equivalent of [chargeCents], for display only.
  ///
  /// A yearly price does not always split into whole cents
  /// (4999 / 12 = 416,58 cents), so the value is rounded **up** to the next
  /// whole cent (4,17 €). Rounding up means the shown monthly amount never
  /// understates what is actually charged.
  int get monthlyEquivalentCents =>
      (chargeCents + billingPeriodMonths - 1) ~/ billingPeriodMonths;
}

/// The single place for Lookin Premium prices and plan facts. Change prices
/// here; the paywall, profile and tests read them from this class.
abstract final class SubscriptionPlans {
  static const productName = 'Lookin Premium';

  /// Free, app-controlled trial. No payment data, ends automatically and can
  /// be used once per account. The server grants the same length in
  /// `start_premium_trial()` (`0011_premium_trial_seven_days.sql`).
  static const trialDays = 7;

  /// Share of the recipe catalog marked `access_level = 'free'`. The catalog
  /// grows, so the UI names the share, never a fixed number of recipes.
  static const freeRecipeSharePercent = 30;

  static const yearly = PremiumPlan(
    id: PremiumPlanId.yearly,
    storeProductId: 'lookin_premium_yearly',
    billingPeriodMonths: 12,
    chargeCents: 4999,
  );

  static const monthly = PremiumPlan(
    id: PremiumPlanId.monthly,
    storeProductId: 'lookin_premium_monthly',
    billingPeriodMonths: 1,
    chargeCents: 699,
  );

  /// Display order; the recommended plan comes first.
  static const all = [yearly, monthly];

  static const recommended = PremiumPlanId.yearly;

  static PremiumPlan byId(PremiumPlanId id) =>
      all.firstWhere((plan) => plan.id == id);

  /// What one year costs on the monthly plan (12 × 6,99 € = 83,88 €).
  static int get monthlyPlanYearCents =>
      monthly.chargeCents * yearly.billingPeriodMonths;

  /// What the yearly plan saves compared with a year of monthly payments
  /// (83,88 € − 49,99 € = 33,89 €).
  static int get yearlySavingsCents =>
      monthlyPlanYearCents - yearly.chargeCents;

  /// [yearlySavingsCents] as a share of [monthlyPlanYearCents], rounded to
  /// the nearest whole percent (33,89 / 83,88 = 40,4 % → 40 %). The exact
  /// euro saving is always shown next to it on the paywall.
  static int get yearlySavingsPercent =>
      (yearlySavingsCents * 100 / monthlyPlanYearCents).round();
}
