import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @allergiesAllergiesIntolerances.
  ///
  /// In de, this message translates to:
  /// **'Allergien & Unverträglichkeiten'**
  String get allergiesAllergiesIntolerances;

  /// No description provided for @allergiesAllergyInformationMissing.
  ///
  /// In de, this message translates to:
  /// **'Allergieangaben fehlen'**
  String get allergiesAllergyInformationMissing;

  /// No description provided for @allergiesChange.
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get allergiesChange;

  /// No description provided for @allergiesClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get allergiesClose;

  /// No description provided for @allergiesEGCoconutHistamine.
  ///
  /// In de, this message translates to:
  /// **'z. B. Kokos, Histamin'**
  String get allergiesEGCoconutHistamine;

  /// No description provided for @allergiesNoReliableAllergenOrIngredientInformationIs.
  ///
  /// In de, this message translates to:
  /// **'Zu diesem Eintrag liegen keine verlässlichen Allergen- oder Zutatenangaben vor.'**
  String get allergiesNoReliableAllergenOrIngredientInformationIs;

  /// No description provided for @allergiesNoneOfYourSelectedTriggersWereRecognised.
  ///
  /// In de, this message translates to:
  /// **'In den vorhandenen Angaben wurde kein gewählter Auslöser erkannt. Das ist keine Sicherheitsgarantie.'**
  String get allergiesNoneOfYourSelectedTriggersWereRecognised;

  /// No description provided for @allergiesNoneSpecified.
  ///
  /// In de, this message translates to:
  /// **'Keine angegeben'**
  String get allergiesNoneSpecified;

  /// No description provided for @allergiesOptionalHealthInformationItIsSavedIn.
  ///
  /// In de, this message translates to:
  /// **'Freiwillige Gesundheitsangabe: Sie wird in deinem Konto gespeichert und dem Lookin Coach als Kontext mitgegeben, damit er nichts Unpassendes vorschlägt. Du kannst sie hier jederzeit ändern oder leeren.'**
  String get allergiesOptionalHealthInformationItIsSavedIn;

  /// No description provided for @allergiesOtherAllergiesIntolerances.
  ///
  /// In de, this message translates to:
  /// **'Weitere Allergien / Unverträglichkeiten'**
  String get allergiesOtherAllergiesIntolerances;

  /// No description provided for @allergiesPleaseCheckTheIngredientsList.
  ///
  /// In de, this message translates to:
  /// **'Bitte Zutatenliste prüfen'**
  String get allergiesPleaseCheckTheIngredientsList;

  /// No description provided for @allergiesPossibleAllergenConflict.
  ///
  /// In de, this message translates to:
  /// **'Möglicher Allergenkonflikt'**
  String get allergiesPossibleAllergenConflict;

  /// No description provided for @allergiesProductInformationMayBeMissingOrOutdated.
  ///
  /// In de, this message translates to:
  /// **'Produktangaben können fehlen oder veraltet sein. Prüfe bei einer Allergie immer die aktuelle Verpackung und mögliche Kreuzkontamination.'**
  String get allergiesProductInformationMayBeMissingOrOutdated;

  /// No description provided for @allergiesSaveSelection.
  ///
  /// In de, this message translates to:
  /// **'Auswahl speichern'**
  String get allergiesSaveSelection;

  /// No description provided for @allergiesSelect.
  ///
  /// In de, this message translates to:
  /// **'Auswählen'**
  String get allergiesSelect;

  /// No description provided for @allergiesSelectKnownAllergensLactoseIsListedSeparately.
  ///
  /// In de, this message translates to:
  /// **'Wähle bekannte Allergene aus. Laktose ist separat als Unverträglichkeit aufgeführt.'**
  String get allergiesSelectKnownAllergensLactoseIsListedSeparately;

  /// No description provided for @allergiesSeparateMultipleEntriesWithCommas.
  ///
  /// In de, this message translates to:
  /// **'Mehrere Angaben mit Komma trennen.'**
  String get allergiesSeparateMultipleEntriesWithCommas;

  /// No description provided for @allergiesTheAvailableProductOrIngredientInformationMentions.
  ///
  /// In de, this message translates to:
  /// **'Die verfügbaren Produkt-/Zutatenangaben nennen: {arg0}.'**
  String allergiesTheAvailableProductOrIngredientInformationMentions(
    String arg0,
  );

  /// No description provided for @allergiesValueIfYouHaveAllergiesAlwaysCheck.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Prüfe bei Allergien immer die aktuelle Verpackung und mögliche Kreuzkontamination.'**
  String allergiesValueIfYouHaveAllergiesAlwaysCheck(String arg0);

  /// No description provided for @allergiesWhatShouldTheAppTakeIntoAccount.
  ///
  /// In de, this message translates to:
  /// **'Was soll die App beachten?'**
  String get allergiesWhatShouldTheAppTakeIntoAccount;

  /// No description provided for @appConfirmedIfYouAlsoReceivedAnEmail.
  ///
  /// In de, this message translates to:
  /// **'Bestätigt. Hast du auch an deine andere Adresse eine E-Mail bekommen, bestätige die Änderung dort ebenfalls.'**
  String get appConfirmedIfYouAlsoReceivedAnEmail;

  /// No description provided for @appNoConnectionToTheServerYourLink.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung zum Server. Dein Link ist vermutlich noch gültig: Lade die Seite neu oder tippe den Link in der E-Mail noch einmal an.'**
  String get appNoConnectionToTheServerYourLink;

  /// No description provided for @appOpeningSemantics.
  ///
  /// In de, this message translates to:
  /// **'Lookin wird geöffnet'**
  String get appOpeningSemantics;

  /// No description provided for @appYourConfirmationLinkHasExpiredOrHas.
  ///
  /// In de, this message translates to:
  /// **'Der Bestätigungslink ist abgelaufen oder wurde schon benutzt. Melde dich an. Ist deine Adresse noch nicht bestätigt, kannst du dort eine neue Bestätigungs-Mail anfordern.'**
  String get appYourConfirmationLinkHasExpiredOrHas;

  /// No description provided for @appYourResetLinkHasExpiredOrHas.
  ///
  /// In de, this message translates to:
  /// **'Der Link zum Zurücksetzen ist abgelaufen oder wurde schon benutzt. Fordere unter „Passwort vergessen?“ einen neuen an.'**
  String get appYourResetLinkHasExpiredOrHas;

  /// No description provided for @authAlmostThere.
  ///
  /// In de, this message translates to:
  /// **'Fast geschafft!'**
  String get authAlmostThere;

  /// No description provided for @authAnAccountAlreadyExistsForThisEmail.
  ///
  /// In de, this message translates to:
  /// **'Für diese E-Mail gibt es bereits ein Konto.'**
  String get authAnAccountAlreadyExistsForThisEmail;

  /// No description provided for @authAtLeastEightCharacters.
  ///
  /// In de, this message translates to:
  /// **'Mindestens acht Zeichen.'**
  String get authAtLeastEightCharacters;

  /// No description provided for @authBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get authBack;

  /// No description provided for @authByTappingGetStartedForFreeYou.
  ///
  /// In de, this message translates to:
  /// **'Mit „Kostenlos starten“ bestätigst du, dass du mindestens 18 Jahre alt bist, und akzeptierst die AGB. Hinweise zum Datenschutz findest du in der Datenschutzerklärung.'**
  String get authByTappingGetStartedForFreeYou;

  /// No description provided for @authCancelAndReturnToSignIn.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen und zum Login'**
  String get authCancelAndReturnToSignIn;

  /// No description provided for @authChangeAnswers.
  ///
  /// In de, this message translates to:
  /// **'Antworten ändern'**
  String get authChangeAnswers;

  /// No description provided for @authCheckYourInbox.
  ///
  /// In de, this message translates to:
  /// **'Schau in dein Postfach'**
  String get authCheckYourInbox;

  /// No description provided for @authCheckingYourSignIn.
  ///
  /// In de, this message translates to:
  /// **'Anmeldung wird geprüft'**
  String get authCheckingYourSignIn;

  /// No description provided for @authChooseANewPasswordYouWillThen.
  ///
  /// In de, this message translates to:
  /// **'Wähle ein neues Passwort. Danach meldest du dich damit erneut an.'**
  String get authChooseANewPasswordYouWillThen;

  /// No description provided for @authConnectionFailedPleaseTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Verbindung fehlgeschlagen. Bitte versuche es erneut.'**
  String get authConnectionFailedPleaseTryAgain;

  /// No description provided for @authCreateYourFreeAccountLookinWillThen.
  ///
  /// In de, this message translates to:
  /// **'Erstelle dein kostenloses Konto. Dann speichert Lookin deine Antworten und dein Tagebuch – auch auf deinen anderen Geräten.'**
  String get authCreateYourFreeAccountLookinWillThen;

  /// No description provided for @authEatSimplyChooseClearly.
  ///
  /// In de, this message translates to:
  /// **'Einfach essen. Klarer entscheiden.'**
  String get authEatSimplyChooseClearly;

  /// No description provided for @authEmailAddress.
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Adresse'**
  String get authEmailAddress;

  /// No description provided for @authEmailConfirmed.
  ///
  /// In de, this message translates to:
  /// **'E-Mail bestätigt'**
  String get authEmailConfirmed;

  /// No description provided for @authEnergy.
  ///
  /// In de, this message translates to:
  /// **'ENERGIE'**
  String get authEnergy;

  /// No description provided for @authEnterYourEmailAddressFirst.
  ///
  /// In de, this message translates to:
  /// **'Gib zuerst deine E-Mail-Adresse ein.'**
  String get authEnterYourEmailAddressFirst;

  /// No description provided for @authForgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get authForgotPassword;

  /// No description provided for @authGetStartedForFree.
  ///
  /// In de, this message translates to:
  /// **'Kostenlos starten'**
  String get authGetStartedForFree;

  /// No description provided for @authHidePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort verbergen'**
  String get authHidePassword;

  /// No description provided for @authIHaveConfirmedContinue.
  ///
  /// In de, this message translates to:
  /// **'Ich habe bestätigt – weiter'**
  String get authIHaveConfirmedContinue;

  /// No description provided for @authIfALookinAccountExistsWithThis.
  ///
  /// In de, this message translates to:
  /// **'Falls es ein Lookin-Konto mit dieser Adresse gibt, haben wir dir einen Link zum Zurücksetzen geschickt. Schau auch im Spam-Ordner nach.'**
  String get authIfALookinAccountExistsWithThis;

  /// No description provided for @authIfNoLookinAccountExistsForThis.
  ///
  /// In de, this message translates to:
  /// **' geschickt, falls es dort noch kein Lookin-Konto gibt. Tippe auf den Link darin, um dein Konto zu aktivieren.'**
  String get authIfNoLookinAccountExistsForThis;

  /// No description provided for @authIfYourAddressHasNotBeenConfirmed.
  ///
  /// In de, this message translates to:
  /// **'Falls die Adresse noch nicht bestätigt ist, haben wir dir eine neue Bestätigungs-Mail geschickt. Schau auch im Spam-Ordner nach.'**
  String get authIfYourAddressHasNotBeenConfirmed;

  /// No description provided for @authNewPassword.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort'**
  String get authNewPassword;

  /// No description provided for @authNothingArrivedCheckYourSpamFolderToo.
  ///
  /// In de, this message translates to:
  /// **'Nichts angekommen? Schau auch im Spam-Ordner nach. Es kann ein bis zwei Minuten dauern. Hast du dich mit dieser Adresse schon einmal registriert? Dann melde dich an oder nutze dort „Passwort vergessen?“.'**
  String get authNothingArrivedCheckYourSpamFolderToo;

  /// No description provided for @authOneAccountForYourGoalsNutritionAnd.
  ///
  /// In de, this message translates to:
  /// **'Ein Konto für Ziele, Ernährung und Fortschritt.'**
  String get authOneAccountForYourGoalsNutritionAnd;

  /// No description provided for @authOpenYourInbox.
  ///
  /// In de, this message translates to:
  /// **'Postfach öffnen'**
  String get authOpenYourInbox;

  /// No description provided for @authPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get authPassword;

  /// No description provided for @authPersonal.
  ///
  /// In de, this message translates to:
  /// **'Persönlich'**
  String get authPersonal;

  /// No description provided for @authPleaseCheckYourEmailAddress.
  ///
  /// In de, this message translates to:
  /// **'Bitte prüfe deine E-Mail-Adresse.'**
  String get authPleaseCheckYourEmailAddress;

  /// No description provided for @authPleaseEnterAValidEmailAddress.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib eine gültige E-Mail ein.'**
  String get authPleaseEnterAValidEmailAddress;

  /// No description provided for @authPleaseEnterYourName.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib deinen Namen ein.'**
  String get authPleaseEnterYourName;

  /// No description provided for @authPrivate.
  ///
  /// In de, this message translates to:
  /// **'Privat'**
  String get authPrivate;

  /// No description provided for @authQuick.
  ///
  /// In de, this message translates to:
  /// **'Schnell'**
  String get authQuick;

  /// No description provided for @authRepeatPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort wiederholen'**
  String get authRepeatPassword;

  /// No description provided for @authResendConfirmationEmail.
  ///
  /// In de, this message translates to:
  /// **'Bestätigungs-Mail erneut senden'**
  String get authResendConfirmationEmail;

  /// No description provided for @authSavePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort speichern'**
  String get authSavePassword;

  /// No description provided for @authSecurelyStoredDeleteAtAnyTime.
  ///
  /// In de, this message translates to:
  /// **'Sicher gespeichert · jederzeit löschbar'**
  String get authSecurelyStoredDeleteAtAnyTime;

  /// No description provided for @authSendAgainInValueS.
  ///
  /// In de, this message translates to:
  /// **'Erneut senden in {arg0} s'**
  String authSendAgainInValueS(String arg0);

  /// No description provided for @authShowPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort anzeigen'**
  String get authShowPassword;

  /// No description provided for @authSignIn.
  ///
  /// In de, this message translates to:
  /// **'Einloggen'**
  String get authSignIn;

  /// No description provided for @authSignIn2.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get authSignIn2;

  /// No description provided for @authSignInAndPickUpWhereYou.
  ///
  /// In de, this message translates to:
  /// **'Einloggen und direkt dort weitermachen, wo du aufgehört hast.'**
  String get authSignInAndPickUpWhereYou;

  /// No description provided for @authSignInNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt anmelden'**
  String get authSignInNow;

  /// No description provided for @authSignOutFailedPleaseTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Abmelden fehlgeschlagen. Bitte versuche es erneut.'**
  String get authSignOutFailedPleaseTryAgain;

  /// No description provided for @authSignUp.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get authSignUp;

  /// No description provided for @authTapConfirmEmail.
  ///
  /// In de, this message translates to:
  /// **'Auf „E-Mail bestätigen“ tippen'**
  String get authTapConfirmEmail;

  /// No description provided for @authThatDidNotWorkJustNowPlease.
  ///
  /// In de, this message translates to:
  /// **'Das hat gerade nicht geklappt. Bitte versuche es später erneut.'**
  String get authThatDidNotWorkJustNowPlease;

  /// No description provided for @authTheEmailComesFromLookinNoreplyLookin.
  ///
  /// In de, this message translates to:
  /// **'Die Mail kommt von Lookin (noreply@lookin-foodtracker.de).'**
  String get authTheEmailComesFromLookinNoreplyLookin;

  /// No description provided for @authTheLinkCanOnlyBeUsedOnce.
  ///
  /// In de, this message translates to:
  /// **'Der Link funktioniert nur einmal und ist begrenzt gültig.'**
  String get authTheLinkCanOnlyBeUsedOnce;

  /// No description provided for @authThePasswordsDoNotMatch.
  ///
  /// In de, this message translates to:
  /// **'Die Passwörter stimmen nicht überein.'**
  String get authThePasswordsDoNotMatch;

  /// No description provided for @authThisPasswordIsTooEasyToGuess.
  ///
  /// In de, this message translates to:
  /// **'Dieses Passwort ist zu unsicher. Wähle ein anderes.'**
  String get authThisPasswordIsTooEasyToGuess;

  /// No description provided for @authTipReturnToLookinInTheWindow.
  ///
  /// In de, this message translates to:
  /// **'Tipp: Kehre einfach zu Lookin zurück, in dem Fenster oder der App, in der du dich registriert hast. Dort wirst du automatisch angemeldet.'**
  String get authTipReturnToLookinInTheWindow;

  /// No description provided for @authToday.
  ///
  /// In de, this message translates to:
  /// **'HEUTE'**
  String get authToday;

  /// No description provided for @authTooManyAttemptsPleaseWaitAMoment.
  ///
  /// In de, this message translates to:
  /// **'Zu viele Versuche. Bitte warte kurz und versuche es dann erneut.'**
  String get authTooManyAttemptsPleaseWaitAMoment;

  /// No description provided for @authTrackUnderstandAndMakeBetterChoicesWithout.
  ///
  /// In de, this message translates to:
  /// **'Tracken, verstehen und besser entscheiden — ohne komplizierte Tabellen.'**
  String get authTrackUnderstandAndMakeBetterChoicesWithout;

  /// No description provided for @authUseADifferentEmailAddress.
  ///
  /// In de, this message translates to:
  /// **'Andere E-Mail-Adresse verwenden'**
  String get authUseADifferentEmailAddress;

  /// No description provided for @authUsingYourEmailAddressAndPassword.
  ///
  /// In de, this message translates to:
  /// **'Mit deiner E-Mail-Adresse und deinem Passwort.'**
  String get authUsingYourEmailAddressAndPassword;

  /// No description provided for @authWeHaveSentAConfirmationEmailTo.
  ///
  /// In de, this message translates to:
  /// **'Wir haben eine Bestätigungs-Mail an '**
  String get authWeHaveSentAConfirmationEmailTo;

  /// No description provided for @authWelcomeBack.
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück.'**
  String get authWelcomeBack;

  /// No description provided for @authYourAddressHasNotBeenConfirmedYet.
  ///
  /// In de, this message translates to:
  /// **'Deine Adresse ist noch nicht bestätigt. Tippe zuerst auf den Link in der E-Mail und komm dann hierher zurück.'**
  String get authYourAddressHasNotBeenConfirmedYet;

  /// No description provided for @authYourDayYourRhythm.
  ///
  /// In de, this message translates to:
  /// **'Dein Alltag.\nDein Rhythmus.'**
  String get authYourDayYourRhythm;

  /// No description provided for @authYourEmailAddressHasNotBeenConfirmed.
  ///
  /// In de, this message translates to:
  /// **'Deine E-Mail-Adresse ist noch nicht bestätigt. Tippe auf den Link in unserer E-Mail oder fordere unten eine neue an.'**
  String get authYourEmailAddressHasNotBeenConfirmed;

  /// No description provided for @authYourEmailOrPasswordIsIncorrectIf.
  ///
  /// In de, this message translates to:
  /// **'E-Mail oder Passwort ist nicht korrekt. Hast du dich mit dieser Adresse schon einmal registriert, gilt das damalige Passwort. Setze es sonst über „Passwort vergessen?“ zurück.'**
  String get authYourEmailOrPasswordIsIncorrectIf;

  /// No description provided for @authYourFoodYourRhythm.
  ///
  /// In de, this message translates to:
  /// **'Dein Essen.\nDein Rhythmus.'**
  String get authYourFoodYourRhythm;

  /// No description provided for @authYourLookinAccountIsNowActiveYou.
  ///
  /// In de, this message translates to:
  /// **'Dein Lookin-Konto ist jetzt aktiv. Du kannst dich mit deiner E-Mail-Adresse und deinem Passwort anmelden.'**
  String get authYourLookinAccountIsNowActiveYou;

  /// No description provided for @authYourLookinAccountIsReady.
  ///
  /// In de, this message translates to:
  /// **'Dein Lookin-Konto ist bereit.'**
  String get authYourLookinAccountIsReady;

  /// No description provided for @authYourName.
  ///
  /// In de, this message translates to:
  /// **'Dein Name'**
  String get authYourName;

  /// No description provided for @authYourNewPasswordHasBeenSavedSign.
  ///
  /// In de, this message translates to:
  /// **'Dein neues Passwort ist gespeichert. Melde dich jetzt damit an.'**
  String get authYourNewPasswordHasBeenSavedSign;

  /// No description provided for @authYourNewPasswordMustBeDifferentFrom.
  ///
  /// In de, this message translates to:
  /// **'Das neue Passwort muss sich von deinem bisherigen unterscheiden.'**
  String get authYourNewPasswordMustBeDifferentFrom;

  /// No description provided for @authYourPasswordCouldNotBeSetRequest.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort konnte nicht gesetzt werden. Fordere unter „Passwort vergessen?“ einen neuen Link an.'**
  String get authYourPasswordCouldNotBeSetRequest;

  /// No description provided for @authYourPasswordIsTooWeakPleaseUse.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort ist zu schwach. Wähle mindestens acht Zeichen.'**
  String get authYourPasswordIsTooWeakPleaseUse;

  /// No description provided for @authYourPasswordMustContainAtLeastEight.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort muss mindestens acht Zeichen haben.'**
  String get authYourPasswordMustContainAtLeastEight;

  /// No description provided for @authYourStart.
  ///
  /// In de, this message translates to:
  /// **'Dein Start.'**
  String get authYourStart;

  /// No description provided for @coachAiCanMakeMistakesNotMedicalAdvice.
  ///
  /// In de, this message translates to:
  /// **'KI kann Fehler machen · Keine medizinische Beratung'**
  String get coachAiCanMakeMistakesNotMedicalAdvice;

  /// No description provided for @coachAiCanMakeMistakesValuesAreEstimates.
  ///
  /// In de, this message translates to:
  /// **'KI kann Fehler machen · Werte sind Schätzungen · Keine medizinische Beratung'**
  String get coachAiCanMakeMistakesValuesAreEstimates;

  /// No description provided for @coachAiNutritionFitness.
  ///
  /// In de, this message translates to:
  /// **'KI · Ernährung & Fitness'**
  String get coachAiNutritionFitness;

  /// No description provided for @coachAnalyseAFoodPhoto.
  ///
  /// In de, this message translates to:
  /// **'Lebensmittel-Foto analysieren'**
  String get coachAnalyseAFoodPhoto;

  /// No description provided for @coachAskAboutMealsNutritionOrTrainingAnswers.
  ///
  /// In de, this message translates to:
  /// **'Frag nach Mahlzeiten, Nährwerten oder Training – die Antworten berücksichtigen dein Ziel und deine Tageswerte.'**
  String get coachAskAboutMealsNutritionOrTrainingAnswers;

  /// No description provided for @coachAskAboutMealsRecipesNutritionOrTraining.
  ///
  /// In de, this message translates to:
  /// **'Frag nach Mahlzeiten, Rezepten, Nährwerten oder Training. Dein Ziel und deine heutigen Werte werden dabei berücksichtigt.'**
  String get coachAskAboutMealsRecipesNutritionOrTraining;

  /// No description provided for @coachAskYourCoach.
  ///
  /// In de, this message translates to:
  /// **'Frag deinen Coach …'**
  String get coachAskYourCoach;

  /// No description provided for @coachCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get coachCancel;

  /// No description provided for @coachCoachIsTyping.
  ///
  /// In de, this message translates to:
  /// **'Coach schreibt …'**
  String get coachCoachIsTyping;

  /// No description provided for @coachCoachSAnswer.
  ///
  /// In de, this message translates to:
  /// **'Antwort vom Coach'**
  String get coachCoachSAnswer;

  /// No description provided for @coachDailyLimitReachedComeBackTomorrow.
  ///
  /// In de, this message translates to:
  /// **'Tageslimit erreicht – morgen geht es weiter'**
  String get coachDailyLimitReachedComeBackTomorrow;

  /// No description provided for @coachDailyTarget.
  ///
  /// In de, this message translates to:
  /// **'Tagesziel'**
  String get coachDailyTarget;

  /// No description provided for @coachDeleteChatHistory.
  ///
  /// In de, this message translates to:
  /// **'Chatverlauf löschen?'**
  String get coachDeleteChatHistory;

  /// No description provided for @coachDeleteHistory.
  ///
  /// In de, this message translates to:
  /// **'Verlauf löschen'**
  String get coachDeleteHistory;

  /// No description provided for @coachDeleteHistoryExplanation.
  ///
  /// In de, this message translates to:
  /// **'Dein Chatverlauf wird dauerhaft aus deinem Konto gelöscht. Das lässt sich nicht rückgängig machen. Dein Tageslimit bleibt unverändert.'**
  String get coachDeleteHistoryExplanation;

  /// No description provided for @coachDeleteSavedCoachHistory.
  ///
  /// In de, this message translates to:
  /// **'Gespeicherten Coach-Verlauf löschen'**
  String get coachDeleteSavedCoachHistory;

  /// No description provided for @coachDinner.
  ///
  /// In de, this message translates to:
  /// **'Abendessen'**
  String get coachDinner;

  /// No description provided for @coachDismissNotice.
  ///
  /// In de, this message translates to:
  /// **'Hinweis schließen'**
  String get coachDismissNotice;

  /// No description provided for @coachEachQuestionSendsYourGoalDailyTargets.
  ///
  /// In de, this message translates to:
  /// **'Mit jeder Frage gehen dein Ziel, deine Tagesziele, heutigen Tageswerte, Ernährungsstil, Allergien und Aktivität an den KI-Dienst – nicht dein Name. Der Chat wird in deinem Konto gespeichert und lässt sich jederzeit löschen.'**
  String get coachEachQuestionSendsYourGoalDailyTargets;

  /// No description provided for @coachExample.
  ///
  /// In de, this message translates to:
  /// **'Beispiel'**
  String get coachExample;

  /// No description provided for @coachExampleCoachConversationAvailableWithPremium.
  ///
  /// In de, this message translates to:
  /// **'Beispiel eines Coach-Gesprächs, mit Premium verfügbar'**
  String get coachExampleCoachConversationAvailableWithPremium;

  /// No description provided for @coachFocusedOnNutritionFitnessAndAHealthy.
  ///
  /// In de, this message translates to:
  /// **'Fokussiert auf Ernährung, Fitness und gesunden Alltag'**
  String get coachFocusedOnNutritionFitnessAndAHealthy;

  /// No description provided for @coachFoodPhoto.
  ///
  /// In de, this message translates to:
  /// **'Lebensmittel-Foto'**
  String get coachFoodPhoto;

  /// No description provided for @coachFoodPhotoForAnalysis.
  ///
  /// In de, this message translates to:
  /// **'📷 Lebensmittel-Foto zur Analyse'**
  String get coachFoodPhotoForAnalysis;

  /// No description provided for @coachGetEstimatesFromPhotosOfYourMeals.
  ///
  /// In de, this message translates to:
  /// **'Fotos deiner Mahlzeiten einschätzen lassen'**
  String get coachGetEstimatesFromPhotosOfYourMeals;

  /// No description provided for @coachGiveMeASimpleHighProteinIdea.
  ///
  /// In de, this message translates to:
  /// **'Gib mir eine einfache proteinreiche Idee.'**
  String get coachGiveMeASimpleHighProteinIdea;

  /// No description provided for @coachHowCanISensiblyReachMyCalorie.
  ///
  /// In de, this message translates to:
  /// **'Wie erreiche ich heute sinnvoll mein Kalorienziel?'**
  String get coachHowCanISensiblyReachMyCalorie;

  /// No description provided for @coachIdeasThatFitYourRemainingCalories.
  ///
  /// In de, this message translates to:
  /// **'Ideen, die zu deinen restlichen Kalorien passen'**
  String get coachIdeasThatFitYourRemainingCalories;

  /// No description provided for @coachLoadingYourHistory.
  ///
  /// In de, this message translates to:
  /// **'Dein Verlauf wird geladen …'**
  String get coachLoadingYourHistory;

  /// No description provided for @coachMoreProtein.
  ///
  /// In de, this message translates to:
  /// **'Mehr Protein'**
  String get coachMoreProtein;

  /// No description provided for @coachNewChatDeleteHistory.
  ///
  /// In de, this message translates to:
  /// **'Neuer Chat (Verlauf löschen)'**
  String get coachNewChatDeleteHistory;

  /// No description provided for @coachNewChatExplanation.
  ///
  /// In de, this message translates to:
  /// **'Dafür wird dein bisheriger Chatverlauf dauerhaft aus deinem Konto gelöscht. Das lässt sich nicht rückgängig machen. Dein Tageslimit bleibt unverändert.'**
  String get coachNewChatExplanation;

  /// No description provided for @coachNotSent.
  ///
  /// In de, this message translates to:
  /// **'Nicht gesendet'**
  String get coachNotSent;

  /// No description provided for @coachPremiumFeature.
  ///
  /// In de, this message translates to:
  /// **'Premium-Funktion'**
  String get coachPremiumFeature;

  /// No description provided for @coachProteinAndTrainingTipsForYourDay.
  ///
  /// In de, this message translates to:
  /// **'Protein- und Trainingstipps für deinen Alltag'**
  String get coachProteinAndTrainingTipsForYourDay;

  /// No description provided for @coachReportAnswer.
  ///
  /// In de, this message translates to:
  /// **'Antwort melden'**
  String get coachReportAnswer;

  /// No description provided for @coachReportFailed.
  ///
  /// In de, this message translates to:
  /// **'Die Meldung konnte gerade nicht gesendet werden. Bitte prüfe die Verbindung und versuche es noch einmal.'**
  String get coachReportFailed;

  /// No description provided for @coachReportLimit.
  ///
  /// In de, this message translates to:
  /// **'Du hast heute schon viele Antworten gemeldet, danke! Bitte melde weitere morgen.'**
  String get coachReportLimit;

  /// No description provided for @coachReportReasonInappropriate.
  ///
  /// In de, this message translates to:
  /// **'Unpassend oder beleidigend'**
  String get coachReportReasonInappropriate;

  /// No description provided for @coachReportReasonOther.
  ///
  /// In de, this message translates to:
  /// **'Etwas anderes'**
  String get coachReportReasonOther;

  /// No description provided for @coachReportReasonUnsafe.
  ///
  /// In de, this message translates to:
  /// **'Unsicher oder gesundheitlich bedenklich'**
  String get coachReportReasonUnsafe;

  /// No description provided for @coachReportReasonWrong.
  ///
  /// In de, this message translates to:
  /// **'Falsch oder irreführend'**
  String get coachReportReasonWrong;

  /// No description provided for @coachReportSend.
  ///
  /// In de, this message translates to:
  /// **'Meldung senden'**
  String get coachReportSend;

  /// No description provided for @coachReportSheetText.
  ///
  /// In de, this message translates to:
  /// **'Falsch, unpassend oder unsicher? Melde es hier direkt in der App. Wir prüfen jede Meldung und verbessern damit den Coach. Gespeichert werden der Grund, die gemeldete Antwort und dein Konto, höchstens 12 Monate.'**
  String get coachReportSheetText;

  /// No description provided for @coachReportSheetTitle.
  ///
  /// In de, this message translates to:
  /// **'Antwort melden'**
  String get coachReportSheetTitle;

  /// No description provided for @coachReportThanks.
  ///
  /// In de, this message translates to:
  /// **'Danke! Deine Meldung ist angekommen. Wir prüfen sie.'**
  String get coachReportThanks;

  /// No description provided for @coachSendMessage.
  ///
  /// In de, this message translates to:
  /// **'Nachricht senden'**
  String get coachSendMessage;

  /// No description provided for @coachStartANewChat.
  ///
  /// In de, this message translates to:
  /// **'Neuen Chat beginnen?'**
  String get coachStartANewChat;

  /// No description provided for @coachTheCoachCannotBeOpenedJustNow.
  ///
  /// In de, this message translates to:
  /// **'Der Coach kann gerade nicht geöffnet werden.'**
  String get coachTheCoachCannotBeOpenedJustNow;

  /// No description provided for @coachTheCoachIsReplying.
  ///
  /// In de, this message translates to:
  /// **'Der Coach antwortet …'**
  String get coachTheCoachIsReplying;

  /// No description provided for @coachTheCoachIsWritingAnAnswer.
  ///
  /// In de, this message translates to:
  /// **'Der Coach schreibt eine Antwort'**
  String get coachTheCoachIsWritingAnAnswer;

  /// No description provided for @coachTheLookinCoachIsPartOfLookin.
  ///
  /// In de, this message translates to:
  /// **'Der Lookin Coach ist Teil von Lookin Premium. Deine Testphase oder dein Abo ist nicht mehr aktiv.'**
  String get coachTheLookinCoachIsPartOfLookin;

  /// No description provided for @coachThePhotoIsTooLargePleaseChoose.
  ///
  /// In de, this message translates to:
  /// **'Das Foto ist zu groß. Bitte wähle ein kleineres Bild.'**
  String get coachThePhotoIsTooLargePleaseChoose;

  /// No description provided for @coachThisImageCouldNotBeRead.
  ///
  /// In de, this message translates to:
  /// **'Dieses Bild konnte nicht gelesen werden.'**
  String get coachThisImageCouldNotBeRead;

  /// No description provided for @coachThisIsTakingALittleLongerThan.
  ///
  /// In de, this message translates to:
  /// **'Das dauert etwas länger als sonst …'**
  String get coachThisIsTakingALittleLongerThan;

  /// No description provided for @coachTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get coachTryAgain;

  /// No description provided for @coachUnlockPremium.
  ///
  /// In de, this message translates to:
  /// **'Premium freischalten'**
  String get coachUnlockPremium;

  /// No description provided for @coachValueDayFreeTrialEndsAutomaticallyNo.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Tage kostenlos testen · danach Abo, jederzeit kündbar'**
  String coachValueDayFreeTrialEndsAutomaticallyNo(String arg0);

  /// No description provided for @coachValueOfValueAiRequestsLeftToday.
  ///
  /// In de, this message translates to:
  /// **'Noch {arg0} von {arg1} KI-Anfragen heute'**
  String coachValueOfValueAiRequestsLeftToday(String arg0, String arg1);

  /// No description provided for @coachValueOfValueCharactersRemaining.
  ///
  /// In de, this message translates to:
  /// **'Noch {arg0} von {arg1} Zeichen frei'**
  String coachValueOfValueCharactersRemaining(String arg0, String arg1);

  /// No description provided for @coachValuePermanentlyDeletedFromYourAccountThis.
  ///
  /// In de, this message translates to:
  /// **'{arg0} dauerhaft aus deinem Konto gelöscht. Das lässt sich nicht rückgängig machen. Dein Tageslimit bleibt unverändert.'**
  String coachValuePermanentlyDeletedFromYourAccountThis(String arg0);

  /// No description provided for @coachViewPremium.
  ///
  /// In de, this message translates to:
  /// **'Premium ansehen'**
  String get coachViewPremium;

  /// No description provided for @coachWhatCanIStillEatThisEvening.
  ///
  /// In de, this message translates to:
  /// **'Was kann ich heute Abend noch essen?'**
  String get coachWhatCanIStillEatThisEvening;

  /// No description provided for @coachWhatDoYouNeedToday.
  ///
  /// In de, this message translates to:
  /// **'Was brauchst du heute?'**
  String get coachWhatDoYouNeedToday;

  /// No description provided for @coachWithPremium.
  ///
  /// In de, this message translates to:
  /// **'Mit Premium'**
  String get coachWithPremium;

  /// No description provided for @coachYouHaveAbout650KcalLeftToday.
  ///
  /// In de, this message translates to:
  /// **'Du hast heute noch etwa 650 kcal frei. Wie wäre eine Lachs-Bowl mit Reis und Gemüse? Das bringt dir rund 35 g Protein und hält lange satt.'**
  String get coachYouHaveAbout650KcalLeftToday;

  /// No description provided for @coachYourChatHistoryHasBeenDeleted.
  ///
  /// In de, this message translates to:
  /// **'Dein Chatverlauf wurde gelöscht.'**
  String get coachYourChatHistoryHasBeenDeleted;

  /// No description provided for @coachYourHistoryIsSavedInYourAccount.
  ///
  /// In de, this message translates to:
  /// **'Dein Verlauf ist in deinem Konto gespeichert – höchstens die letzten {arg0} Nachrichten der letzten {arg1} Tage.'**
  String coachYourHistoryIsSavedInYourAccount(String arg0, String arg1);

  /// No description provided for @coachYourPersonalAiCoach.
  ///
  /// In de, this message translates to:
  /// **'Dein persönlicher KI-Coach'**
  String get coachYourPersonalAiCoach;

  /// No description provided for @coachYourPremiumStatusCouldNotBeLoaded.
  ///
  /// In de, this message translates to:
  /// **'Dein Premium-Status konnte nicht geladen werden. Bitte prüfe deine Internetverbindung.'**
  String get coachYourPremiumStatusCouldNotBeLoaded;

  /// No description provided for @coachYourQuestion.
  ///
  /// In de, this message translates to:
  /// **'Deine Frage'**
  String get coachYourQuestion;

  /// No description provided for @coachYourQuestionIsTooLongPleaseShorten.
  ///
  /// In de, this message translates to:
  /// **'Deine Frage ist zu lang. Bitte kürze sie auf höchstens {arg0} Zeichen.'**
  String coachYourQuestionIsTooLongPleaseShorten(String arg0);

  /// No description provided for @coachYourQuestionNotSent.
  ///
  /// In de, this message translates to:
  /// **'Deine Frage, nicht gesendet'**
  String get coachYourQuestionNotSent;

  /// No description provided for @coachYourTrialHasEndedContinueChattingWith.
  ///
  /// In de, this message translates to:
  /// **'Deine Testphase ist vorbei. Mit Premium schreibst du weiter mit deinem Coach.'**
  String get coachYourTrialHasEndedContinueChattingWith;

  /// Window/task title of the app.
  ///
  /// In de, this message translates to:
  /// **'Lookin – Ernährung'**
  String get commonAppTitle;

  /// No description provided for @commonBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get commonClose;

  /// No description provided for @commonConnectionFailed.
  ///
  /// In de, this message translates to:
  /// **'Verbindung fehlgeschlagen. Bitte versuche es erneut.'**
  String get commonConnectionFailed;

  /// No description provided for @commonContinue.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get commonContinue;

  /// No description provided for @commonDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get commonDone;

  /// No description provided for @commonEdit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get commonEdit;

  /// No description provided for @commonLater.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get commonLater;

  /// No description provided for @commonLoading.
  ///
  /// In de, this message translates to:
  /// **'Wird geladen …'**
  String get commonLoading;

  /// No description provided for @commonNo.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get commonNo;

  /// No description provided for @commonOk.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonPremium.
  ///
  /// In de, this message translates to:
  /// **'Premium'**
  String get commonPremium;

  /// No description provided for @commonRetry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get commonRetry;

  /// No description provided for @commonSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get commonSave;

  /// No description provided for @commonUnknownError.
  ///
  /// In de, this message translates to:
  /// **'Das hat gerade nicht geklappt. Bitte versuche es später erneut.'**
  String get commonUnknownError;

  /// No description provided for @commonYes.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get commonYes;

  /// No description provided for @consentAiCoachAndAiPhotoWillThen.
  ///
  /// In de, this message translates to:
  /// **'KI-Coach und KI-Foto senden dann nichts mehr an OpenAI und fragen dich vor der nächsten Nutzung erneut.'**
  String get consentAiCoachAndAiPhotoWillThen;

  /// No description provided for @consentCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get consentCancel;

  /// No description provided for @consentConsentCouldNotBeSaved.
  ///
  /// In de, this message translates to:
  /// **'Deine Einwilligung konnte nicht gespeichert werden. Bitte prüfe die Verbindung und versuche es noch einmal.'**
  String get consentConsentCouldNotBeSaved;

  /// No description provided for @consentConsents.
  ///
  /// In de, this message translates to:
  /// **'Einwilligungen'**
  String get consentConsents;

  /// No description provided for @consentContinueWithoutConsent.
  ///
  /// In de, this message translates to:
  /// **'Ohne Einwilligung weiter'**
  String get consentContinueWithoutConsent;

  /// No description provided for @consentGiveConsent.
  ///
  /// In de, this message translates to:
  /// **'Einwilligen'**
  String get consentGiveConsent;

  /// No description provided for @consentIConsentToLookinStoringMyOptional.
  ///
  /// In de, this message translates to:
  /// **'Ich willige ein, dass Lookin meine freiwilligen Gesundheitsangaben (Gewicht, Taillenumfang, Zielgewicht, Allergien und Unverträglichkeiten sowie meine Antworten aus der Einführung wie Geburtstag, Größe, Geschlecht und einen optionalen Gesundheitshinweis) in meinem Konto speichert und für Richtwerte, Rezeptfilter und Warnhinweise nutzt. So muss ich sie auf einem neuen Gerät nicht noch einmal eingeben.'**
  String get consentIConsentToLookinStoringMyOptional;

  /// No description provided for @consentIExpresslyConsentToMyQuestionsPhotos.
  ///
  /// In de, this message translates to:
  /// **'Ich willige ausdrücklich ein, dass meine Fragen, Fotos, die letzten Chat-Nachrichten und folgende Angaben zur Beantwortung an den KI-Dienst OpenAI übermittelt werden (Verarbeitung auch in den USA): Ziel, Tageswerte, Ernährungsstil, Aktivität, Angaben aus der Einführung (Motivation, Hürden, Erfahrung) und meine Allergien und Unverträglichkeiten, also Gesundheitsdaten. Name und E-Mail werden nicht übermittelt.'**
  String get consentIExpresslyConsentToMyQuestionsPhotos;

  /// No description provided for @consentIExpresslyRequestThatLookinPremiumBegins.
  ///
  /// In de, this message translates to:
  /// **'Ich verlange ausdrücklich, dass Lookin Premium sofort, also vor Ablauf der Widerrufsfrist, beginnt. Mir ist bekannt, dass ich bei einem Widerruf einen anteiligen Betrag für die bis dahin erbrachte Leistung zahle und mein Widerrufsrecht bei vollständiger Vertragserfüllung erlischt.'**
  String get consentIExpresslyRequestThatLookinPremiumBegins;

  /// No description provided for @consentLookinAlsoWorksWithoutTheseConsentsWithout.
  ///
  /// In de, this message translates to:
  /// **'Lookin funktioniert auch ohne diese Einwilligungen. Ohne sie bleiben Gesundheitsangaben nur auf diesem Gerät, und KI-Coach und KI-Foto fragen dich vor der ersten Nutzung noch einmal.'**
  String get consentLookinAlsoWorksWithoutTheseConsentsWithout;

  /// No description provided for @consentNotNow.
  ///
  /// In de, this message translates to:
  /// **'Nicht jetzt'**
  String get consentNotNow;

  /// No description provided for @consentOptionalYouCanWithdrawEachConsentAt.
  ///
  /// In de, this message translates to:
  /// **'Freiwillig. Du kannst jede Einwilligung jederzeit unter Profil › Datenschutz & Daten widerrufen.'**
  String get consentOptionalYouCanWithdrawEachConsentAt;

  /// No description provided for @consentSaveAndContinue.
  ///
  /// In de, this message translates to:
  /// **'Speichern und weiter'**
  String get consentSaveAndContinue;

  /// No description provided for @consentSaveHealthInformation.
  ///
  /// In de, this message translates to:
  /// **'Gesundheitsangaben speichern'**
  String get consentSaveHealthInformation;

  /// No description provided for @consentSaveWeightTargetWeightAndAllergiesIn.
  ///
  /// In de, this message translates to:
  /// **'Gewicht, Zielgewicht und Allergien im Konto speichern'**
  String get consentSaveWeightTargetWeightAndAllergiesIn;

  /// No description provided for @consentSendQuestionsAndPhotosToOpenaiUsa.
  ///
  /// In de, this message translates to:
  /// **'Fragen und Fotos an OpenAI (USA) senden'**
  String get consentSendQuestionsAndPhotosToOpenaiUsa;

  /// No description provided for @consentUseAiCoachAndAiPhoto.
  ///
  /// In de, this message translates to:
  /// **'KI-Coach und KI-Foto nutzen'**
  String get consentUseAiCoachAndAiPhoto;

  /// No description provided for @consentWeWillThenDeleteYourHealthInformation.
  ///
  /// In de, this message translates to:
  /// **'Wir löschen dann deine Gesundheitsangaben in deinem Konto (Allergien, Zielgewicht, Gewichts- und Taillenwerte). Auf diesem Gerät bleiben deine Angaben erhalten.'**
  String get consentWeWillThenDeleteYourHealthInformation;

  /// No description provided for @consentWithdraw.
  ///
  /// In de, this message translates to:
  /// **'Widerrufen'**
  String get consentWithdraw;

  /// No description provided for @consentWithdrawAndDelete.
  ///
  /// In de, this message translates to:
  /// **'Widerrufen und löschen'**
  String get consentWithdrawAndDelete;

  /// No description provided for @consentWithdrawConsent.
  ///
  /// In de, this message translates to:
  /// **'Einwilligung widerrufen?'**
  String get consentWithdrawConsent;

  /// No description provided for @consentYourConsents.
  ///
  /// In de, this message translates to:
  /// **'Deine Einwilligungen'**
  String get consentYourConsents;

  /// No description provided for @coreAccountChanged.
  ///
  /// In de, this message translates to:
  /// **'Konto geändert.'**
  String get coreAccountChanged;

  /// No description provided for @coreAiFeaturesNeedYourConsent.
  ///
  /// In de, this message translates to:
  /// **'Die KI-Funktionen brauchen deine Einwilligung. Du kannst sie unter Profil › Exportieren, löschen, Einwilligungen erteilen.'**
  String get coreAiFeaturesNeedYourConsent;

  /// No description provided for @coreBarcodeSearchDidNotReceiveAValid.
  ///
  /// In de, this message translates to:
  /// **'Die Barcode-Suche hat gerade keine gültige Serverantwort erhalten. Bitte versuche es später erneut.'**
  String get coreBarcodeSearchDidNotReceiveAValid;

  /// No description provided for @coreBarcodeSearchIsCurrentlyUnavailablePleaseTry.
  ///
  /// In de, this message translates to:
  /// **'Die Barcode-Suche ist gerade nicht erreichbar. Bitte versuche es später erneut.'**
  String get coreBarcodeSearchIsCurrentlyUnavailablePleaseTry;

  /// No description provided for @coreCatalogueSourceValue.
  ///
  /// In de, this message translates to:
  /// **'Katalogquelle: {arg0}'**
  String coreCatalogueSourceValue(String arg0);

  /// No description provided for @coreImageAnalysisIsCurrentlyUnavailablePleaseTry.
  ///
  /// In de, this message translates to:
  /// **'Die Bildanalyse ist gerade nicht erreichbar. Bitte versuche es erneut.'**
  String get coreImageAnalysisIsCurrentlyUnavailablePleaseTry;

  /// No description provided for @coreInvalidAiNutritionValue.
  ///
  /// In de, this message translates to:
  /// **'Ungültiger KI-Nährwert.'**
  String get coreInvalidAiNutritionValue;

  /// No description provided for @coreInvalidRecognisedFood.
  ///
  /// In de, this message translates to:
  /// **'Ungültiges erkanntes Lebensmittel.'**
  String get coreInvalidRecognisedFood;

  /// No description provided for @coreLookinCatalogue.
  ///
  /// In de, this message translates to:
  /// **'Lookin-Katalog'**
  String get coreLookinCatalogue;

  /// No description provided for @coreMissingNutritionValueValue.
  ///
  /// In de, this message translates to:
  /// **'Nährwert fehlt: {arg0}'**
  String coreMissingNutritionValueValue(String arg0);

  /// No description provided for @coreMustBeGreaterThan0.
  ///
  /// In de, this message translates to:
  /// **'Muss größer als 0 sein.'**
  String get coreMustBeGreaterThan0;

  /// No description provided for @coreNoAccountAvailable.
  ///
  /// In de, this message translates to:
  /// **'Konto fehlt.'**
  String get coreNoAccountAvailable;

  /// No description provided for @coreNoConnectionToTheCoachPleaseCheck.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung zum Coach. Bitte prüfe deine Internetverbindung und versuche es erneut.'**
  String get coreNoConnectionToTheCoachPleaseCheck;

  /// No description provided for @coreNoFoodsCouldBeConfidentlyRecognisedIn.
  ///
  /// In de, this message translates to:
  /// **'Auf dem Foto konnten keine Lebensmittel sicher erkannt werden.'**
  String get coreNoFoodsCouldBeConfidentlyRecognisedIn;

  /// No description provided for @coreNoPermittedFoodsCouldBeConfidentlyRecognised.
  ///
  /// In de, this message translates to:
  /// **'Auf dem Foto konnten keine erlaubten Lebensmittel sicher erkannt werden.'**
  String get coreNoPermittedFoodsCouldBeConfidentlyRecognised;

  /// No description provided for @coreNothingCouldBeConfidentlyRecognisedInThis.
  ///
  /// In de, this message translates to:
  /// **'Auf dem Foto konnte gerade nichts sicher erkannt werden.'**
  String get coreNothingCouldBeConfidentlyRecognisedInThis;

  /// No description provided for @coreNutritionValuesMustBeValidNumbersOf.
  ///
  /// In de, this message translates to:
  /// **'Nährwerte müssen gültige Zahlen ab 0 sein.'**
  String get coreNutritionValuesMustBeValidNumbersOf;

  /// No description provided for @corePhotoAnalysisDidNotReturnAValid.
  ///
  /// In de, this message translates to:
  /// **'Die Fotoanalyse hat keine gültige Antwort erhalten.'**
  String get corePhotoAnalysisDidNotReturnAValid;

  /// No description provided for @corePhotoAnalysisIsCurrentlyUnavailablePleaseCheck.
  ///
  /// In de, this message translates to:
  /// **'Die Fotoanalyse ist gerade nicht erreichbar. Bitte prüfe deine Verbindung.'**
  String get corePhotoAnalysisIsCurrentlyUnavailablePleaseCheck;

  /// No description provided for @corePhotoAnalysisIsCurrentlyUnavailablePleaseTry.
  ///
  /// In de, this message translates to:
  /// **'Die Fotoanalyse ist gerade nicht erreichbar. Bitte versuche es erneut.'**
  String get corePhotoAnalysisIsCurrentlyUnavailablePleaseTry;

  /// No description provided for @corePleaseAddSugarSaturatedFatAndSalt.
  ///
  /// In de, this message translates to:
  /// **'Bitte Zucker, gesättigte Fettsäuren und Salz vom Etikett ergänzen.'**
  String get corePleaseAddSugarSaturatedFatAndSalt;

  /// No description provided for @corePleaseEnterAnAmountGreaterThan0.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine Menge größer als 0 eingeben.'**
  String get corePleaseEnterAnAmountGreaterThan0;

  /// No description provided for @corePleaseEnterYourPassword.
  ///
  /// In de, this message translates to:
  /// **'Bitte Passwort eingeben.'**
  String get corePleaseEnterYourPassword;

  /// No description provided for @corePleaseRephraseYourQuestion.
  ///
  /// In de, this message translates to:
  /// **'Bitte formuliere deine Frage etwas anders.'**
  String get corePleaseRephraseYourQuestion;

  /// No description provided for @corePleaseSignInAgain.
  ///
  /// In de, this message translates to:
  /// **'Bitte erneut anmelden.'**
  String get corePleaseSignInAgain;

  /// No description provided for @corePleaseSignInAgainThenTryScanning.
  ///
  /// In de, this message translates to:
  /// **'Bitte melde dich erneut an und versuche den Scan danach noch einmal.'**
  String get corePleaseSignInAgainThenTryScanning;

  /// No description provided for @corePleaseSignInAgainToUsePhoto.
  ///
  /// In de, this message translates to:
  /// **'Bitte melde dich erneut an, um die Fotoanalyse zu verwenden.'**
  String get corePleaseSignInAgainToUsePhoto;

  /// No description provided for @corePleaseSignInBeforeSavingAnything.
  ///
  /// In de, this message translates to:
  /// **'Bitte melde dich an, bevor du etwas speicherst.'**
  String get corePleaseSignInBeforeSavingAnything;

  /// No description provided for @corePleaseSignInFirst.
  ///
  /// In de, this message translates to:
  /// **'Bitte melde dich zuerst an.'**
  String get corePleaseSignInFirst;

  /// No description provided for @corePleaseSignInFirst2.
  ///
  /// In de, this message translates to:
  /// **'Bitte zuerst anmelden.'**
  String get corePleaseSignInFirst2;

  /// No description provided for @corePleaseWaitAMomentBeforeSearchingFor.
  ///
  /// In de, this message translates to:
  /// **'Bitte kurz warten, bevor du den nächsten Barcode suchst.'**
  String get corePleaseWaitAMomentBeforeSearchingFor;

  /// No description provided for @coreSaturatedFatCannotExceedTotalFat.
  ///
  /// In de, this message translates to:
  /// **'Gesättigte Fettsäuren dürfen nicht höher als Fett sein.'**
  String get coreSaturatedFatCannotExceedTotalFat;

  /// No description provided for @coreSugarCannotExceedCarbohydrates.
  ///
  /// In de, this message translates to:
  /// **'Zucker darf nicht höher als die Kohlenhydrate sein.'**
  String get coreSugarCannotExceedCarbohydrates;

  /// No description provided for @coreTheAmountOrANutritionValueIs.
  ///
  /// In de, this message translates to:
  /// **'Die Menge oder ein Nährwert ist zu groß.'**
  String get coreTheAmountOrANutritionValueIs;

  /// No description provided for @coreTheCoachCouldNotPutTogetherAn.
  ///
  /// In de, this message translates to:
  /// **'Der Coach konnte gerade keine Antwort formulieren. Bitte versuche es noch einmal.'**
  String get coreTheCoachCouldNotPutTogetherAn;

  /// No description provided for @coreTheCoachDidNotSendAValid.
  ///
  /// In de, this message translates to:
  /// **'Der Coach hat keine gültige Antwort geschickt. Bitte versuche es noch einmal.'**
  String get coreTheCoachDidNotSendAValid;

  /// No description provided for @coreTheCoachIsCurrentlyUnavailablePleaseTry.
  ///
  /// In de, this message translates to:
  /// **'Der Coach ist gerade nicht erreichbar. Bitte versuche es gleich noch einmal.'**
  String get coreTheCoachIsCurrentlyUnavailablePleaseTry;

  /// No description provided for @coreTheCoachIsTakingTooLongPlease.
  ///
  /// In de, this message translates to:
  /// **'Der Coach braucht gerade zu lange. Bitte versuche es noch einmal.'**
  String get coreTheCoachIsTakingTooLongPlease;

  /// No description provided for @coreTheCustomEntryHasNotBeenSaved.
  ///
  /// In de, this message translates to:
  /// **'Der eigene Eintrag ist nicht gespeichert.'**
  String get coreTheCustomEntryHasNotBeenSaved;

  /// No description provided for @coreTheDataExportIsIncomplete.
  ///
  /// In de, this message translates to:
  /// **'Der Datenexport ist unvollständig.'**
  String get coreTheDataExportIsIncomplete;

  /// No description provided for @coreTheFoodEntryIsIncomplete.
  ///
  /// In de, this message translates to:
  /// **'Der Lebensmitteleintrag ist unvollständig.'**
  String get coreTheFoodEntryIsIncomplete;

  /// No description provided for @coreTheMealEntryHasNotBeenSaved.
  ///
  /// In de, this message translates to:
  /// **'Der Mahlzeiteneintrag ist nicht gespeichert.'**
  String get coreTheMealEntryHasNotBeenSaved;

  /// No description provided for @coreThePhotoIsTooLargePleaseChoose.
  ///
  /// In de, this message translates to:
  /// **'Das Foto ist zu groß. Bitte wähle ein kleineres Bild.'**
  String get coreThePhotoIsTooLargePleaseChoose;

  /// No description provided for @coreThePhotoIsTooLargePleaseTake.
  ///
  /// In de, this message translates to:
  /// **'Das Foto ist zu groß. Bitte nimm ein kleineres Bild auf.'**
  String get coreThePhotoIsTooLargePleaseTake;

  /// No description provided for @coreTheProductResponseWasIncomplete.
  ///
  /// In de, this message translates to:
  /// **'Die Produktantwort war unvollständig.'**
  String get coreTheProductResponseWasIncomplete;

  /// No description provided for @coreTheRecognisedValuesWereIncompletePleaseTry.
  ///
  /// In de, this message translates to:
  /// **'Die erkannten Werte waren unvollständig. Bitte versuche es erneut.'**
  String get coreTheRecognisedValuesWereIncompletePleaseTry;

  /// No description provided for @coreTheServerResponseIsInvalid.
  ///
  /// In de, this message translates to:
  /// **'Die Antwort des Servers ist ungültig.'**
  String get coreTheServerResponseIsInvalid;

  /// No description provided for @coreTheSignedInAccountHasChanged.
  ///
  /// In de, this message translates to:
  /// **'Das angemeldete Konto hat sich geändert.'**
  String get coreTheSignedInAccountHasChanged;

  /// No description provided for @coreThisAiFeatureIsPartOfLookin.
  ///
  /// In de, this message translates to:
  /// **'Diese KI-Funktion ist Teil von Lookin Premium.'**
  String get coreThisAiFeatureIsPartOfLookin;

  /// No description provided for @coreThisBarcodeIsInvalid.
  ///
  /// In de, this message translates to:
  /// **'Dieser Barcode ist ungültig.'**
  String get coreThisBarcodeIsInvalid;

  /// No description provided for @coreThisFoodCouldNoLongerBeFound.
  ///
  /// In de, this message translates to:
  /// **'Das Lebensmittel konnte nicht mehr gefunden werden.'**
  String get coreThisFoodCouldNoLongerBeFound;

  /// No description provided for @coreThisProductDoesNotMeetLookinS.
  ///
  /// In de, this message translates to:
  /// **'Dieses Produkt entspricht nicht den Halal-Inhaltsregeln von Lookin.'**
  String get coreThisProductDoesNotMeetLookinS;

  /// No description provided for @coreThisProductWasNotFound.
  ///
  /// In de, this message translates to:
  /// **'Dieses Produkt wurde nicht gefunden.'**
  String get coreThisProductWasNotFound;

  /// No description provided for @coreThisRecipeHasNoSavedIngredientsYet.
  ///
  /// In de, this message translates to:
  /// **'Dieses Rezept hat noch keine gespeicherten Zutaten.'**
  String get coreThisRecipeHasNoSavedIngredientsYet;

  /// No description provided for @coreUnknownNutritionBasis.
  ///
  /// In de, this message translates to:
  /// **'Unbekannte Nährwert-Basis.'**
  String get coreUnknownNutritionBasis;

  /// No description provided for @coreUnknownNutritionDataVersion.
  ///
  /// In de, this message translates to:
  /// **'Unbekannte Nährwert-Version.'**
  String get coreUnknownNutritionDataVersion;

  /// No description provided for @coreUsdaFoodData.
  ///
  /// In de, this message translates to:
  /// **'USDA-Lebensmitteldaten'**
  String get coreUsdaFoodData;

  /// No description provided for @coreWriteAShortQuestionFirst.
  ///
  /// In de, this message translates to:
  /// **'Schreib zuerst eine kurze Frage.'**
  String get coreWriteAShortQuestionFirst;

  /// No description provided for @coreYouHaveReachedTodaySAiLimit.
  ///
  /// In de, this message translates to:
  /// **'Dein KI-Limit für heute ist erreicht. Morgen kannst du wieder analysieren.'**
  String get coreYouHaveReachedTodaySAiLimit;

  /// No description provided for @coreYouHaveReachedYourDailyAiLimit.
  ///
  /// In de, this message translates to:
  /// **'Dein KI-Tageslimit ist erreicht. Morgen kannst du wieder schreiben.'**
  String get coreYouHaveReachedYourDailyAiLimit;

  /// No description provided for @coreYourAccountCouldNotBeDeleted.
  ///
  /// In de, this message translates to:
  /// **'Das Konto konnte nicht gelöscht werden.'**
  String get coreYourAccountCouldNotBeDeleted;

  /// No description provided for @coreYourAccountWasDeletedButSomeLocal.
  ///
  /// In de, this message translates to:
  /// **'Das Konto wurde gelöscht, aber lokale Daten konnten nicht vollständig entfernt werden.'**
  String get coreYourAccountWasDeletedButSomeLocal;

  /// No description provided for @coreYourChatHistoryCouldNotBeDeleted.
  ///
  /// In de, this message translates to:
  /// **'Dein Chatverlauf konnte gerade nicht gelöscht werden. Bitte versuche es gleich noch einmal.'**
  String get coreYourChatHistoryCouldNotBeDeleted;

  /// No description provided for @coreYourChatHistoryCouldNotBeLoaded.
  ///
  /// In de, this message translates to:
  /// **'Dein Chatverlauf konnte nicht geladen werden.'**
  String get coreYourChatHistoryCouldNotBeLoaded;

  /// No description provided for @coreYourChatHistoryCouldNotBeLoaded2.
  ///
  /// In de, this message translates to:
  /// **'Dein Chatverlauf konnte gerade nicht geladen werden.'**
  String get coreYourChatHistoryCouldNotBeLoaded2;

  /// No description provided for @coreYourMessageIsTooLongPleaseShorten.
  ///
  /// In de, this message translates to:
  /// **'Deine Nachricht ist zu lang. Bitte kürze sie auf höchstens {arg0} Zeichen.'**
  String coreYourMessageIsTooLongPleaseShorten(String arg0);

  /// No description provided for @coreYourProfilePictureMustBeAJpeg.
  ///
  /// In de, this message translates to:
  /// **'Das Profilbild muss ein JPEG mit höchstens 1 MB sein.'**
  String get coreYourProfilePictureMustBeAJpeg;

  /// No description provided for @coreYourSessionHasExpiredPleaseSignIn.
  ///
  /// In de, this message translates to:
  /// **'Deine Anmeldung ist abgelaufen. Bitte melde dich erneut an.'**
  String get coreYourSessionHasExpiredPleaseSignIn;

  /// No description provided for @diary10GLess.
  ///
  /// In de, this message translates to:
  /// **'10 g weniger'**
  String get diary10GLess;

  /// No description provided for @diary10GMore.
  ///
  /// In de, this message translates to:
  /// **'10 g mehr'**
  String get diary10GMore;

  /// No description provided for @diaryAdd.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get diaryAdd;

  /// No description provided for @diaryAddAtLeastOneFood.
  ///
  /// In de, this message translates to:
  /// **'Füge mindestens ein Lebensmittel hinzu.'**
  String get diaryAddAtLeastOneFood;

  /// No description provided for @diaryAddManually.
  ///
  /// In de, this message translates to:
  /// **'Selbst hinzufügen'**
  String get diaryAddManually;

  /// No description provided for @diaryAddMeal.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit hinzufügen'**
  String get diaryAddMeal;

  /// No description provided for @diaryAddToDiary.
  ///
  /// In de, this message translates to:
  /// **'Zum Tagebuch hinzufügen'**
  String get diaryAddToDiary;

  /// No description provided for @diaryAddToValue.
  ///
  /// In de, this message translates to:
  /// **'Zu {arg0} hinzufügen'**
  String diaryAddToValue(String arg0);

  /// No description provided for @diaryAddToValueValueKcal.
  ///
  /// In de, this message translates to:
  /// **'Zu {arg0} hinzufügen · {arg1} kcal'**
  String diaryAddToValueValueKcal(String arg0, String arg1);

  /// No description provided for @diaryAddedToValue.
  ///
  /// In de, this message translates to:
  /// **'Zu {arg0} hinzugefügt.'**
  String diaryAddedToValue(String arg0);

  /// No description provided for @diaryAiEstimate.
  ///
  /// In de, this message translates to:
  /// **'KI-Schätzung'**
  String get diaryAiEstimate;

  /// No description provided for @diaryAiIsRecognisingFoodsAndEstimatingAmounts.
  ///
  /// In de, this message translates to:
  /// **'KI erkennt Lebensmittel und schätzt die Mengen …'**
  String get diaryAiIsRecognisingFoodsAndEstimatingAmounts;

  /// No description provided for @diaryAiPhoto.
  ///
  /// In de, this message translates to:
  /// **'KI-Foto'**
  String get diaryAiPhoto;

  /// No description provided for @diaryAiPhotoRecognitionIsPartOfLookin.
  ///
  /// In de, this message translates to:
  /// **'Die KI-Foto-Erkennung ist Teil von Lookin Premium. Du kannst die Mahlzeit trotzdem über „Suchen“ oder „Selbst hinzufügen“ eintragen.'**
  String get diaryAiPhotoRecognitionIsPartOfLookin;

  /// No description provided for @diaryAiValuesAreEstimatesAPhotoCannot.
  ///
  /// In de, this message translates to:
  /// **'KI-Werte sind Schätzungen. Ein Foto ersetzt keine Waage oder Verpackungsangabe – prüfe Mengen und Nährwerte vor dem Speichern.'**
  String get diaryAiValuesAreEstimatesAPhotoCannot;

  /// No description provided for @diaryAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get diaryAll;

  /// No description provided for @diaryAllLabelValuesAreRequiredFibreIs.
  ///
  /// In de, this message translates to:
  /// **'Alle Etikettwerte sind erforderlich. Ballaststoffe sind freiwillig.'**
  String get diaryAllLabelValuesAreRequiredFibreIs;

  /// No description provided for @diaryAllergensAccordingToProductData.
  ///
  /// In de, this message translates to:
  /// **'Allergene laut Produktdaten'**
  String get diaryAllergensAccordingToProductData;

  /// No description provided for @diaryAllergyNotice.
  ///
  /// In de, this message translates to:
  /// **'Allergiehinweis'**
  String get diaryAllergyNotice;

  /// No description provided for @diaryAllergyNoticeValue.
  ///
  /// In de, this message translates to:
  /// **'Allergiehinweis: {arg0}'**
  String diaryAllergyNoticeValue(String arg0);

  /// No description provided for @diaryAlternativelyChooseAPhotoUsingGalleryBelow.
  ///
  /// In de, this message translates to:
  /// **'Alternativ unten über „Galerie“ ein Foto auswählen.'**
  String get diaryAlternativelyChooseAPhotoUsingGalleryBelow;

  /// No description provided for @diaryAmount.
  ///
  /// In de, this message translates to:
  /// **'Menge'**
  String get diaryAmount;

  /// No description provided for @diaryAmountEaten.
  ///
  /// In de, this message translates to:
  /// **'Gegessene Menge'**
  String get diaryAmountEaten;

  /// No description provided for @diaryAnotherMeal.
  ///
  /// In de, this message translates to:
  /// **'Weitere Mahlzeit'**
  String get diaryAnotherMeal;

  /// No description provided for @diaryCalories.
  ///
  /// In de, this message translates to:
  /// **'Kalorien'**
  String get diaryCalories;

  /// No description provided for @diaryCameraAccessWasNotAllowedAllowThe.
  ///
  /// In de, this message translates to:
  /// **'Der Kamerazugriff wurde nicht erlaubt. Erlaube die Kamera in den Browser- bzw. Geräteeinstellungen und versuche es erneut.'**
  String get diaryCameraAccessWasNotAllowedAllowThe;

  /// No description provided for @diaryCameraActiveHoldTheBarcodeInsideThe.
  ///
  /// In de, this message translates to:
  /// **'Kamera aktiv – Barcode in den Rahmen halten'**
  String get diaryCameraActiveHoldTheBarcodeInsideThe;

  /// No description provided for @diaryCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get diaryCancel;

  /// No description provided for @diaryCarbohydrates.
  ///
  /// In de, this message translates to:
  /// **'Kohlenhydrate'**
  String get diaryCarbohydrates;

  /// No description provided for @diaryCarbs.
  ///
  /// In de, this message translates to:
  /// **'Kohlenh.'**
  String get diaryCarbs;

  /// No description provided for @diaryCarbsG.
  ///
  /// In de, this message translates to:
  /// **'Kohlenhydrate g'**
  String get diaryCarbsG;

  /// No description provided for @diaryChangesAreSavedDirectlyToYourDiary.
  ///
  /// In de, this message translates to:
  /// **'Änderungen werden direkt in deinem Tagebuch gespeichert.'**
  String get diaryChangesAreSavedDirectlyToYourDiary;

  /// No description provided for @diaryChickpeaRiceBowl.
  ///
  /// In de, this message translates to:
  /// **'Kichererbsen-Reis-Bowl'**
  String get diaryChickpeaRiceBowl;

  /// No description provided for @diaryChooseFromGallery.
  ///
  /// In de, this message translates to:
  /// **'Aus Galerie wählen'**
  String get diaryChooseFromGallery;

  /// No description provided for @diaryClearSearch.
  ///
  /// In de, this message translates to:
  /// **'Suche löschen'**
  String get diaryClearSearch;

  /// No description provided for @diaryClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get diaryClose;

  /// No description provided for @diaryCopyTheNutritionValuesFromTheLabel.
  ///
  /// In de, this message translates to:
  /// **'Übernimm die Nährwerte vom Etikett. Wir rechnen deine gegessene Menge automatisch aus.'**
  String get diaryCopyTheNutritionValuesFromTheLabel;

  /// No description provided for @diaryCustomEntry.
  ///
  /// In de, this message translates to:
  /// **'Eigener Eintrag'**
  String get diaryCustomEntry;

  /// No description provided for @diaryDay.
  ///
  /// In de, this message translates to:
  /// **'Tag'**
  String get diaryDay;

  /// No description provided for @diaryDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get diaryDelete;

  /// No description provided for @diaryDeleteEntry.
  ///
  /// In de, this message translates to:
  /// **'Eintrag löschen?'**
  String get diaryDeleteEntry;

  /// No description provided for @diaryDeleteEntry2.
  ///
  /// In de, this message translates to:
  /// **'Eintrag löschen'**
  String get diaryDeleteEntry2;

  /// No description provided for @diaryDiary.
  ///
  /// In de, this message translates to:
  /// **'Tagebuch'**
  String get diaryDiary;

  /// No description provided for @diaryDuplicate.
  ///
  /// In de, this message translates to:
  /// **'Duplizieren'**
  String get diaryDuplicate;

  /// No description provided for @diaryEG05.
  ///
  /// In de, this message translates to:
  /// **'z. B. 0,5'**
  String get diaryEG05;

  /// No description provided for @diaryEG3017620422003.
  ///
  /// In de, this message translates to:
  /// **'z. B. 3017620422003'**
  String get diaryEG3017620422003;

  /// No description provided for @diaryEaten.
  ///
  /// In de, this message translates to:
  /// **'Gegessen'**
  String get diaryEaten;

  /// No description provided for @diaryEditMeal.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit bearbeiten'**
  String get diaryEditMeal;

  /// No description provided for @diaryEditRecipe.
  ///
  /// In de, this message translates to:
  /// **'Rezept bearbeiten'**
  String get diaryEditRecipe;

  /// No description provided for @diaryEditYourEntry.
  ///
  /// In de, this message translates to:
  /// **'Deinen Eintrag bearbeiten'**
  String get diaryEditYourEntry;

  /// No description provided for @diaryEnergy.
  ///
  /// In de, this message translates to:
  /// **'Energie'**
  String get diaryEnergy;

  /// No description provided for @diaryEnterBarcode.
  ///
  /// In de, this message translates to:
  /// **'Barcode eingeben'**
  String get diaryEnterBarcode;

  /// No description provided for @diaryEnterBarcodeManually.
  ///
  /// In de, this message translates to:
  /// **'Barcode manuell eingeben'**
  String get diaryEnterBarcodeManually;

  /// No description provided for @diaryEnterManually.
  ///
  /// In de, this message translates to:
  /// **'Selbst eintragen'**
  String get diaryEnterManually;

  /// No description provided for @diaryEnterManually2.
  ///
  /// In de, this message translates to:
  /// **'Manuell eintragen'**
  String get diaryEnterManually2;

  /// No description provided for @diaryEntryDeleted.
  ///
  /// In de, this message translates to:
  /// **'Eintrag wurde gelöscht.'**
  String get diaryEntryDeleted;

  /// No description provided for @diaryFat.
  ///
  /// In de, this message translates to:
  /// **'Fett'**
  String get diaryFat;

  /// No description provided for @diaryFatG.
  ///
  /// In de, this message translates to:
  /// **'Fett g'**
  String get diaryFatG;

  /// No description provided for @diaryFibre.
  ///
  /// In de, this message translates to:
  /// **'Ballaststoffe'**
  String get diaryFibre;

  /// No description provided for @diaryFibreOptional.
  ///
  /// In de, this message translates to:
  /// **'Ballaststoffe (optional)'**
  String get diaryFibreOptional;

  /// No description provided for @diaryFindAPackagedProductUsingItsBarcode.
  ///
  /// In de, this message translates to:
  /// **'Verpacktes Produkt über den Barcode finden'**
  String get diaryFindAPackagedProductUsingItsBarcode;

  /// No description provided for @diaryFood.
  ///
  /// In de, this message translates to:
  /// **'Lebensmittel'**
  String get diaryFood;

  /// No description provided for @diaryFoodPhoto.
  ///
  /// In de, this message translates to:
  /// **'Lebensmittel-Foto'**
  String get diaryFoodPhoto;

  /// No description provided for @diaryForExampleMyChocolateCereal.
  ///
  /// In de, this message translates to:
  /// **'Zum Beispiel: Mein Schoko-Müsli'**
  String get diaryForExampleMyChocolateCereal;

  /// No description provided for @diaryForTheAmountYouAte.
  ///
  /// In de, this message translates to:
  /// **'Für deine gegessene Menge'**
  String get diaryForTheAmountYouAte;

  /// No description provided for @diaryForWhichMeal.
  ///
  /// In de, this message translates to:
  /// **'Für welche Mahlzeit?'**
  String get diaryForWhichMeal;

  /// No description provided for @diaryFri.
  ///
  /// In de, this message translates to:
  /// **'Fr'**
  String get diaryFri;

  /// No description provided for @diaryFromSearch.
  ///
  /// In de, this message translates to:
  /// **'Aus der Suche'**
  String get diaryFromSearch;

  /// No description provided for @diaryGallery.
  ///
  /// In de, this message translates to:
  /// **'Galerie'**
  String get diaryGallery;

  /// No description provided for @diaryGreekYoghurt.
  ///
  /// In de, this message translates to:
  /// **'Griechischer Joghurt'**
  String get diaryGreekYoghurt;

  /// No description provided for @diaryHighInProtein.
  ///
  /// In de, this message translates to:
  /// **'Proteinreich'**
  String get diaryHighInProtein;

  /// No description provided for @diaryIngredientsList.
  ///
  /// In de, this message translates to:
  /// **'Zutatenliste'**
  String get diaryIngredientsList;

  /// No description provided for @diaryLeaveUnknownAdditionalValuesBlank.
  ///
  /// In de, this message translates to:
  /// **'Unbekannte Zusatzwerte bleiben leer.'**
  String get diaryLeaveUnknownAdditionalValuesBlank;

  /// No description provided for @diaryLight.
  ///
  /// In de, this message translates to:
  /// **'Leicht'**
  String get diaryLight;

  /// No description provided for @diaryLightFoods.
  ///
  /// In de, this message translates to:
  /// **'Leichte Lebensmittel'**
  String get diaryLightFoods;

  /// No description provided for @diaryLogAnyway.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem protokollieren'**
  String get diaryLogAnyway;

  /// No description provided for @diaryLogInDiary.
  ///
  /// In de, this message translates to:
  /// **'Ins Tagebuch eintragen'**
  String get diaryLogInDiary;

  /// No description provided for @diaryMeal.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit'**
  String get diaryMeal;

  /// No description provided for @diaryMealDuplicated.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit wurde dupliziert.'**
  String get diaryMealDuplicated;

  /// No description provided for @diaryMealName.
  ///
  /// In de, this message translates to:
  /// **'Name der Mahlzeit'**
  String get diaryMealName;

  /// No description provided for @diaryMealUpdated.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit wurde aktualisiert.'**
  String get diaryMealUpdated;

  /// No description provided for @diaryMeals.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeiten'**
  String get diaryMeals;

  /// No description provided for @diaryMon.
  ///
  /// In de, this message translates to:
  /// **'Mo'**
  String get diaryMon;

  /// No description provided for @diaryMoveMeal.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit verschieben'**
  String get diaryMoveMeal;

  /// No description provided for @diaryNewFood.
  ///
  /// In de, this message translates to:
  /// **'Neues Lebensmittel'**
  String get diaryNewFood;

  /// No description provided for @diaryNextWeek.
  ///
  /// In de, this message translates to:
  /// **'Nächste Woche'**
  String get diaryNextWeek;

  /// No description provided for @diaryNoCameraIsAvailableOnThisDevice.
  ///
  /// In de, this message translates to:
  /// **'Auf diesem Gerät ist keine Kamera verfügbar.'**
  String get diaryNoCameraIsAvailableOnThisDevice;

  /// No description provided for @diaryNoCameraWasFound.
  ///
  /// In de, this message translates to:
  /// **'Es wurde keine Kamera gefunden.'**
  String get diaryNoCameraWasFound;

  /// No description provided for @diaryNoFoodFoundYouCanAlsoLog.
  ///
  /// In de, this message translates to:
  /// **'Kein Lebensmittel gefunden. Du kannst es auch über „Selbst hinzufügen“ eintragen.'**
  String get diaryNoFoodFoundYouCanAlsoLog;

  /// No description provided for @diaryNoFoodsHaveBeenFoundInThis.
  ///
  /// In de, this message translates to:
  /// **'In diesem Bereich wurden noch keine Lebensmittel gefunden.'**
  String get diaryNoFoodsHaveBeenFoundInThis;

  /// No description provided for @diaryNoResultsCheckTheSpellingOrEnter.
  ///
  /// In de, this message translates to:
  /// **'Kein Treffer. Prüfe die Schreibweise oder trage das Lebensmittel selbst ein.'**
  String get diaryNoResultsCheckTheSpellingOrEnter;

  /// No description provided for @diaryNothingSavedYetSaveFoodsFromTheir.
  ///
  /// In de, this message translates to:
  /// **'Noch nichts gemerkt. Speichere Lebensmittel über die Detailansicht.'**
  String get diaryNothingSavedYetSaveFoodsFromTheir;

  /// No description provided for @diaryNothingUsedYetFoodsYouAddWill.
  ///
  /// In de, this message translates to:
  /// **'Noch nichts verwendet. Hinzugefügte Lebensmittel erscheinen später hier.'**
  String get diaryNothingUsedYetFoodsYouAddWill;

  /// No description provided for @diaryNutrition.
  ///
  /// In de, this message translates to:
  /// **'Nährwerte'**
  String get diaryNutrition;

  /// No description provided for @diaryNutritionValuesApplyToTheAmountSelected.
  ///
  /// In de, this message translates to:
  /// **'Nährwerte gelten für die oben eingestellte Menge.'**
  String get diaryNutritionValuesApplyToTheAmountSelected;

  /// No description provided for @diaryNutritionValuesValue.
  ///
  /// In de, this message translates to:
  /// **'Nährwerte {arg0}'**
  String diaryNutritionValuesValue(String arg0);

  /// No description provided for @diaryOfWhichSaturates.
  ///
  /// In de, this message translates to:
  /// **'davon gesättigte Fettsäuren'**
  String get diaryOfWhichSaturates;

  /// No description provided for @diaryOfWhichSugars.
  ///
  /// In de, this message translates to:
  /// **'davon Zucker'**
  String get diaryOfWhichSugars;

  /// No description provided for @diaryOnceYouEnterTheAmountEnergyAnd.
  ///
  /// In de, this message translates to:
  /// **'Sobald Menge, Energie und Makros eingetragen sind, siehst du hier die Berechnung.'**
  String get diaryOnceYouEnterTheAmountEnergyAnd;

  /// No description provided for @diaryPer100G.
  ///
  /// In de, this message translates to:
  /// **'Pro 100 g'**
  String get diaryPer100G;

  /// No description provided for @diaryPer100Ml.
  ///
  /// In de, this message translates to:
  /// **'Pro 100 ml'**
  String get diaryPer100Ml;

  /// No description provided for @diaryPerServing.
  ///
  /// In de, this message translates to:
  /// **'Pro Portion'**
  String get diaryPerServing;

  /// No description provided for @diaryPhotoAiCannotReliablyRecogniseHiddenAllergens.
  ///
  /// In de, this message translates to:
  /// **'Die Foto-KI kann Allergene, die man nicht sieht, oder Spuren nicht zuverlässig erkennen. Zutatenliste und Verpackung selbst prüfen.'**
  String get diaryPhotoAiCannotReliablyRecogniseHiddenAllergens;

  /// No description provided for @diaryPhotoFromGallery.
  ///
  /// In de, this message translates to:
  /// **'Foto aus Galerie'**
  String get diaryPhotoFromGallery;

  /// No description provided for @diaryPhotographTheWholeMealClearlyFromAbove.
  ///
  /// In de, this message translates to:
  /// **'Das ganze Essen gut sichtbar von oben aufnehmen.'**
  String get diaryPhotographTheWholeMealClearlyFromAbove;

  /// No description provided for @diaryPleaseCheckBriefly.
  ///
  /// In de, this message translates to:
  /// **'Bitte kurz prüfen'**
  String get diaryPleaseCheckBriefly;

  /// No description provided for @diaryPleaseCheckTheHighlightedFieldsAbove.
  ///
  /// In de, this message translates to:
  /// **'Bitte prüfe die markierten Felder weiter oben.'**
  String get diaryPleaseCheckTheHighlightedFieldsAbove;

  /// No description provided for @diaryPleaseCheckTheNutritionValuesForValue.
  ///
  /// In de, this message translates to:
  /// **'Bitte prüfe die Nährwerte von „{arg0}“.'**
  String diaryPleaseCheckTheNutritionValuesForValue(String arg0);

  /// No description provided for @diaryPleaseEnterANameAndValidPositive.
  ///
  /// In de, this message translates to:
  /// **'Bitte Name und gültige, positive Werte eintragen.'**
  String get diaryPleaseEnterANameAndValidPositive;

  /// No description provided for @diaryPleaseEnterAValidValueOf0.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen gültigen Wert ab 0 eingeben.'**
  String get diaryPleaseEnterAValidValueOf0;

  /// No description provided for @diaryPleaseEnterAnAmountGreaterThan0.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine Menge größer als 0 eingeben.'**
  String get diaryPleaseEnterAnAmountGreaterThan0;

  /// No description provided for @diaryPleaseEnterAnAmountGreaterThan02.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib für „{arg0}“ eine Menge über 0 g an.'**
  String diaryPleaseEnterAnAmountGreaterThan02(String arg0);

  /// No description provided for @diaryPleaseGiveEveryFoodAName.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib jedem Lebensmittel einen Namen.'**
  String get diaryPleaseGiveEveryFoodAName;

  /// No description provided for @diaryPleaseGiveYourFoodAName.
  ///
  /// In de, this message translates to:
  /// **'Bitte deinem Lebensmittel einen Namen geben.'**
  String get diaryPleaseGiveYourFoodAName;

  /// No description provided for @diaryPleaseUseNoMoreThan100Characters.
  ///
  /// In de, this message translates to:
  /// **'Bitte höchstens 100 Zeichen verwenden.'**
  String get diaryPleaseUseNoMoreThan100Characters;

  /// No description provided for @diaryPleaseWaitAMomentBeforeSearchingFor.
  ///
  /// In de, this message translates to:
  /// **'Bitte kurz warten, bevor du den nächsten Barcode suchst.'**
  String get diaryPleaseWaitAMomentBeforeSearchingFor;

  /// No description provided for @diaryPremiumFeature.
  ///
  /// In de, this message translates to:
  /// **'Premium-Funktion'**
  String get diaryPremiumFeature;

  /// No description provided for @diaryPreviousWeek.
  ///
  /// In de, this message translates to:
  /// **'Vorherige Woche'**
  String get diaryPreviousWeek;

  /// No description provided for @diaryProductInformation.
  ///
  /// In de, this message translates to:
  /// **'Produktinfos'**
  String get diaryProductInformation;

  /// No description provided for @diaryProtein.
  ///
  /// In de, this message translates to:
  /// **'Eiweiß / Protein'**
  String get diaryProtein;

  /// No description provided for @diaryProteinPasta.
  ///
  /// In de, this message translates to:
  /// **'Protein-Pasta'**
  String get diaryProteinPasta;

  /// No description provided for @diaryRecent.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt'**
  String get diaryRecent;

  /// No description provided for @diaryRecentlyUsed.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt verwendet'**
  String get diaryRecentlyUsed;

  /// No description provided for @diaryRecogniseMeal.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit erkennen'**
  String get diaryRecogniseMeal;

  /// No description provided for @diaryRecognisedFoods.
  ///
  /// In de, this message translates to:
  /// **'Erkannte Lebensmittel'**
  String get diaryRecognisedFoods;

  /// No description provided for @diaryRecognisedWell.
  ///
  /// In de, this message translates to:
  /// **'Gut erkannt'**
  String get diaryRecognisedWell;

  /// No description provided for @diaryRemaining.
  ///
  /// In de, this message translates to:
  /// **'Übrig'**
  String get diaryRemaining;

  /// No description provided for @diaryRemove.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get diaryRemove;

  /// No description provided for @diaryRemoveFromSavedFoods.
  ///
  /// In de, this message translates to:
  /// **'Von Merkliste entfernen'**
  String get diaryRemoveFromSavedFoods;

  /// No description provided for @diarySalt.
  ///
  /// In de, this message translates to:
  /// **'Salz'**
  String get diarySalt;

  /// No description provided for @diarySat.
  ///
  /// In de, this message translates to:
  /// **'Sa'**
  String get diarySat;

  /// No description provided for @diarySaturatedFat.
  ///
  /// In de, this message translates to:
  /// **'gesättigte Fettsäuren'**
  String get diarySaturatedFat;

  /// No description provided for @diarySaturatedFatCannotExceedTotalFat.
  ///
  /// In de, this message translates to:
  /// **'Gesättigte Fettsäuren dürfen Fett nicht überschreiten.'**
  String get diarySaturatedFatCannotExceedTotalFat;

  /// No description provided for @diarySave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get diarySave;

  /// No description provided for @diarySaveChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get diarySaveChanges;

  /// No description provided for @diarySaveFood.
  ///
  /// In de, this message translates to:
  /// **'Merken'**
  String get diarySaveFood;

  /// No description provided for @diarySaved.
  ///
  /// In de, this message translates to:
  /// **'Gemerkte'**
  String get diarySaved;

  /// No description provided for @diarySavedFoods.
  ///
  /// In de, this message translates to:
  /// **'Gemerkte Lebensmittel'**
  String get diarySavedFoods;

  /// No description provided for @diarySavedItemsRemoved.
  ///
  /// In de, this message translates to:
  /// **'Bereits gespeicherte Einträge wurden aus der Liste entfernt.'**
  String get diarySavedItemsRemoved;

  /// No description provided for @diarySaving.
  ///
  /// In de, this message translates to:
  /// **'Wird gespeichert …'**
  String get diarySaving;

  /// No description provided for @diarySaving2.
  ///
  /// In de, this message translates to:
  /// **'Wird gespeichert ...'**
  String get diarySaving2;

  /// No description provided for @diarySavingDidNotWorkPleaseTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Das Speichern hat nicht geklappt. Bitte versuche es erneut.'**
  String get diarySavingDidNotWorkPleaseTryAgain;

  /// No description provided for @diarySavingDidNotWorkYourInformationStays.
  ///
  /// In de, this message translates to:
  /// **'Das Speichern hat nicht geklappt. Deine Angaben bleiben hier erhalten.'**
  String get diarySavingDidNotWorkYourInformationStays;

  /// No description provided for @diarySavingFailedPleaseTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Speichern fehlgeschlagen. Bitte erneut versuchen.'**
  String get diarySavingFailedPleaseTryAgain;

  /// No description provided for @diaryScanBarcode.
  ///
  /// In de, this message translates to:
  /// **'Barcode scannen'**
  String get diaryScanBarcode;

  /// No description provided for @diarySearch.
  ///
  /// In de, this message translates to:
  /// **'Suchen'**
  String get diarySearch;

  /// No description provided for @diarySearchFoods.
  ///
  /// In de, this message translates to:
  /// **'Lebensmittel suchen'**
  String get diarySearchFoods;

  /// No description provided for @diarySearchForFoodsOrEnterThemYourself.
  ///
  /// In de, this message translates to:
  /// **'Lebensmittel suchen oder selbst eintragen'**
  String get diarySearchForFoodsOrEnterThemYourself;

  /// No description provided for @diarySearchResults.
  ///
  /// In de, this message translates to:
  /// **'Suchergebnisse'**
  String get diarySearchResults;

  /// No description provided for @diarySearchingForProduct.
  ///
  /// In de, this message translates to:
  /// **'Produkt wird gesucht ...'**
  String get diarySearchingForProduct;

  /// No description provided for @diarySelectMeal.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit auswählen'**
  String get diarySelectMeal;

  /// No description provided for @diaryServingBasis.
  ///
  /// In de, this message translates to:
  /// **'BASIS: {grams} G'**
  String diaryServingBasis(int grams);

  /// No description provided for @diaryServings.
  ///
  /// In de, this message translates to:
  /// **'Portionen'**
  String get diaryServings;

  /// No description provided for @diaryServingsEaten.
  ///
  /// In de, this message translates to:
  /// **'Gegessene Portionen'**
  String get diaryServingsEaten;

  /// No description provided for @diarySourceOpenFoodFactsInformationMayBe.
  ///
  /// In de, this message translates to:
  /// **'Quelle: Open Food Facts. Angaben können fehlen oder sich ändern – bei Allergien und Unverträglichkeiten immer das Verpackungsetikett prüfen.'**
  String get diarySourceOpenFoodFactsInformationMayBe;

  /// No description provided for @diarySugar.
  ///
  /// In de, this message translates to:
  /// **'Zucker'**
  String get diarySugar;

  /// No description provided for @diarySugarCannotExceedCarbohydrates.
  ///
  /// In de, this message translates to:
  /// **'Zucker darf die Kohlenhydrate nicht überschreiten.'**
  String get diarySugarCannotExceedCarbohydrates;

  /// No description provided for @diarySun.
  ///
  /// In de, this message translates to:
  /// **'So'**
  String get diarySun;

  /// No description provided for @diarySwitch.
  ///
  /// In de, this message translates to:
  /// **'Wechseln'**
  String get diarySwitch;

  /// No description provided for @diaryTakeAMealPhoto.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit fotografieren'**
  String get diaryTakeAMealPhoto;

  /// No description provided for @diaryTakeANewPhoto.
  ///
  /// In de, this message translates to:
  /// **'Neues Foto aufnehmen'**
  String get diaryTakeANewPhoto;

  /// No description provided for @diaryTakeAPhotoAiEstimatesFoodsAnd.
  ///
  /// In de, this message translates to:
  /// **'Foto machen, KI schätzt Lebensmittel und Mengen'**
  String get diaryTakeAPhotoAiEstimatesFoodsAnd;

  /// No description provided for @diaryTakeAPhotoOfYourMealAi.
  ///
  /// In de, this message translates to:
  /// **'Fotografiere deine Mahlzeit – die KI schätzt Lebensmittel und Mengen.'**
  String get diaryTakeAPhotoOfYourMealAi;

  /// No description provided for @diaryTakePhoto.
  ///
  /// In de, this message translates to:
  /// **'Foto aufnehmen'**
  String get diaryTakePhoto;

  /// No description provided for @diaryTapAFoodToChangeItsName.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf ein Lebensmittel, um Name und Nährwerte zu ändern. Wenn du die Menge änderst, passen sich Kalorien und Nährwerte automatisch an.'**
  String get diaryTapAFoodToChangeItsName;

  /// No description provided for @diaryTheAvailableInformationMayMentionValueIf.
  ///
  /// In de, this message translates to:
  /// **'Die verfügbaren Angaben nennen möglicherweise: {arg0}. Bei einer Allergie nicht als Empfehlung verstehen. Nur fortfahren, wenn du das Essen dokumentieren möchtest.'**
  String diaryTheAvailableInformationMayMentionValueIf(String arg0);

  /// No description provided for @diaryTheBarcodeCouldNotBeProcessedJust.
  ///
  /// In de, this message translates to:
  /// **'Barcode konnte gerade nicht verarbeitet werden.'**
  String get diaryTheBarcodeCouldNotBeProcessedJust;

  /// No description provided for @diaryTheCameraCouldNotBeStarted.
  ///
  /// In de, this message translates to:
  /// **'Die Kamera konnte nicht gestartet werden.'**
  String get diaryTheCameraCouldNotBeStarted;

  /// No description provided for @diaryTheFoodCouldNotBeSaved.
  ///
  /// In de, this message translates to:
  /// **'Das Lebensmittel konnte nicht gespeichert werden.'**
  String get diaryTheFoodCouldNotBeSaved;

  /// No description provided for @diaryTheLabelValuesBelowArePer100.
  ///
  /// In de, this message translates to:
  /// **'Unten stehen die Etikettwerte pro 100 g.'**
  String get diaryTheLabelValuesBelowArePer100;

  /// No description provided for @diaryTheLabelValuesBelowArePer1002.
  ///
  /// In de, this message translates to:
  /// **'Unten stehen die Etikettwerte pro 100 ml.'**
  String get diaryTheLabelValuesBelowArePer1002;

  /// No description provided for @diaryTheMealCouldNotBeDuplicated.
  ///
  /// In de, this message translates to:
  /// **'Die Mahlzeit konnte nicht dupliziert werden.'**
  String get diaryTheMealCouldNotBeDuplicated;

  /// No description provided for @diaryTheMealCouldNotBeSaved.
  ///
  /// In de, this message translates to:
  /// **'Die Mahlzeit konnte nicht gespeichert werden.'**
  String get diaryTheMealCouldNotBeSaved;

  /// No description provided for @diaryTheNameYouEnteredSuggestsAPossible.
  ///
  /// In de, this message translates to:
  /// **'Der eingegebene Name deutet auf einen möglichen Konflikt: {arg0}. Die Nährwertangaben enthalten keine verlässliche Zutatenprüfung.'**
  String diaryTheNameYouEnteredSuggestsAPossible(String arg0);

  /// No description provided for @diaryThePhotoCouldNotBeAnalysedJust.
  ///
  /// In de, this message translates to:
  /// **'Das Foto konnte gerade nicht analysiert werden.'**
  String get diaryThePhotoCouldNotBeAnalysedJust;

  /// No description provided for @diaryThePhotoCouldNotBeTaken.
  ///
  /// In de, this message translates to:
  /// **'Foto konnte nicht aufgenommen werden.'**
  String get diaryThePhotoCouldNotBeTaken;

  /// No description provided for @diaryTheProductInformationMayMentionValueOnly.
  ///
  /// In de, this message translates to:
  /// **'Die Produktdaten nennen möglicherweise: {arg0}. Nur fortfahren, wenn du das Lebensmittel bereits gegessen hast und es lediglich dokumentieren möchtest. Prüfe die Verpackung.'**
  String diaryTheProductInformationMayMentionValueOnly(String arg0);

  /// No description provided for @diaryTheRecognisedNamesMayMatchYourProfile.
  ///
  /// In de, this message translates to:
  /// **'Die erkannten Namen können zu deinem Profil passen: {arg0}. KI-Fotos können versteckte Zutaten und Spuren nicht erkennen. Nur fortfahren, wenn du die Mahlzeit dokumentieren möchtest.'**
  String diaryTheRecognisedNamesMayMatchYourProfile(String arg0);

  /// No description provided for @diaryTheValuesBelowAreForAWhole.
  ///
  /// In de, this message translates to:
  /// **'Unten stehen die Werte für eine ganze Portion. Eine halbe Portion ist 0,5.'**
  String get diaryTheValuesBelowAreForAWhole;

  /// No description provided for @diaryThisPhotoCouldNotBeRead.
  ///
  /// In de, this message translates to:
  /// **'Dieses Foto konnte nicht gelesen werden.'**
  String get diaryThisPhotoCouldNotBeRead;

  /// No description provided for @diaryThisProductDoesNotMeetLookinS.
  ///
  /// In de, this message translates to:
  /// **'Dieses Produkt entspricht nicht den Halal-Inhaltsregeln von Lookin.'**
  String get diaryThisProductDoesNotMeetLookinS;

  /// No description provided for @diaryThisProductIsNotInTheData.
  ///
  /// In de, this message translates to:
  /// **'Dieses Produkt ist noch nicht in der Datenquelle. Du kannst es selbst eintragen.'**
  String get diaryThisProductIsNotInTheData;

  /// No description provided for @diaryThu.
  ///
  /// In de, this message translates to:
  /// **'Do'**
  String get diaryThu;

  /// No description provided for @diaryTotalKcal.
  ///
  /// In de, this message translates to:
  /// **'kcal gesamt'**
  String get diaryTotalKcal;

  /// No description provided for @diaryTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get diaryTryAgain;

  /// No description provided for @diaryTue.
  ///
  /// In de, this message translates to:
  /// **'Di'**
  String get diaryTue;

  /// No description provided for @diaryUncertainPleaseCheck.
  ///
  /// In de, this message translates to:
  /// **'Unsicher – bitte prüfen'**
  String get diaryUncertainPleaseCheck;

  /// No description provided for @diaryUnknown.
  ///
  /// In de, this message translates to:
  /// **'Nicht bekannt'**
  String get diaryUnknown;

  /// No description provided for @diaryValueGCarbs.
  ///
  /// In de, this message translates to:
  /// **'{arg0} g Kohlenhydrate'**
  String diaryValueGCarbs(String arg0);

  /// No description provided for @diaryValueGFat.
  ///
  /// In de, this message translates to:
  /// **'{arg0} g Fett'**
  String diaryValueGFat(String arg0);

  /// No description provided for @diaryValueGProtein.
  ///
  /// In de, this message translates to:
  /// **'{arg0} g Protein'**
  String diaryValueGProtein(String arg0);

  /// No description provided for @diaryValueKcalCValueGPValue.
  ///
  /// In de, this message translates to:
  /// **'{arg0} kcal · K {arg1} g · P {arg2} g · F {arg3} g'**
  String diaryValueKcalCValueGPValue(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  );

  /// No description provided for @diaryValueKcalValueGValueGProtein.
  ///
  /// In de, this message translates to:
  /// **'{arg0} kcal · {arg1} g · {arg2} g Protein'**
  String diaryValueKcalValueGValueGProtein(
    String arg0,
    String arg1,
    String arg2,
  );

  /// No description provided for @diaryValueOf8Glasses.
  ///
  /// In de, this message translates to:
  /// **'{arg0} von 8 Gläsern'**
  String diaryValueOf8Glasses(String arg0);

  /// No description provided for @diaryValueValuePValueCValueF.
  ///
  /// In de, this message translates to:
  /// **'{arg0}{arg1} P · {arg2} K · {arg3} F'**
  String diaryValueValuePValueCValueF(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  );

  /// No description provided for @diaryValueWasAdded.
  ///
  /// In de, this message translates to:
  /// **'{arg0} wurde hinzugefügt.'**
  String diaryValueWasAdded(String arg0);

  /// No description provided for @diaryValueWillBeRemovedFromYourDiary.
  ///
  /// In de, this message translates to:
  /// **'„{arg0}“ wird aus deinem Tagebuch entfernt.'**
  String diaryValueWillBeRemovedFromYourDiary(String arg0);

  /// No description provided for @diaryVegetableOmelette.
  ///
  /// In de, this message translates to:
  /// **'Gemüse-Omelett'**
  String get diaryVegetableOmelette;

  /// No description provided for @diaryViewPremium.
  ///
  /// In de, this message translates to:
  /// **'Premium ansehen'**
  String get diaryViewPremium;

  /// No description provided for @diaryWater.
  ///
  /// In de, this message translates to:
  /// **'Wasser'**
  String get diaryWater;

  /// No description provided for @diaryWed.
  ///
  /// In de, this message translates to:
  /// **'Mi'**
  String get diaryWed;

  /// No description provided for @diaryWhatDoTheValuesReferTo.
  ///
  /// In de, this message translates to:
  /// **'Worauf beziehen sich die Werte?'**
  String get diaryWhatDoTheValuesReferTo;

  /// No description provided for @diaryWhichMeal.
  ///
  /// In de, this message translates to:
  /// **'Zu welcher Mahlzeit?'**
  String get diaryWhichMeal;

  /// No description provided for @diaryWholemealBreadWithEgg.
  ///
  /// In de, this message translates to:
  /// **'Vollkornbrot mit Ei'**
  String get diaryWholemealBreadWithEgg;

  /// No description provided for @diaryYouAreAboveYourDailyTargetThis.
  ///
  /// In de, this message translates to:
  /// **'Du liegst über deinem Tagesziel. Das ist eine Orientierung, keine Bewertung.'**
  String get diaryYouAreAboveYourDailyTargetThis;

  /// No description provided for @diaryYouCanChangeTheMealTypeIngredients.
  ///
  /// In de, this message translates to:
  /// **'Die Mahlzeitenart kann angepasst werden. Zutaten und Werte bleiben mit dem Rezept verbunden.'**
  String get diaryYouCanChangeTheMealTypeIngredients;

  /// No description provided for @diaryYourCustomFood.
  ///
  /// In de, this message translates to:
  /// **'Dein eigenes Lebensmittel'**
  String get diaryYourCustomFood;

  /// No description provided for @diaryYourMeal.
  ///
  /// In de, this message translates to:
  /// **'Deine Mahlzeit'**
  String get diaryYourMeal;

  /// No description provided for @diaryYourMealRhythm.
  ///
  /// In de, this message translates to:
  /// **'Dein Mahlzeitenrhythmus'**
  String get diaryYourMealRhythm;

  /// No description provided for @diaryYourMealsClearlyOrganisedAndEasyTo.
  ///
  /// In de, this message translates to:
  /// **'Deine Mahlzeiten klar und ohne unnötigen Aufwand.'**
  String get diaryYourMealsClearlyOrganisedAndEasyTo;

  /// No description provided for @diaryYourPreferenceNotARequirementYouCan.
  ///
  /// In de, this message translates to:
  /// **'Dein Wunsch, kein Muss. Du kannst jederzeit weitere Mahlzeiten eintragen.'**
  String get diaryYourPreferenceNotARequirementYouCan;

  /// No description provided for @diaryYourPreviousValuesApplyToOneServing.
  ///
  /// In de, this message translates to:
  /// **'Deine bisherigen Werte gelten für eine Portion. Fehlende Etikettwerte kannst du ergänzen.'**
  String get diaryYourPreviousValuesApplyToOneServing;

  /// No description provided for @discover1Ingredient.
  ///
  /// In de, this message translates to:
  /// **'1 Zutat'**
  String get discover1Ingredient;

  /// No description provided for @discover1IngredientMissing.
  ///
  /// In de, this message translates to:
  /// **'1 Zutat fehlt'**
  String get discover1IngredientMissing;

  /// No description provided for @discover1Recipe.
  ///
  /// In de, this message translates to:
  /// **'1 Rezept'**
  String get discover1Recipe;

  /// No description provided for @discover1ServingIsNowListedUnderValue.
  ///
  /// In de, this message translates to:
  /// **'1 Portion steht jetzt unter „{arg0}“ im Tagebuch.'**
  String discover1ServingIsNowListedUnderValue(String arg0);

  /// No description provided for @discover1ServingValueKcalValueGProtein.
  ///
  /// In de, this message translates to:
  /// **'1 Portion · {arg0} kcal · {arg1} g Protein'**
  String discover1ServingValueKcalValueGProtein(String arg0, String arg1);

  /// No description provided for @discover1Step.
  ///
  /// In de, this message translates to:
  /// **'1 Schritt'**
  String get discover1Step;

  /// No description provided for @discoverAdaptToMyTarget.
  ///
  /// In de, this message translates to:
  /// **'An mein Ziel anpassen'**
  String get discoverAdaptToMyTarget;

  /// No description provided for @discoverAdaptToMyTargetValue.
  ///
  /// In de, this message translates to:
  /// **'An mein Ziel anpassen · {arg0}'**
  String discoverAdaptToMyTargetValue(String arg0);

  /// No description provided for @discoverAddIngredient.
  ///
  /// In de, this message translates to:
  /// **'Zutat hinzufügen'**
  String get discoverAddIngredient;

  /// No description provided for @discoverAddToFavourites.
  ///
  /// In de, this message translates to:
  /// **'Zu Favoriten hinzufügen'**
  String get discoverAddToFavourites;

  /// No description provided for @discoverAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get discoverAll;

  /// No description provided for @discoverAllRecipes.
  ///
  /// In de, this message translates to:
  /// **'Alle Rezepte'**
  String get discoverAllRecipes;

  /// No description provided for @discoverAllergyLogWarning.
  ///
  /// In de, this message translates to:
  /// **'Die Zutatenangaben nennen möglicherweise: {conflicts}. Prüfe die Packungen und mögliche Kreuzkontamination. Möchtest du das Rezept trotzdem protokollieren?'**
  String discoverAllergyLogWarning(String conflicts);

  /// No description provided for @discoverAllergyNotice.
  ///
  /// In de, this message translates to:
  /// **'Allergiehinweis'**
  String get discoverAllergyNotice;

  /// No description provided for @discoverAny.
  ///
  /// In de, this message translates to:
  /// **'Egal'**
  String get discoverAny;

  /// No description provided for @discoverApples.
  ///
  /// In de, this message translates to:
  /// **'Äpfel'**
  String get discoverApples;

  /// No description provided for @discoverApply.
  ///
  /// In de, this message translates to:
  /// **'Übernehmen'**
  String get discoverApply;

  /// No description provided for @discoverApproxValue.
  ///
  /// In de, this message translates to:
  /// **'ca. {arg0}'**
  String discoverApproxValue(String arg0);

  /// No description provided for @discoverApproxValueKcal.
  ///
  /// In de, this message translates to:
  /// **'ca. {arg0} kcal'**
  String discoverApproxValueKcal(String arg0);

  /// No description provided for @discoverApproxValueValueProtein.
  ///
  /// In de, this message translates to:
  /// **'ca. {arg0} · {arg1} Protein'**
  String discoverApproxValueValueProtein(String arg0, String arg1);

  /// No description provided for @discoverAsInTheOriginalRecipe.
  ///
  /// In de, this message translates to:
  /// **'wie im Originalrezept'**
  String get discoverAsInTheOriginalRecipe;

  /// No description provided for @discoverBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get discoverBack;

  /// No description provided for @discoverBag.
  ///
  /// In de, this message translates to:
  /// **'Beutel'**
  String get discoverBag;

  /// No description provided for @discoverBalls.
  ///
  /// In de, this message translates to:
  /// **'Kugeln'**
  String get discoverBalls;

  /// No description provided for @discoverBananas.
  ///
  /// In de, this message translates to:
  /// **'Bananen'**
  String get discoverBananas;

  /// No description provided for @discoverBasedOnValueMealsADayWith.
  ///
  /// In de, this message translates to:
  /// **'Grundlage: {arg0} Mahlzeiten am Tag, davon {arg1} schon im Tagebuch. Das ist eine Schätzung zur Orientierung und keine Ernährungsberatung – hör auch auf deinen Hunger. „Übernehmen“ rechnet nur die Zutatenmengen um; ins Tagebuch wird weiterhin 1 Portion eingetragen.'**
  String discoverBasedOnValueMealsADayWith(String arg0, String arg1);

  /// No description provided for @discoverBasicIngredients.
  ///
  /// In de, this message translates to:
  /// **'Grundzutaten'**
  String get discoverBasicIngredients;

  /// No description provided for @discoverBasicIngredientsAreAvailable.
  ///
  /// In de, this message translates to:
  /// **'Grundzutaten sind vorhanden'**
  String get discoverBasicIngredientsAreAvailable;

  /// No description provided for @discoverBreadRoll.
  ///
  /// In de, this message translates to:
  /// **'Brötchen'**
  String get discoverBreadRoll;

  /// No description provided for @discoverBulbs.
  ///
  /// In de, this message translates to:
  /// **'Knollen'**
  String get discoverBulbs;

  /// No description provided for @discoverBunch.
  ///
  /// In de, this message translates to:
  /// **'Bund'**
  String get discoverBunch;

  /// No description provided for @discoverCalculatedFromTheIngredientsValuesMayVary.
  ///
  /// In de, this message translates to:
  /// **'Berechnet aus den Zutaten. Je nach Produkt und Zubereitung können die Werte abweichen.'**
  String get discoverCalculatedFromTheIngredientsValuesMayVary;

  /// No description provided for @discoverCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get discoverCancel;

  /// No description provided for @discoverCarbohydrates.
  ///
  /// In de, this message translates to:
  /// **'Kohlenhydrate'**
  String get discoverCarbohydrates;

  /// No description provided for @discoverCarrots.
  ///
  /// In de, this message translates to:
  /// **'Karotten'**
  String get discoverCarrots;

  /// No description provided for @discoverCarrots2.
  ///
  /// In de, this message translates to:
  /// **'Möhren'**
  String get discoverCarrots2;

  /// No description provided for @discoverChillies.
  ///
  /// In de, this message translates to:
  /// **'Chilischoten'**
  String get discoverChillies;

  /// No description provided for @discoverClearSearch.
  ///
  /// In de, this message translates to:
  /// **'Suche löschen'**
  String get discoverClearSearch;

  /// No description provided for @discoverClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get discoverClose;

  /// No description provided for @discoverCloves.
  ///
  /// In de, this message translates to:
  /// **'Zehen'**
  String get discoverCloves;

  /// No description provided for @discoverCommonIngredients.
  ///
  /// In de, this message translates to:
  /// **'Häufige Zutaten'**
  String get discoverCommonIngredients;

  /// No description provided for @discoverCommonMistakes.
  ///
  /// In de, this message translates to:
  /// **'Häufige Fehler'**
  String get discoverCommonMistakes;

  /// No description provided for @discoverContinue.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get discoverContinue;

  /// No description provided for @discoverCooking.
  ///
  /// In de, this message translates to:
  /// **'Kochen'**
  String get discoverCooking;

  /// No description provided for @discoverCookingModeValue.
  ///
  /// In de, this message translates to:
  /// **'Kochmodus · {arg0}'**
  String discoverCookingModeValue(String arg0);

  /// No description provided for @discoverCookingModeWithTimers.
  ///
  /// In de, this message translates to:
  /// **'Kochmodus mit Timern'**
  String get discoverCookingModeWithTimers;

  /// No description provided for @discoverCube.
  ///
  /// In de, this message translates to:
  /// **'Würfel'**
  String get discoverCube;

  /// No description provided for @discoverCucumbers.
  ///
  /// In de, this message translates to:
  /// **'Gurken'**
  String get discoverCucumbers;

  /// No description provided for @discoverCups.
  ///
  /// In de, this message translates to:
  /// **'Tassen'**
  String get discoverCups;

  /// No description provided for @discoverDash.
  ///
  /// In de, this message translates to:
  /// **'Spritzer'**
  String get discoverDash;

  /// No description provided for @discoverDifficulty.
  ///
  /// In de, this message translates to:
  /// **'Schwierigkeit'**
  String get discoverDifficulty;

  /// No description provided for @discoverDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get discoverDone;

  /// No description provided for @discoverDurationValue.
  ///
  /// In de, this message translates to:
  /// **'Dauer {arg0}'**
  String discoverDurationValue(String arg0);

  /// No description provided for @discoverEggs.
  ///
  /// In de, this message translates to:
  /// **'Eier'**
  String get discoverEggs;

  /// No description provided for @discoverEnergy.
  ///
  /// In de, this message translates to:
  /// **'Energie'**
  String get discoverEnergy;

  /// No description provided for @discoverEnergyShare.
  ///
  /// In de, this message translates to:
  /// **'Anteil an der Energie'**
  String get discoverEnergyShare;

  /// No description provided for @discoverEnjoyYourMeal.
  ///
  /// In de, this message translates to:
  /// **'Guten Appetit!'**
  String get discoverEnjoyYourMeal;

  /// No description provided for @discoverEnterAnIngredientEGPotatoes.
  ///
  /// In de, this message translates to:
  /// **'Zutat eingeben, z. B. Kartoffeln'**
  String get discoverEnterAnIngredientEGPotatoes;

  /// No description provided for @discoverEquipment.
  ///
  /// In de, this message translates to:
  /// **'Utensilien'**
  String get discoverEquipment;

  /// No description provided for @discoverEverythingAvailable.
  ///
  /// In de, this message translates to:
  /// **'Alles da'**
  String get discoverEverythingAvailable;

  /// No description provided for @discoverExit.
  ///
  /// In de, this message translates to:
  /// **'Beenden'**
  String get discoverExit;

  /// No description provided for @discoverExitCookingMode.
  ///
  /// In de, this message translates to:
  /// **'Kochmodus beenden?'**
  String get discoverExitCookingMode;

  /// No description provided for @discoverExitCookingMode2.
  ///
  /// In de, this message translates to:
  /// **'Kochmodus beenden'**
  String get discoverExitCookingMode2;

  /// No description provided for @discoverExtraKnowledgeAboutThisRecipe.
  ///
  /// In de, this message translates to:
  /// **'Extra-Wissen zu diesem Rezept.'**
  String get discoverExtraKnowledgeAboutThisRecipe;

  /// No description provided for @discoverFat.
  ///
  /// In de, this message translates to:
  /// **'Fett'**
  String get discoverFat;

  /// No description provided for @discoverFavourites.
  ///
  /// In de, this message translates to:
  /// **'Favoriten'**
  String get discoverFavourites;

  /// No description provided for @discoverFibre.
  ///
  /// In de, this message translates to:
  /// **'Ballaststoffe'**
  String get discoverFibre;

  /// No description provided for @discoverFillets.
  ///
  /// In de, this message translates to:
  /// **'Filets'**
  String get discoverFillets;

  /// No description provided for @discoverFiltersAndSorting.
  ///
  /// In de, this message translates to:
  /// **'Filter und Sortierung'**
  String get discoverFiltersAndSorting;

  /// No description provided for @discoverFiltersAndSortingValueActive.
  ///
  /// In de, this message translates to:
  /// **'Filter und Sortierung, {arg0} aktiv'**
  String discoverFiltersAndSortingValueActive(String arg0);

  /// No description provided for @discoverFiltersSorting.
  ///
  /// In de, this message translates to:
  /// **'Filter & Sortierung'**
  String get discoverFiltersSorting;

  /// No description provided for @discoverFlatbreads.
  ///
  /// In de, this message translates to:
  /// **'Fladenbrote'**
  String get discoverFlatbreads;

  /// No description provided for @discoverForThisMeal.
  ///
  /// In de, this message translates to:
  /// **'Für diese Mahlzeit'**
  String get discoverForThisMeal;

  /// No description provided for @discoverForValue.
  ///
  /// In de, this message translates to:
  /// **'für {arg0}'**
  String discoverForValue(String arg0);

  /// No description provided for @discoverForYou.
  ///
  /// In de, this message translates to:
  /// **'Für dich'**
  String get discoverForYou;

  /// No description provided for @discoverGlasses.
  ///
  /// In de, this message translates to:
  /// **'Gläser'**
  String get discoverGlasses;

  /// No description provided for @discoverGoToStepValue.
  ///
  /// In de, this message translates to:
  /// **'Zu Schritt {arg0}'**
  String discoverGoToStepValue(String arg0);

  /// No description provided for @discoverGuidelineValues.
  ///
  /// In de, this message translates to:
  /// **'Richtwerte'**
  String get discoverGuidelineValues;

  /// No description provided for @discoverHandful.
  ///
  /// In de, this message translates to:
  /// **'Handvoll'**
  String get discoverHandful;

  /// No description provided for @discoverHiddenForAllergies.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Rezept} other{{count} Rezepte}} wegen deiner Allergieangaben ausgeblendet.'**
  String discoverHiddenForAllergies(int count);

  /// No description provided for @discoverHowThisSuggestionWasCalculated.
  ///
  /// In de, this message translates to:
  /// **'So ist der Vorschlag entstanden'**
  String get discoverHowThisSuggestionWasCalculated;

  /// No description provided for @discoverIHaveThese.
  ///
  /// In de, this message translates to:
  /// **'Das habe ich da'**
  String get discoverIHaveThese;

  /// No description provided for @discoverIdeasThatFitYourGoalAndYour.
  ///
  /// In de, this message translates to:
  /// **'Ideen, die zu deinem Ziel und deinem Alltag passen.'**
  String get discoverIdeasThatFitYourGoalAndYour;

  /// No description provided for @discoverIngredientAmountsHaveNotBeenAddedFor.
  ///
  /// In de, this message translates to:
  /// **'Für dieses Rezept sind noch keine Zutatenmengen hinterlegt.'**
  String get discoverIngredientAmountsHaveNotBeenAddedFor;

  /// No description provided for @discoverIngredientSubstitutions.
  ///
  /// In de, this message translates to:
  /// **'Austausch-Zutaten'**
  String get discoverIngredientSubstitutions;

  /// No description provided for @discoverIngredients.
  ///
  /// In de, this message translates to:
  /// **'Zutaten'**
  String get discoverIngredients;

  /// No description provided for @discoverKeepCooking.
  ///
  /// In de, this message translates to:
  /// **'Weiterkochen'**
  String get discoverKeepCooking;

  /// No description provided for @discoverLeaves.
  ///
  /// In de, this message translates to:
  /// **'Blätter'**
  String get discoverLeaves;

  /// No description provided for @discoverLemons.
  ///
  /// In de, this message translates to:
  /// **'Zitronen'**
  String get discoverLemons;

  /// No description provided for @discoverLimes.
  ///
  /// In de, this message translates to:
  /// **'Limetten'**
  String get discoverLimes;

  /// No description provided for @discoverLog.
  ///
  /// In de, this message translates to:
  /// **'Eintragen'**
  String get discoverLog;

  /// No description provided for @discoverLog1ServingInDiary.
  ///
  /// In de, this message translates to:
  /// **'1 Portion zum Tagebuch'**
  String get discoverLog1ServingInDiary;

  /// No description provided for @discoverLogAnyway.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem protokollieren'**
  String get discoverLogAnyway;

  /// No description provided for @discoverLoggedToday.
  ///
  /// In de, this message translates to:
  /// **'Heute eingetragen'**
  String get discoverLoggedToday;

  /// No description provided for @discoverMatchingRecipes.
  ///
  /// In de, this message translates to:
  /// **'Passende Rezepte'**
  String get discoverMatchingRecipes;

  /// No description provided for @discoverMaximumPreparationTime.
  ///
  /// In de, this message translates to:
  /// **'Maximale Zubereitungszeit'**
  String get discoverMaximumPreparationTime;

  /// No description provided for @discoverMealPrepStorage.
  ///
  /// In de, this message translates to:
  /// **'Meal-Prep & Aufbewahrung'**
  String get discoverMealPrepStorage;

  /// No description provided for @discoverMealsStillToComeToday.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeiten, die heute noch kommen'**
  String get discoverMealsStillToComeToday;

  /// No description provided for @discoverMethod.
  ///
  /// In de, this message translates to:
  /// **'Zubereitung'**
  String get discoverMethod;

  /// No description provided for @discoverMissing.
  ///
  /// In de, this message translates to:
  /// **'Fehlt'**
  String get discoverMissing;

  /// No description provided for @discoverMissingNutrition.
  ///
  /// In de, this message translates to:
  /// **'Pro Portion, aus den Katalogwerten der Zutaten. {count, plural, =1{1 Zutat hat keine Katalogwerte und fehlt hier.} other{{count} Zutaten haben keine Katalogwerte und fehlen hier.}}'**
  String discoverMissingNutrition(int count);

  /// No description provided for @discoverMoreKnowledgeForEveryRecipe.
  ///
  /// In de, this message translates to:
  /// **'Mehr Wissen zu jedem Rezept'**
  String get discoverMoreKnowledgeForEveryRecipe;

  /// No description provided for @discoverNoInstructionsHaveBeenAddedForThis.
  ///
  /// In de, this message translates to:
  /// **'Für dieses Rezept ist noch keine Anleitung hinterlegt.'**
  String get discoverNoInstructionsHaveBeenAddedForThis;

  /// No description provided for @discoverNoMatchingRecipes.
  ///
  /// In de, this message translates to:
  /// **'Keine passenden Rezepte'**
  String get discoverNoMatchingRecipes;

  /// No description provided for @discoverNoRecipeFoundWithTheseIngredients.
  ///
  /// In de, this message translates to:
  /// **'Kein Rezept mit diesen Zutaten gefunden.'**
  String get discoverNoRecipeFoundWithTheseIngredients;

  /// No description provided for @discoverNoRecipeMatchesYourSelection.
  ///
  /// In de, this message translates to:
  /// **'Kein Rezept passt zu deiner Auswahl.'**
  String get discoverNoRecipeMatchesYourSelection;

  /// No description provided for @discoverNoSteps.
  ///
  /// In de, this message translates to:
  /// **'Keine Schritte'**
  String get discoverNoSteps;

  /// No description provided for @discoverNotNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt nicht'**
  String get discoverNotNow;

  /// No description provided for @discoverNotSpecified.
  ///
  /// In de, this message translates to:
  /// **'keine Angabe'**
  String get discoverNotSpecified;

  /// No description provided for @discoverNutrition.
  ///
  /// In de, this message translates to:
  /// **'Nährwerte'**
  String get discoverNutrition;

  /// No description provided for @discoverOneServingLess.
  ///
  /// In de, this message translates to:
  /// **'Eine Portion weniger'**
  String get discoverOneServingLess;

  /// No description provided for @discoverOneServingMore.
  ///
  /// In de, this message translates to:
  /// **'Eine Portion mehr'**
  String get discoverOneServingMore;

  /// No description provided for @discoverOneStepPerPageLargeTextAnd.
  ///
  /// In de, this message translates to:
  /// **'Ein Schritt pro Seite, große Schrift und Timer.'**
  String get discoverOneStepPerPageLargeTextAnd;

  /// No description provided for @discoverOnions.
  ///
  /// In de, this message translates to:
  /// **'Zwiebeln'**
  String get discoverOnions;

  /// No description provided for @discoverOpenTimerInCookingMode.
  ///
  /// In de, this message translates to:
  /// **'Timer im Kochmodus öffnen'**
  String get discoverOpenTimerInCookingMode;

  /// No description provided for @discoverOriginalAmount.
  ///
  /// In de, this message translates to:
  /// **'Originalmenge'**
  String get discoverOriginalAmount;

  /// No description provided for @discoverPack.
  ///
  /// In de, this message translates to:
  /// **'Pck.'**
  String get discoverPack;

  /// No description provided for @discoverPack2.
  ///
  /// In de, this message translates to:
  /// **'Pkg.'**
  String get discoverPack2;

  /// No description provided for @discoverPacks.
  ///
  /// In de, this message translates to:
  /// **'Packungen'**
  String get discoverPacks;

  /// No description provided for @discoverPause.
  ///
  /// In de, this message translates to:
  /// **'Pausieren'**
  String get discoverPause;

  /// No description provided for @discoverPaused.
  ///
  /// In de, this message translates to:
  /// **'Pausiert'**
  String get discoverPaused;

  /// No description provided for @discoverPeppers.
  ///
  /// In de, this message translates to:
  /// **'Paprika'**
  String get discoverPeppers;

  /// No description provided for @discoverPerServing.
  ///
  /// In de, this message translates to:
  /// **'pro Portion'**
  String get discoverPerServing;

  /// No description provided for @discoverPerServingBasedOnIngredientCatalogueValues.
  ///
  /// In de, this message translates to:
  /// **'Pro Portion, aus den Katalogwerten der Zutaten. {arg0} {arg1} keine Katalogwerte und fehlt hier.'**
  String discoverPerServingBasedOnIngredientCatalogueValues(
    String arg0,
    String arg1,
  );

  /// No description provided for @discoverPerServingBasedOnIngredientCatalogueValues2.
  ///
  /// In de, this message translates to:
  /// **'Pro Portion, aus den Katalogwerten der Zutaten.'**
  String get discoverPerServingBasedOnIngredientCatalogueValues2;

  /// No description provided for @discoverPiece.
  ///
  /// In de, this message translates to:
  /// **'Stk.'**
  String get discoverPiece;

  /// No description provided for @discoverPiece2.
  ///
  /// In de, this message translates to:
  /// **'Stück'**
  String get discoverPiece2;

  /// No description provided for @discoverPinch.
  ///
  /// In de, this message translates to:
  /// **'Msp.'**
  String get discoverPinch;

  /// No description provided for @discoverPinches.
  ///
  /// In de, this message translates to:
  /// **'Prisen'**
  String get discoverPinches;

  /// No description provided for @discoverPinches2.
  ///
  /// In de, this message translates to:
  /// **'Messerspitzen'**
  String get discoverPinches2;

  /// No description provided for @discoverPods.
  ///
  /// In de, this message translates to:
  /// **'Schoten'**
  String get discoverPods;

  /// No description provided for @discoverPot.
  ///
  /// In de, this message translates to:
  /// **'Becher'**
  String get discoverPot;

  /// No description provided for @discoverPotatoes.
  ///
  /// In de, this message translates to:
  /// **'Kartoffeln'**
  String get discoverPotatoes;

  /// No description provided for @discoverPreparation.
  ///
  /// In de, this message translates to:
  /// **'Vorbereitung'**
  String get discoverPreparation;

  /// No description provided for @discoverProTip.
  ///
  /// In de, this message translates to:
  /// **'Profi-Tipp: '**
  String get discoverProTip;

  /// No description provided for @discoverProTipsForEveryStep.
  ///
  /// In de, this message translates to:
  /// **'Profi-Tipps zu jedem Schritt'**
  String get discoverProTipsForEveryStep;

  /// No description provided for @discoverQuickUnder15Min.
  ///
  /// In de, this message translates to:
  /// **'Schnell unter 15 Min.'**
  String get discoverQuickUnder15Min;

  /// No description provided for @discoverRecipes.
  ///
  /// In de, this message translates to:
  /// **'Rezepte'**
  String get discoverRecipes;

  /// No description provided for @discoverRecipesUsingWhatYouHaveAtHome.
  ///
  /// In de, this message translates to:
  /// **'Rezepte mit dem, was du zu Hause hast'**
  String get discoverRecipesUsingWhatYouHaveAtHome;

  /// No description provided for @discoverRemaining.
  ///
  /// In de, this message translates to:
  /// **'Noch offen'**
  String get discoverRemaining;

  /// No description provided for @discoverRemoveFromFavourites.
  ///
  /// In de, this message translates to:
  /// **'Aus Favoriten entfernen'**
  String get discoverRemoveFromFavourites;

  /// No description provided for @discoverRemoveValue.
  ///
  /// In de, this message translates to:
  /// **'{arg0} entfernen'**
  String discoverRemoveValue(String arg0);

  /// No description provided for @discoverRemoveValue2.
  ///
  /// In de, this message translates to:
  /// **'„{arg0}“ entfernen'**
  String discoverRemoveValue2(String arg0);

  /// No description provided for @discoverReset.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get discoverReset;

  /// No description provided for @discoverResetAllFilters.
  ///
  /// In de, this message translates to:
  /// **'Alle Filter zurücksetzen'**
  String get discoverResetAllFilters;

  /// No description provided for @discoverRestart.
  ///
  /// In de, this message translates to:
  /// **'Neu starten'**
  String get discoverRestart;

  /// No description provided for @discoverResume.
  ///
  /// In de, this message translates to:
  /// **'Fortsetzen'**
  String get discoverResume;

  /// No description provided for @discoverRoughGuidelineValuesACompleteCalculationBased.
  ///
  /// In de, this message translates to:
  /// **'Grobe Richtwerte. Eine vollständige Berechnung aus den Zutaten liegt für dieses Rezept noch nicht vor.'**
  String get discoverRoughGuidelineValuesACompleteCalculationBased;

  /// No description provided for @discoverRunning.
  ///
  /// In de, this message translates to:
  /// **'Läuft'**
  String get discoverRunning;

  /// No description provided for @discoverRunningTimersWillBeStopped.
  ///
  /// In de, this message translates to:
  /// **'Laufende Timer werden dabei gestoppt.'**
  String get discoverRunningTimersWillBeStopped;

  /// No description provided for @discoverSalt.
  ///
  /// In de, this message translates to:
  /// **'Salz'**
  String get discoverSalt;

  /// No description provided for @discoverSaving.
  ///
  /// In de, this message translates to:
  /// **'Wird gespeichert …'**
  String get discoverSaving;

  /// No description provided for @discoverSearchRecipesOrIngredients.
  ///
  /// In de, this message translates to:
  /// **'Rezepte oder Zutaten suchen'**
  String get discoverSearchRecipesOrIngredients;

  /// No description provided for @discoverSelectWhatYouHaveAtHomeLookin.
  ///
  /// In de, this message translates to:
  /// **'Wähle, was du zu Hause hast. Lookin zeigt Rezepte mit diesen Zutaten – die mit den wenigsten fehlenden zuerst.'**
  String get discoverSelectWhatYouHaveAtHomeLookin;

  /// No description provided for @discoverServing.
  ///
  /// In de, this message translates to:
  /// **'Portion'**
  String get discoverServing;

  /// No description provided for @discoverServingSuggestion.
  ///
  /// In de, this message translates to:
  /// **'Serviervorschlag'**
  String get discoverServingSuggestion;

  /// No description provided for @discoverServingUnit.
  ///
  /// In de, this message translates to:
  /// **'Portion'**
  String get discoverServingUnit;

  /// No description provided for @discoverServings.
  ///
  /// In de, this message translates to:
  /// **'Portionen'**
  String get discoverServings;

  /// No description provided for @discoverServingsUnit.
  ///
  /// In de, this message translates to:
  /// **'Portionen'**
  String get discoverServingsUnit;

  /// No description provided for @discoverShow.
  ///
  /// In de, this message translates to:
  /// **'Zeigen'**
  String get discoverShow;

  /// No description provided for @discoverShow1Recipe.
  ///
  /// In de, this message translates to:
  /// **'1 Rezept anzeigen'**
  String get discoverShow1Recipe;

  /// No description provided for @discoverShowIngredients.
  ///
  /// In de, this message translates to:
  /// **'Zutaten anzeigen'**
  String get discoverShowIngredients;

  /// No description provided for @discoverShowValueRecipes.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Rezepte anzeigen'**
  String discoverShowValueRecipes(String arg0);

  /// No description provided for @discoverSlices.
  ///
  /// In de, this message translates to:
  /// **'Scheiben'**
  String get discoverSlices;

  /// No description provided for @discoverSortBy.
  ///
  /// In de, this message translates to:
  /// **'Sortieren nach'**
  String get discoverSortBy;

  /// No description provided for @discoverSortedByValue.
  ///
  /// In de, this message translates to:
  /// **'Sortiert: {arg0}'**
  String discoverSortedByValue(String arg0);

  /// No description provided for @discoverSortedForYouByValueSortingDoes.
  ///
  /// In de, this message translates to:
  /// **'Für dich sortiert nach {arg0}. Die Sortierung blendet keine Rezepte aus.'**
  String discoverSortedForYouByValueSortingDoes(String arg0);

  /// No description provided for @discoverSpokenMinutes.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Minute} other{{count} Minuten}}'**
  String discoverSpokenMinutes(int count);

  /// No description provided for @discoverSpokenSeconds.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Sekunde} other{{count} Sekunden}}'**
  String discoverSpokenSeconds(int count);

  /// No description provided for @discoverSprigs.
  ///
  /// In de, this message translates to:
  /// **'Zweige'**
  String get discoverSprigs;

  /// No description provided for @discoverSpringOnions.
  ///
  /// In de, this message translates to:
  /// **'Frühlingszwiebeln'**
  String get discoverSpringOnions;

  /// No description provided for @discoverStartCookingMode.
  ///
  /// In de, this message translates to:
  /// **'Kochmodus starten'**
  String get discoverStartCookingMode;

  /// No description provided for @discoverStartTimer.
  ///
  /// In de, this message translates to:
  /// **'Timer starten'**
  String get discoverStartTimer;

  /// No description provided for @discoverStepValue.
  ///
  /// In de, this message translates to:
  /// **'Schritt {arg0}'**
  String discoverStepValue(String arg0);

  /// No description provided for @discoverStepValueOfValue.
  ///
  /// In de, this message translates to:
  /// **'Schritt {arg0} von {arg1}'**
  String discoverStepValueOfValue(String arg0, String arg1);

  /// No description provided for @discoverStepValueTimeIsUp.
  ///
  /// In de, this message translates to:
  /// **'Schritt {arg0} · Zeit ist um'**
  String discoverStepValueTimeIsUp(String arg0);

  /// No description provided for @discoverStepValueValue.
  ///
  /// In de, this message translates to:
  /// **'Schritt {arg0} · {arg1}'**
  String discoverStepValueValue(String arg0, String arg1);

  /// No description provided for @discoverSticks.
  ///
  /// In de, this message translates to:
  /// **'Stangen'**
  String get discoverSticks;

  /// No description provided for @discoverSubstitutions.
  ///
  /// In de, this message translates to:
  /// **'Austausch-Möglichkeiten'**
  String get discoverSubstitutions;

  /// No description provided for @discoverSugar.
  ///
  /// In de, this message translates to:
  /// **'Zucker'**
  String get discoverSugar;

  /// No description provided for @discoverSuggestion.
  ///
  /// In de, this message translates to:
  /// **'Vorschlag'**
  String get discoverSuggestion;

  /// No description provided for @discoverSuggestionEstimate.
  ///
  /// In de, this message translates to:
  /// **'VORSCHLAG · SCHÄTZUNG'**
  String get discoverSuggestionEstimate;

  /// No description provided for @discoverSweetPotatoes.
  ///
  /// In de, this message translates to:
  /// **'Süßkartoffeln'**
  String get discoverSweetPotatoes;

  /// No description provided for @discoverTapACommonIngredientOrEnterOne.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf eine häufige Zutat oder gib selbst etwas ein, zum Beispiel „Kartoffeln“.'**
  String get discoverTapACommonIngredientOrEnterOne;

  /// No description provided for @discoverTbsp.
  ///
  /// In de, this message translates to:
  /// **'EL'**
  String get discoverTbsp;

  /// No description provided for @discoverTheIngredientInformationMayMentionValueCheck.
  ///
  /// In de, this message translates to:
  /// **'Die Zutatenangaben nennen möglicherweise: {arg0}. Prüfe die Packungen und mögliche Kreuzkontamination. Möchtest du das Rezept trotzdem {arg1}?'**
  String discoverTheIngredientInformationMayMentionValueCheck(
    String arg0,
    String arg1,
  );

  /// No description provided for @discoverTheRecipeCouldNotBeLogged.
  ///
  /// In de, this message translates to:
  /// **'Das Rezept konnte nicht eingetragen werden.'**
  String get discoverTheRecipeCouldNotBeLogged;

  /// No description provided for @discoverTheServingCalculatorAndAllNutritionValues.
  ///
  /// In de, this message translates to:
  /// **'Den Portionsrechner und alle Nährwerte kannst du weiterhin kostenlos nutzen.'**
  String get discoverTheServingCalculatorAndAllNutritionValues;

  /// No description provided for @discoverThingsToWatch.
  ///
  /// In de, this message translates to:
  /// **'Darauf achten'**
  String get discoverThingsToWatch;

  /// No description provided for @discoverThisServingSizeIsASuggestionTo.
  ///
  /// In de, this message translates to:
  /// **'Damit dieses Rezept gut zu deinem heutigen Tagesziel passt, wäre diese Portionsgröße ein Vorschlag:'**
  String get discoverThisServingSizeIsASuggestionTo;

  /// No description provided for @discoverTickWhatYouAlreadyHaveTicksOnly.
  ///
  /// In de, this message translates to:
  /// **'Hake ab, was du schon da hast. Die Haken gelten nur, solange dieses Rezept geöffnet ist.'**
  String get discoverTickWhatYouAlreadyHaveTicksOnly;

  /// No description provided for @discoverTimeIsUp.
  ///
  /// In de, this message translates to:
  /// **'Zeit ist um!'**
  String get discoverTimeIsUp;

  /// No description provided for @discoverTimeIsUpForStepValue.
  ///
  /// In de, this message translates to:
  /// **'Die Zeit für Schritt {arg0} ist um.'**
  String discoverTimeIsUpForStepValue(String arg0);

  /// No description provided for @discoverTimeRemainingValue.
  ///
  /// In de, this message translates to:
  /// **'Verbleibende Zeit: {arg0}'**
  String discoverTimeRemainingValue(String arg0);

  /// No description provided for @discoverTins.
  ///
  /// In de, this message translates to:
  /// **'Dosen'**
  String get discoverTins;

  /// No description provided for @discoverTomatoes.
  ///
  /// In de, this message translates to:
  /// **'Tomaten'**
  String get discoverTomatoes;

  /// No description provided for @discoverTotalTime.
  ///
  /// In de, this message translates to:
  /// **'Gesamtzeit'**
  String get discoverTotalTime;

  /// No description provided for @discoverTryAnotherIngredientOrADifferentName.
  ///
  /// In de, this message translates to:
  /// **'Probiere eine weitere Zutat oder einen anderen Namen, zum Beispiel „Nudeln“ statt „Spaghetti“.'**
  String get discoverTryAnotherIngredientOrADifferentName;

  /// No description provided for @discoverTryAnotherSearchTermOrRemoveA.
  ///
  /// In de, this message translates to:
  /// **'Probiere einen anderen Suchbegriff oder entferne einen Filter.'**
  String get discoverTryAnotherSearchTermOrRemoveA;

  /// No description provided for @discoverTryValue.
  ///
  /// In de, this message translates to:
  /// **'{arg0} testen'**
  String discoverTryValue(String arg0);

  /// No description provided for @discoverTryValueFreeForValueDays.
  ///
  /// In de, this message translates to:
  /// **'{arg0} {arg1} Tage kostenlos testen'**
  String discoverTryValueFreeForValueDays(String arg0, String arg1);

  /// No description provided for @discoverTsp.
  ///
  /// In de, this message translates to:
  /// **'TL'**
  String get discoverTsp;

  /// No description provided for @discoverTubes.
  ///
  /// In de, this message translates to:
  /// **'Tuben'**
  String get discoverTubes;

  /// No description provided for @discoverUpToValueMin.
  ///
  /// In de, this message translates to:
  /// **'bis {arg0} Min.'**
  String discoverUpToValueMin(String arg0);

  /// No description provided for @discoverValueAnyway.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem {arg0}'**
  String discoverValueAnyway(String arg0);

  /// No description provided for @discoverValueGProtein.
  ///
  /// In de, this message translates to:
  /// **'{arg0} g Protein'**
  String discoverValueGProtein(String arg0);

  /// No description provided for @discoverValueHiddenBecauseOfYourAllergyInformation.
  ///
  /// In de, this message translates to:
  /// **'{arg0} wegen deiner Allergieangaben ausgeblendet.'**
  String discoverValueHiddenBecauseOfYourAllergyInformation(String arg0);

  /// No description provided for @discoverValueHr.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Std.'**
  String discoverValueHr(String arg0);

  /// No description provided for @discoverValueHrValueMin.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Std. {arg1} Min.'**
  String discoverValueHrValueMin(String arg0, String arg1);

  /// No description provided for @discoverValueIngredients.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Zutaten'**
  String discoverValueIngredients(String arg0);

  /// No description provided for @discoverValueIngredientsMissing.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Zutaten fehlen'**
  String discoverValueIngredientsMissing(String arg0);

  /// No description provided for @discoverValueKcalValueGProtein.
  ///
  /// In de, this message translates to:
  /// **'{arg0} kcal · {arg1} g Protein'**
  String discoverValueKcalValueGProtein(String arg0, String arg1);

  /// No description provided for @discoverValueMin.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Min.'**
  String discoverValueMin(String arg0);

  /// No description provided for @discoverValueOfValueAvailable.
  ///
  /// In de, this message translates to:
  /// **'{arg0} von {arg1} da'**
  String discoverValueOfValueAvailable(String arg0, String arg1);

  /// No description provided for @discoverValueOfValueIngredientsAvailable.
  ///
  /// In de, this message translates to:
  /// **'{arg0} von {arg1} Zutaten vorhanden'**
  String discoverValueOfValueIngredientsAvailable(String arg0, String arg1);

  /// No description provided for @discoverValueRecipes.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Rezepte'**
  String discoverValueRecipes(String arg0);

  /// No description provided for @discoverValueSteps.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Schritte'**
  String discoverValueSteps(String arg0);

  /// No description provided for @discoverValueValueProtein.
  ///
  /// In de, this message translates to:
  /// **'{arg0} · {arg1} Protein'**
  String discoverValueValueProtein(String arg0, String arg1);

  /// No description provided for @discoverVariations.
  ///
  /// In de, this message translates to:
  /// **'Variationen'**
  String get discoverVariations;

  /// No description provided for @discoverViewValue.
  ///
  /// In de, this message translates to:
  /// **'{arg0} ansehen'**
  String discoverViewValue(String arg0);

  /// No description provided for @discoverWhatCanICook.
  ///
  /// In de, this message translates to:
  /// **'Was kann ich kochen?'**
  String get discoverWhatCanICook;

  /// No description provided for @discoverWhatDoYouHaveAtHome.
  ///
  /// In de, this message translates to:
  /// **'Was hast du zu Hause?'**
  String get discoverWhatDoYouHaveAtHome;

  /// No description provided for @discoverWhereDoTheNutritionValuesComeFrom.
  ///
  /// In de, this message translates to:
  /// **'Woher kommen die Nährwerte?'**
  String get discoverWhereDoTheNutritionValuesComeFrom;

  /// No description provided for @discoverWhichMeal.
  ///
  /// In de, this message translates to:
  /// **'Zu welcher Mahlzeit?'**
  String get discoverWhichMeal;

  /// No description provided for @discoverWithValueLookinSuggestsAServingSize.
  ///
  /// In de, this message translates to:
  /// **'Mit {arg0} schlägt dir Lookin eine Portionsgröße vor, die zu deinem heutigen Tagesziel passt – geschätzt aus deinem Tagebuch. Die Zutatenmengen werden dafür automatisch umgerechnet.'**
  String discoverWithValueLookinSuggestsAServingSize(String arg0);

  /// No description provided for @discoverYouCanCookThisEntireRecipeFor.
  ///
  /// In de, this message translates to:
  /// **'Dieses Rezept kannst du komplett kostenlos nachkochen. {arg0} ergänzt:'**
  String discoverYouCanCookThisEntireRecipeFor(String arg0);

  /// No description provided for @discoverYouHave.
  ///
  /// In de, this message translates to:
  /// **'Hast du'**
  String get discoverYouHave;

  /// No description provided for @discoverYouHaveNoFavouritesYetTapA.
  ///
  /// In de, this message translates to:
  /// **'Du hast noch keine Favoriten. Tippe auf das Herz eines Rezepts, um es dir zu merken.'**
  String get discoverYouHaveNoFavouritesYetTapA;

  /// No description provided for @discoverYourDailyTarget.
  ///
  /// In de, this message translates to:
  /// **'Dein Tagesziel'**
  String get discoverYourDailyTarget;

  /// No description provided for @discoverYourDiaryShowsYouHaveAlreadyReached.
  ///
  /// In de, this message translates to:
  /// **'Laut deinem Tagebuch ist dein Tagesziel heute schon erreicht. Wenn du Hunger hast, ist eine kleinere Portion eine Möglichkeit.'**
  String get discoverYourDiaryShowsYouHaveAlreadyReached;

  /// No description provided for @display1Fillet.
  ///
  /// In de, this message translates to:
  /// **'1 Filet'**
  String get display1Fillet;

  /// No description provided for @display1Year.
  ///
  /// In de, this message translates to:
  /// **'1 Jahr'**
  String get display1Year;

  /// No description provided for @display30Days.
  ///
  /// In de, this message translates to:
  /// **'30 Tage'**
  String get display30Days;

  /// No description provided for @display3Months.
  ///
  /// In de, this message translates to:
  /// **'3 Monate'**
  String get display3Months;

  /// No description provided for @display45MinutesOrMore.
  ///
  /// In de, this message translates to:
  /// **'45 Minuten und mehr'**
  String get display45MinutesOrMore;

  /// No description provided for @display6Months.
  ///
  /// In de, this message translates to:
  /// **'6 Monate'**
  String get display6Months;

  /// No description provided for @display7Days.
  ///
  /// In de, this message translates to:
  /// **'7 Tage'**
  String get display7Days;

  /// No description provided for @displayAConditionRequiringMedicalGuidanceOnNutrition.
  ///
  /// In de, this message translates to:
  /// **'Erkrankung, bei der die Ernährung ärztlich begleitet wird'**
  String get displayAConditionRequiringMedicalGuidanceOnNutrition;

  /// No description provided for @displayAQuickAfterWorkMeal.
  ///
  /// In de, this message translates to:
  /// **'Schnelles Feierabendgericht'**
  String get displayAQuickAfterWorkMeal;

  /// No description provided for @displayAbout30Minutes.
  ///
  /// In de, this message translates to:
  /// **'Etwa 30 Minuten'**
  String get displayAbout30Minutes;

  /// No description provided for @displayActive.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get displayActive;

  /// No description provided for @displayAddTheTopping.
  ///
  /// In de, this message translates to:
  /// **'Toppen'**
  String get displayAddTheTopping;

  /// No description provided for @displayAllTime.
  ///
  /// In de, this message translates to:
  /// **'Alles'**
  String get displayAllTime;

  /// No description provided for @displayAllspice.
  ///
  /// In de, this message translates to:
  /// **'Piment'**
  String get displayAllspice;

  /// No description provided for @displayAlmondFlour.
  ///
  /// In de, this message translates to:
  /// **'Mandelmehl'**
  String get displayAlmondFlour;

  /// No description provided for @displayAlmondMilk.
  ///
  /// In de, this message translates to:
  /// **'Mandelmilch'**
  String get displayAlmondMilk;

  /// No description provided for @displayApple.
  ///
  /// In de, this message translates to:
  /// **'Apfel'**
  String get displayApple;

  /// No description provided for @displayApril.
  ///
  /// In de, this message translates to:
  /// **'April'**
  String get displayApril;

  /// No description provided for @displayAubergine.
  ///
  /// In de, this message translates to:
  /// **'Melanzani'**
  String get displayAubergine;

  /// No description provided for @displayAubergine2.
  ///
  /// In de, this message translates to:
  /// **'Aubergine'**
  String get displayAubergine2;

  /// No description provided for @displayAugust.
  ///
  /// In de, this message translates to:
  /// **'August'**
  String get displayAugust;

  /// No description provided for @displayBalance.
  ///
  /// In de, this message translates to:
  /// **'BALANCE'**
  String get displayBalance;

  /// No description provided for @displayBall.
  ///
  /// In de, this message translates to:
  /// **'Kugel'**
  String get displayBall;

  /// No description provided for @displayBanana.
  ///
  /// In de, this message translates to:
  /// **'Banane'**
  String get displayBanana;

  /// No description provided for @displayBasil.
  ///
  /// In de, this message translates to:
  /// **'Basilikum'**
  String get displayBasil;

  /// No description provided for @displayBasilLeaves.
  ///
  /// In de, this message translates to:
  /// **'Basilikumblätter'**
  String get displayBasilLeaves;

  /// No description provided for @displayBayLeaf.
  ///
  /// In de, this message translates to:
  /// **'Lorbeerblatt'**
  String get displayBayLeaf;

  /// No description provided for @displayBayLeaf2.
  ///
  /// In de, this message translates to:
  /// **'Lorbeer'**
  String get displayBayLeaf2;

  /// No description provided for @displayBayLeaves.
  ///
  /// In de, this message translates to:
  /// **'Lorbeerblätter'**
  String get displayBayLeaves;

  /// No description provided for @displayBeARoleModelForFamilyChildren.
  ///
  /// In de, this message translates to:
  /// **'Vorbild für Familie & Kinder'**
  String get displayBeARoleModelForFamilyChildren;

  /// No description provided for @displayBeef.
  ///
  /// In de, this message translates to:
  /// **'Rind'**
  String get displayBeef;

  /// No description provided for @displayBetterHabits.
  ///
  /// In de, this message translates to:
  /// **'Bessere Gewohnheiten'**
  String get displayBetterHabits;

  /// No description provided for @displayBreadcrumbs.
  ///
  /// In de, this message translates to:
  /// **'Paniermehl'**
  String get displayBreadcrumbs;

  /// No description provided for @displayBreakfastInEightMinutes.
  ///
  /// In de, this message translates to:
  /// **'Frühstück in acht Minuten'**
  String get displayBreakfastInEightMinutes;

  /// No description provided for @displayBringPlentyOfWaterWith1Tsp.
  ///
  /// In de, this message translates to:
  /// **'Reichlich Wasser mit 1 TL Salz aufkochen und die Pasta nach Packungsangabe bissfest garen.'**
  String get displayBringPlentyOfWaterWith1Tsp;

  /// No description provided for @displayBrusselsSprouts.
  ///
  /// In de, this message translates to:
  /// **'Rosenkohl'**
  String get displayBrusselsSprouts;

  /// No description provided for @displayBulb.
  ///
  /// In de, this message translates to:
  /// **'Knolle'**
  String get displayBulb;

  /// No description provided for @displayButtermilk.
  ///
  /// In de, this message translates to:
  /// **'Buttermilch'**
  String get displayButtermilk;

  /// No description provided for @displayCaraway.
  ///
  /// In de, this message translates to:
  /// **'Kümmel'**
  String get displayCaraway;

  /// No description provided for @displayCarrot.
  ///
  /// In de, this message translates to:
  /// **'Möhre'**
  String get displayCarrot;

  /// No description provided for @displayCarrot2.
  ///
  /// In de, this message translates to:
  /// **'Karotte'**
  String get displayCarrot2;

  /// No description provided for @displayCarrot3.
  ///
  /// In de, this message translates to:
  /// **'Mohrrübe'**
  String get displayCarrot3;

  /// No description provided for @displayCarrot4.
  ///
  /// In de, this message translates to:
  /// **'Rübli'**
  String get displayCarrot4;

  /// No description provided for @displayCauliflower.
  ///
  /// In de, this message translates to:
  /// **'Karfiol'**
  String get displayCauliflower;

  /// No description provided for @displayCauliflower2.
  ///
  /// In de, this message translates to:
  /// **'Blumenkohl'**
  String get displayCauliflower2;

  /// No description provided for @displayCelery.
  ///
  /// In de, this message translates to:
  /// **'Sellerie'**
  String get displayCelery;

  /// No description provided for @displayCerealsContainingGluten.
  ///
  /// In de, this message translates to:
  /// **'Glutenhaltiges Getreide'**
  String get displayCerealsContainingGluten;

  /// No description provided for @displayChallenging.
  ///
  /// In de, this message translates to:
  /// **'Anspruchsvoll'**
  String get displayChallenging;

  /// No description provided for @displayCheese.
  ///
  /// In de, this message translates to:
  /// **'Käse'**
  String get displayCheese;

  /// No description provided for @displayChicken.
  ///
  /// In de, this message translates to:
  /// **'Hähnchen'**
  String get displayChicken;

  /// No description provided for @displayChicken2.
  ///
  /// In de, this message translates to:
  /// **'Hühnchen'**
  String get displayChicken2;

  /// No description provided for @displayChicken3.
  ///
  /// In de, this message translates to:
  /// **'Huhn'**
  String get displayChicken3;

  /// No description provided for @displayChicken4.
  ///
  /// In de, this message translates to:
  /// **'Hendl'**
  String get displayChicken4;

  /// No description provided for @displayChickpea.
  ///
  /// In de, this message translates to:
  /// **'Kichererbse'**
  String get displayChickpea;

  /// No description provided for @displayChickpeaFlour.
  ///
  /// In de, this message translates to:
  /// **'Kichererbsenmehl'**
  String get displayChickpeaFlour;

  /// No description provided for @displayChickpeas.
  ///
  /// In de, this message translates to:
  /// **'Kichererbsen'**
  String get displayChickpeas;

  /// No description provided for @displayChilli.
  ///
  /// In de, this message translates to:
  /// **'Chilischote'**
  String get displayChilli;

  /// No description provided for @displayChilliFlakes.
  ///
  /// In de, this message translates to:
  /// **'Chiliflocken'**
  String get displayChilliFlakes;

  /// No description provided for @displayChilliPowder.
  ///
  /// In de, this message translates to:
  /// **'Chilipulver'**
  String get displayChilliPowder;

  /// No description provided for @displayCinnamon.
  ///
  /// In de, this message translates to:
  /// **'Zimt'**
  String get displayCinnamon;

  /// No description provided for @displayCinnamonStick.
  ///
  /// In de, this message translates to:
  /// **'Zimtstange'**
  String get displayCinnamonStick;

  /// No description provided for @displayClove.
  ///
  /// In de, this message translates to:
  /// **'Nelke'**
  String get displayClove;

  /// No description provided for @displayClove2.
  ///
  /// In de, this message translates to:
  /// **'Zehe'**
  String get displayClove2;

  /// No description provided for @displayCocoaButter.
  ///
  /// In de, this message translates to:
  /// **'Kakaobutter'**
  String get displayCocoaButter;

  /// No description provided for @displayCoconut.
  ///
  /// In de, this message translates to:
  /// **'Kokosnuss'**
  String get displayCoconut;

  /// No description provided for @displayCoconutCream.
  ///
  /// In de, this message translates to:
  /// **'Kokossahne'**
  String get displayCoconutCream;

  /// No description provided for @displayCoconutFlour.
  ///
  /// In de, this message translates to:
  /// **'Kokosmehl'**
  String get displayCoconutFlour;

  /// No description provided for @displayCoconutMilk.
  ///
  /// In de, this message translates to:
  /// **'Kokosmilch'**
  String get displayCoconutMilk;

  /// No description provided for @displayCoconutWater.
  ///
  /// In de, this message translates to:
  /// **'Kokoswasser'**
  String get displayCoconutWater;

  /// No description provided for @displayCoconutYoghurt.
  ///
  /// In de, this message translates to:
  /// **'Kokosjoghurt'**
  String get displayCoconutYoghurt;

  /// No description provided for @displayCombine.
  ///
  /// In de, this message translates to:
  /// **'Vermengen'**
  String get displayCombine;

  /// No description provided for @displayCondensedMilk.
  ///
  /// In de, this message translates to:
  /// **'Kondensmilch'**
  String get displayCondensedMilk;

  /// No description provided for @displayConnectingToYourDiaryDidNotWork.
  ///
  /// In de, this message translates to:
  /// **'Die Verbindung zu deinem Tagebuch hat gerade nicht geklappt. Bitte prüfe dein Internet und versuche es erneut.'**
  String get displayConnectingToYourDiaryDidNotWork;

  /// No description provided for @displayCookThePasta.
  ///
  /// In de, this message translates to:
  /// **'Pasta kochen'**
  String get displayCookThePasta;

  /// No description provided for @displayCottageCheese.
  ///
  /// In de, this message translates to:
  /// **'Hüttenkäse'**
  String get displayCottageCheese;

  /// No description provided for @displayCourgette.
  ///
  /// In de, this message translates to:
  /// **'Zucchetti'**
  String get displayCourgette;

  /// No description provided for @displayCourgette2.
  ///
  /// In de, this message translates to:
  /// **'Zucchini'**
  String get displayCourgette2;

  /// No description provided for @displayCravingsSnacking.
  ///
  /// In de, this message translates to:
  /// **'Heißhunger & Naschen'**
  String get displayCravingsSnacking;

  /// No description provided for @displayCream.
  ///
  /// In de, this message translates to:
  /// **'Rahm'**
  String get displayCream;

  /// No description provided for @displayCream2.
  ///
  /// In de, this message translates to:
  /// **'Sahne'**
  String get displayCream2;

  /// No description provided for @displayCream3.
  ///
  /// In de, this message translates to:
  /// **'Obers'**
  String get displayCream3;

  /// No description provided for @displayCreamCheese.
  ///
  /// In de, this message translates to:
  /// **'Frischkäse'**
  String get displayCreamCheese;

  /// No description provided for @displayCreamyProteinPasta.
  ///
  /// In de, this message translates to:
  /// **'Cremige Protein-Pasta'**
  String get displayCreamyProteinPasta;

  /// No description provided for @displayCrustaceans.
  ///
  /// In de, this message translates to:
  /// **'Krebstiere'**
  String get displayCrustaceans;

  /// No description provided for @displayCucumber.
  ///
  /// In de, this message translates to:
  /// **'Gurke'**
  String get displayCucumber;

  /// No description provided for @displayCumin.
  ///
  /// In de, this message translates to:
  /// **'Kreuzkümmel'**
  String get displayCumin;

  /// No description provided for @displayCup.
  ///
  /// In de, this message translates to:
  /// **'Tasse'**
  String get displayCup;

  /// No description provided for @displayCurryPowder.
  ///
  /// In de, this message translates to:
  /// **'Currypulver'**
  String get displayCurryPowder;

  /// No description provided for @displayDrainThePastaMixWithTheSauce.
  ///
  /// In de, this message translates to:
  /// **'Pasta abgießen, mit der Sauce vermengen und mit Pfeffer abschmecken.'**
  String get displayDrainThePastaMixWithTheSauce;

  /// No description provided for @displayEasy.
  ///
  /// In de, this message translates to:
  /// **'Einfach'**
  String get displayEasy;

  /// No description provided for @displayEatHealthier.
  ///
  /// In de, this message translates to:
  /// **'Gesünder ernähren'**
  String get displayEatHealthier;

  /// No description provided for @displayEatHealthier2.
  ///
  /// In de, this message translates to:
  /// **'Gesünder essen'**
  String get displayEatHealthier2;

  /// No description provided for @displayEatingDisorderCurrentOrPast.
  ///
  /// In de, this message translates to:
  /// **'Essstörung – aktuell oder früher'**
  String get displayEatingDisorderCurrentOrPast;

  /// No description provided for @displayEatingWhenStressed.
  ///
  /// In de, this message translates to:
  /// **'Essen bei Stress'**
  String get displayEatingWhenStressed;

  /// No description provided for @displayEgg.
  ///
  /// In de, this message translates to:
  /// **'Ei'**
  String get displayEgg;

  /// No description provided for @displayEggWhite.
  ///
  /// In de, this message translates to:
  /// **'Eiklar'**
  String get displayEggWhite;

  /// No description provided for @displayEggYolk.
  ///
  /// In de, this message translates to:
  /// **'Eigelb'**
  String get displayEggYolk;

  /// No description provided for @displayEntriesPlural.
  ///
  /// In de, this message translates to:
  /// **'Einträge'**
  String get displayEntriesPlural;

  /// No description provided for @displayEntrySingular.
  ///
  /// In de, this message translates to:
  /// **'Eintrag'**
  String get displayEntrySingular;

  /// No description provided for @displayFeelBetterInMyBody.
  ///
  /// In de, this message translates to:
  /// **'Wohler im eigenen Körper'**
  String get displayFeelBetterInMyBody;

  /// No description provided for @displayFemale.
  ///
  /// In de, this message translates to:
  /// **'Weiblich'**
  String get displayFemale;

  /// No description provided for @displayFewestCalories.
  ///
  /// In de, this message translates to:
  /// **'Wenigste kcal'**
  String get displayFewestCalories;

  /// No description provided for @displayFillet.
  ///
  /// In de, this message translates to:
  /// **'Filet'**
  String get displayFillet;

  /// No description provided for @displayFillingFreshAndRichInProtein.
  ///
  /// In de, this message translates to:
  /// **'Sättigend, frisch und proteinreich'**
  String get displayFillingFreshAndRichInProtein;

  /// No description provided for @displayFish.
  ///
  /// In de, this message translates to:
  /// **'Fisch'**
  String get displayFish;

  /// No description provided for @displayFishNoMeat.
  ///
  /// In de, this message translates to:
  /// **'Mit Fisch, ohne Fleisch'**
  String get displayFishNoMeat;

  /// No description provided for @displayFlatbread.
  ///
  /// In de, this message translates to:
  /// **'Fladenbrot'**
  String get displayFlatbread;

  /// No description provided for @displayFlour.
  ///
  /// In de, this message translates to:
  /// **'Mehl'**
  String get displayFlour;

  /// No description provided for @displayGarlic.
  ///
  /// In de, this message translates to:
  /// **'Knoblauch'**
  String get displayGarlic;

  /// No description provided for @displayGarlicClove.
  ///
  /// In de, this message translates to:
  /// **'Knoblauchzehe'**
  String get displayGarlicClove;

  /// No description provided for @displayGarlicPowder.
  ///
  /// In de, this message translates to:
  /// **'Knoblauchpulver'**
  String get displayGarlicPowder;

  /// No description provided for @displayGentle.
  ///
  /// In de, this message translates to:
  /// **'Sanft'**
  String get displayGentle;

  /// No description provided for @displayGinger.
  ///
  /// In de, this message translates to:
  /// **'Ingwerknolle'**
  String get displayGinger;

  /// No description provided for @displayGinger2.
  ///
  /// In de, this message translates to:
  /// **'Ingwer'**
  String get displayGinger2;

  /// No description provided for @displayGingerPowder.
  ///
  /// In de, this message translates to:
  /// **'Ingwerpulver'**
  String get displayGingerPowder;

  /// No description provided for @displayGingerRoot.
  ///
  /// In de, this message translates to:
  /// **'Ingwerwurzel'**
  String get displayGingerRoot;

  /// No description provided for @displayGlass.
  ///
  /// In de, this message translates to:
  /// **'Glas'**
  String get displayGlass;

  /// No description provided for @displayHerbesDeProvence.
  ///
  /// In de, this message translates to:
  /// **'Kräuter der Provence'**
  String get displayHerbesDeProvence;

  /// No description provided for @displayImproveMyFitness.
  ///
  /// In de, this message translates to:
  /// **'Sportlich stärker werden'**
  String get displayImproveMyFitness;

  /// No description provided for @displayIngredientSingular.
  ///
  /// In de, this message translates to:
  /// **'Zutat'**
  String get displayIngredientSingular;

  /// No description provided for @displayIngredientsPlural.
  ///
  /// In de, this message translates to:
  /// **'Zutaten'**
  String get displayIngredientsPlural;

  /// No description provided for @displayIrregularMeals.
  ///
  /// In de, this message translates to:
  /// **'Unregelmäßige Mahlzeiten'**
  String get displayIrregularMeals;

  /// No description provided for @displayItVaries.
  ///
  /// In de, this message translates to:
  /// **'Mal so, mal so'**
  String get displayItVaries;

  /// No description provided for @displayItalianHerbs.
  ///
  /// In de, this message translates to:
  /// **'Italienische Kräuter'**
  String get displayItalianHerbs;

  /// No description provided for @displayKale.
  ///
  /// In de, this message translates to:
  /// **'Grünkohl'**
  String get displayKale;

  /// No description provided for @displayLactoseIntolerance.
  ///
  /// In de, this message translates to:
  /// **'Laktose (Unverträglichkeit)'**
  String get displayLactoseIntolerance;

  /// No description provided for @displayLeaf.
  ///
  /// In de, this message translates to:
  /// **'Blatt'**
  String get displayLeaf;

  /// No description provided for @displayLeek.
  ///
  /// In de, this message translates to:
  /// **'Porree'**
  String get displayLeek;

  /// No description provided for @displayLeek2.
  ///
  /// In de, this message translates to:
  /// **'Lauch'**
  String get displayLeek2;

  /// No description provided for @displayLemon.
  ///
  /// In de, this message translates to:
  /// **'Zitrone'**
  String get displayLemon;

  /// No description provided for @displayLemonJuice.
  ///
  /// In de, this message translates to:
  /// **'Zitronensaft'**
  String get displayLemonJuice;

  /// No description provided for @displayLemongrass.
  ///
  /// In de, this message translates to:
  /// **'Zitronengras'**
  String get displayLemongrass;

  /// No description provided for @displayLentil.
  ///
  /// In de, this message translates to:
  /// **'Linse'**
  String get displayLentil;

  /// No description provided for @displayLentils.
  ///
  /// In de, this message translates to:
  /// **'Linsen'**
  String get displayLentils;

  /// No description provided for @displayLime.
  ///
  /// In de, this message translates to:
  /// **'Limette'**
  String get displayLime;

  /// No description provided for @displayLimeJuice.
  ///
  /// In de, this message translates to:
  /// **'Limettensaft'**
  String get displayLimeJuice;

  /// No description provided for @displayLittleTimeToCook.
  ///
  /// In de, this message translates to:
  /// **'Wenig Zeit zum Kochen'**
  String get displayLittleTimeToCook;

  /// No description provided for @displayLiveHealthier.
  ///
  /// In de, this message translates to:
  /// **'Gesünder leben'**
  String get displayLiveHealthier;

  /// No description provided for @displayLookinCoachPremium.
  ///
  /// In de, this message translates to:
  /// **'LOOKIN COACH · PREMIUM'**
  String get displayLookinCoachPremium;

  /// No description provided for @displayLupin.
  ///
  /// In de, this message translates to:
  /// **'Lupinen'**
  String get displayLupin;

  /// No description provided for @displayMale.
  ///
  /// In de, this message translates to:
  /// **'Männlich'**
  String get displayMale;

  /// No description provided for @displayMarjoram.
  ///
  /// In de, this message translates to:
  /// **'Majoran'**
  String get displayMarjoram;

  /// No description provided for @displayMeatFromLandAnimalsIsOnlyIncluded.
  ///
  /// In de, this message translates to:
  /// **'Fleisch von Landtieren wird nur mit eindeutiger Halal-Kennzeichnung aufgenommen.'**
  String get displayMeatFromLandAnimalsIsOnlyIncluded;

  /// No description provided for @displayMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get displayMedium;

  /// No description provided for @displayMilk.
  ///
  /// In de, this message translates to:
  /// **'Milch'**
  String get displayMilk;

  /// No description provided for @displayMint.
  ///
  /// In de, this message translates to:
  /// **'Minze'**
  String get displayMint;

  /// No description provided for @displayMintLeaves.
  ///
  /// In de, this message translates to:
  /// **'Minzblätter'**
  String get displayMintLeaves;

  /// No description provided for @displayMixTheOatsWith80MlOf.
  ///
  /// In de, this message translates to:
  /// **'Haferflocken mit 80 ml Wasser verrühren und 3 Minuten quellen lassen.'**
  String get displayMixTheOatsWith80MlOf;

  /// No description provided for @displayMixTheSauce.
  ///
  /// In de, this message translates to:
  /// **'Sauce rühren'**
  String get displayMixTheSauce;

  /// No description provided for @displayMixed.
  ///
  /// In de, this message translates to:
  /// **'Gemischt'**
  String get displayMixed;

  /// No description provided for @displayMolluscs.
  ///
  /// In de, this message translates to:
  /// **'Weichtiere'**
  String get displayMolluscs;

  /// No description provided for @displayMoreConsistency.
  ///
  /// In de, this message translates to:
  /// **'Mehr Regelmäßigkeit'**
  String get displayMoreConsistency;

  /// No description provided for @displayMoreEnergyDayToDay.
  ///
  /// In de, this message translates to:
  /// **'Mehr Energie im Alltag'**
  String get displayMoreEnergyDayToDay;

  /// No description provided for @displayMostProtein.
  ///
  /// In de, this message translates to:
  /// **'Meistes Protein'**
  String get displayMostProtein;

  /// No description provided for @displayMostlySeated.
  ///
  /// In de, this message translates to:
  /// **'Meist sitzend'**
  String get displayMostlySeated;

  /// No description provided for @displayMotivationDoesNotLast.
  ///
  /// In de, this message translates to:
  /// **'Motivation hält nicht lange'**
  String get displayMotivationDoesNotLast;

  /// No description provided for @displayMushroom.
  ///
  /// In de, this message translates to:
  /// **'Champignon'**
  String get displayMushroom;

  /// No description provided for @displayMushroom2.
  ///
  /// In de, this message translates to:
  /// **'Pilz'**
  String get displayMushroom2;

  /// No description provided for @displayMushrooms.
  ///
  /// In de, this message translates to:
  /// **'Champignons'**
  String get displayMushrooms;

  /// No description provided for @displayMustard.
  ///
  /// In de, this message translates to:
  /// **'Senf'**
  String get displayMustard;

  /// No description provided for @displayNever.
  ///
  /// In de, this message translates to:
  /// **'Noch nie'**
  String get displayNever;

  /// No description provided for @displayNewMealIdeas.
  ///
  /// In de, this message translates to:
  /// **'Neue Essensideen'**
  String get displayNewMealIdeas;

  /// No description provided for @displayNonStickFryingPan.
  ///
  /// In de, this message translates to:
  /// **'Beschichtete Pfanne'**
  String get displayNonStickFryingPan;

  /// No description provided for @displayNovember.
  ///
  /// In de, this message translates to:
  /// **'November'**
  String get displayNovember;

  /// No description provided for @displayNutmeg.
  ///
  /// In de, this message translates to:
  /// **'Muskatnuss'**
  String get displayNutmeg;

  /// No description provided for @displayNutmeg2.
  ///
  /// In de, this message translates to:
  /// **'Muskat'**
  String get displayNutmeg2;

  /// No description provided for @displayNuts.
  ///
  /// In de, this message translates to:
  /// **'Nüsse'**
  String get displayNuts;

  /// No description provided for @displayOatCream.
  ///
  /// In de, this message translates to:
  /// **'Hafersahne'**
  String get displayOatCream;

  /// No description provided for @displayOatMilk.
  ///
  /// In de, this message translates to:
  /// **'Hafermilch'**
  String get displayOatMilk;

  /// No description provided for @displayOats.
  ///
  /// In de, this message translates to:
  /// **'Haferflocken'**
  String get displayOats;

  /// No description provided for @displayOats2.
  ///
  /// In de, this message translates to:
  /// **'Hafer'**
  String get displayOats2;

  /// No description provided for @displayOftenEatOnTheGo.
  ///
  /// In de, this message translates to:
  /// **'Viel unterwegs essen'**
  String get displayOftenEatOnTheGo;

  /// No description provided for @displayOftenOnTheMove.
  ///
  /// In de, this message translates to:
  /// **'Viel in Bewegung'**
  String get displayOftenOnTheMove;

  /// No description provided for @displayOil.
  ///
  /// In de, this message translates to:
  /// **'Öl'**
  String get displayOil;

  /// No description provided for @displayOnion.
  ///
  /// In de, this message translates to:
  /// **'Zwiebel'**
  String get displayOnion;

  /// No description provided for @displayOnionPowder.
  ///
  /// In de, this message translates to:
  /// **'Zwiebelpulver'**
  String get displayOnionPowder;

  /// No description provided for @displayOpenProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil öffnen'**
  String get displayOpenProfile;

  /// No description provided for @displayPack.
  ///
  /// In de, this message translates to:
  /// **'Packung'**
  String get displayPack;

  /// No description provided for @displayPanFryTheSalmon.
  ///
  /// In de, this message translates to:
  /// **'Lachs braten'**
  String get displayPanFryTheSalmon;

  /// No description provided for @displayPaprika.
  ///
  /// In de, this message translates to:
  /// **'Paprikapulver'**
  String get displayPaprika;

  /// No description provided for @displayPasta.
  ///
  /// In de, this message translates to:
  /// **'Nudeln'**
  String get displayPasta;

  /// No description provided for @displayPasta2.
  ///
  /// In de, this message translates to:
  /// **'Nudel'**
  String get displayPasta2;

  /// No description provided for @displayPatTheSalmonDryAndFrySkin.
  ///
  /// In de, this message translates to:
  /// **'Den Lachs trocken tupfen und mit der Hautseite nach unten bei mittlerer Hitze 5 Minuten braten. Wenden und weitere 3 Minuten garen, bis er innen nicht mehr glasig ist.'**
  String get displayPatTheSalmonDryAndFrySkin;

  /// No description provided for @displayPeanutButter.
  ///
  /// In de, this message translates to:
  /// **'Erdnussbutter'**
  String get displayPeanutButter;

  /// No description provided for @displayPeanuts.
  ///
  /// In de, this message translates to:
  /// **'Erdnüsse'**
  String get displayPeanuts;

  /// No description provided for @displayPepper.
  ///
  /// In de, this message translates to:
  /// **'Paprikaschote'**
  String get displayPepper;

  /// No description provided for @displayPepper2.
  ///
  /// In de, this message translates to:
  /// **'Pfeffer'**
  String get displayPepper2;

  /// No description provided for @displayPeppercorns.
  ///
  /// In de, this message translates to:
  /// **'Pfefferkörner'**
  String get displayPeppercorns;

  /// No description provided for @displayPiece.
  ///
  /// In de, this message translates to:
  /// **'½ Stück'**
  String get displayPiece;

  /// No description provided for @displayPinch.
  ///
  /// In de, this message translates to:
  /// **'Prise'**
  String get displayPinch;

  /// No description provided for @displayPinch2.
  ///
  /// In de, this message translates to:
  /// **'Messerspitze'**
  String get displayPinch2;

  /// No description provided for @displayPleaseGiveYourFoodAName.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib deinem Lebensmittel einen Namen.'**
  String get displayPleaseGiveYourFoodAName;

  /// No description provided for @displayPod.
  ///
  /// In de, this message translates to:
  /// **'Schote'**
  String get displayPod;

  /// No description provided for @displayPollock.
  ///
  /// In de, this message translates to:
  /// **'Seelachs'**
  String get displayPollock;

  /// No description provided for @displayPortionsPlural.
  ///
  /// In de, this message translates to:
  /// **'Portionen'**
  String get displayPortionsPlural;

  /// No description provided for @displayPotato.
  ///
  /// In de, this message translates to:
  /// **'Kartoffel'**
  String get displayPotato;

  /// No description provided for @displayPotatoes.
  ///
  /// In de, this message translates to:
  /// **'Erdäpfel'**
  String get displayPotatoes;

  /// No description provided for @displayPreferNotToSay.
  ///
  /// In de, this message translates to:
  /// **'Möchte ich nicht angeben'**
  String get displayPreferNotToSay;

  /// No description provided for @displayPregnantOrBreastfeeding.
  ///
  /// In de, this message translates to:
  /// **'Schwanger oder stillend'**
  String get displayPregnantOrBreastfeeding;

  /// No description provided for @displayPreview.
  ///
  /// In de, this message translates to:
  /// **'VORSCHAU'**
  String get displayPreview;

  /// No description provided for @displayProtein.
  ///
  /// In de, this message translates to:
  /// **'PROTEIN'**
  String get displayProtein;

  /// No description provided for @displayProteinBerryOats.
  ///
  /// In de, this message translates to:
  /// **'Protein-Beeren-Oats'**
  String get displayProteinBerryOats;

  /// No description provided for @displayProteinG.
  ///
  /// In de, this message translates to:
  /// **'Protein g'**
  String get displayProteinG;

  /// No description provided for @displayPutTheRiceInABowlPlace.
  ///
  /// In de, this message translates to:
  /// **'Reis in eine Schüssel geben, Lachs und Avocado darauf legen und sofort servieren.'**
  String get displayPutTheRiceInABowlPlace;

  /// No description provided for @displayQuark.
  ///
  /// In de, this message translates to:
  /// **'Topfen'**
  String get displayQuark;

  /// No description provided for @displayRecipe.
  ///
  /// In de, this message translates to:
  /// **'Rezept'**
  String get displayRecipe;

  /// No description provided for @displayRiceCooked.
  ///
  /// In de, this message translates to:
  /// **'Reis, gekocht'**
  String get displayRiceCooked;

  /// No description provided for @displayRiceFlour.
  ///
  /// In de, this message translates to:
  /// **'Reismehl'**
  String get displayRiceFlour;

  /// No description provided for @displayRiceMilk.
  ///
  /// In de, this message translates to:
  /// **'Reismilch'**
  String get displayRiceMilk;

  /// No description provided for @displayRoseWater.
  ///
  /// In de, this message translates to:
  /// **'Rosenwasser'**
  String get displayRoseWater;

  /// No description provided for @displayRosemary.
  ///
  /// In de, this message translates to:
  /// **'Rosmarin'**
  String get displayRosemary;

  /// No description provided for @displayRosemarySprig.
  ///
  /// In de, this message translates to:
  /// **'Rosmarinzweig'**
  String get displayRosemarySprig;

  /// No description provided for @displayRosemarySprigs.
  ///
  /// In de, this message translates to:
  /// **'Rosmarinzweige'**
  String get displayRosemarySprigs;

  /// No description provided for @displaySalmonFillet.
  ///
  /// In de, this message translates to:
  /// **'Lachsfilet'**
  String get displaySalmonFillet;

  /// No description provided for @displaySalmonPowerBowl.
  ///
  /// In de, this message translates to:
  /// **'Lachs Power Bowl'**
  String get displaySalmonPowerBowl;

  /// No description provided for @displaySaltPepperOilWaterAndCommonSpices.
  ///
  /// In de, this message translates to:
  /// **'Salz, Pfeffer, Öl, Wasser und gängige Gewürze wie Paprikapulver, Currypulver, Kreuzkümmel, Zimt oder Oregano'**
  String get displaySaltPepperOilWaterAndCommonSpices;

  /// No description provided for @displaySavedRecipe.
  ///
  /// In de, this message translates to:
  /// **'Gespeichertes Rezept'**
  String get displaySavedRecipe;

  /// No description provided for @displayScatterTheBerriesOverTheTopAnd.
  ///
  /// In de, this message translates to:
  /// **'Beeren darauf verteilen und sofort servieren.'**
  String get displayScatterTheBerriesOverTheTopAnd;

  /// No description provided for @displaySeptember.
  ///
  /// In de, this message translates to:
  /// **'September'**
  String get displaySeptember;

  /// No description provided for @displayServe.
  ///
  /// In de, this message translates to:
  /// **'Anrichten'**
  String get displayServe;

  /// No description provided for @displaySesame.
  ///
  /// In de, this message translates to:
  /// **'Sesam'**
  String get displaySesame;

  /// No description provided for @displaySheepSCheese.
  ///
  /// In de, this message translates to:
  /// **'Schafskäse'**
  String get displaySheepSCheese;

  /// No description provided for @displayShortOnTime.
  ///
  /// In de, this message translates to:
  /// **'Wenig Zeit'**
  String get displayShortOnTime;

  /// No description provided for @displaySkyrWithAlmonds.
  ///
  /// In de, this message translates to:
  /// **'Skyr mit Mandeln'**
  String get displaySkyrWithAlmonds;

  /// No description provided for @displaySlice.
  ///
  /// In de, this message translates to:
  /// **'Scheibe'**
  String get displaySlice;

  /// No description provided for @displaySliced.
  ///
  /// In de, this message translates to:
  /// **'in Scheiben'**
  String get displaySliced;

  /// No description provided for @displaySmallSaucepanWithLid.
  ///
  /// In de, this message translates to:
  /// **'Kleiner Topf mit Deckel'**
  String get displaySmallSaucepanWithLid;

  /// No description provided for @displaySoakTheOats.
  ///
  /// In de, this message translates to:
  /// **'Hafer quellen lassen'**
  String get displaySoakTheOats;

  /// No description provided for @displaySourCream.
  ///
  /// In de, this message translates to:
  /// **'Sauerrahm'**
  String get displaySourCream;

  /// No description provided for @displaySourCream2.
  ///
  /// In de, this message translates to:
  /// **'Schmand'**
  String get displaySourCream2;

  /// No description provided for @displaySoya.
  ///
  /// In de, this message translates to:
  /// **'Soja'**
  String get displaySoya;

  /// No description provided for @displaySoyaCream.
  ///
  /// In de, this message translates to:
  /// **'Sojasahne'**
  String get displaySoyaCream;

  /// No description provided for @displaySoyaMilk.
  ///
  /// In de, this message translates to:
  /// **'Sojamilch'**
  String get displaySoyaMilk;

  /// No description provided for @displaySoyaYoghurt.
  ///
  /// In de, this message translates to:
  /// **'Sojajoghurt'**
  String get displaySoyaYoghurt;

  /// No description provided for @displaySpiceMix.
  ///
  /// In de, this message translates to:
  /// **'Gewürzmischung'**
  String get displaySpiceMix;

  /// No description provided for @displaySpices.
  ///
  /// In de, this message translates to:
  /// **'Gewürze'**
  String get displaySpices;

  /// No description provided for @displaySprig.
  ///
  /// In de, this message translates to:
  /// **'Zweig'**
  String get displaySprig;

  /// No description provided for @displaySpringOnion.
  ///
  /// In de, this message translates to:
  /// **'Frühlingslauch'**
  String get displaySpringOnion;

  /// No description provided for @displaySpringOnion2.
  ///
  /// In de, this message translates to:
  /// **'Frühlingszwiebel'**
  String get displaySpringOnion2;

  /// No description provided for @displaySpringOnion3.
  ///
  /// In de, this message translates to:
  /// **'Lauchzwiebel'**
  String get displaySpringOnion3;

  /// No description provided for @displayStepSingular.
  ///
  /// In de, this message translates to:
  /// **'Schritt'**
  String get displayStepSingular;

  /// No description provided for @displayStepsPlural.
  ///
  /// In de, this message translates to:
  /// **'Schritte'**
  String get displayStepsPlural;

  /// No description provided for @displayStick.
  ///
  /// In de, this message translates to:
  /// **'Stange'**
  String get displayStick;

  /// No description provided for @displayStirInTheSkyr.
  ///
  /// In de, this message translates to:
  /// **'Skyr unterrühren'**
  String get displayStirInTheSkyr;

  /// No description provided for @displayStirInTheSkyrUntilEvenlyCreamy.
  ///
  /// In de, this message translates to:
  /// **'Skyr unterrühren, bis alles gleichmäßig cremig ist.'**
  String get displayStirInTheSkyrUntilEvenlyCreamy;

  /// No description provided for @displayStirTheSkyrWithALittlePasta.
  ///
  /// In de, this message translates to:
  /// **'Skyr mit etwas Nudelwasser glatt rühren, bis eine cremige Sauce entsteht.'**
  String get displayStirTheSkyrWithALittlePasta;

  /// No description provided for @displayStock.
  ///
  /// In de, this message translates to:
  /// **'Brühe'**
  String get displayStock;

  /// No description provided for @displayStockCube.
  ///
  /// In de, this message translates to:
  /// **'Brühwürfel'**
  String get displayStockCube;

  /// No description provided for @displaySugarSnapPea.
  ///
  /// In de, this message translates to:
  /// **'Zuckerschote'**
  String get displaySugarSnapPea;

  /// No description provided for @displaySulphurDioxideSulphites.
  ///
  /// In de, this message translates to:
  /// **'Schwefeldioxid / Sulfite'**
  String get displaySulphurDioxideSulphites;

  /// No description provided for @displaySweetPotato.
  ///
  /// In de, this message translates to:
  /// **'Süßkartoffel'**
  String get displaySweetPotato;

  /// No description provided for @displayThisEntryContainsAnIngredientExcludedFrom.
  ///
  /// In de, this message translates to:
  /// **'Dieser Eintrag enthält einen in Lookin ausgeschlossenen Bestandteil.'**
  String get displayThisEntryContainsAnIngredientExcludedFrom;

  /// No description provided for @displayThisEntryDoesNotMeetLookinS.
  ///
  /// In de, this message translates to:
  /// **'Dieser Eintrag entspricht nicht den Halal-Inhaltsregeln von Lookin.'**
  String get displayThisEntryDoesNotMeetLookinS;

  /// No description provided for @displayThisFoodDoesNotMeetLookinS.
  ///
  /// In de, this message translates to:
  /// **'Dieses Lebensmittel entspricht nicht den Halal-Inhaltsregeln von Lookin.'**
  String get displayThisFoodDoesNotMeetLookinS;

  /// No description provided for @displayThisRecipeCouldNoLongerBeFound.
  ///
  /// In de, this message translates to:
  /// **'Das Rezept konnte nicht mehr gefunden werden.'**
  String get displayThisRecipeCouldNoLongerBeFound;

  /// No description provided for @displayThisRecipeDoesNotMeetLookinS.
  ///
  /// In de, this message translates to:
  /// **'Dieses Rezept entspricht nicht den Halal-Inhaltsregeln von Lookin.'**
  String get displayThisRecipeDoesNotMeetLookinS;

  /// No description provided for @displayThyme.
  ///
  /// In de, this message translates to:
  /// **'Thymian'**
  String get displayThyme;

  /// No description provided for @displayThymeSprig.
  ///
  /// In de, this message translates to:
  /// **'Thymianzweig'**
  String get displayThymeSprig;

  /// No description provided for @displayThymeSprigs.
  ///
  /// In de, this message translates to:
  /// **'Thymianzweige'**
  String get displayThymeSprigs;

  /// No description provided for @displayTin.
  ///
  /// In de, this message translates to:
  /// **'Dose'**
  String get displayTin;

  /// No description provided for @displayTinnedTomatoes.
  ///
  /// In de, this message translates to:
  /// **'Dosentomaten'**
  String get displayTinnedTomatoes;

  /// No description provided for @displayTomato.
  ///
  /// In de, this message translates to:
  /// **'Tomate'**
  String get displayTomato;

  /// No description provided for @displayTomatoes.
  ///
  /// In de, this message translates to:
  /// **'Paradeiser'**
  String get displayTomatoes;

  /// No description provided for @displayTreeNuts.
  ///
  /// In de, this message translates to:
  /// **'Schalenfrüchte'**
  String get displayTreeNuts;

  /// No description provided for @displayTriedItBefore.
  ///
  /// In de, this message translates to:
  /// **'Schon mal ausprobiert'**
  String get displayTriedItBefore;

  /// No description provided for @displayTurkey.
  ///
  /// In de, this message translates to:
  /// **'Pute'**
  String get displayTurkey;

  /// No description provided for @displayTurmeric.
  ///
  /// In de, this message translates to:
  /// **'Kurkuma'**
  String get displayTurmeric;

  /// No description provided for @displayUnsureWhatIsGoodForMe.
  ///
  /// In de, this message translates to:
  /// **'Unsicher, was gut für mich ist'**
  String get displayUnsureWhatIsGoodForMe;

  /// No description provided for @displayUpTo15Minutes.
  ///
  /// In de, this message translates to:
  /// **'Bis 15 Minuten'**
  String get displayUpTo15Minutes;

  /// No description provided for @displayVanilla.
  ///
  /// In de, this message translates to:
  /// **'Vanille'**
  String get displayVanilla;

  /// No description provided for @displayVanillaPod.
  ///
  /// In de, this message translates to:
  /// **'Vanilleschote'**
  String get displayVanillaPod;

  /// No description provided for @displayWarmTheCookedRiceWith1Tbsp.
  ///
  /// In de, this message translates to:
  /// **'Den gekochten Reis mit 1 EL Wasser in einem kleinen Topf mit Deckel bei niedriger Hitze etwa 4 Minuten erwärmen.'**
  String get displayWarmTheCookedRiceWith1Tbsp;

  /// No description provided for @displayWarmTheRice.
  ///
  /// In de, this message translates to:
  /// **'Reis erwärmen'**
  String get displayWarmTheRice;

  /// No description provided for @displayWatchMyBudget.
  ///
  /// In de, this message translates to:
  /// **'Aufs Budget achten'**
  String get displayWatchMyBudget;

  /// No description provided for @displayWhippingCream.
  ///
  /// In de, this message translates to:
  /// **'Schlagobers'**
  String get displayWhippingCream;

  /// No description provided for @displayWhiteBrinedCheese.
  ///
  /// In de, this message translates to:
  /// **'Hirtenkäse'**
  String get displayWhiteBrinedCheese;

  /// No description provided for @displayYesRegularly.
  ///
  /// In de, this message translates to:
  /// **'Ja, regelmäßig'**
  String get displayYesRegularly;

  /// No description provided for @displayYoghurt.
  ///
  /// In de, this message translates to:
  /// **'Joghurt'**
  String get displayYoghurt;

  /// No description provided for @displayYoghurt2.
  ///
  /// In de, this message translates to:
  /// **'Jogurt'**
  String get displayYoghurt2;

  /// No description provided for @displayYourLocalProfilePictureCouldNotBe.
  ///
  /// In de, this message translates to:
  /// **'Dein lokales Profilbild konnte nicht geladen werden.'**
  String get displayYourLocalProfilePictureCouldNotBe;

  /// No description provided for @displayYourPictureCouldNotBeRemovedPlease.
  ///
  /// In de, this message translates to:
  /// **'Dein Bild konnte nicht entfernt werden. Bitte versuche es erneut.'**
  String get displayYourPictureCouldNotBeRemovedPlease;

  /// No description provided for @displayYourPictureCouldNotBeSavedOn.
  ///
  /// In de, this message translates to:
  /// **'Dein Bild konnte nur auf diesem Gerät nicht gespeichert werden. Bitte versuche es erneut.'**
  String get displayYourPictureCouldNotBeSavedOn;

  /// No description provided for @displayYourSelectionCouldNotBeSavedPermanently.
  ///
  /// In de, this message translates to:
  /// **'Die Auswahl konnte nicht dauerhaft gespeichert werden.'**
  String get displayYourSelectionCouldNotBeSavedPermanently;

  /// No description provided for @displayYourStreakCouldNotBeLoaded.
  ///
  /// In de, this message translates to:
  /// **'Deine Serie konnte nicht geladen werden.'**
  String get displayYourStreakCouldNotBeLoaded;

  /// No description provided for @displayYourStreakCouldNotBeUpdated.
  ///
  /// In de, this message translates to:
  /// **'Deine Serie konnte nicht aktualisiert werden.'**
  String get displayYourStreakCouldNotBeUpdated;

  /// No description provided for @homeAddValue.
  ///
  /// In de, this message translates to:
  /// **'{name} hinzufügen'**
  String homeAddValue(String name);

  /// No description provided for @homeCarbohydrates.
  ///
  /// In de, this message translates to:
  /// **'Kohlenhydrate'**
  String get homeCarbohydrates;

  /// No description provided for @homeFat.
  ///
  /// In de, this message translates to:
  /// **'Fett'**
  String get homeFat;

  /// No description provided for @homeFriday.
  ///
  /// In de, this message translates to:
  /// **'Freitag'**
  String get homeFriday;

  /// No description provided for @homeHelloValue.
  ///
  /// In de, this message translates to:
  /// **'Hallo, {arg0}'**
  String homeHelloValue(String arg0);

  /// No description provided for @homeKcalEaten.
  ///
  /// In de, this message translates to:
  /// **'kcal gegessen'**
  String get homeKcalEaten;

  /// No description provided for @homeLoadingStreak.
  ///
  /// In de, this message translates to:
  /// **'Serie wird geladen'**
  String get homeLoadingStreak;

  /// No description provided for @homeMealEntries.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Eintrag} other{{count} Einträge}} · {calories} kcal'**
  String homeMealEntries(int count, String calories);

  /// No description provided for @homeMonday.
  ///
  /// In de, this message translates to:
  /// **'Montag'**
  String get homeMonday;

  /// No description provided for @homeNothingLoggedYet.
  ///
  /// In de, this message translates to:
  /// **'Noch nichts eingetragen'**
  String get homeNothingLoggedYet;

  /// No description provided for @homeReminders.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen'**
  String get homeReminders;

  /// No description provided for @homeSaturday.
  ///
  /// In de, this message translates to:
  /// **'Samstag'**
  String get homeSaturday;

  /// No description provided for @homeSunday.
  ///
  /// In de, this message translates to:
  /// **'Sonntag'**
  String get homeSunday;

  /// No description provided for @homeTapAMealToLogFood.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf eine Mahlzeit, um Essen einzutragen.'**
  String get homeTapAMealToLogFood;

  /// No description provided for @homeThursday.
  ///
  /// In de, this message translates to:
  /// **'Donnerstag'**
  String get homeThursday;

  /// No description provided for @homeTuesday.
  ///
  /// In de, this message translates to:
  /// **'Dienstag'**
  String get homeTuesday;

  /// No description provided for @homeValueAbove.
  ///
  /// In de, this message translates to:
  /// **'{arg0} darüber'**
  String homeValueAbove(String arg0);

  /// No description provided for @homeValueDayTrackingStreak.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Tage Tracking-Serie'**
  String homeValueDayTrackingStreak(String arg0);

  /// No description provided for @homeValueKcalAboveYourTarget.
  ///
  /// In de, this message translates to:
  /// **'{arg0} kcal über deinem Ziel'**
  String homeValueKcalAboveYourTarget(String arg0);

  /// No description provided for @homeValueKcalEaten.
  ///
  /// In de, this message translates to:
  /// **'{arg0} kcal gegessen'**
  String homeValueKcalEaten(String arg0);

  /// No description provided for @homeValueKcalRemaining.
  ///
  /// In de, this message translates to:
  /// **'{arg0} kcal übrig'**
  String homeValueKcalRemaining(String arg0);

  /// No description provided for @homeValueKcalTarget.
  ///
  /// In de, this message translates to:
  /// **'{arg0} kcal Ziel'**
  String homeValueKcalTarget(String arg0);

  /// No description provided for @homeValuePValueCValueF.
  ///
  /// In de, this message translates to:
  /// **'{arg0} P · {arg1} K · {arg2} F'**
  String homeValuePValueCValueF(String arg0, String arg1, String arg2);

  /// No description provided for @homeValueRemaining.
  ///
  /// In de, this message translates to:
  /// **'{arg0} übrig'**
  String homeValueRemaining(String arg0);

  /// No description provided for @homeWednesday.
  ///
  /// In de, this message translates to:
  /// **'Mittwoch'**
  String get homeWednesday;

  /// No description provided for @homeYourDay.
  ///
  /// In de, this message translates to:
  /// **'Dein Tag'**
  String get homeYourDay;

  /// No description provided for @homeYourMeals.
  ///
  /// In de, this message translates to:
  /// **'Deine Mahlzeiten'**
  String get homeYourMeals;

  /// Button on the first-start language page, names the selected language.
  ///
  /// In de, this message translates to:
  /// **'Weiter auf Deutsch'**
  String get languageContinue;

  /// No description provided for @languageDeviceActive.
  ///
  /// In de, this message translates to:
  /// **'Handysprache'**
  String get languageDeviceActive;

  /// No description provided for @languageDeviceSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Automatisch Deutsch oder Englisch'**
  String get languageDeviceSubtitle;

  /// No description provided for @languageDeviceTitle.
  ///
  /// In de, this message translates to:
  /// **'Handysprache verwenden'**
  String get languageDeviceTitle;

  /// No description provided for @languageSelectedSemantics.
  ///
  /// In de, this message translates to:
  /// **'{language}, ausgewählt'**
  String languageSelectedSemantics(String language);

  /// No description provided for @languageSettingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get languageSettingsTitle;

  /// No description provided for @languageSheetSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Die ganze App wechselt sofort, auch Rezepte und Lebensmittel.'**
  String get languageSheetSubtitle;

  /// No description provided for @languageSheetTitle.
  ///
  /// In de, this message translates to:
  /// **'Sprache wählen'**
  String get languageSheetTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Du kannst sie später jederzeit im Profil ändern.'**
  String get languageSubtitle;

  /// No description provided for @languageTitle.
  ///
  /// In de, this message translates to:
  /// **'Wähle deine Sprache'**
  String get languageTitle;

  /// No description provided for @navigationAdd.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get navigationAdd;

  /// No description provided for @navigationAddMeal.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit hinzufügen'**
  String get navigationAddMeal;

  /// No description provided for @navigationAi.
  ///
  /// In de, this message translates to:
  /// **'KI'**
  String get navigationAi;

  /// No description provided for @navigationDiary.
  ///
  /// In de, this message translates to:
  /// **'Tagebuch'**
  String get navigationDiary;

  /// No description provided for @navigationProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get navigationProfile;

  /// No description provided for @navigationRecipes.
  ///
  /// In de, this message translates to:
  /// **'Rezepte'**
  String get navigationRecipes;

  /// No description provided for @navigationYourDayYourRhythm.
  ///
  /// In de, this message translates to:
  /// **'Dein Alltag. Dein Rhythmus.'**
  String get navigationYourDayYourRhythm;

  /// No description provided for @onboarding20Min.
  ///
  /// In de, this message translates to:
  /// **'20 Min.'**
  String get onboarding20Min;

  /// No description provided for @onboarding560Kcal34GProtein.
  ///
  /// In de, this message translates to:
  /// **'560 kcal · 34 g Protein'**
  String get onboarding560Kcal34GProtein;

  /// No description provided for @onboardingARoughEstimateAtAValuePace.
  ///
  /// In de, this message translates to:
  /// **'Grobe Schätzung bei {arg0} Tempo – dein Körper hält sich nicht an Kalender.'**
  String onboardingARoughEstimateAtAValuePace(String arg0);

  /// No description provided for @onboardingARoughEstimateYourBodyDoesNot.
  ///
  /// In de, this message translates to:
  /// **'Grobe Schätzung – dein Körper hält sich nicht an Kalender.'**
  String get onboardingARoughEstimateYourBodyDoesNot;

  /// No description provided for @onboardingATargetThatFitsYouNotA.
  ///
  /// In de, this message translates to:
  /// **'Ein Ziel, das zu dir passt – kein Muss. Du kannst es jederzeit ändern.'**
  String get onboardingATargetThatFitsYouNotA;

  /// No description provided for @onboardingAddMeal.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit hinzufügen'**
  String get onboardingAddMeal;

  /// No description provided for @onboardingAddToDiary.
  ///
  /// In de, this message translates to:
  /// **'Zum Tagebuch hinzufügen'**
  String get onboardingAddToDiary;

  /// No description provided for @onboardingAddToLunchValueKcal.
  ///
  /// In de, this message translates to:
  /// **'Zu Mittagessen hinzufügen · {arg0} kcal'**
  String onboardingAddToLunchValueKcal(String arg0);

  /// No description provided for @onboardingAge.
  ///
  /// In de, this message translates to:
  /// **'Alter'**
  String get onboardingAge;

  /// No description provided for @onboardingAgeBlockedText.
  ///
  /// In de, this message translates to:
  /// **'Du hast angegeben, unter 18 zu sein. Deshalb kannst du Lookin nicht nutzen. Wenn du dich vertippt hast, schließe die App und öffne sie neu.'**
  String get onboardingAgeBlockedText;

  /// No description provided for @onboardingAgeBlockedTitle.
  ///
  /// In de, this message translates to:
  /// **'Lookin ist erst ab 18'**
  String get onboardingAgeBlockedTitle;

  /// No description provided for @onboardingAgeGateNo.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get onboardingAgeGateNo;

  /// No description provided for @onboardingAgeGateText.
  ///
  /// In de, this message translates to:
  /// **'Lookin ist für Personen ab 18 Jahren gedacht. Bitte bestätige dein Alter, bevor du weitermachst.'**
  String get onboardingAgeGateText;

  /// No description provided for @onboardingAgeGateTitle.
  ///
  /// In de, this message translates to:
  /// **'Bist du mindestens 18 Jahre alt?'**
  String get onboardingAgeGateTitle;

  /// No description provided for @onboardingAgeGateYes.
  ///
  /// In de, this message translates to:
  /// **'Ja, ich bin mindestens 18'**
  String get onboardingAgeGateYes;

  /// No description provided for @onboardingAiEstimate.
  ///
  /// In de, this message translates to:
  /// **'KI-Schätzung'**
  String get onboardingAiEstimate;

  /// No description provided for @onboardingAiEstimates.
  ///
  /// In de, this message translates to:
  /// **'KI schätzt.'**
  String get onboardingAiEstimates;

  /// No description provided for @onboardingAiEstimatesFoods.
  ///
  /// In de, this message translates to:
  /// **'KI schätzt Lebensmittel'**
  String get onboardingAiEstimatesFoods;

  /// No description provided for @onboardingAiNutritionFitness.
  ///
  /// In de, this message translates to:
  /// **'KI · Ernährung & Fitness'**
  String get onboardingAiNutritionFitness;

  /// No description provided for @onboardingAiPhoto.
  ///
  /// In de, this message translates to:
  /// **'KI-Foto'**
  String get onboardingAiPhoto;

  /// No description provided for @onboardingAiPhotoPremium.
  ///
  /// In de, this message translates to:
  /// **'KI-FOTO · PREMIUM'**
  String get onboardingAiPhotoPremium;

  /// No description provided for @onboardingAiRecognisesFoodsAndEstimatesAmountsYou.
  ///
  /// In de, this message translates to:
  /// **'Die KI erkennt Lebensmittel und schätzt die Mengen. Du prüfst Gramm und Nährwerte, ergänzt, was fehlt – und speicherst erst dann.'**
  String get onboardingAiRecognisesFoodsAndEstimatesAmountsYou;

  /// No description provided for @onboardingAlreadyAMember.
  ///
  /// In de, this message translates to:
  /// **'Schon dabei? '**
  String get onboardingAlreadyAMember;

  /// No description provided for @onboardingAlreadyHaveAnAccountSignIn.
  ///
  /// In de, this message translates to:
  /// **'Schon ein Konto? Anmelden'**
  String get onboardingAlreadyHaveAnAccountSignIn;

  /// No description provided for @onboardingAmount.
  ///
  /// In de, this message translates to:
  /// **'Menge'**
  String get onboardingAmount;

  /// No description provided for @onboardingAnswerTheQuestionsInYourProfileAt.
  ///
  /// In de, this message translates to:
  /// **'Beantworte die Fragen jederzeit im Profil, dann passt sich Lookin an dich an.'**
  String get onboardingAnswerTheQuestionsInYourProfileAt;

  /// No description provided for @onboardingAnswersAboutNutritionAndFitnessTailoredTo.
  ///
  /// In de, this message translates to:
  /// **'Antworten zu Ernährung und Fitness, passend zu deinem Ziel und deinen Tageswerten.'**
  String get onboardingAnswersAboutNutritionAndFitnessTailoredTo;

  /// No description provided for @onboardingAskYourCoach.
  ///
  /// In de, this message translates to:
  /// **'Frag deinen Coach …'**
  String get onboardingAskYourCoach;

  /// No description provided for @onboardingAtAGlance.
  ///
  /// In de, this message translates to:
  /// **'Auf einen Blick.'**
  String get onboardingAtAGlance;

  /// No description provided for @onboardingAtHome.
  ///
  /// In de, this message translates to:
  /// **'Zu Hause'**
  String get onboardingAtHome;

  /// No description provided for @onboardingBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get onboardingBack;

  /// No description provided for @onboardingBreakfast.
  ///
  /// In de, this message translates to:
  /// **'Frühstück'**
  String get onboardingBreakfast;

  /// No description provided for @onboardingBreakfastLunchDinnerAndSnacksInOne.
  ///
  /// In de, this message translates to:
  /// **'Frühstück, Mittagessen, Abendessen und Snacks an einem Ort – mit Kalorien, Kohlenhydraten, Protein und Fett.'**
  String get onboardingBreakfastLunchDinnerAndSnacksInOne;

  /// No description provided for @onboardingBuildMuscle.
  ///
  /// In de, this message translates to:
  /// **'Muskeln aufbauen'**
  String get onboardingBuildMuscle;

  /// No description provided for @onboardingCalculateEnergyNeedsFromValue.
  ///
  /// In de, this message translates to:
  /// **'Energiebedarf aus {arg0} berechnen'**
  String onboardingCalculateEnergyNeedsFromValue(String arg0);

  /// No description provided for @onboardingCarbohydrates.
  ///
  /// In de, this message translates to:
  /// **'Kohlenhydrate'**
  String get onboardingCarbohydrates;

  /// No description provided for @onboardingChangeAnswers.
  ///
  /// In de, this message translates to:
  /// **'Antworten ändern'**
  String get onboardingChangeAnswers;

  /// No description provided for @onboardingCheckTheEstimateThenSave.
  ///
  /// In de, this message translates to:
  /// **'Schätzung prüfen, dann speichern'**
  String get onboardingCheckTheEstimateThenSave;

  /// No description provided for @onboardingChooseTheUnitThatFeelsNaturalTo.
  ///
  /// In de, this message translates to:
  /// **'Wähle die Einheit, die für dich natürlich ist, und wische zum passenden Wert.'**
  String get onboardingChooseTheUnitThatFeelsNaturalTo;

  /// No description provided for @onboardingClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get onboardingClose;

  /// No description provided for @onboardingContinue.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get onboardingContinue;

  /// No description provided for @onboardingContinueForNow.
  ///
  /// In de, this message translates to:
  /// **'Für jetzt fortfahren'**
  String get onboardingContinueForNow;

  /// No description provided for @onboardingCookSimply.
  ///
  /// In de, this message translates to:
  /// **'Einfach kochen.'**
  String get onboardingCookSimply;

  /// No description provided for @onboardingCookWithWhatYouHave.
  ///
  /// In de, this message translates to:
  /// **'Kochen mit dem, was da ist'**
  String get onboardingCookWithWhatYouHave;

  /// No description provided for @onboardingCreatingPlanValuePerCent.
  ///
  /// In de, this message translates to:
  /// **'Plan wird erstellt, {arg0} Prozent'**
  String onboardingCreatingPlanValuePerCent(String arg0);

  /// No description provided for @onboardingCreatingYourPlan.
  ///
  /// In de, this message translates to:
  /// **'Dein Plan wird erstellt …'**
  String get onboardingCreatingYourPlan;

  /// No description provided for @onboardingDailyRoutine.
  ///
  /// In de, this message translates to:
  /// **'Alltag'**
  String get onboardingDailyRoutine;

  /// No description provided for @onboardingDailyTarget.
  ///
  /// In de, this message translates to:
  /// **'Tagesziel'**
  String get onboardingDailyTarget;

  /// No description provided for @onboardingDateOfBirth.
  ///
  /// In de, this message translates to:
  /// **'Geburtsdatum'**
  String get onboardingDateOfBirth;

  /// No description provided for @onboardingDayStreak.
  ///
  /// In de, this message translates to:
  /// **'Tage Serie'**
  String get onboardingDayStreak;

  /// No description provided for @onboardingDec.
  ///
  /// In de, this message translates to:
  /// **'Dez'**
  String get onboardingDec;

  /// No description provided for @onboardingDecember.
  ///
  /// In de, this message translates to:
  /// **'Dezember'**
  String get onboardingDecember;

  /// No description provided for @onboardingDinner.
  ///
  /// In de, this message translates to:
  /// **'Abendessen'**
  String get onboardingDinner;

  /// No description provided for @onboardingDragTheRulerLeftOrRightThis.
  ///
  /// In de, this message translates to:
  /// **'Ziehe das Lineal nach links oder rechts. Es ist dein aktuelles Gewicht, kein Ziel.'**
  String get onboardingDragTheRulerLeftOrRightThis;

  /// No description provided for @onboardingDragTheRulerLeftOrRightYour.
  ///
  /// In de, this message translates to:
  /// **'Ziehe das Lineal nach links oder rechts. Dein Gewicht wird nicht bewertet.'**
  String get onboardingDragTheRulerLeftOrRightYour;

  /// No description provided for @onboardingEggs.
  ///
  /// In de, this message translates to:
  /// **'Eier'**
  String get onboardingEggs;

  /// No description provided for @onboardingEnterManually.
  ///
  /// In de, this message translates to:
  /// **'Manuell eintragen'**
  String get onboardingEnterManually;

  /// No description provided for @onboardingEntriesToday.
  ///
  /// In de, this message translates to:
  /// **'Einträge heute'**
  String get onboardingEntriesToday;

  /// No description provided for @onboardingEstimateProteinAndFatFromYourWeight.
  ///
  /// In de, this message translates to:
  /// **'Eiweiß und Fett aus deinem Gewicht ableiten'**
  String get onboardingEstimateProteinAndFatFromYourWeight;

  /// No description provided for @onboardingEstimateTimeToYourTargetWeight.
  ///
  /// In de, this message translates to:
  /// **'Zeit bis zu deinem Wunschgewicht abschätzen'**
  String get onboardingEstimateTimeToYourTargetWeight;

  /// No description provided for @onboardingEstimatesAreAlwaysLabelledAsEstimates.
  ///
  /// In de, this message translates to:
  /// **'Schätzungen sind immer als Schätzung markiert.'**
  String get onboardingEstimatesAreAlwaysLabelledAsEstimates;

  /// No description provided for @onboardingEveryRoutineIsDifferent.
  ///
  /// In de, this message translates to:
  /// **'Jeder Alltag ist anders.'**
  String get onboardingEveryRoutineIsDifferent;

  /// No description provided for @onboardingEverythingIsBasedOnYourAnswersAnd.
  ///
  /// In de, this message translates to:
  /// **'Alles basiert auf deinen Antworten und lässt sich jederzeit im Profil anpassen.'**
  String get onboardingEverythingIsBasedOnYourAnswersAnd;

  /// No description provided for @onboardingExampleView.
  ///
  /// In de, this message translates to:
  /// **'Beispielansicht'**
  String get onboardingExampleView;

  /// No description provided for @onboardingFat.
  ///
  /// In de, this message translates to:
  /// **'Fett'**
  String get onboardingFat;

  /// No description provided for @onboardingFebruary.
  ///
  /// In de, this message translates to:
  /// **'Februar'**
  String get onboardingFebruary;

  /// No description provided for @onboardingFilterByQuickHighProteinOrVegetarian.
  ///
  /// In de, this message translates to:
  /// **'Filtere nach Schnell, High Protein oder Vegetarisch und finde Rezepte mit dem, was du zu Hause hast.'**
  String get onboardingFilterByQuickHighProteinOrVegetarian;

  /// No description provided for @onboardingFilterOutRecipesContainingYourAllergens.
  ///
  /// In de, this message translates to:
  /// **'Rezepte mit deinen Allergenen aussortieren'**
  String get onboardingFilterOutRecipesContainingYourAllergens;

  /// No description provided for @onboardingFindProduct.
  ///
  /// In de, this message translates to:
  /// **'Produkt finden'**
  String get onboardingFindProduct;

  /// No description provided for @onboardingFindRecipes.
  ///
  /// In de, this message translates to:
  /// **'Rezepte finden.'**
  String get onboardingFindRecipes;

  /// No description provided for @onboardingFocusedOnNutritionAndFitness.
  ///
  /// In de, this message translates to:
  /// **'Konzentriert auf Ernährung und Fitness.'**
  String get onboardingFocusedOnNutritionAndFitness;

  /// No description provided for @onboardingForExampleAlex.
  ///
  /// In de, this message translates to:
  /// **'Zum Beispiel Alex'**
  String get onboardingForExampleAlex;

  /// No description provided for @onboardingForYou.
  ///
  /// In de, this message translates to:
  /// **'FÜR DICH'**
  String get onboardingForYou;

  /// No description provided for @onboardingFourMealsOneOverview.
  ///
  /// In de, this message translates to:
  /// **'Vier Mahlzeiten. Ein Überblick.'**
  String get onboardingFourMealsOneOverview;

  /// No description provided for @onboardingGiveYourCoachYourAnswersAsBackground.
  ///
  /// In de, this message translates to:
  /// **'Deinem Coach deine Antworten als Hintergrund mitgeben'**
  String get onboardingGiveYourCoachYourAnswersAsBackground;

  /// No description provided for @onboardingGuidelineValuesForOrientationNotMedicalAdvice.
  ///
  /// In de, this message translates to:
  /// **'Richtwerte zur Orientierung, keine medizinische Beratung. Du kannst alles jederzeit im Profil anpassen.'**
  String get onboardingGuidelineValuesForOrientationNotMedicalAdvice;

  /// No description provided for @onboardingGuidelineValuesOnlyIfYouWantThem.
  ///
  /// In de, this message translates to:
  /// **'Richtwerte nur, wenn du möchtest'**
  String get onboardingGuidelineValuesOnlyIfYouWantThem;

  /// No description provided for @onboardingHaveYouCountedCaloriesBefore.
  ///
  /// In de, this message translates to:
  /// **'Hast du schon einmal Kalorien gezählt?'**
  String get onboardingHaveYouCountedCaloriesBefore;

  /// No description provided for @onboardingHeight.
  ///
  /// In de, this message translates to:
  /// **'Größe'**
  String get onboardingHeight;

  /// No description provided for @onboardingHelloValue.
  ///
  /// In de, this message translates to:
  /// **'Hallo, {arg0}.'**
  String onboardingHelloValue(String arg0);

  /// No description provided for @onboardingHowActiveAreYouUsually.
  ///
  /// In de, this message translates to:
  /// **'Wie aktiv bist du meistens?'**
  String get onboardingHowActiveAreYouUsually;

  /// No description provided for @onboardingHowDoYouEat.
  ///
  /// In de, this message translates to:
  /// **'Wie isst du?'**
  String get onboardingHowDoYouEat;

  /// No description provided for @onboardingHowDoYouLikeToEatSet.
  ///
  /// In de, this message translates to:
  /// **'Wie isst du gern? Richte deinen Rhythmus und deine Rezeptideen in wenigen Schritten ein.'**
  String get onboardingHowDoYouLikeToEatSet;

  /// No description provided for @onboardingHowTallAreYou.
  ///
  /// In de, this message translates to:
  /// **'Wie groß bist du?'**
  String get onboardingHowTallAreYou;

  /// No description provided for @onboardingIdeasMarkedAsBudgetRecipesAppearHigher.
  ///
  /// In de, this message translates to:
  /// **'Für deinen Einkauf stehen als Budget-Rezept markierte Ideen weiter oben.'**
  String get onboardingIdeasMarkedAsBudgetRecipesAppearHigher;

  /// No description provided for @onboardingIdeasMarkedAsBudgetRecipesMoveUp.
  ///
  /// In de, this message translates to:
  /// **'Als Budget-Rezept markierte Ideen rücken nach vorne.'**
  String get onboardingIdeasMarkedAsBudgetRecipesMoveUp;

  /// No description provided for @onboardingIfYouWishLookinCalculatesGuidelineValues.
  ///
  /// In de, this message translates to:
  /// **'Wenn du möchtest, berechnet Lookin Richtwerte aus Alter, Größe und Gewicht. Deine Serie zeigt, wie regelmäßig du dabei bist.'**
  String get onboardingIfYouWishLookinCalculatesGuidelineValues;

  /// No description provided for @onboardingInDiary.
  ///
  /// In de, this message translates to:
  /// **'Im Tagebuch'**
  String get onboardingInDiary;

  /// No description provided for @onboardingIntentionallyLeaveOutCalorieTargetsForYou.
  ///
  /// In de, this message translates to:
  /// **'Kalorienziele für dich bewusst weglassen'**
  String get onboardingIntentionallyLeaveOutCalorieTargetsForYou;

  /// No description provided for @onboardingIsThereAnythingLookinShouldTakeInto.
  ///
  /// In de, this message translates to:
  /// **'Gibt es etwas, worauf Lookin achten soll?'**
  String get onboardingIsThereAnythingLookinShouldTakeInto;

  /// No description provided for @onboardingJanuary.
  ///
  /// In de, this message translates to:
  /// **'Januar'**
  String get onboardingJanuary;

  /// No description provided for @onboardingJuly.
  ///
  /// In de, this message translates to:
  /// **'Juli'**
  String get onboardingJuly;

  /// No description provided for @onboardingJune.
  ///
  /// In de, this message translates to:
  /// **'Juni'**
  String get onboardingJune;

  /// No description provided for @onboardingJustAsk.
  ///
  /// In de, this message translates to:
  /// **'Frag einfach.'**
  String get onboardingJustAsk;

  /// No description provided for @onboardingKcalToday.
  ///
  /// In de, this message translates to:
  /// **'kcal heute'**
  String get onboardingKcalToday;

  /// No description provided for @onboardingLetSGo.
  ///
  /// In de, this message translates to:
  /// **'Los geht’s'**
  String get onboardingLetSGo;

  /// No description provided for @onboardingLogInYourDiaryWithOneTap.
  ///
  /// In de, this message translates to:
  /// **'Mit einem Tipp ins Tagebuch.'**
  String get onboardingLogInYourDiaryWithOneTap;

  /// No description provided for @onboardingLogMealsThroughSearchOrBarcodeAnd.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeiten per Suche oder Barcode eintragen – mit Premium auch per Foto.'**
  String get onboardingLogMealsThroughSearchOrBarcodeAnd;

  /// No description provided for @onboardingLookinDoesNotCalculateCalorieTargetsFor.
  ///
  /// In de, this message translates to:
  /// **'Für dich berechnet Lookin keine Kalorienziele. Tagebuch, Rezepte und Coach kannst du trotzdem nutzen – deine Ziele besprichst du am besten mit einer Ärztin, einem Arzt oder einer Ernährungsfachkraft.'**
  String get onboardingLookinDoesNotCalculateCalorieTargetsFor;

  /// No description provided for @onboardingLookinDoesNotCalculateCalorieTargetsFor2.
  ///
  /// In de, this message translates to:
  /// **'Für Personen unter 18 Jahren berechnet Lookin keine Kalorienziele. Rezepte, Tagebuch und Tipps kannst du trotzdem nutzen.'**
  String get onboardingLookinDoesNotCalculateCalorieTargetsFor2;

  /// No description provided for @onboardingLookinDoesNotCalculateDailyTargetsWithout.
  ///
  /// In de, this message translates to:
  /// **'Ohne Alter, Größe und Gewicht berechnet Lookin keine Tagesziele. Du kannst sie jederzeit im Profil ergänzen.'**
  String get onboardingLookinDoesNotCalculateDailyTargetsWithout;

  /// No description provided for @onboardingLookinHidesRecipesContainingYourAllergens.
  ///
  /// In de, this message translates to:
  /// **'Rezepte mit deinen Allergenen blendet Lookin aus.'**
  String get onboardingLookinHidesRecipesContainingYourAllergens;

  /// No description provided for @onboardingLookinIsProcessingYourAnswers.
  ///
  /// In de, this message translates to:
  /// **'Lookin verarbeitet gerade deine Antworten.'**
  String get onboardingLookinIsProcessingYourAnswers;

  /// No description provided for @onboardingLookinOnlyOffersTargetsWithinTheHealthy.
  ///
  /// In de, this message translates to:
  /// **'Lookin bietet nur Ziele im gesunden Bereich (BMI ab 18,5) und höchstens etwa ein halbes Kilo pro Woche an.'**
  String get onboardingLookinOnlyOffersTargetsWithinTheHealthy;

  /// No description provided for @onboardingLookinWorksWithoutThisInformationToo.
  ///
  /// In de, this message translates to:
  /// **'Ohne Angaben funktioniert Lookin genauso.'**
  String get onboardingLookinWorksWithoutThisInformationToo;

  /// No description provided for @onboardingLunch.
  ///
  /// In de, this message translates to:
  /// **'Mittagessen'**
  String get onboardingLunch;

  /// No description provided for @onboardingMakeLookinFitYou.
  ///
  /// In de, this message translates to:
  /// **'So passt Lookin zu dir'**
  String get onboardingMakeLookinFitYou;

  /// No description provided for @onboardingMar.
  ///
  /// In de, this message translates to:
  /// **'Mär'**
  String get onboardingMar;

  /// No description provided for @onboardingMarch.
  ///
  /// In de, this message translates to:
  /// **'März'**
  String get onboardingMarch;

  /// No description provided for @onboardingMay.
  ///
  /// In de, this message translates to:
  /// **'Mai'**
  String get onboardingMay;

  /// No description provided for @onboardingMealPrepForYourDay.
  ///
  /// In de, this message translates to:
  /// **'Vorkochen für deinen Alltag'**
  String get onboardingMealPrepForYourDay;

  /// No description provided for @onboardingMetricCmKg.
  ///
  /// In de, this message translates to:
  /// **'Metrisch · cm / kg'**
  String get onboardingMetricCmKg;

  /// No description provided for @onboardingMoreProtein.
  ///
  /// In de, this message translates to:
  /// **'Mehr Protein'**
  String get onboardingMoreProtein;

  /// No description provided for @onboardingMostlySeatedOfficeStudyCarOftenMoving.
  ///
  /// In de, this message translates to:
  /// **'Meist sitzend: Büro, Studium, Auto. Viel in Bewegung: Pflege, Handwerk, Verkauf oder viele Wege zu Fuß.'**
  String get onboardingMostlySeatedOfficeStudyCarOftenMoving;

  /// No description provided for @onboardingMuscleGrowsSlowlyEnoughProteinAndTraining.
  ///
  /// In de, this message translates to:
  /// **'Muskeln wachsen langsam. Genug Eiweiß und Training sind wichtiger als schnelle Zahlen.'**
  String get onboardingMuscleGrowsSlowlyEnoughProteinAndTraining;

  /// No description provided for @onboardingMyDailyTargets.
  ///
  /// In de, this message translates to:
  /// **'MEINE TÄGLICHEN ZIELE'**
  String get onboardingMyDailyTargets;

  /// No description provided for @onboardingNoneOfTheseApplySimplyTapContinue.
  ///
  /// In de, this message translates to:
  /// **'Trifft nichts davon zu? Dann tippe einfach auf „Weiter“.'**
  String get onboardingNoneOfTheseApplySimplyTapContinue;

  /// No description provided for @onboardingNutritionAndFitnessOnly.
  ///
  /// In de, this message translates to:
  /// **'Nur Ernährung und Fitness'**
  String get onboardingNutritionAndFitnessOnly;

  /// No description provided for @onboardingNutritionStyle.
  ///
  /// In de, this message translates to:
  /// **'Ernährungsweise'**
  String get onboardingNutritionStyle;

  /// No description provided for @onboardingOct.
  ///
  /// In de, this message translates to:
  /// **'Okt'**
  String get onboardingOct;

  /// No description provided for @onboardingOctober.
  ///
  /// In de, this message translates to:
  /// **'Oktober'**
  String get onboardingOctober;

  /// No description provided for @onboardingOf2100.
  ///
  /// In de, this message translates to:
  /// **'von 2.100'**
  String get onboardingOf2100;

  /// No description provided for @onboardingOneMoment.
  ///
  /// In de, this message translates to:
  /// **'Einen Moment …'**
  String get onboardingOneMoment;

  /// No description provided for @onboardingOnlyUsedToEstimateYourEnergyNeeds.
  ///
  /// In de, this message translates to:
  /// **'Nur für die Schätzung deines Energiebedarfs – Körper verbrauchen je nach Geschlecht unterschiedlich viel. Du kannst das auch offenlassen.'**
  String get onboardingOnlyUsedToEstimateYourEnergyNeeds;

  /// No description provided for @onboardingOpeningLookin.
  ///
  /// In de, this message translates to:
  /// **'Lookin wird geöffnet'**
  String get onboardingOpeningLookin;

  /// No description provided for @onboardingOptionalAndOnlyForYourSafetyThis.
  ///
  /// In de, this message translates to:
  /// **'Freiwillig und nur für deine Sicherheit. Diese Angabe bleibt auf diesem Gerät, solange du der Speicherung im Konto nicht zustimmst.'**
  String get onboardingOptionalAndOnlyForYourSafetyThis;

  /// No description provided for @onboardingPageValueOfValue.
  ///
  /// In de, this message translates to:
  /// **'Seite {arg0} von {arg1}'**
  String onboardingPageValueOfValue(String arg0, String arg1);

  /// No description provided for @onboardingPersonalise.
  ///
  /// In de, this message translates to:
  /// **'Persönlich einrichten'**
  String get onboardingPersonalise;

  /// No description provided for @onboardingPescatarian.
  ///
  /// In de, this message translates to:
  /// **'Pescetarisch'**
  String get onboardingPescatarian;

  /// No description provided for @onboardingPhotoBarcodeOrManualEntry.
  ///
  /// In de, this message translates to:
  /// **'Foto, Barcode oder selbst eintragen'**
  String get onboardingPhotoBarcodeOrManualEntry;

  /// No description provided for @onboardingPotatoes.
  ///
  /// In de, this message translates to:
  /// **'Kartoffeln'**
  String get onboardingPotatoes;

  /// No description provided for @onboardingPreparingYourLookin.
  ///
  /// In de, this message translates to:
  /// **'Dein Lookin wird vorbereitet …'**
  String get onboardingPreparingYourLookin;

  /// No description provided for @onboardingProtein.
  ///
  /// In de, this message translates to:
  /// **'Eiweiß'**
  String get onboardingProtein;

  /// No description provided for @onboardingQuick.
  ///
  /// In de, this message translates to:
  /// **'Schnell'**
  String get onboardingQuick;

  /// No description provided for @onboardingQuickToLog.
  ///
  /// In de, this message translates to:
  /// **'SCHNELL EINGETRAGEN'**
  String get onboardingQuickToLog;

  /// No description provided for @onboardingRecipeIdeasLabelledAsValueAppearFirst.
  ///
  /// In de, this message translates to:
  /// **'Passend gekennzeichnete {arg0} Rezeptideen erscheinen zuerst.'**
  String onboardingRecipeIdeasLabelledAsValueAppearFirst(String arg0);

  /// No description provided for @onboardingRecipes.
  ///
  /// In de, this message translates to:
  /// **'REZEPTE'**
  String get onboardingRecipes;

  /// No description provided for @onboardingRecipesAreSortedByValue.
  ///
  /// In de, this message translates to:
  /// **'Rezepte erscheinen sortiert nach {arg0}.'**
  String onboardingRecipesAreSortedByValue(String arg0);

  /// No description provided for @onboardingRecipesTakingUpToValueMinutesGet.
  ///
  /// In de, this message translates to:
  /// **'Rezepte bis {arg0} Minuten bekommen Vorrang, wenn passende vorhanden sind.'**
  String onboardingRecipesTakingUpToValueMinutesGet(String arg0);

  /// No description provided for @onboardingRemovalDidNotWorkPleaseTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Entfernen hat nicht geklappt. Bitte versuche es erneut.'**
  String get onboardingRemovalDidNotWorkPleaseTryAgain;

  /// No description provided for @onboardingRemoveAnswers.
  ///
  /// In de, this message translates to:
  /// **'Antworten entfernen'**
  String get onboardingRemoveAnswers;

  /// No description provided for @onboardingReplayAnimation.
  ///
  /// In de, this message translates to:
  /// **'Animation wiederholen'**
  String get onboardingReplayAnimation;

  /// No description provided for @onboardingRice.
  ///
  /// In de, this message translates to:
  /// **'Reis'**
  String get onboardingRice;

  /// No description provided for @onboardingSalad.
  ///
  /// In de, this message translates to:
  /// **'Salat'**
  String get onboardingSalad;

  /// No description provided for @onboardingSalmon.
  ///
  /// In de, this message translates to:
  /// **'Lachs'**
  String get onboardingSalmon;

  /// No description provided for @onboardingSalmonAvocadoRice.
  ///
  /// In de, this message translates to:
  /// **'Lachs-Avocado-Reis'**
  String get onboardingSalmonAvocadoRice;

  /// No description provided for @onboardingSaving.
  ///
  /// In de, this message translates to:
  /// **'Wird gespeichert …'**
  String get onboardingSaving;

  /// No description provided for @onboardingScanBarcode.
  ///
  /// In de, this message translates to:
  /// **'Barcode scannen'**
  String get onboardingScanBarcode;

  /// No description provided for @onboardingSearchAndCustomFoodsIncluded.
  ///
  /// In de, this message translates to:
  /// **'Suchen und eigene Lebensmittel inklusive.'**
  String get onboardingSearchAndCustomFoodsIncluded;

  /// No description provided for @onboardingSearchOrEnterManually.
  ///
  /// In de, this message translates to:
  /// **'Suchen oder selbst'**
  String get onboardingSearchOrEnterManually;

  /// No description provided for @onboardingSeeWhatYouHaveAlreadyEatenToday.
  ///
  /// In de, this message translates to:
  /// **'Sehen, was du heute schon gegessen hast.'**
  String get onboardingSeeWhatYouHaveAlreadyEatenToday;

  /// No description provided for @onboardingSelectEverythingThatFitsItIsCompletely.
  ///
  /// In de, this message translates to:
  /// **'Wähle alles, was passt – das ist völlig normal. Lookin gibt dir dazu passende Tipps.'**
  String get onboardingSelectEverythingThatFitsItIsCompletely;

  /// No description provided for @onboardingSelectEverythingThatFitsYourCoachUses.
  ///
  /// In de, this message translates to:
  /// **'Wähle alles, was passt. Dein Coach greift das auf, wenn es mal schwerfällt.'**
  String get onboardingSelectEverythingThatFitsYourCoachUses;

  /// No description provided for @onboardingSetProteinAndFatToFitYour.
  ///
  /// In de, this message translates to:
  /// **'Eiweiß und Fett passend zu deinem Ziel festlegen'**
  String get onboardingSetProteinAndFatToFitYour;

  /// No description provided for @onboardingSex.
  ///
  /// In de, this message translates to:
  /// **'Geschlecht'**
  String get onboardingSex;

  /// No description provided for @onboardingShortOnTimeTodayQuickMealsAppear.
  ///
  /// In de, this message translates to:
  /// **'Wenig Zeit heute? In deinen Rezeptideen stehen schnelle Gerichte weiter oben.'**
  String get onboardingShortOnTimeTodayQuickMealsAppear;

  /// No description provided for @onboardingSignIn.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get onboardingSignIn;

  /// No description provided for @onboardingSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get onboardingSkip;

  /// No description provided for @onboardingSoLookinCanAddressYouProperly.
  ///
  /// In de, this message translates to:
  /// **'Damit Lookin dich richtig anspricht.'**
  String get onboardingSoLookinCanAddressYouProperly;

  /// No description provided for @onboardingSoRecipesSuggestionsAndTheCoachFit.
  ///
  /// In de, this message translates to:
  /// **'Damit Rezepte, Vorschläge und der Coach zu dir passen.'**
  String get onboardingSoRecipesSuggestionsAndTheCoachFit;

  /// No description provided for @onboardingSortRecipesByValue.
  ///
  /// In de, this message translates to:
  /// **'Rezepte nach {arg0} sortieren'**
  String onboardingSortRecipesByValue(String arg0);

  /// No description provided for @onboardingSpaceForYou.
  ///
  /// In de, this message translates to:
  /// **'Platz für dich.'**
  String get onboardingSpaceForYou;

  /// No description provided for @onboardingSteadyPace.
  ///
  /// In de, this message translates to:
  /// **'Ausgewogen'**
  String get onboardingSteadyPace;

  /// No description provided for @onboardingStillEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch leer'**
  String get onboardingStillEmpty;

  /// No description provided for @onboardingSummariseYourAnswers.
  ///
  /// In de, this message translates to:
  /// **'Deine Antworten zusammenfassen'**
  String get onboardingSummariseYourAnswers;

  /// No description provided for @onboardingSwipeTheWheelsUpOrDown.
  ///
  /// In de, this message translates to:
  /// **'Wische direkt in den Rädern nach oben oder unten.'**
  String get onboardingSwipeTheWheelsUpOrDown;

  /// No description provided for @onboardingTakeAPhoto.
  ///
  /// In de, this message translates to:
  /// **'Foto machen.'**
  String get onboardingTakeAPhoto;

  /// No description provided for @onboardingTakeAPhotoScanABarcodeOr.
  ///
  /// In de, this message translates to:
  /// **'Foto machen, Barcode scannen oder selbst eintragen. Das Plus in der Mitte ist immer nur einen Tipp entfernt.'**
  String get onboardingTakeAPhotoScanABarcodeOr;

  /// No description provided for @onboardingTapThePlus.
  ///
  /// In de, this message translates to:
  /// **'Ein Tipp aufs Plus.'**
  String get onboardingTapThePlus;

  /// No description provided for @onboardingThankYouForSharingThisLookinDoes.
  ///
  /// In de, this message translates to:
  /// **'Danke, dass du das teilst. Lookin berechnet für dich keine Kalorienziele und schlägt keine Diät vor. Tagebuch, Rezepte und Coach kannst du trotzdem nutzen – deine Ziele besprichst du am besten mit deiner Ärztin, deinem Arzt oder einer Ernährungsfachkraft.'**
  String get onboardingThankYouForSharingThisLookinDoes;

  /// No description provided for @onboardingThatDidNotWorkJustNowPlease.
  ///
  /// In de, this message translates to:
  /// **'Das hat gerade nicht geklappt. Bitte versuche es noch einmal.'**
  String get onboardingThatDidNotWorkJustNowPlease;

  /// No description provided for @onboardingThatFitsUseThisValue.
  ///
  /// In de, this message translates to:
  /// **'Passt genau so – Wert übernehmen'**
  String get onboardingThatFitsUseThisValue;

  /// No description provided for @onboardingTheIntroductionMayAppearAgainAtThe.
  ///
  /// In de, this message translates to:
  /// **'Die Einführung erscheint beim nächsten Start eventuell erneut.'**
  String get onboardingTheIntroductionMayAppearAgainAtThe;

  /// No description provided for @onboardingThisHelpsLookinSuggestRecipesThatFit.
  ///
  /// In de, this message translates to:
  /// **'So schlägt Lookin Rezepte vor, die in deinen Tag passen.'**
  String get onboardingThisHelpsLookinSuggestRecipesThatFit;

  /// No description provided for @onboardingThreeWays.
  ///
  /// In de, this message translates to:
  /// **'Drei Wege.'**
  String get onboardingThreeWays;

  /// No description provided for @onboardingTimeToCookOnANormalDay.
  ///
  /// In de, this message translates to:
  /// **'Zeit zum Kochen an einem normalen Tag'**
  String get onboardingTimeToCookOnANormalDay;

  /// No description provided for @onboardingTodayValue.
  ///
  /// In de, this message translates to:
  /// **'Heute · {arg0}'**
  String onboardingTodayValue(String arg0);

  /// No description provided for @onboardingTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get onboardingTryAgain;

  /// No description provided for @onboardingUpToValueMin.
  ///
  /// In de, this message translates to:
  /// **'Bis {arg0} Min.'**
  String onboardingUpToValueMin(String arg0);

  /// No description provided for @onboardingValueAndValue.
  ///
  /// In de, this message translates to:
  /// **'{arg0} und {arg1}'**
  String onboardingValueAndValue(String arg0, String arg1);

  /// No description provided for @onboardingValueAroundValue.
  ///
  /// In de, this message translates to:
  /// **'{arg0} etwa im {arg1}'**
  String onboardingValueAroundValue(String arg0, String arg1);

  /// No description provided for @onboardingValueKcalCValueGPValue.
  ///
  /// In de, this message translates to:
  /// **'{arg0} kcal · K {arg1} g · P {arg2} g'**
  String onboardingValueKcalCValueGPValue(
    String arg0,
    String arg1,
    String arg2,
  );

  /// No description provided for @onboardingValueKilocaloriesPerDay.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Kilokalorien pro Tag'**
  String onboardingValueKilocaloriesPerDay(String arg0);

  /// No description provided for @onboardingValueMealsFitIntoYourDay.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Mahlzeiten passen in deinen Tag'**
  String onboardingValueMealsFitIntoYourDay(String arg0);

  /// No description provided for @onboardingValueUpToValueMin.
  ///
  /// In de, this message translates to:
  /// **'{arg0} · bis {arg1} Min.'**
  String onboardingValueUpToValueMin(String arg0, String arg1);

  /// No description provided for @onboardingValueValueKgWeek.
  ///
  /// In de, this message translates to:
  /// **'{arg0}\n{arg1} kg/Woche'**
  String onboardingValueValueKgWeek(String arg0, String arg1);

  /// No description provided for @onboardingVegetarian.
  ///
  /// In de, this message translates to:
  /// **'Vegetarisch'**
  String get onboardingVegetarian;

  /// No description provided for @onboardingViewRecipeIdeas.
  ///
  /// In de, this message translates to:
  /// **'Rezeptideen ansehen'**
  String get onboardingViewRecipeIdeas;

  /// No description provided for @onboardingWeight.
  ///
  /// In de, this message translates to:
  /// **'Gewicht'**
  String get onboardingWeight;

  /// No description provided for @onboardingWhatCanIStillEatThisEvening.
  ///
  /// In de, this message translates to:
  /// **'Was kann ich heute Abend noch essen?'**
  String get onboardingWhatCanIStillEatThisEvening;

  /// No description provided for @onboardingWhatFeelsRightForYouMatters.
  ///
  /// In de, this message translates to:
  /// **'Was dir guttut, zählt.'**
  String get onboardingWhatFeelsRightForYouMatters;

  /// No description provided for @onboardingWhatHasHeldYouBackSoFar.
  ///
  /// In de, this message translates to:
  /// **'Was hat dich bisher gebremst?'**
  String get onboardingWhatHasHeldYouBackSoFar;

  /// No description provided for @onboardingWhatIsYourGoal.
  ///
  /// In de, this message translates to:
  /// **'Was ist dein Ziel?'**
  String get onboardingWhatIsYourGoal;

  /// No description provided for @onboardingWhatIsYourKitchenRoutine.
  ///
  /// In de, this message translates to:
  /// **'Wie sieht es in deiner Küche aus?'**
  String get onboardingWhatIsYourKitchenRoutine;

  /// No description provided for @onboardingWhatIsYourTargetWeight.
  ///
  /// In de, this message translates to:
  /// **'Was ist dein Wunschgewicht?'**
  String get onboardingWhatIsYourTargetWeight;

  /// No description provided for @onboardingWhatLookinDoesForYouNow.
  ///
  /// In de, this message translates to:
  /// **'Das macht Lookin jetzt für dich'**
  String get onboardingWhatLookinDoesForYouNow;

  /// No description provided for @onboardingWhatShouldWeCallYouOptional.
  ///
  /// In de, this message translates to:
  /// **'Wie dürfen wir dich nennen? (optional)'**
  String get onboardingWhatShouldWeCallYouOptional;

  /// No description provided for @onboardingWhenIsYourBirthday.
  ///
  /// In de, this message translates to:
  /// **'Wann hast du Geburtstag?'**
  String get onboardingWhenIsYourBirthday;

  /// No description provided for @onboardingWhereAreYouNow.
  ///
  /// In de, this message translates to:
  /// **'Wo stehst du gerade?'**
  String get onboardingWhereAreYouNow;

  /// No description provided for @onboardingWhereWouldYouLikeToBe.
  ///
  /// In de, this message translates to:
  /// **'Wohin möchtest du?'**
  String get onboardingWhereWouldYouLikeToBe;

  /// No description provided for @onboardingWhyDoesItMatterToYou.
  ///
  /// In de, this message translates to:
  /// **'Warum ist dir das wichtig?'**
  String get onboardingWhyDoesItMatterToYou;

  /// No description provided for @onboardingYouAreStartingWithACleanSlate.
  ///
  /// In de, this message translates to:
  /// **'Du startest ganz neutral.'**
  String get onboardingYouAreStartingWithACleanSlate;

  /// No description provided for @onboardingYouCanContinueTheQuestionsMayAppear.
  ///
  /// In de, this message translates to:
  /// **'Du kannst weitermachen. Die Fragen erscheinen beim nächsten Start möglicherweise erneut.'**
  String get onboardingYouCanContinueTheQuestionsMayAppear;

  /// No description provided for @onboardingYouCanSkipAboveLookinWorksWithout.
  ///
  /// In de, this message translates to:
  /// **'Du kannst oben überspringen. Lookin funktioniert auch ohne diese Antworten.'**
  String get onboardingYouCanSkipAboveLookinWorksWithout;

  /// No description provided for @onboardingYouChooseTheDirection.
  ///
  /// In de, this message translates to:
  /// **'Du bestimmst die Richtung.'**
  String get onboardingYouChooseTheDirection;

  /// No description provided for @onboardingYouHaveAbout650KcalLeftToday.
  ///
  /// In de, this message translates to:
  /// **'Du hast heute noch etwa 650 kcal frei. Wie wäre eine Lachs-Tomaten-Bowl? Rund 35 g Protein.'**
  String get onboardingYouHaveAbout650KcalLeftToday;

  /// No description provided for @onboardingYouHaveNotProvidedAnyInformationLookin.
  ///
  /// In de, this message translates to:
  /// **'Du hast keine Angaben gemacht. Darum berechnet Lookin noch keine Tagesziele und sortiert Rezepte nicht für dich. Sobald du im Profil etwas ergänzt, passt sich Lookin an.'**
  String get onboardingYouHaveNotProvidedAnyInformationLookin;

  /// No description provided for @onboardingYourAiCoach.
  ///
  /// In de, this message translates to:
  /// **'Dein KI-Coach.'**
  String get onboardingYourAiCoach;

  /// No description provided for @onboardingYourBudget.
  ///
  /// In de, this message translates to:
  /// **'deinem Budget'**
  String get onboardingYourBudget;

  /// No description provided for @onboardingYourChoices.
  ///
  /// In de, this message translates to:
  /// **'DEINE AUSWAHL'**
  String get onboardingYourChoices;

  /// No description provided for @onboardingYourCoachKnowsYourGoalsAndObstacles.
  ///
  /// In de, this message translates to:
  /// **'Dein Coach kennt deine Ziele und Hürden und richtet Tipps daran aus.'**
  String get onboardingYourCoachKnowsYourGoalsAndObstacles;

  /// No description provided for @onboardingYourCoachTakesIntoAccountValue.
  ///
  /// In de, this message translates to:
  /// **'Dein Coach berücksichtigt: {arg0}.'**
  String onboardingYourCoachTakesIntoAccountValue(String arg0);

  /// No description provided for @onboardingYourCookingTime.
  ///
  /// In de, this message translates to:
  /// **'deiner Zeit zum Kochen'**
  String get onboardingYourCookingTime;

  /// No description provided for @onboardingYourDailyGuideline.
  ///
  /// In de, this message translates to:
  /// **'Dein Tagesrichtwert'**
  String get onboardingYourDailyGuideline;

  /// No description provided for @onboardingYourDay.
  ///
  /// In de, this message translates to:
  /// **'DEIN TAG'**
  String get onboardingYourDay;

  /// No description provided for @onboardingYourDay2.
  ///
  /// In de, this message translates to:
  /// **'Dein Tag.'**
  String get onboardingYourDay2;

  /// No description provided for @onboardingYourDayYourLookin.
  ///
  /// In de, this message translates to:
  /// **'Dein Alltag. Dein Lookin.'**
  String get onboardingYourDayYourLookin;

  /// No description provided for @onboardingYourDiary.
  ///
  /// In de, this message translates to:
  /// **'DEIN TAGEBUCH'**
  String get onboardingYourDiary;

  /// No description provided for @onboardingYourFocusValue.
  ///
  /// In de, this message translates to:
  /// **'Dein Fokus: {arg0}.'**
  String onboardingYourFocusValue(String arg0);

  /// No description provided for @onboardingYourGoal.
  ///
  /// In de, this message translates to:
  /// **'deinem Ziel'**
  String get onboardingYourGoal;

  /// No description provided for @onboardingYourGoals.
  ///
  /// In de, this message translates to:
  /// **'Deine Ziele.'**
  String get onboardingYourGoals;

  /// No description provided for @onboardingYourHeight.
  ///
  /// In de, this message translates to:
  /// **'Deine Größe'**
  String get onboardingYourHeight;

  /// No description provided for @onboardingYourInformationCouldNotBeSavedPlease.
  ///
  /// In de, this message translates to:
  /// **'Deine Angaben konnten nicht gespeichert werden. Bitte versuche es erneut.'**
  String get onboardingYourInformationCouldNotBeSavedPlease;

  /// No description provided for @onboardingYourLookinPlanIsReady.
  ///
  /// In de, this message translates to:
  /// **'Dein Lookin-Plan ist bereit.'**
  String get onboardingYourLookinPlanIsReady;

  /// No description provided for @onboardingYourMealRhythmStaysFlexible.
  ///
  /// In de, this message translates to:
  /// **'Dein Rhythmus bleibt flexibel'**
  String get onboardingYourMealRhythmStaysFlexible;

  /// No description provided for @onboardingYourNameIsOptionalYouCanChange.
  ///
  /// In de, this message translates to:
  /// **'Dein Name ist optional. Alle Angaben kannst du später im Profil ändern.'**
  String get onboardingYourNameIsOptionalYouCanChange;

  /// No description provided for @onboardingYourNormalEverydayRoutineWithoutDedicatedExercise.
  ///
  /// In de, this message translates to:
  /// **'Dein ganz normaler Alltag, ohne gezieltes Training.'**
  String get onboardingYourNormalEverydayRoutineWithoutDedicatedExercise;

  /// No description provided for @onboardingYourNutritionStyle.
  ///
  /// In de, this message translates to:
  /// **'deiner Ernährungsweise'**
  String get onboardingYourNutritionStyle;

  /// No description provided for @onboardingYourOptionalInformationHelpsLookinAndThe.
  ///
  /// In de, this message translates to:
  /// **'Deine freiwilligen Angaben helfen Lookin und dem KI-Coach, Vorschläge persönlicher zu machen. Du kannst sie jederzeit ändern oder entfernen.'**
  String get onboardingYourOptionalInformationHelpsLookinAndThe;

  /// No description provided for @onboardingYourPreferencesAtAGlance.
  ///
  /// In de, this message translates to:
  /// **'Deine Wünsche auf einen Blick.'**
  String get onboardingYourPreferencesAtAGlance;

  /// No description provided for @onboardingYourProfile.
  ///
  /// In de, this message translates to:
  /// **'Dein Profil'**
  String get onboardingYourProfile;

  /// No description provided for @onboardingYourProfile2.
  ///
  /// In de, this message translates to:
  /// **'DEIN PROFIL'**
  String get onboardingYourProfile2;

  /// No description provided for @onboardingYourRecipeIdeasReflectThePreferencesYou.
  ///
  /// In de, this message translates to:
  /// **'Deine Rezeptideen richten sich nach den Vorlieben, die du angegeben hast.'**
  String get onboardingYourRecipeIdeasReflectThePreferencesYou;

  /// No description provided for @onboardingYourRecipeIdeasTakeYourCookingTime.
  ///
  /// In de, this message translates to:
  /// **'Deine Rezeptideen berücksichtigen deine Kochzeit.'**
  String get onboardingYourRecipeIdeasTakeYourCookingTime;

  /// No description provided for @onboardingYourRhythmIsAGuideYouCan.
  ///
  /// In de, this message translates to:
  /// **'Dein Rhythmus ist eine Orientierung. Du kannst ihn jederzeit ändern.'**
  String get onboardingYourRhythmIsAGuideYouCan;

  /// No description provided for @onboardingYourRoutineValue.
  ///
  /// In de, this message translates to:
  /// **'Dein Alltag: {arg0}.'**
  String onboardingYourRoutineValue(String arg0);

  /// No description provided for @onboardingYourSettingsCouldNotBeLoaded.
  ///
  /// In de, this message translates to:
  /// **'Deine Einstellungen konnten nicht geladen werden.'**
  String get onboardingYourSettingsCouldNotBeLoaded;

  /// No description provided for @onboardingYourSetupAnswersHaveBeenRemovedFrom.
  ///
  /// In de, this message translates to:
  /// **'Deine Einrichtungsantworten wurden von diesem Gerät entfernt.'**
  String get onboardingYourSetupAnswersHaveBeenRemovedFrom;

  /// No description provided for @onboardingYourSex.
  ///
  /// In de, this message translates to:
  /// **'Dein Geschlecht'**
  String get onboardingYourSex;

  /// No description provided for @onboardingYourStreak.
  ///
  /// In de, this message translates to:
  /// **'Deine Serie.'**
  String get onboardingYourStreak;

  /// No description provided for @onboardingYourWeightIsAlreadyAtTheLower.
  ///
  /// In de, this message translates to:
  /// **'Dein Gewicht liegt bereits im unteren gesunden Bereich. Lookin schlägt dir deshalb kein Abnehmziel vor – wir helfen dir, gut und ausgewogen zu essen.'**
  String get onboardingYourWeightIsAlreadyAtTheLower;

  /// No description provided for @profileALittlePieceOfYou.
  ///
  /// In de, this message translates to:
  /// **'Ein kleines Stück von dir.'**
  String get profileALittlePieceOfYou;

  /// No description provided for @profileActivity.
  ///
  /// In de, this message translates to:
  /// **'Aktivität'**
  String get profileActivity;

  /// No description provided for @profileActivityLevel.
  ///
  /// In de, this message translates to:
  /// **'Aktivitätsniveau'**
  String get profileActivityLevel;

  /// No description provided for @profileAiPhotoAiChat.
  ///
  /// In de, this message translates to:
  /// **'KI-Foto & KI-Chat'**
  String get profileAiPhotoAiChat;

  /// No description provided for @profileAiService.
  ///
  /// In de, this message translates to:
  /// **'KI-DIENST'**
  String get profileAiService;

  /// No description provided for @profileAllergies.
  ///
  /// In de, this message translates to:
  /// **'Allergien'**
  String get profileAllergies;

  /// No description provided for @profileAnswerQuestions.
  ///
  /// In de, this message translates to:
  /// **'Fragen beantworten'**
  String get profileAnswerQuestions;

  /// No description provided for @profileAppPrivacy.
  ///
  /// In de, this message translates to:
  /// **'App & Datenschutz'**
  String get profileAppPrivacy;

  /// No description provided for @profileApplyChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen übernehmen'**
  String get profileApplyChanges;

  /// No description provided for @profileBalanced.
  ///
  /// In de, this message translates to:
  /// **'Ausgewogen'**
  String get profileBalanced;

  /// No description provided for @profileBecauseYouIndicatedThatYourNutritionNeeds.
  ///
  /// In de, this message translates to:
  /// **'Weil du angegeben hast, dass deine Ernährung gerade besondere Aufmerksamkeit braucht, berechnet Lookin keine Kalorienziele. Besprich deine Ziele bitte mit deiner Ärztin, deinem Arzt oder einer Ernährungsfachkraft. Tagebuch und Rezepte kannst du trotzdem nutzen.'**
  String get profileBecauseYouIndicatedThatYourNutritionNeeds;

  /// No description provided for @profileBuildMuscle.
  ///
  /// In de, this message translates to:
  /// **'Muskeln aufbauen'**
  String get profileBuildMuscle;

  /// No description provided for @profileCalorieTargetValueKcal.
  ///
  /// In de, this message translates to:
  /// **'Kalorienziel: {arg0} kcal'**
  String profileCalorieTargetValueKcal(String arg0);

  /// No description provided for @profileCalories.
  ///
  /// In de, this message translates to:
  /// **'Kalorien'**
  String get profileCalories;

  /// No description provided for @profileCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get profileCancel;

  /// No description provided for @profileChangeInformation.
  ///
  /// In de, this message translates to:
  /// **'Angaben ändern'**
  String get profileChangeInformation;

  /// No description provided for @profileChangeNutritionStyleAndActivityUnderChange.
  ///
  /// In de, this message translates to:
  /// **'Ernährungsweise und Aktivität änderst du unter „Antworten ändern“.'**
  String get profileChangeNutritionStyleAndActivityUnderChange;

  /// No description provided for @profileChangeProfilePicture.
  ///
  /// In de, this message translates to:
  /// **'Profilbild ändern'**
  String get profileChangeProfilePicture;

  /// No description provided for @profileChangeYourPreferredNameAndPersonalPreferences.
  ///
  /// In de, this message translates to:
  /// **'Rufname und persönliche Wünsche änderst du im Profil unter „Antworten ändern“. Die folgenden Zahlen sind deine separat eingestellten Ziele.'**
  String get profileChangeYourPreferredNameAndPersonalPreferences;

  /// No description provided for @profileChooseAnImageNoLargerThan8.
  ///
  /// In de, this message translates to:
  /// **'Wähle ein Bild mit höchstens 8 MB.'**
  String get profileChooseAnImageNoLargerThan8;

  /// No description provided for @profileChooseAnotherImage.
  ///
  /// In de, this message translates to:
  /// **'Anderes Bild auswählen'**
  String get profileChooseAnotherImage;

  /// No description provided for @profileChooseImage.
  ///
  /// In de, this message translates to:
  /// **'Bild auswählen'**
  String get profileChooseImage;

  /// No description provided for @profileClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get profileClose;

  /// No description provided for @profileComingSoon.
  ///
  /// In de, this message translates to:
  /// **'Bald verfügbar'**
  String get profileComingSoon;

  /// No description provided for @profileContactSupport.
  ///
  /// In de, this message translates to:
  /// **'Support schreiben'**
  String get profileContactSupport;

  /// No description provided for @profileContactSupportText.
  ///
  /// In de, this message translates to:
  /// **'Fragen, Probleme oder eine Meldung zu einer Antwort? Wir antworten per E-Mail.'**
  String get profileContactSupportText;

  /// No description provided for @profileCropYourImageDragItOrUse.
  ///
  /// In de, this message translates to:
  /// **'Bildausschnitt. Ziehe das Bild oder nutze die Regler.'**
  String get profileCropYourImageDragItOrUse;

  /// No description provided for @profileDayStreak.
  ///
  /// In de, this message translates to:
  /// **'Tag Serie'**
  String get profileDayStreak;

  /// No description provided for @profileDayStreak2.
  ///
  /// In de, this message translates to:
  /// **'Tage Serie'**
  String get profileDayStreak2;

  /// No description provided for @profileDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get profileDelete;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto löschen'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountAndAccountData.
  ///
  /// In de, this message translates to:
  /// **'Konto und Kontodaten löschen'**
  String get profileDeleteAccountAndAccountData;

  /// No description provided for @profileDeleteDemoData.
  ///
  /// In de, this message translates to:
  /// **'Lokale Daten löschen?'**
  String get profileDeleteDemoData;

  /// No description provided for @profileDeleteLocalDemoData.
  ///
  /// In de, this message translates to:
  /// **'Lokale Daten löschen'**
  String get profileDeleteLocalDemoData;

  /// No description provided for @profileDeletingYourAccountDoesNotCancelYour.
  ///
  /// In de, this message translates to:
  /// **'Das Löschen des Kontos kündigt dein Abo nicht. Der Store bucht weiter ab, bis du es dort kündigst. Kündige zuerst, dann lösche das Konto.'**
  String get profileDeletingYourAccountDoesNotCancelYour;

  /// No description provided for @profileDemoChangesLastUntilTheAppRestarts.
  ///
  /// In de, this message translates to:
  /// **'Demo: Änderungen bleiben bis zum Neustart erhalten.'**
  String get profileDemoChangesLastUntilTheAppRestarts;

  /// No description provided for @profileDeveloperPremium.
  ///
  /// In de, this message translates to:
  /// **'Entwickler: Premium'**
  String get profileDeveloperPremium;

  /// No description provided for @profileDeviceOnly.
  ///
  /// In de, this message translates to:
  /// **'NUR GERÄT'**
  String get profileDeviceOnly;

  /// No description provided for @profileDoNotFollowDietOrCalorieTargets.
  ///
  /// In de, this message translates to:
  /// **'Nutze keine Diät- oder Kalorienziele auf eigene Faust. Hole dir persönliche Hilfe bei medizinischem oder psychotherapeutischem Fachpersonal. Bei einem akuten Notfall wende dich an den örtlichen Notruf.'**
  String get profileDoNotFollowDietOrCalorieTargets;

  /// No description provided for @profileEatingDisorderOrAcuteSymptoms.
  ///
  /// In de, this message translates to:
  /// **'Essstörung oder akute Beschwerden'**
  String get profileEatingDisorderOrAcuteSymptoms;

  /// No description provided for @profileEditProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil bearbeiten'**
  String get profileEditProfile;

  /// No description provided for @profileEntriesToday.
  ///
  /// In de, this message translates to:
  /// **'Einträge heute'**
  String get profileEntriesToday;

  /// No description provided for @profileEntryToday.
  ///
  /// In de, this message translates to:
  /// **'Eintrag heute'**
  String get profileEntryToday;

  /// No description provided for @profileExportDeleteConsents.
  ///
  /// In de, this message translates to:
  /// **'Exportieren, löschen, Einwilligungen'**
  String get profileExportDeleteConsents;

  /// No description provided for @profileExportFailedPleaseCheckYourConnectionAnd.
  ///
  /// In de, this message translates to:
  /// **'Der Export hat nicht geklappt. Bitte prüfe deine Verbindung und versuche es erneut.'**
  String get profileExportFailedPleaseCheckYourConnectionAnd;

  /// No description provided for @profileExportMyData.
  ///
  /// In de, this message translates to:
  /// **'Meine Daten exportieren'**
  String get profileExportMyData;

  /// No description provided for @profileFat.
  ///
  /// In de, this message translates to:
  /// **'Fett'**
  String get profileFat;

  /// No description provided for @profileFineTuneTheCrop.
  ///
  /// In de, this message translates to:
  /// **'Ausschnitt fein einstellen'**
  String get profileFineTuneTheCrop;

  /// No description provided for @profileFlexible.
  ///
  /// In de, this message translates to:
  /// **'Flexibel'**
  String get profileFlexible;

  /// No description provided for @profileForLookinPremiumWithoutGivingAReason.
  ///
  /// In de, this message translates to:
  /// **'Für Lookin Premium, ohne Angabe von Gründen'**
  String get profileForLookinPremiumWithoutGivingAReason;

  /// No description provided for @profileHealthAlwaysComesBeforeTracking.
  ///
  /// In de, this message translates to:
  /// **'Gesundheit geht immer vor Tracking'**
  String get profileHealthAlwaysComesBeforeTracking;

  /// No description provided for @profileHelpSafety.
  ///
  /// In de, this message translates to:
  /// **'Hilfe & Sicherheit'**
  String get profileHelpSafety;

  /// No description provided for @profileHidePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort verbergen'**
  String get profileHidePassword;

  /// No description provided for @profileImages.
  ///
  /// In de, this message translates to:
  /// **'Bilder'**
  String get profileImages;

  /// No description provided for @profileImprint.
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get profileImprint;

  /// No description provided for @profileImprintLegal.
  ///
  /// In de, this message translates to:
  /// **'Impressum & Rechtliches'**
  String get profileImprintLegal;

  /// No description provided for @profileImprintTermsPrivacyWithdrawal.
  ///
  /// In de, this message translates to:
  /// **'Impressum, AGB, Datenschutz, Widerruf'**
  String get profileImprintTermsPrivacyWithdrawal;

  /// No description provided for @profileInAccount.
  ///
  /// In de, this message translates to:
  /// **'IM KONTO'**
  String get profileInAccount;

  /// No description provided for @profileInformationAndContact.
  ///
  /// In de, this message translates to:
  /// **'Hinweise und Kontakt'**
  String get profileInformationAndContact;

  /// No description provided for @profileIntroductionQuestionsAndPremiumAsOnThe.
  ///
  /// In de, this message translates to:
  /// **'Einführung, Fragen und Premium wie beim ersten Start'**
  String get profileIntroductionQuestionsAndPremiumAsOnThe;

  /// No description provided for @profileJpgOrPngUpTo8Mb.
  ///
  /// In de, this message translates to:
  /// **'JPG oder PNG · bis 8 MB\nDein Profilbild ist nur für dein Konto sichtbar.'**
  String get profileJpgOrPngUpTo8Mb;

  /// No description provided for @profileKcalToday.
  ///
  /// In de, this message translates to:
  /// **'kcal heute'**
  String get profileKcalToday;

  /// No description provided for @profileLeaveThisAccountOnThisDevice.
  ///
  /// In de, this message translates to:
  /// **'Dieses Konto auf dem Gerät verlassen'**
  String get profileLeaveThisAccountOnThisDevice;

  /// No description provided for @profileLeftRight.
  ///
  /// In de, this message translates to:
  /// **'Links – rechts'**
  String get profileLeftRight;

  /// No description provided for @profileLegal.
  ///
  /// In de, this message translates to:
  /// **'Rechtliches'**
  String get profileLegal;

  /// No description provided for @profileLocalDataOverview.
  ///
  /// In de, this message translates to:
  /// **'Lokale Datenübersicht'**
  String get profileLocalDataOverview;

  /// No description provided for @profileLocalOverviewSummary.
  ///
  /// In de, this message translates to:
  /// **'Name: {arg0}\nZiel: {arg1}\nMahlzeiten: {arg2}\nFavoriten: {arg3}'**
  String profileLocalOverviewSummary(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  );

  /// No description provided for @profileLookinDoesNotCalculateCalorieTargetsFor.
  ///
  /// In de, this message translates to:
  /// **'Für Personen unter 18 Jahren berechnet Lookin keine Kalorienziele. Bei Fragen zur Ernährung wende dich bitte an eine Ärztin, einen Arzt oder eine Ernährungsfachkraft.'**
  String get profileLookinDoesNotCalculateCalorieTargetsFor;

  /// No description provided for @profileLookinSupportsHabitsButDoesNotDiagnose.
  ///
  /// In de, this message translates to:
  /// **'Lookin unterstützt Gewohnheiten, stellt aber keine Diagnose und ersetzt keine Ärztin, keinen Arzt oder qualifizierte Ernährungsberatung.'**
  String get profileLookinSupportsHabitsButDoesNotDiagnose;

  /// No description provided for @profileLoseFat.
  ///
  /// In de, this message translates to:
  /// **'Fett verlieren'**
  String get profileLoseFat;

  /// No description provided for @profileLowActivity.
  ///
  /// In de, this message translates to:
  /// **'Wenig aktiv'**
  String get profileLowActivity;

  /// No description provided for @profileMaintainWeight.
  ///
  /// In de, this message translates to:
  /// **'Gewicht halten'**
  String get profileMaintainWeight;

  /// No description provided for @profileMealWaterAndWeeklyReviewRemindersWill.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen an Mahlzeiten, Wasser und einen Wochenrückblick kommen mit einem der nächsten Updates. Bis dahin verschickt Lookin keine Benachrichtigungen.'**
  String get profileMealWaterAndWeeklyReviewRemindersWill;

  /// No description provided for @profileMeals.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeiten'**
  String get profileMeals;

  /// No description provided for @profileMealsFavouritesListsAndWaterTotalsAre.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeiten, Favoriten, Listen und Wasserstand werden auf diesem Gerät geleert. Ohne Konto erscheinen nach einem App-Neustart die Beispiel-Mahlzeiten wieder.'**
  String get profileMealsFavouritesListsAndWaterTotalsAre;

  /// No description provided for @profileMealsNutrition.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeiten & Nährwerte'**
  String get profileMealsNutrition;

  /// No description provided for @profileModeratelyActive.
  ///
  /// In de, this message translates to:
  /// **'Moderat aktiv'**
  String get profileModeratelyActive;

  /// No description provided for @profileMoveTheImageToChooseYourCrop.
  ///
  /// In de, this message translates to:
  /// **'Verschiebe das Bild für deinen Ausschnitt.'**
  String get profileMoveTheImageToChooseYourCrop;

  /// No description provided for @profileMyDailyTargets.
  ///
  /// In de, this message translates to:
  /// **'Meine täglichen Ziele'**
  String get profileMyDailyTargets;

  /// No description provided for @profileMyGoal.
  ///
  /// In de, this message translates to:
  /// **'Mein Ziel'**
  String get profileMyGoal;

  /// No description provided for @profileNoGoalSelectedYet.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Ziel gewählt'**
  String get profileNoGoalSelectedYet;

  /// No description provided for @profileNotMedicalAdvice.
  ///
  /// In de, this message translates to:
  /// **'Keine medizinische Beratung'**
  String get profileNotMedicalAdvice;

  /// No description provided for @profileNumbersAreAGuide.
  ///
  /// In de, this message translates to:
  /// **'Zahlen sind Orientierung'**
  String get profileNumbersAreAGuide;

  /// No description provided for @profileNutritionProfile.
  ///
  /// In de, this message translates to:
  /// **'Ernährungsprofil'**
  String get profileNutritionProfile;

  /// No description provided for @profileNutritionStyle.
  ///
  /// In de, this message translates to:
  /// **'Ernährungsstil'**
  String get profileNutritionStyle;

  /// No description provided for @profileNutritionValuesAndTargetsAreEstimatesAlso.
  ///
  /// In de, this message translates to:
  /// **'Nährwerte und Ziele sind Schätzungen. Achte zusätzlich auf Energie, Wohlbefinden, Schlaf und ein entspanntes Verhältnis zum Essen.'**
  String get profileNutritionValuesAndTargetsAreEstimatesAlso;

  /// No description provided for @profileOneMoment.
  ///
  /// In de, this message translates to:
  /// **'Einen Moment …'**
  String get profileOneMoment;

  /// No description provided for @profileOnlyVisibleToYourDeveloperAccount.
  ///
  /// In de, this message translates to:
  /// **'Nur für dein Entwickler-Konto sichtbar'**
  String get profileOnlyVisibleToYourDeveloperAccount;

  /// No description provided for @profileOpenStoreSubscriptions.
  ///
  /// In de, this message translates to:
  /// **'Abos im Store öffnen'**
  String get profileOpenStoreSubscriptions;

  /// No description provided for @profileOpensInBrowser.
  ///
  /// In de, this message translates to:
  /// **'Öffnet sich im Browser'**
  String get profileOpensInBrowser;

  /// No description provided for @profilePasswordToConfirm.
  ///
  /// In de, this message translates to:
  /// **'Passwort zur Bestätigung'**
  String get profilePasswordToConfirm;

  /// No description provided for @profilePermanentlyDeleteAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto endgültig löschen?'**
  String get profilePermanentlyDeleteAccount;

  /// No description provided for @profilePleaseChooseAJpgOrPngImage.
  ///
  /// In de, this message translates to:
  /// **'Wähle bitte ein JPG- oder PNG-Bild.'**
  String get profilePleaseChooseAJpgOrPngImage;

  /// No description provided for @profilePleaseChooseTheImageAgain.
  ///
  /// In de, this message translates to:
  /// **'Wähle das Bild bitte erneut aus.'**
  String get profilePleaseChooseTheImageAgain;

  /// No description provided for @profilePremiumActive.
  ///
  /// In de, this message translates to:
  /// **'Premium aktiv'**
  String get profilePremiumActive;

  /// No description provided for @profilePremiumCouldNotBeSwitchedJustNow.
  ///
  /// In de, this message translates to:
  /// **'Premium konnte gerade nicht umgeschaltet werden.'**
  String get profilePremiumCouldNotBeSwitchedJustNow;

  /// No description provided for @profilePrivacyData.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz & Daten'**
  String get profilePrivacyData;

  /// No description provided for @profilePrivacyPolicy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get profilePrivacyPolicy;

  /// No description provided for @profileProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get profileProfile;

  /// No description provided for @profileProfilePictureReminders.
  ///
  /// In de, this message translates to:
  /// **'Profilbild & Erinnerungen'**
  String get profileProfilePictureReminders;

  /// No description provided for @profileProfileTargets.
  ///
  /// In de, this message translates to:
  /// **'Profil & Ziele'**
  String get profileProfileTargets;

  /// No description provided for @profileRemaining.
  ///
  /// In de, this message translates to:
  /// **'Noch offen'**
  String get profileRemaining;

  /// No description provided for @profileReminders.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen'**
  String get profileReminders;

  /// No description provided for @profileRemoveProfilePicture.
  ///
  /// In de, this message translates to:
  /// **'Profilbild entfernen'**
  String get profileRemoveProfilePicture;

  /// No description provided for @profileSaveNutritionProfile.
  ///
  /// In de, this message translates to:
  /// **'Ernährungsprofil speichern'**
  String get profileSaveNutritionProfile;

  /// No description provided for @profileSaveProfilePicture.
  ///
  /// In de, this message translates to:
  /// **'Profilbild speichern'**
  String get profileSaveProfilePicture;

  /// No description provided for @profileSavedListsAndYourWaterTotalAre.
  ///
  /// In de, this message translates to:
  /// **'Gespeicherte Listen und dein Wasserstand werden auf diesem Gerät geleert. Deine gespeicherten Mahlzeiten und Favoriten im Konto bleiben erhalten.'**
  String get profileSavedListsAndYourWaterTotalAre;

  /// No description provided for @profileSavingCancelled.
  ///
  /// In de, this message translates to:
  /// **'Speichern abgebrochen.'**
  String get profileSavingCancelled;

  /// No description provided for @profileSelectTheCropAgain.
  ///
  /// In de, this message translates to:
  /// **'Wähle den Bildausschnitt erneut.'**
  String get profileSelectTheCropAgain;

  /// No description provided for @profileShowPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort anzeigen'**
  String get profileShowPassword;

  /// No description provided for @profileSignOut.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get profileSignOut;

  /// No description provided for @profileSignOut2.
  ///
  /// In de, this message translates to:
  /// **'Abmelden?'**
  String get profileSignOut2;

  /// No description provided for @profileSignOutFailedPleaseTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Abmelden fehlgeschlagen. Bitte versuche es erneut.'**
  String get profileSignOutFailedPleaseTryAgain;

  /// No description provided for @profileStartFromTheBeginning.
  ///
  /// In de, this message translates to:
  /// **'Von vorne zeigen'**
  String get profileStartFromTheBeginning;

  /// No description provided for @profileSupportMailNotOpened.
  ///
  /// In de, this message translates to:
  /// **'Die E-Mail-App konnte nicht geöffnet werden. Schreib uns bitte an {address}.'**
  String profileSupportMailNotOpened(String address);

  /// No description provided for @profileSupportMailSubject.
  ///
  /// In de, this message translates to:
  /// **'Lookin Support'**
  String get profileSupportMailSubject;

  /// No description provided for @profileTargetWeightValueKg.
  ///
  /// In de, this message translates to:
  /// **'Zielgewicht: {arg0} kg'**
  String profileTargetWeightValueKg(String arg0);

  /// No description provided for @profileTerms.
  ///
  /// In de, this message translates to:
  /// **'AGB'**
  String get profileTerms;

  /// No description provided for @profileTheExportAlsoContainsHealthAndChat.
  ///
  /// In de, this message translates to:
  /// **'Der Export enthält auch Gesundheits- und Chatdaten. Bewahre die Datei sicher auf.'**
  String get profileTheExportAlsoContainsHealthAndChat;

  /// No description provided for @profileTheImageCouldNotBeOpenedTry.
  ///
  /// In de, this message translates to:
  /// **'Das Bild ließ sich nicht öffnen. Versuche es mit einem anderen JPG oder PNG.'**
  String get profileTheImageCouldNotBeOpenedTry;

  /// No description provided for @profileTheImageCouldNotBeResized.
  ///
  /// In de, this message translates to:
  /// **'Das Bild konnte nicht verkleinert werden.'**
  String get profileTheImageCouldNotBeResized;

  /// No description provided for @profileTheImageIsVeryLargeChooseA.
  ///
  /// In de, this message translates to:
  /// **'Das Bild ist sehr groß. Wähle ein Foto mit höchstens 24 Megapixeln.'**
  String get profileTheImageIsVeryLargeChooseA;

  /// No description provided for @profileThisImageCouldNotBeOpened.
  ///
  /// In de, this message translates to:
  /// **'Dieses Bild konnte nicht geöffnet werden.'**
  String get profileThisImageCouldNotBeOpened;

  /// No description provided for @profileTransparentAndUnderYourControl.
  ///
  /// In de, this message translates to:
  /// **'Transparent und unter deiner Kontrolle'**
  String get profileTransparentAndUnderYourControl;

  /// No description provided for @profileTrialActive.
  ///
  /// In de, this message translates to:
  /// **'Testphase aktiv'**
  String get profileTrialActive;

  /// No description provided for @profileTrialActiveUntilValue.
  ///
  /// In de, this message translates to:
  /// **'Testphase aktiv bis {arg0}'**
  String profileTrialActiveUntilValue(String arg0);

  /// No description provided for @profileUpDown.
  ///
  /// In de, this message translates to:
  /// **'Oben – unten'**
  String get profileUpDown;

  /// No description provided for @profileValueDayFreeTrial.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Tage kostenlos testen'**
  String profileValueDayFreeTrial(String arg0);

  /// No description provided for @profileValuePerDay.
  ///
  /// In de, this message translates to:
  /// **'{arg0} pro Tag'**
  String profileValuePerDay(String arg0);

  /// No description provided for @profileValueValuePerCent.
  ///
  /// In de, this message translates to:
  /// **'{arg0}: {arg1} Prozent'**
  String profileValueValuePerCent(String arg0, String arg1);

  /// No description provided for @profileValueZoom.
  ///
  /// In de, this message translates to:
  /// **'{arg0}-fache Vergrößerung'**
  String profileValueZoom(String arg0);

  /// No description provided for @profileVegetarian.
  ///
  /// In de, this message translates to:
  /// **'Vegetarisch'**
  String get profileVegetarian;

  /// No description provided for @profileVeryActive.
  ///
  /// In de, this message translates to:
  /// **'Sehr aktiv'**
  String get profileVeryActive;

  /// No description provided for @profileViewLocalData.
  ///
  /// In de, this message translates to:
  /// **'Lokale Daten ansehen'**
  String get profileViewLocalData;

  /// No description provided for @profileViewPlansAndBenefits.
  ///
  /// In de, this message translates to:
  /// **'Pläne und Vorteile ansehen'**
  String get profileViewPlansAndBenefits;

  /// No description provided for @profileWeCalculateTheseGuidelineValuesFromYour.
  ///
  /// In de, this message translates to:
  /// **'Diese Richtwerte berechnen wir aus deinem Alter, deiner Größe, deinem Gewicht und deinem Alltag. Sie dienen zur Orientierung und ersetzen keine ärztliche Beratung.'**
  String get profileWeCalculateTheseGuidelineValuesFromYour;

  /// No description provided for @profileWeCalculateYourDailyTargetsFromYour.
  ///
  /// In de, this message translates to:
  /// **'Deine Tagesziele berechnen wir aus deinem Alter, deiner Größe, deinem Gewicht und deinem Alltag. Wenn du möchtest, beantworte dazu ein paar kurze Fragen. Du kannst Lookin aber auch ganz ohne Ziele nutzen.'**
  String get profileWeCalculateYourDailyTargetsFromYour;

  /// No description provided for @profileWithdrawFromContract.
  ///
  /// In de, this message translates to:
  /// **'Vertrag widerrufen'**
  String get profileWithdrawFromContract;

  /// No description provided for @profileWithdrawalInformation.
  ///
  /// In de, this message translates to:
  /// **'Widerrufsbelehrung'**
  String get profileWithdrawalInformation;

  /// No description provided for @profileWithin14DaysOfPurchaseWithoutGiving.
  ///
  /// In de, this message translates to:
  /// **'Innerhalb von 14 Tagen nach dem Kauf, ohne Grund'**
  String get profileWithin14DaysOfPurchaseWithoutGiving;

  /// No description provided for @profileYourAccountCouldNotBeCompletelyDeleted.
  ///
  /// In de, this message translates to:
  /// **'Das Konto konnte nicht vollständig gelöscht werden. Bitte prüfe, ob du noch angemeldet bist.'**
  String get profileYourAccountCouldNotBeCompletelyDeleted;

  /// No description provided for @profileYourAccountCouldNotBeDeletedPlease.
  ///
  /// In de, this message translates to:
  /// **'Das Konto konnte nicht gelöscht werden. Bitte versuche es erneut.'**
  String get profileYourAccountCouldNotBeDeletedPlease;

  /// No description provided for @profileYourAccountValueAndItsAssociatedData.
  ///
  /// In de, this message translates to:
  /// **'Dein Konto{arg0} und die dazugehörigen Daten werden gelöscht. Das kann nicht rückgängig gemacht werden. Ein späteres Store-Abo müsstest du separat im Store kündigen.'**
  String profileYourAccountValueAndItsAssociatedData(String arg0);

  /// No description provided for @profileYourCalorieTargetIsCalculatedFromYour.
  ///
  /// In de, this message translates to:
  /// **'Dein Kalorienziel wird aus deinen Angaben berechnet.'**
  String get profileYourCalorieTargetIsCalculatedFromYour;

  /// No description provided for @profileYourDataHasBeenSavedAsA.
  ///
  /// In de, this message translates to:
  /// **'Deine Daten wurden als JSON-Datei gespeichert.'**
  String get profileYourDataHasBeenSavedAsA;

  /// No description provided for @profileYourPasswordIsIncorrectYourAccountWas.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort stimmt nicht. Dein Konto wurde nicht gelöscht.'**
  String get profileYourPasswordIsIncorrectYourAccountWas;

  /// No description provided for @profileYourPremiumSubscriptionWillContinue.
  ///
  /// In de, this message translates to:
  /// **'Dein Premium-Abo läuft weiter!'**
  String get profileYourPremiumSubscriptionWillContinue;

  /// No description provided for @profileYourProfilePicture.
  ///
  /// In de, this message translates to:
  /// **'Dein Profilbild'**
  String get profileYourProfilePicture;

  /// No description provided for @profileYourProfilePictureCouldNotBeRemoved.
  ///
  /// In de, this message translates to:
  /// **'Das Profilbild konnte nicht entfernt werden.'**
  String get profileYourProfilePictureCouldNotBeRemoved;

  /// No description provided for @profileYourProfilePictureCouldNotBeRemoved2.
  ///
  /// In de, this message translates to:
  /// **'Das Profilbild konnte nicht entfernt werden. Versuche es erneut.'**
  String get profileYourProfilePictureCouldNotBeRemoved2;

  /// No description provided for @profileYourProfilePictureWasNotSavedPlease.
  ///
  /// In de, this message translates to:
  /// **'Das Profilbild wurde nicht gespeichert. Versuche es erneut.'**
  String get profileYourProfilePictureWasNotSavedPlease;

  /// No description provided for @profileYourProfilePictureWasNotSavedYour.
  ///
  /// In de, this message translates to:
  /// **'Das Profilbild wurde nicht gespeichert. Dein bisheriges Bild bleibt erhalten.'**
  String get profileYourProfilePictureWasNotSavedYour;

  /// No description provided for @profileYourProfileTargetsAndDiaryAreSaved.
  ///
  /// In de, this message translates to:
  /// **'Profil, Ziele und Tagebuch werden in deinem Lookin-Konto (Supabase) gespeichert, damit sie auf jedem Gerät verfügbar sind. Fotos für die KI-Foto-Analyse und Nachrichten an den KI-Coach werden über unseren Server an OpenAI übertragen; Fotos werden dabei nicht gespeichert. Profilbild, Erinnerungen und gemerkte Lebensmittel bleiben nur auf diesem Gerät. Unter den Optionen oben kannst du deine Kontodaten exportieren oder dein Konto endgültig löschen.'**
  String get profileYourProfileTargetsAndDiaryAreSaved;

  /// No description provided for @profileYourSavedAccountDataWillBeKept.
  ///
  /// In de, this message translates to:
  /// **'Deine gespeicherten Kontodaten bleiben erhalten. Du kannst dich später wieder anmelden.'**
  String get profileYourSavedAccountDataWillBeKept;

  /// No description provided for @profileYourSavedProfileInformation.
  ///
  /// In de, this message translates to:
  /// **'Deine gespeicherten Profilangaben'**
  String get profileYourSavedProfileInformation;

  /// No description provided for @progressAMeasurementReplacesTheValueFromThe.
  ///
  /// In de, this message translates to:
  /// **'Eine Messung ersetzt den Wert desselben Tages.'**
  String get progressAMeasurementReplacesTheValueFromThe;

  /// No description provided for @progressAnActualTrendStartsHereAutomaticallyAfter.
  ///
  /// In de, this message translates to:
  /// **'Nach deinem ersten Tagebucheintrag entsteht hier automatisch ein echter Verlauf.'**
  String get progressAnActualTrendStartsHereAutomaticallyAfter;

  /// No description provided for @progressAverageOnTrackedDays.
  ///
  /// In de, this message translates to:
  /// **'Durchschnitt an getrackten Tagen'**
  String get progressAverageOnTrackedDays;

  /// No description provided for @progressAveragePerTimePeriodComparedWithYour.
  ///
  /// In de, this message translates to:
  /// **'Durchschnitt pro Zeitabschnitt im Vergleich zu deinen Zielen'**
  String get progressAveragePerTimePeriodComparedWithYour;

  /// No description provided for @progressAvgKcalTrackedDay.
  ///
  /// In de, this message translates to:
  /// **'Ø kcal / Track-Tag'**
  String get progressAvgKcalTrackedDay;

  /// No description provided for @progressAvgProteinTrackedDay.
  ///
  /// In de, this message translates to:
  /// **'Ø Protein / Track-Tag'**
  String get progressAvgProteinTrackedDay;

  /// No description provided for @progressBodyTrend.
  ///
  /// In de, this message translates to:
  /// **'Körperverlauf'**
  String get progressBodyTrend;

  /// No description provided for @progressCalories.
  ///
  /// In de, this message translates to:
  /// **'KALORIEN'**
  String get progressCalories;

  /// No description provided for @progressCarbohydrates.
  ///
  /// In de, this message translates to:
  /// **'Kohlenhydrate'**
  String get progressCarbohydrates;

  /// No description provided for @progressCheckYourConnectionAndTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Prüfe deine Verbindung und versuche es erneut.'**
  String get progressCheckYourConnectionAndTryAgain;

  /// No description provided for @progressClearTrendsFromYourActualDiaryWithout.
  ///
  /// In de, this message translates to:
  /// **'Klare Trends aus deinem echten Tagebuch – ohne Druck durch einzelne Tage.'**
  String get progressClearTrendsFromYourActualDiaryWithout;

  /// No description provided for @progressClosenessToTarget.
  ///
  /// In de, this message translates to:
  /// **'Zielnähe'**
  String get progressClosenessToTarget;

  /// No description provided for @progressCurrentStreak.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Serie'**
  String get progressCurrentStreak;

  /// No description provided for @progressDaysInCalorieRange.
  ///
  /// In de, this message translates to:
  /// **'Tage im Kalorienbereich'**
  String get progressDaysInCalorieRange;

  /// No description provided for @progressFat.
  ///
  /// In de, this message translates to:
  /// **'Fett'**
  String get progressFat;

  /// No description provided for @progressInTargetRange.
  ///
  /// In de, this message translates to:
  /// **'im Zielbereich'**
  String get progressInTargetRange;

  /// No description provided for @progressLog.
  ///
  /// In de, this message translates to:
  /// **'Eintragen'**
  String get progressLog;

  /// No description provided for @progressLogMealsAndAddYourWeightLookin.
  ///
  /// In de, this message translates to:
  /// **'Trage Mahlzeiten ein und ergänze dein Gewicht. Lookin berechnet danach nur aus deinen echten Daten.'**
  String get progressLogMealsAndAddYourWeightLookin;

  /// No description provided for @progressLogOrdinaryDaysTooThisMakesYour.
  ///
  /// In de, this message translates to:
  /// **'Trage auch an normalen Tagen ein. So wird dein Trend ehrlich und nützlich.'**
  String get progressLogOrdinaryDaysTooThisMakesYour;

  /// No description provided for @progressLookAtWeightOverSeveralWeeksWater.
  ///
  /// In de, this message translates to:
  /// **'Bewerte Gewicht über mehrere Wochen; Wasser und Salz verschieben einzelne Messungen.'**
  String get progressLookAtWeightOverSeveralWeeksWater;

  /// No description provided for @progressMacroBalance.
  ///
  /// In de, this message translates to:
  /// **'Makro-Balance'**
  String get progressMacroBalance;

  /// No description provided for @progressMeasurementCouldNotBeSaved.
  ///
  /// In de, this message translates to:
  /// **'Messung konnte nicht gespeichert werden.'**
  String get progressMeasurementCouldNotBeSaved;

  /// No description provided for @progressMeasurementSaved.
  ///
  /// In de, this message translates to:
  /// **'Messung gespeichert.'**
  String get progressMeasurementSaved;

  /// No description provided for @progressNewMeasurement.
  ///
  /// In de, this message translates to:
  /// **'Neue Messung'**
  String get progressNewMeasurement;

  /// No description provided for @progressNoMeasurementYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Messung'**
  String get progressNoMeasurementYet;

  /// No description provided for @progressNoNutritionTrendYet.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Ernährungstrend'**
  String get progressNoNutritionTrendYet;

  /// No description provided for @progressNutritionTrend.
  ///
  /// In de, this message translates to:
  /// **'Ernährungstrend'**
  String get progressNutritionTrend;

  /// No description provided for @progressOneOrTwoMeasurementsAWeekAre.
  ///
  /// In de, this message translates to:
  /// **'Ein bis zwei Messungen pro Woche reichen. Tages-Schwankungen sind normal.'**
  String get progressOneOrTwoMeasurementsAWeekAre;

  /// No description provided for @progressOneOrTwoMeasurementsAWeekUnder.
  ///
  /// In de, this message translates to:
  /// **'Für einen Gewichtstrend genügen ein bis zwei Messungen pro Woche unter ähnlichen Bedingungen.'**
  String get progressOneOrTwoMeasurementsAWeekUnder;

  /// No description provided for @progressPleaseEnterARealisticWeightBetween25.
  ///
  /// In de, this message translates to:
  /// **'Bitte gib ein realistisches Gewicht zwischen 25 und 400 kg ein.'**
  String get progressPleaseEnterARealisticWeightBetween25;

  /// No description provided for @progressProteinWasCloseToTargetOnValue.
  ///
  /// In de, this message translates to:
  /// **'An {arg0} Tagen lag Protein nahe am Ziel. Eine feste Proteinquelle pro Mahlzeit kann helfen.'**
  String progressProteinWasCloseToTargetOnValue(String arg0);

  /// No description provided for @progressRefresh.
  ///
  /// In de, this message translates to:
  /// **'Aktualisieren'**
  String get progressRefresh;

  /// No description provided for @progressRegularTrackingHelpsYouUnderstandYourHabits.
  ///
  /// In de, this message translates to:
  /// **'Regelmäßiges Tracken schafft zuerst Klarheit.'**
  String get progressRegularTrackingHelpsYouUnderstandYourHabits;

  /// No description provided for @progressSaveMeasurement.
  ///
  /// In de, this message translates to:
  /// **'Messung speichern'**
  String get progressSaveMeasurement;

  /// No description provided for @progressTarget100.
  ///
  /// In de, this message translates to:
  /// **'ZIEL = 100 %'**
  String get progressTarget100;

  /// No description provided for @progressTrackingConsistency.
  ///
  /// In de, this message translates to:
  /// **'Tracking-Konstanz'**
  String get progressTrackingConsistency;

  /// No description provided for @progressTryAgain.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get progressTryAgain;

  /// No description provided for @progressUpToTheLast28Days.
  ///
  /// In de, this message translates to:
  /// **'Die letzten maximal 28 Tage'**
  String get progressUpToTheLast28Days;

  /// No description provided for @progressValueDays.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Tage'**
  String progressValueDays(String arg0);

  /// No description provided for @progressValueDaysAlreadyGiveABetterFoundation.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Tage liefern bereits eine bessere Grundlage als ein einzelner Tageswert.'**
  String progressValueDaysAlreadyGiveABetterFoundation(String arg0);

  /// No description provided for @progressValueOfValueDaysWithEntriesValue.
  ///
  /// In de, this message translates to:
  /// **'{arg0} von {arg1} Tagen mit Einträgen · {arg2} Mahlzeiten ausgewertet'**
  String progressValueOfValueDaysWithEntriesValue(
    String arg0,
    String arg1,
    String arg2,
  );

  /// No description provided for @progressValueValueKcalValueGProtein.
  ///
  /// In de, this message translates to:
  /// **'{arg0}: {arg1} kcal · {arg2} g Protein'**
  String progressValueValueKcalValueGProtein(
    String arg0,
    String arg1,
    String arg2,
  );

  /// No description provided for @progressValueValueKgInThisPeriod.
  ///
  /// In de, this message translates to:
  /// **'{arg0}{arg1} kg im Zeitraum'**
  String progressValueValueKgInThisPeriod(String arg0, String arg1);

  /// No description provided for @progressValueValueNoEntry.
  ///
  /// In de, this message translates to:
  /// **'{arg0} · kein Eintrag'**
  String progressValueValueNoEntry(String arg0);

  /// No description provided for @progressWaistCircumferenceMustBeBetween30And.
  ///
  /// In de, this message translates to:
  /// **'Der Taillenumfang muss zwischen 30 und 300 cm liegen.'**
  String get progressWaistCircumferenceMustBeBetween30And;

  /// No description provided for @progressWaistOptional.
  ///
  /// In de, this message translates to:
  /// **'Taille (optional)'**
  String get progressWaistOptional;

  /// No description provided for @progressWeight.
  ///
  /// In de, this message translates to:
  /// **'Gewicht'**
  String get progressWeight;

  /// No description provided for @progressWeightAndOptionalWaistCircumferenceViewedCalmly.
  ///
  /// In de, this message translates to:
  /// **'Gewicht und optionaler Taillenumfang – ruhig und langfristig betrachtet'**
  String get progressWeightAndOptionalWaistCircumferenceViewedCalmly;

  /// No description provided for @progressWhatYourDataSays.
  ///
  /// In de, this message translates to:
  /// **'Was deine Daten sagen'**
  String get progressWhatYourDataSays;

  /// No description provided for @progressYouAreHeadingInTheRightDirection.
  ///
  /// In de, this message translates to:
  /// **'Deine Richtung stimmt – Beständigkeit bringt jetzt am meisten.'**
  String get progressYouAreHeadingInTheRightDirection;

  /// No description provided for @progressYouAreVeryCloseToYourPersonal.
  ///
  /// In de, this message translates to:
  /// **'Du liegst sehr nah an deinen persönlichen Zielen.'**
  String get progressYouAreVeryCloseToYourPersonal;

  /// No description provided for @progressYourActualTrendStartsHere.
  ///
  /// In de, this message translates to:
  /// **'Dein echter Verlauf beginnt hier'**
  String get progressYourActualTrendStartsHere;

  /// No description provided for @progressYourAverageProteinIsCloseToYour.
  ///
  /// In de, this message translates to:
  /// **'Dein Proteindurchschnitt liegt nah am Ziel. Das unterstützt Sättigung und Muskelerhalt.'**
  String get progressYourAverageProteinIsCloseToYour;

  /// No description provided for @progressYourFirstEntryMakesTrendsVisible.
  ///
  /// In de, this message translates to:
  /// **'Dein erster Eintrag macht Trends sichtbar.'**
  String get progressYourFirstEntryMakesTrendsVisible;

  /// No description provided for @progressYourProgress.
  ///
  /// In de, this message translates to:
  /// **'Dein Fortschritt'**
  String get progressYourProgress;

  /// No description provided for @progressYourProgressDataCouldNotBeLoaded.
  ///
  /// In de, this message translates to:
  /// **'Deine Fortschrittsdaten konnten nicht geladen werden.'**
  String get progressYourProgressDataCouldNotBeLoaded;

  /// No description provided for @progressYourRhythm.
  ///
  /// In de, this message translates to:
  /// **'DEIN RHYTHMUS'**
  String get progressYourRhythm;

  /// No description provided for @sharedCatalogReload.
  ///
  /// In de, this message translates to:
  /// **'Erneut laden'**
  String get sharedCatalogReload;

  /// No description provided for @sharedCatalogReloading.
  ///
  /// In de, this message translates to:
  /// **'Lädt …'**
  String get sharedCatalogReloading;

  /// No description provided for @sharedCatalogUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Der Katalog konnte nicht geladen werden. Du siehst vorerst nur Beispiele. Prüfe deine Verbindung.'**
  String get sharedCatalogUnavailable;

  /// No description provided for @sharedImprint.
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get sharedImprint;

  /// No description provided for @sharedPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get sharedPrivacy;

  /// No description provided for @sharedTerms.
  ///
  /// In de, this message translates to:
  /// **'AGB'**
  String get sharedTerms;

  /// No description provided for @sharedTheLinkCouldNotBeOpenedPlease.
  ///
  /// In de, this message translates to:
  /// **'Der Link konnte nicht geöffnet werden. Bitte versuche es später noch einmal.'**
  String get sharedTheLinkCouldNotBeOpenedPlease;

  /// No description provided for @sharedWithdrawFromContract.
  ///
  /// In de, this message translates to:
  /// **'Vertrag widerrufen'**
  String get sharedWithdrawFromContract;

  /// No description provided for @sharedWithdrawal.
  ///
  /// In de, this message translates to:
  /// **'Widerruf'**
  String get sharedWithdrawal;

  /// No description provided for @subscriptionAiPhoto.
  ///
  /// In de, this message translates to:
  /// **'KI-Foto'**
  String get subscriptionAiPhoto;

  /// No description provided for @subscriptionAiPhotoIsPartOfPremium.
  ///
  /// In de, this message translates to:
  /// **'KI-Foto ist Teil von Premium'**
  String get subscriptionAiPhotoIsPartOfPremium;

  /// No description provided for @subscriptionAiPhotoRecognition.
  ///
  /// In de, this message translates to:
  /// **'KI-Foto-Erkennung'**
  String get subscriptionAiPhotoRecognition;

  /// No description provided for @subscriptionAiPhotoYourPersonalCoachAndAll.
  ///
  /// In de, this message translates to:
  /// **'KI-Foto, dein persönlicher Coach und alle Rezepte – für weniger Aufwand und mehr Klarheit beim Essen.'**
  String get subscriptionAiPhotoYourPersonalCoachAndAll;

  /// No description provided for @subscriptionAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get subscriptionAll;

  /// No description provided for @subscriptionAllRecipes.
  ///
  /// In de, this message translates to:
  /// **'Alle Rezepte'**
  String get subscriptionAllRecipes;

  /// No description provided for @subscriptionAllRecipesAreAvailableWithPremium.
  ///
  /// In de, this message translates to:
  /// **'Alle Rezepte gibt es mit Premium'**
  String get subscriptionAllRecipesAreAvailableWithPremium;

  /// No description provided for @subscriptionBilledEveryMonth.
  ///
  /// In de, this message translates to:
  /// **'jeden Monat berechnet'**
  String get subscriptionBilledEveryMonth;

  /// No description provided for @subscriptionBilledOnceAYearSaveValueCompared.
  ///
  /// In de, this message translates to:
  /// **'einmal im Jahr berechnet – du sparst {arg0} gegenüber monatlich'**
  String subscriptionBilledOnceAYearSaveValueCompared(String arg0);

  /// No description provided for @subscriptionCancelMonthly.
  ///
  /// In de, this message translates to:
  /// **'monatlich kündbar'**
  String get subscriptionCancelMonthly;

  /// No description provided for @subscriptionChooseAPremiumSubscription.
  ///
  /// In de, this message translates to:
  /// **'Premium-Abo wählen'**
  String get subscriptionChooseAPremiumSubscription;

  /// No description provided for @subscriptionClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get subscriptionClose;

  /// No description provided for @subscriptionComingSoon.
  ///
  /// In de, this message translates to:
  /// **'Bald verfügbar'**
  String get subscriptionComingSoon;

  /// No description provided for @subscriptionConfirmWithdrawal.
  ///
  /// In de, this message translates to:
  /// **'Widerruf bestätigen'**
  String get subscriptionConfirmWithdrawal;

  /// No description provided for @subscriptionContinueWithTheFreeVersion.
  ///
  /// In de, this message translates to:
  /// **'Weiter mit der kostenlosen Version'**
  String get subscriptionContinueWithTheFreeVersion;

  /// No description provided for @subscriptionDiaryMacrosStreak.
  ///
  /// In de, this message translates to:
  /// **'Tagebuch, Makros & Serie'**
  String get subscriptionDiaryMacrosStreak;

  /// No description provided for @subscriptionDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get subscriptionDone;

  /// No description provided for @subscriptionEmailForAcknowledgement.
  ///
  /// In de, this message translates to:
  /// **'E-Mail für die Bestätigung'**
  String get subscriptionEmailForAcknowledgement;

  /// No description provided for @subscriptionEquivalentToValuePerMonth.
  ///
  /// In de, this message translates to:
  /// **'entspricht {arg0} pro Monat'**
  String subscriptionEquivalentToValuePerMonth(String arg0);

  /// No description provided for @subscriptionForExampleTheOrderNumberFromThe.
  ///
  /// In de, this message translates to:
  /// **'Zum Beispiel die Bestellnummer aus der Google-Play-Mail'**
  String get subscriptionForExampleTheOrderNumberFromThe;

  /// No description provided for @subscriptionFree.
  ///
  /// In de, this message translates to:
  /// **'Kostenlos'**
  String get subscriptionFree;

  /// No description provided for @subscriptionFreeOrPremium.
  ///
  /// In de, this message translates to:
  /// **'Kostenlos oder Premium?'**
  String get subscriptionFreeOrPremium;

  /// No description provided for @subscriptionFreeTrialUntilValueItEndsAutomatically.
  ///
  /// In de, this message translates to:
  /// **'Kostenlose Testphase bis {arg0}. Danach beginnt das bezahlte Abo, wenn du nicht vorher in Google Play kündigst.'**
  String subscriptionFreeTrialUntilValueItEndsAutomatically(String arg0);

  /// No description provided for @subscriptionFreeTrialValueDaysStoreOnly.
  ///
  /// In de, this message translates to:
  /// **'Kostenlose Testphase: {arg0} Tage, einmal pro Google-Konto und nur mit einem Zahlungsmittel in Google Play. Wenn du nicht vor Ende der Testphase in Google Play kündigst, beginnt das bezahlte Abo und verlängert sich automatisch zum Preis des gewählten Tarifs.\n\n{arg1}'**
  String subscriptionFreeTrialValueDaysStoreOnly(String arg0, String arg1);

  /// No description provided for @subscriptionGenerousAiAllowance.
  ///
  /// In de, this message translates to:
  /// **'Großzügiges KI-Kontingent'**
  String get subscriptionGenerousAiAllowance;

  /// No description provided for @subscriptionGet.
  ///
  /// In de, this message translates to:
  /// **'Hol dir '**
  String get subscriptionGet;

  /// No description provided for @subscriptionGladYouAreHere.
  ///
  /// In de, this message translates to:
  /// **'Schön, dass du da bist'**
  String get subscriptionGladYouAreHere;

  /// No description provided for @subscriptionHereYouCanWithdrawFromYourLookin.
  ///
  /// In de, this message translates to:
  /// **'Hier widerrufst du deinen Vertrag über Lookin Premium. Einen Grund musst du nicht angeben. Du bekommst sofort eine Eingangsbestätigung mit Datum und Uhrzeit.'**
  String get subscriptionHereYouCanWithdrawFromYourLookin;

  /// No description provided for @subscriptionIncluded.
  ///
  /// In de, this message translates to:
  /// **'enthalten'**
  String get subscriptionIncluded;

  /// No description provided for @subscriptionLetSGo.
  ///
  /// In de, this message translates to:
  /// **'Los geht’s'**
  String get subscriptionLetSGo;

  /// No description provided for @subscriptionLookinCoachAiChat.
  ///
  /// In de, this message translates to:
  /// **'Lookin Coach (KI-Chat)'**
  String get subscriptionLookinCoachAiChat;

  /// No description provided for @subscriptionManageSubscription.
  ///
  /// In de, this message translates to:
  /// **'Abo verwalten'**
  String get subscriptionManageSubscription;

  /// No description provided for @subscriptionMonthly.
  ///
  /// In de, this message translates to:
  /// **'Monatlich'**
  String get subscriptionMonthly;

  /// No description provided for @subscriptionMoreRecipesWithPremium.
  ///
  /// In de, this message translates to:
  /// **'Mehr Rezepte mit Premium'**
  String get subscriptionMoreRecipesWithPremium;

  /// No description provided for @subscriptionNew.
  ///
  /// In de, this message translates to:
  /// **'Neues'**
  String get subscriptionNew;

  /// No description provided for @subscriptionNoActiveSubscriptionWasFoundForThis.
  ///
  /// In de, this message translates to:
  /// **'Für dieses Store-Konto wurde kein aktives Abo gefunden.'**
  String get subscriptionNoActiveSubscriptionWasFoundForThis;

  /// No description provided for @subscriptionNotADeveloperAccount.
  ///
  /// In de, this message translates to:
  /// **'Kein Entwickler-Konto.'**
  String get subscriptionNotADeveloperAccount;

  /// No description provided for @subscriptionNotIncluded.
  ///
  /// In de, this message translates to:
  /// **'nicht enthalten'**
  String get subscriptionNotIncluded;

  /// No description provided for @subscriptionOrderNumberOrNoteOptional.
  ///
  /// In de, this message translates to:
  /// **'Bestellnummer oder Hinweis (freiwillig)'**
  String get subscriptionOrderNumberOrNoteOptional;

  /// No description provided for @subscriptionPaymentIsHandledSecurelyByTheStore.
  ///
  /// In de, this message translates to:
  /// **'Die Zahlung läuft sicher über den Store. Lookin sieht und speichert keine Zahlungsdaten.'**
  String get subscriptionPaymentIsHandledSecurelyByTheStore;

  /// No description provided for @subscriptionPaymentsAreBeingSetUp.
  ///
  /// In de, this message translates to:
  /// **'Bezahlung wird gerade eingerichtet'**
  String get subscriptionPaymentsAreBeingSetUp;

  /// No description provided for @subscriptionPerMonth.
  ///
  /// In de, this message translates to:
  /// **'pro Monat'**
  String get subscriptionPerMonth;

  /// No description provided for @subscriptionPerYear.
  ///
  /// In de, this message translates to:
  /// **'pro Jahr'**
  String get subscriptionPerYear;

  /// No description provided for @subscriptionPleaseConfirmFirstThatLookinPremiumShould.
  ///
  /// In de, this message translates to:
  /// **'Bitte bestätige zuerst, dass Lookin Premium sofort beginnen soll.'**
  String get subscriptionPleaseConfirmFirstThatLookinPremiumShould;

  /// No description provided for @subscriptionPleaseTakeAScreenshotOfThisAcknowledgement.
  ///
  /// In de, this message translates to:
  /// **'Bitte mach einen Screenshot dieser Bestätigung. Eine Bestätigung per E-Mail folgt, sobald unser E-Mail-Versand eingerichtet ist. Die Rückzahlung erfolgt über Google Play.'**
  String get subscriptionPleaseTakeAScreenshotOfThisAcknowledgement;

  /// No description provided for @subscriptionPopularSavings.
  ///
  /// In de, this message translates to:
  /// **', beliebt, {savings} Prozent günstiger als monatlich'**
  String subscriptionPopularSavings(String savings);

  /// No description provided for @subscriptionPopularValue.
  ///
  /// In de, this message translates to:
  /// **'Beliebt · −{arg0} %'**
  String subscriptionPopularValue(String arg0);

  /// No description provided for @subscriptionPremiumInTheAndroidApp.
  ///
  /// In de, this message translates to:
  /// **'Premium in der Android-App'**
  String get subscriptionPremiumInTheAndroidApp;

  /// No description provided for @subscriptionPremiumIsActive.
  ///
  /// In de, this message translates to:
  /// **'Premium ist aktiv'**
  String get subscriptionPremiumIsActive;

  /// No description provided for @subscriptionPremiumIsActiveThankYouForYour.
  ///
  /// In de, this message translates to:
  /// **'Premium ist aktiv. Danke für deine Unterstützung!'**
  String get subscriptionPremiumIsActiveThankYouForYour;

  /// No description provided for @subscriptionPreparingYourLookin.
  ///
  /// In de, this message translates to:
  /// **'Dein Lookin wird vorbereitet …'**
  String get subscriptionPreparingYourLookin;

  /// No description provided for @subscriptionProfileDailyTargets.
  ///
  /// In de, this message translates to:
  /// **'Profil & Tagesziele'**
  String get subscriptionProfileDailyTargets;

  /// No description provided for @subscriptionPurchaseBusy.
  ///
  /// In de, this message translates to:
  /// **'Kauf wird vorbereitet …'**
  String get subscriptionPurchaseBusy;

  /// No description provided for @subscriptionPurchaseCancelledNothingWasCharged.
  ///
  /// In de, this message translates to:
  /// **'Kauf abgebrochen. Es wurde nichts berechnet.'**
  String get subscriptionPurchaseCancelledNothingWasCharged;

  /// No description provided for @subscriptionRecipes.
  ///
  /// In de, this message translates to:
  /// **'Rezepte'**
  String get subscriptionRecipes;

  /// No description provided for @subscriptionReferenceNumberValue.
  ///
  /// In de, this message translates to:
  /// **'Vorgangsnummer: {arg0}'**
  String subscriptionReferenceNumberValue(String arg0);

  /// No description provided for @subscriptionRestorePurchases.
  ///
  /// In de, this message translates to:
  /// **'Käufe wiederherstellen'**
  String get subscriptionRestorePurchases;

  /// No description provided for @subscriptionRestorePurchasesComingSoon.
  ///
  /// In de, this message translates to:
  /// **'Käufe wiederherstellen – bald verfügbar'**
  String get subscriptionRestorePurchasesComingSoon;

  /// No description provided for @subscriptionRestoringPurchasesIsOnlyAvailableInThe.
  ///
  /// In de, this message translates to:
  /// **'Käufe wiederherstellen ist nur in der Lookin-App möglich, sobald die Bezahlung dort freigeschaltet ist. Hier gibt es keine Käufe, die wiederhergestellt werden müssten.'**
  String get subscriptionRestoringPurchasesIsOnlyAvailableInThe;

  /// No description provided for @subscriptionSearchBarcodeCustomFoods.
  ///
  /// In de, this message translates to:
  /// **'Suche, Barcode & eigene Lebensmittel'**
  String get subscriptionSearchBarcodeCustomFoods;

  /// No description provided for @subscriptionSubscribeInTheLookinAppForAndroid.
  ///
  /// In de, this message translates to:
  /// **'Das Abo schließt du in der Lookin-App für Android ab. Im Browser wird nichts gekauft oder berechnet.'**
  String get subscriptionSubscribeInTheLookinAppForAndroid;

  /// No description provided for @subscriptionSubscribeMonthly.
  ///
  /// In de, this message translates to:
  /// **'Monatlich abonnieren'**
  String get subscriptionSubscribeMonthly;

  /// No description provided for @subscriptionSubscribePaid.
  ///
  /// In de, this message translates to:
  /// **'Kostenpflichtig abonnieren'**
  String get subscriptionSubscribePaid;

  /// No description provided for @subscriptionSubscribeYearly.
  ///
  /// In de, this message translates to:
  /// **'Jährlich abonnieren'**
  String get subscriptionSubscribeYearly;

  /// No description provided for @subscriptionSubscriptionBelongsToAnotherAccount.
  ///
  /// In de, this message translates to:
  /// **'Dieses Abo gehört zu einem anderen Lookin-Konto. Melde dich mit diesem Konto an, um Premium zu nutzen. Es wurde nichts berechnet.'**
  String get subscriptionSubscriptionBelongsToAnotherAccount;

  /// No description provided for @subscriptionSubscriptionManagementCouldNotBeOpenedOpen.
  ///
  /// In de, this message translates to:
  /// **'Die Abo-Verwaltung konnte nicht geöffnet werden. Öffne die Abo-Einstellungen direkt im Store.'**
  String get subscriptionSubscriptionManagementCouldNotBeOpenedOpen;

  /// No description provided for @subscriptionSubscriptionPlans.
  ///
  /// In de, this message translates to:
  /// **'Abo-Pläne'**
  String get subscriptionSubscriptionPlans;

  /// No description provided for @subscriptionSubscriptionPricesValuePaymentAndBillingAre.
  ///
  /// In de, this message translates to:
  /// **'Abo-Preise: {arg0} Bezahlung und Abrechnung laufen über {arg1}. Ein Abo verlängert sich automatisch zum selben Preis, bis du es kündigst. Du kündigst jederzeit in den Abo-Einstellungen von {arg2}, wirksam zum Ende des Abrechnungszeitraums. Das Jahresabo läuft zunächst ein Jahr; danach verlängert es sich auf unbestimmte Zeit und ist jederzeit mit höchstens einem Monat Frist kündbar. Mit „Sofort kündigen“ in Google Play bekommst du dann den nicht genutzten Teil anteilig zurück. Innerhalb von 14 Tagen kannst du den Vertrag widerrufen: Profil › „Vertrag widerrufen“. KI-Coach und KI-Foto brauchen deine Einwilligung zur Weitergabe an OpenAI.'**
  String subscriptionSubscriptionPricesValuePaymentAndBillingAre(
    String arg0,
    String arg1,
    String arg2,
  );

  /// No description provided for @subscriptionSubscriptionPricesValueValueASubscriptionRenews.
  ///
  /// In de, this message translates to:
  /// **'Abo-Preise ({arg0}): {arg1} Ein Abo verlängert sich automatisch zum selben Preis und ist jederzeit zum Ende des Abrechnungszeitraums kündbar.'**
  String subscriptionSubscriptionPricesValueValueASubscriptionRenews(
    String arg0,
    String arg1,
  );

  /// No description provided for @subscriptionSubscriptionsAreAvailableInTheLookinApp.
  ///
  /// In de, this message translates to:
  /// **'Abos gibt es in der Lookin-App für Android. Im Browser wurde nichts gekauft und nichts berechnet.'**
  String get subscriptionSubscriptionsAreAvailableInTheLookinApp;

  /// No description provided for @subscriptionTakeAPhotoLookinEstimatesFoodsAnd.
  ///
  /// In de, this message translates to:
  /// **'Foto machen – Lookin schätzt Lebensmittel und Mengen. Du prüfst alles vor dem Speichern.'**
  String get subscriptionTakeAPhotoLookinEstimatesFoodsAnd;

  /// No description provided for @subscriptionTermsShort.
  ///
  /// In de, this message translates to:
  /// **'Abrechnung über den Store · verlängert sich automatisch · jederzeit in den Abo-Einstellungen von {arg0} kündbar, wirksam zum Ende des Abrechnungszeitraums'**
  String subscriptionTermsShort(String arg0);

  /// No description provided for @subscriptionTermsShortTrial.
  ///
  /// In de, this message translates to:
  /// **'Die Testphase braucht ein Zahlungsmittel in {arg0} · danach beginnt das Abo und verlängert sich automatisch · bis zum Ende der Testphase in den Abo-Einstellungen von {arg0} kündbar, dann wird nichts berechnet'**
  String subscriptionTermsShortTrial(String arg0);

  /// No description provided for @subscriptionTheAppStore.
  ///
  /// In de, this message translates to:
  /// **'dem App Store'**
  String get subscriptionTheAppStore;

  /// No description provided for @subscriptionTheLookinCoachIsPartOfPremium.
  ///
  /// In de, this message translates to:
  /// **'Der Lookin Coach ist Teil von Premium'**
  String get subscriptionTheLookinCoachIsPartOfPremium;

  /// No description provided for @subscriptionTheStoreIsCurrentlyUnavailableNothingWas.
  ///
  /// In de, this message translates to:
  /// **'Der Store ist gerade nicht erreichbar. Es wurde nichts berechnet – versuche es später noch einmal.'**
  String get subscriptionTheStoreIsCurrentlyUnavailableNothingWas;

  /// No description provided for @subscriptionThenValue.
  ///
  /// In de, this message translates to:
  /// **'Danach kostenpflichtig: {arg0}'**
  String subscriptionThenValue(String arg0);

  /// No description provided for @subscriptionUnexpectedResponse.
  ///
  /// In de, this message translates to:
  /// **'Unerwartete Antwort.'**
  String get subscriptionUnexpectedResponse;

  /// No description provided for @subscriptionUnlockAllRecipes.
  ///
  /// In de, this message translates to:
  /// **'Alle Rezepte freischalten'**
  String get subscriptionUnlockAllRecipes;

  /// No description provided for @subscriptionUpTo100AiRequestsADay.
  ///
  /// In de, this message translates to:
  /// **'Mit Abo bis zu 100 KI-Anfragen pro Tag (Coach und Foto zusammen), in der Testphase bis zu 50.'**
  String get subscriptionUpTo100AiRequestsADay;

  /// No description provided for @subscriptionValueDayFreeTrial.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Tage kostenlos testen'**
  String subscriptionValueDayFreeTrial(String arg0);

  /// No description provided for @subscriptionValueDayFreeTrialThenSubscription.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Tage kostenlos testen · danach Abo, jederzeit kündbar'**
  String subscriptionValueDayFreeTrialThenSubscription(String arg0);

  /// No description provided for @subscriptionValueFreeValuePremiumValue.
  ///
  /// In de, this message translates to:
  /// **'{arg0}. Kostenlos: {arg1}. Premium: {arg2}.'**
  String subscriptionValueFreeValuePremiumValue(
    String arg0,
    String arg1,
    String arg2,
  );

  /// No description provided for @subscriptionValueItEndsAutomaticallyAtNoCost.
  ///
  /// In de, this message translates to:
  /// **'{arg0} Danach beginnt das bezahlte Abo. Bis dahin kannst du jederzeit in Google Play kündigen.'**
  String subscriptionValueItEndsAutomaticallyAtNoCost(String arg0);

  /// No description provided for @subscriptionValueNothingWasPurchasedOrChargedTry.
  ///
  /// In de, this message translates to:
  /// **'{arg0}. Es wurde nichts gekauft und nichts berechnet.'**
  String subscriptionValueNothingWasPurchasedOrChargedTry(String arg0);

  /// No description provided for @subscriptionValueUnlocked.
  ///
  /// In de, this message translates to:
  /// **'{arg0} freigeschaltet'**
  String subscriptionValueUnlocked(String arg0);

  /// No description provided for @subscriptionValueUntilThenNothingIsPurchasedOr.
  ///
  /// In de, this message translates to:
  /// **'{arg0} – bis dahin wird nichts gekauft oder berechnet.'**
  String subscriptionValueUntilThenNothingIsPurchasedOr(String arg0);

  /// No description provided for @subscriptionWeHaveSentAnAcknowledgementToValue.
  ///
  /// In de, this message translates to:
  /// **'Wir haben dir eine Eingangsbestätigung an {arg0} geschickt. Die Rückzahlung erfolgt über Google Play.'**
  String subscriptionWeHaveSentAnAcknowledgementToValue(String arg0);

  /// No description provided for @subscriptionWelcomeCoachText.
  ///
  /// In de, this message translates to:
  /// **'Persönliche Antworten – bis zu {arg0} Fragen pro Tag'**
  String subscriptionWelcomeCoachText(String arg0);

  /// No description provided for @subscriptionWelcomeMember.
  ///
  /// In de, this message translates to:
  /// **'Premium-Mitglied'**
  String get subscriptionWelcomeMember;

  /// No description provided for @subscriptionWelcomeMemberLabel.
  ///
  /// In de, this message translates to:
  /// **'MITGLIED'**
  String get subscriptionWelcomeMemberLabel;

  /// No description provided for @subscriptionWelcomeNextRenewal.
  ///
  /// In de, this message translates to:
  /// **'Nächste Verlängerung'**
  String get subscriptionWelcomeNextRenewal;

  /// No description provided for @subscriptionWelcomePhotoText.
  ///
  /// In de, this message translates to:
  /// **'Mahlzeit fotografieren, Nährwerte in Sekunden schätzen lassen'**
  String get subscriptionWelcomePhotoText;

  /// No description provided for @subscriptionWelcomeRecipesText.
  ///
  /// In de, this message translates to:
  /// **'Jedes Rezept mit Profi-Tipps zu jedem Schritt'**
  String get subscriptionWelcomeRecipesText;

  /// No description provided for @subscriptionWelcomeRenewsNote.
  ///
  /// In de, this message translates to:
  /// **'Verlängert sich automatisch · jederzeit im Store kündbar'**
  String get subscriptionWelcomeRenewsNote;

  /// No description provided for @subscriptionWelcomeThanks.
  ///
  /// In de, this message translates to:
  /// **'Danke für deine Unterstützung! Dein Abo ist aktiv.'**
  String get subscriptionWelcomeThanks;

  /// No description provided for @subscriptionWelcomeTitle.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei Lookin Premium'**
  String get subscriptionWelcomeTitle;

  /// No description provided for @subscriptionWelcomeTrialEnds.
  ///
  /// In de, this message translates to:
  /// **'Testphase endet'**
  String get subscriptionWelcomeTrialEnds;

  /// No description provided for @subscriptionWelcomeTrialPlan.
  ///
  /// In de, this message translates to:
  /// **'Premium-Test · {arg0} Tage'**
  String subscriptionWelcomeTrialPlan(String arg0);

  /// No description provided for @subscriptionWelcomeUnlockedHeading.
  ///
  /// In de, this message translates to:
  /// **'Jetzt für dich freigeschaltet'**
  String get subscriptionWelcomeUnlockedHeading;

  /// No description provided for @subscriptionWithPremiumAllRecipes.
  ///
  /// In de, this message translates to:
  /// **'Mit Premium: alle Rezepte'**
  String get subscriptionWithPremiumAllRecipes;

  /// No description provided for @subscriptionWithdrawFromContract.
  ///
  /// In de, this message translates to:
  /// **'Vertrag widerrufen'**
  String get subscriptionWithdrawFromContract;

  /// No description provided for @subscriptionWithoutASubscriptionValueValueOfRecipes.
  ///
  /// In de, this message translates to:
  /// **'Ohne Abo: {arg0}{arg1}% der Rezepte'**
  String subscriptionWithoutASubscriptionValueValueOfRecipes(
    String arg0,
    String arg1,
  );

  /// No description provided for @subscriptionYearly.
  ///
  /// In de, this message translates to:
  /// **'Jährlich'**
  String get subscriptionYearly;

  /// No description provided for @subscriptionYearlyValueValueBilledOnceAYear.
  ///
  /// In de, this message translates to:
  /// **'Jährlich {arg0} {arg1}, einmal im Jahr berechnet ({arg2}). Monatlich {arg3} {arg4}. Alle Preise inkl. MwSt.'**
  String subscriptionYearlyValueValueBilledOnceAYear(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
    String arg4,
  );

  /// No description provided for @subscriptionYourAiChatForNutritionAndFitness.
  ///
  /// In de, this message translates to:
  /// **'Dein KI-Chat für Ernährung und Fitness, abgestimmt auf dein Ziel und deine Tageswerte.'**
  String get subscriptionYourAiChatForNutritionAndFitness;

  /// No description provided for @subscriptionYourConsentCouldNotBeSavedJust.
  ///
  /// In de, this message translates to:
  /// **'Deine Zustimmung konnte gerade nicht gespeichert werden. Bitte prüfe deine Verbindung und versuche es erneut. Es wurde nichts gekauft.'**
  String get subscriptionYourConsentCouldNotBeSavedJust;

  /// No description provided for @subscriptionYourFreeTrialIsActiveItEnds.
  ///
  /// In de, this message translates to:
  /// **'Deine kostenlose Testphase läuft. Danach beginnt das bezahlte Abo, wenn du nicht vorher in Google Play kündigst.'**
  String get subscriptionYourFreeTrialIsActiveItEnds;

  /// No description provided for @subscriptionYourFreeTrialLastsValueDays.
  ///
  /// In de, this message translates to:
  /// **'Deine kostenlose Testphase läuft {arg0} Tage.'**
  String subscriptionYourFreeTrialLastsValueDays(String arg0);

  /// No description provided for @subscriptionYourFreeTrialRunsUntilValue.
  ///
  /// In de, this message translates to:
  /// **'Deine kostenlose Testphase läuft bis {arg0}.'**
  String subscriptionYourFreeTrialRunsUntilValue(String arg0);

  /// No description provided for @subscriptionYourName.
  ///
  /// In de, this message translates to:
  /// **'Dein Name'**
  String get subscriptionYourName;

  /// No description provided for @subscriptionYourPaymentIsStillBeingReviewedPremium.
  ///
  /// In de, this message translates to:
  /// **'Deine Zahlung ist noch in Prüfung. Premium wird freigeschaltet, sobald der Store sie bestätigt.'**
  String get subscriptionYourPaymentIsStillBeingReviewedPremium;

  /// No description provided for @subscriptionYourPremiumSubscriptionIsActive.
  ///
  /// In de, this message translates to:
  /// **'Dein Premium-Abo ist aktiv.'**
  String get subscriptionYourPremiumSubscriptionIsActive;

  /// No description provided for @subscriptionYourPremiumSubscriptionIsActiveUntilValue.
  ///
  /// In de, this message translates to:
  /// **'Dein Premium-Abo ist aktiv bis {arg0}.'**
  String subscriptionYourPremiumSubscriptionIsActiveUntilValue(String arg0);

  /// No description provided for @subscriptionYourPurchaseHasBeenReceivedActivationIs.
  ///
  /// In de, this message translates to:
  /// **'Dein Kauf ist angekommen. Die Freischaltung dauert noch einen Moment – öffne Lookin gleich noch einmal. Es wird nichts doppelt berechnet.'**
  String get subscriptionYourPurchaseHasBeenReceivedActivationIs;

  /// No description provided for @subscriptionYourWithdrawalCouldNotBeSubmittedJust.
  ///
  /// In de, this message translates to:
  /// **'Der Widerruf konnte gerade nicht übermittelt werden. Bitte versuche es erneut oder widerrufe per E-Mail an lookinsupport@gmail.com. Es zählt, dass du die Erklärung innerhalb der Frist absendest.'**
  String get subscriptionYourWithdrawalCouldNotBeSubmittedJust;

  /// No description provided for @subscriptionYourWithdrawalWasReceivedOnValue.
  ///
  /// In de, this message translates to:
  /// **'Dein Widerruf ist am {arg0} eingegangen.'**
  String subscriptionYourWithdrawalWasReceivedOnValue(String arg0);

  /// No description provided for @valuesActivityActive.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get valuesActivityActive;

  /// No description provided for @valuesActivityLow.
  ///
  /// In de, this message translates to:
  /// **'Wenig aktiv'**
  String get valuesActivityLow;

  /// No description provided for @valuesActivityModerate.
  ///
  /// In de, this message translates to:
  /// **'Moderat aktiv'**
  String get valuesActivityModerate;

  /// No description provided for @valuesActivityVeryActive.
  ///
  /// In de, this message translates to:
  /// **'Sehr aktiv'**
  String get valuesActivityVeryActive;

  /// No description provided for @valuesAllergiesNone.
  ///
  /// In de, this message translates to:
  /// **'Keine angegeben'**
  String get valuesAllergiesNone;

  /// No description provided for @valuesDifficultyEasy.
  ///
  /// In de, this message translates to:
  /// **'Einfach'**
  String get valuesDifficultyEasy;

  /// No description provided for @valuesDifficultyHard.
  ///
  /// In de, this message translates to:
  /// **'Anspruchsvoll'**
  String get valuesDifficultyHard;

  /// No description provided for @valuesDifficultyMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get valuesDifficultyMedium;

  /// No description provided for @valuesGoalBuildMuscle.
  ///
  /// In de, this message translates to:
  /// **'Muskeln aufbauen'**
  String get valuesGoalBuildMuscle;

  /// No description provided for @valuesGoalEatHealthier.
  ///
  /// In de, this message translates to:
  /// **'Gesünder ernähren'**
  String get valuesGoalEatHealthier;

  /// No description provided for @valuesGoalLoseFat.
  ///
  /// In de, this message translates to:
  /// **'Fett verlieren'**
  String get valuesGoalLoseFat;

  /// No description provided for @valuesGoalMaintain.
  ///
  /// In de, this message translates to:
  /// **'Gewicht halten'**
  String get valuesGoalMaintain;

  /// No description provided for @valuesMealBreakfast.
  ///
  /// In de, this message translates to:
  /// **'Frühstück'**
  String get valuesMealBreakfast;

  /// No description provided for @valuesMealDinner.
  ///
  /// In de, this message translates to:
  /// **'Abendessen'**
  String get valuesMealDinner;

  /// No description provided for @valuesMealLunch.
  ///
  /// In de, this message translates to:
  /// **'Mittagessen'**
  String get valuesMealLunch;

  /// No description provided for @valuesMealSnack.
  ///
  /// In de, this message translates to:
  /// **'Snack'**
  String get valuesMealSnack;

  /// No description provided for @valuesNutritionBalanced.
  ///
  /// In de, this message translates to:
  /// **'Ausgewogen'**
  String get valuesNutritionBalanced;

  /// No description provided for @valuesNutritionPescatarian.
  ///
  /// In de, this message translates to:
  /// **'Pescetarisch'**
  String get valuesNutritionPescatarian;

  /// No description provided for @valuesNutritionVegan.
  ///
  /// In de, this message translates to:
  /// **'Vegan'**
  String get valuesNutritionVegan;

  /// No description provided for @valuesNutritionVegetarian.
  ///
  /// In de, this message translates to:
  /// **'Vegetarisch'**
  String get valuesNutritionVegetarian;

  /// No description provided for @valuesTagBreakfast.
  ///
  /// In de, this message translates to:
  /// **'Frühstück'**
  String get valuesTagBreakfast;

  /// No description provided for @valuesTagBudget.
  ///
  /// In de, this message translates to:
  /// **'Budget'**
  String get valuesTagBudget;

  /// No description provided for @valuesTagDinner.
  ///
  /// In de, this message translates to:
  /// **'Abendessen'**
  String get valuesTagDinner;

  /// No description provided for @valuesTagForYou.
  ///
  /// In de, this message translates to:
  /// **'Für dich'**
  String get valuesTagForYou;

  /// No description provided for @valuesTagHighProtein.
  ///
  /// In de, this message translates to:
  /// **'High Protein'**
  String get valuesTagHighProtein;

  /// No description provided for @valuesTagLunch.
  ///
  /// In de, this message translates to:
  /// **'Mittagessen'**
  String get valuesTagLunch;

  /// No description provided for @valuesTagMealPrep.
  ///
  /// In de, this message translates to:
  /// **'Meal Prep'**
  String get valuesTagMealPrep;

  /// No description provided for @valuesTagPescatarian.
  ///
  /// In de, this message translates to:
  /// **'Pescetarisch'**
  String get valuesTagPescatarian;

  /// No description provided for @valuesTagQuick.
  ///
  /// In de, this message translates to:
  /// **'Schnell'**
  String get valuesTagQuick;

  /// No description provided for @valuesTagSnack.
  ///
  /// In de, this message translates to:
  /// **'Snack'**
  String get valuesTagSnack;

  /// No description provided for @valuesTagVegan.
  ///
  /// In de, this message translates to:
  /// **'Vegan'**
  String get valuesTagVegan;

  /// No description provided for @valuesTagVegetarian.
  ///
  /// In de, this message translates to:
  /// **'Vegetarisch'**
  String get valuesTagVegetarian;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
