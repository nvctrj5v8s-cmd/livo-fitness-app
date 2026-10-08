import 'package:flutter/foundation.dart';

import '../application/subscription_controller.dart';
import '../domain/subscription_plans.dart';

const _nbsp = ' ';

/// German price format: `49,99 €`. The non-breaking space keeps the amount
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

  /// Price paragraph of the paywall terms while no purchase is possible.
  static String get priceTerms => priceTermsFor(billingAvailable: false);

  /// Price paragraph of the paywall terms. With working store billing it
  /// also names who bills and where the subscription is cancelled.
  static String priceTermsFor({required bool billingAvailable}) {
    const yearly = SubscriptionPlans.yearly;
    const monthly = SubscriptionPlans.monthly;
    final prices =
        'Jährlich ${headlinePrice(yearly)} ${headlineUnit(yearly)}, einmal im '
        'Jahr berechnet (${priceDetail(yearly)}). Monatlich '
        '${headlinePrice(monthly)} ${headlineUnit(monthly)}. Alle Preise '
        'inkl. MwSt.';
    if (!billingAvailable) {
      return 'Abo-Preise ($billingPending): $prices Ein Abo verlängert sich '
          'automatisch zum selben Preis und ist jederzeit zum Ende des '
          'Abrechnungszeitraums kündbar.';
    }
    return 'Abo-Preise: $prices Bezahlung und Abrechnung laufen über '
        '$_storeName. Ein Abo verlängert sich automatisch zum selben Preis, '
        'bis du es kündigst. Du kündigst jederzeit in den Abo-Einstellungen '
        'von $_storeName, wirksam zum Ende des Abrechnungszeitraums.';
  }

  static String get _storeName =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS
      ? 'dem App Store'
      : 'Google Play';

  /// Shown under the purchase button when billing works.
  static const storeNote =
      'Die Zahlung läuft sicher über den Store. Lookin sieht und speichert '
      'keine Zahlungsdaten.';

  /// Shown under the purchase button when nothing can be bought here.
  static String get unavailableNote => kIsWeb
      ? 'Das Abo schließt du in der Lookin-App für Android ab. Im Browser wird '
            'nichts gekauft oder berechnet.'
      : '$billingPending – bis dahin wird nichts gekauft oder berechnet.';

  static String get unavailableMessage => kIsWeb
      ? 'Abos gibt es in der Lookin-App für Android. Im Browser wurde nichts '
            'gekauft und nichts berechnet – teste Premium hier '
            '${SubscriptionPlans.trialDays} Tage kostenlos.'
      : '$billingPending. Es wurde nichts gekauft und nichts berechnet – teste '
            'Premium bis dahin ${SubscriptionPlans.trialDays} Tage kostenlos.';

  static const restoreUnavailableMessage =
      'Käufe wiederherstellen ist nur in der Lookin-App möglich, sobald die '
      'Bezahlung dort freigeschaltet ist. Hier gibt es keine Käufe, die '
      'wiederhergestellt werden müssten.';

  static const manageFailedMessage =
      'Die Abo-Verwaltung konnte nicht geöffnet werden. Öffne die Abo-'
      'Einstellungen direkt im Store.';

  /// What the user reads after a purchase or restore attempt.
  static String purchaseOutcomeMessage(PurchaseOutcome outcome) =>
      switch (outcome) {
        PurchaseOutcome.active =>
          'Premium ist aktiv. Danke für deine '
              'Unterstützung!',
        PurchaseOutcome.activating =>
          'Dein Kauf ist angekommen. Die '
              'Freischaltung dauert noch einen Moment – öffne Lookin gleich '
              'noch einmal. Es wird nichts doppelt berechnet.',
        PurchaseOutcome.cancelled =>
          'Kauf abgebrochen. Es wurde nichts '
              'berechnet.',
        PurchaseOutcome.pending =>
          'Deine Zahlung ist noch in Prüfung. '
              'Premium wird freigeschaltet, sobald der Store sie bestätigt.',
        PurchaseOutcome.nothingToRestore =>
          'Für dieses Store-Konto wurde '
              'kein aktives Abo gefunden.',
        PurchaseOutcome.unavailable =>
          'Der Store ist gerade nicht '
              'erreichbar. Es wurde nichts berechnet – versuche es später '
              'noch einmal.',
      };
}
