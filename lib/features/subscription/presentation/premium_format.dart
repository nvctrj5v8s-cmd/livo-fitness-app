import '../domain/subscription_plans.dart';

const _nbsp = ' ';

/// German price format: `59,99 €`. The non-breaking space keeps the amount
/// and currency on one line.
String formatEuro(int cents) {
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
  final local = value.toLocal();
  return '${_two(local.day)}.${_two(local.month)}.${local.year}, '
      '${_two(local.hour)}:${_two(local.minute)}${_nbsp}Uhr';
}

/// `29.09.` in local time.
String formatPremiumShortDate(DateTime value) {
  final local = value.toLocal();
  return '${_two(local.day)}.${_two(local.month)}.';
}

/// Shared, honest copy so every surface names the same facts.
abstract final class PremiumCopy {
  static String get freeRecipes =>
      'Ohne Abo: ${SubscriptionPlans.freeRecipeSharePercent}$_nbsp% der Rezepte';
  static const premiumRecipes = 'Mit Premium: alle Rezepte';

  static String get trialCta =>
      '${SubscriptionPlans.trialDays} Tage kostenlos testen';
  static const trialPromise =
      'Endet automatisch · keine Zahlungsdaten nötig · keine Kosten';
  static const billingPending = 'Bezahlung wird gerade eingerichtet';

  static String planTitle(PremiumPlan plan) =>
      plan.isYearly ? 'Jährlich' : 'Monatlich';

  static String purchaseLabel(PremiumPlan plan) =>
      plan.isYearly ? 'Jährlich abonnieren' : 'Monatlich abonnieren';

  /// Big amount that is charged per billing period.
  static String headlinePrice(PremiumPlan plan) => formatEuro(plan.chargeCents);

  /// Unit next to the charged amount.
  static String headlineUnit(PremiumPlan plan) =>
      plan.isYearly ? 'pro Jahr' : 'pro Monat';

  /// Small line directly below the charged amount.
  static String priceDetail(PremiumPlan plan) => plan.isYearly
      ? 'entspricht ${formatEuro(plan.monthlyEquivalentCents)} pro Monat'
      : 'monatlich kündbar';

  /// How often the plan is charged, always visible below the price.
  static String billingNote(PremiumPlan plan) => plan.isYearly
      ? 'einmal im Jahr berechnet – du sparst '
            '${formatEuro(SubscriptionPlans.yearlySavingsCents)} gegenüber '
            'monatlich'
      : 'jeden Monat berechnet';

  /// Short price summary shown in purchase buttons.
  static String purchaseSummary(PremiumPlan plan) =>
      '${headlinePrice(plan)} ${headlineUnit(plan)} (${priceDetail(plan)})';

  /// Price paragraph of the paywall terms.
  static String get priceTerms {
    const yearly = SubscriptionPlans.yearly;
    const monthly = SubscriptionPlans.monthly;
    return 'Abo-Preise ($billingPending): Jährlich '
        '${headlinePrice(yearly)} ${headlineUnit(yearly)}, einmal im Jahr '
        'berechnet (${priceDetail(yearly)}). Monatlich '
        '${headlinePrice(monthly)} ${headlineUnit(monthly)}. Alle Preise '
        'inkl. MwSt. Ein Abo verlängert sich automatisch zum selben Preis und '
        'ist jederzeit zum Ende des Abrechnungszeitraums kündbar.';
  }
}
