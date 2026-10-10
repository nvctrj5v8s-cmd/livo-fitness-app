/// Kinds of explicit consent Lookin asks for. The wire value matches the
/// `kind` column of `public.user_consents` (migration 0017).
enum ConsentKind {
  /// Storing and using voluntary health data (weight, allergies, target
  /// weight) in the account (Art. 9 Abs. 2 lit. a DSGVO).
  healthData('health_data'),

  /// Sending questions, photos and the needed context to the AI provider
  /// OpenAI in the USA.
  aiProcessing('ai_processing'),

  /// Express request to start the paid service before the withdrawal period
  /// ends (service contract: § 356 Abs. 4, § 357a Abs. 2 BGB).
  immediateStart('immediate_start');

  const ConsentKind(this.wire);
  final String wire;
}

/// The exact wording users agree to. Changing a text means raising
/// [version], so stored decisions can be traced to the text that was shown.
abstract final class ConsentTexts {
  static const version = '2026-10-10b';

  static const healthTitle = 'Gesundheitsangaben speichern';
  static const health =
      'Ich willige ein, dass Lookin meine freiwilligen Gesundheitsangaben '
      '(Gewicht, Taillenumfang, Zielgewicht, Allergien und '
      'Unverträglichkeiten) in meinem Konto speichert und für Richtwerte, '
      'Rezeptfilter und Warnhinweise nutzt.';

  static const aiTitle = 'KI-Coach und KI-Foto nutzen';
  static const ai =
      'Ich willige ausdrücklich ein, dass meine Fragen, Fotos, die letzten '
      'Chat-Nachrichten und folgende Angaben zur Beantwortung an den KI-Dienst '
      'OpenAI übermittelt werden (Verarbeitung auch in den USA): Ziel, '
      'Tageswerte, Ernährungsstil, Aktivität, Angaben aus der Einführung '
      '(Motivation, Hürden, Erfahrung) und meine Allergien und '
      'Unverträglichkeiten, also Gesundheitsdaten. Name und E-Mail werden '
      'nicht übermittelt.';

  static const immediateStart =
      'Ich verlange ausdrücklich, dass Lookin Premium sofort, also vor Ablauf '
      'der Widerrufsfrist, beginnt. Mir ist bekannt, dass ich bei einem '
      'Widerruf einen anteiligen Betrag für die bis dahin erbrachte Leistung '
      'zahle und mein Widerrufsrecht bei vollständiger Vertragserfüllung '
      'erlischt.';

  static const revocableNote =
      'Freiwillig. Du kannst jede Einwilligung jederzeit unter Profil › '
      'Datenschutz & Daten widerrufen.';
}
