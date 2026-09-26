import '../domain/subscription_plans.dart';

const _nbsp = ' ';

/// German price format: `65,88 €`. The non-breaking space keeps the amount
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

  /// Big, billed amount.
  static String headlinePrice(PremiumPlan plan) =>
      formatEuro(plan.firstChargeCents);

  /// Unit next to the billed amount.
  static String headlineUnit(PremiumPlan plan) {
    if (plan.isYearly) return plan.hasIntroOffer ? 'im 1. Jahr' : 'pro Jahr';
    return '/ Monat';
  }

  /// Small line directly below the billed amount.
  static String introDetail(PremiumPlan plan) {
    if (plan.isYearly) {
      return 'entspricht ${formatEuro(plan.firstPeriodMonthlyCents)} pro Monat';
    }
    if (!plan.hasIntroOffer) return 'monatlich kündbar';
    return 'in den ersten ${plan.introMonths} Monaten';
  }

  /// Price after the introductory offer, always visible.
  static String followUp(PremiumPlan plan) {
    if (plan.isYearly) {
      return 'danach ${formatEuro(plan.regularChargeCents)} pro Jahr '
          '(${formatEuro(plan.monthlyPriceCents)} pro Monat)';
    }
    return 'danach ${formatEuro(plan.monthlyPriceCents)} pro Monat';
  }

  /// Short price summary shown in purchase buttons.
  static String purchaseSummary(PremiumPlan plan) => plan.isYearly
      ? '${formatEuro(plan.firstChargeCents)} im 1. Jahr, danach '
            '${formatEuro(plan.regularChargeCents)} pro Jahr'
      : '${formatEuro(plan.introMonthlyPriceCents)} pro Monat für '
            '${plan.introMonths} Monate, danach '
            '${formatEuro(plan.monthlyPriceCents)}';
}
