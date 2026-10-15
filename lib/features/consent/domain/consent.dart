import 'package:fitness_ai_app/l10n/l10n.dart';

/// Kinds of explicit consent Lookin asks for. The wire value matches the
/// `kind` column of `public.user_consents` (migration 0017).
enum ConsentKind {
  /// Storing and using voluntary health data (weight, allergies, target
  /// weight and the answers of the set-up) in the account (Art. 9 Abs. 2
  /// lit. a DSGVO).
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
  static const version = '2026-10-14';
  static String get localizedVersion => '$version:${L10n.code}';

  static String get healthTitle => L10n.current.consentSaveHealthInformation;
  static String get health =>
      L10n.current.consentIConsentToLookinStoringMyOptional;

  static String get aiTitle => L10n.current.consentUseAiCoachAndAiPhoto;
  static String get ai =>
      L10n.current.consentIExpresslyConsentToMyQuestionsPhotos;

  static String get immediateStart =>
      L10n.current.consentIExpresslyRequestThatLookinPremiumBegins;

  static String get revocableNote =>
      L10n.current.consentOptionalYouCanWithdrawEachConsentAt;
}
