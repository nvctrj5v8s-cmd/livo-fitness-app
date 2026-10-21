// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get allergiesAllergiesIntolerances =>
      'Allergien & Unverträglichkeiten';

  @override
  String get allergiesAllergyInformationMissing => 'Allergieangaben fehlen';

  @override
  String get allergiesChange => 'Ändern';

  @override
  String get allergiesClose => 'Schließen';

  @override
  String get allergiesEGCoconutHistamine => 'z. B. Kokos, Histamin';

  @override
  String get allergiesNoReliableAllergenOrIngredientInformationIs =>
      'Zu diesem Eintrag liegen keine verlässlichen Allergen- oder Zutatenangaben vor.';

  @override
  String get allergiesNoneOfYourSelectedTriggersWereRecognised =>
      'In den vorhandenen Angaben wurde kein gewählter Auslöser erkannt. Das ist keine Sicherheitsgarantie.';

  @override
  String get allergiesNoneSpecified => 'Keine angegeben';

  @override
  String get allergiesOptionalHealthInformationItIsSavedIn =>
      'Freiwillige Gesundheitsangabe: Sie wird in deinem Konto gespeichert und dem Lookin Coach als Kontext mitgegeben, damit er nichts Unpassendes vorschlägt. Du kannst sie hier jederzeit ändern oder leeren.';

  @override
  String get allergiesOtherAllergiesIntolerances =>
      'Weitere Allergien / Unverträglichkeiten';

  @override
  String get allergiesPleaseCheckTheIngredientsList =>
      'Bitte Zutatenliste prüfen';

  @override
  String get allergiesPossibleAllergenConflict => 'Möglicher Allergenkonflikt';

  @override
  String get allergiesProductInformationMayBeMissingOrOutdated =>
      'Produktangaben können fehlen oder veraltet sein. Prüfe bei einer Allergie immer die aktuelle Verpackung und mögliche Kreuzkontamination.';

  @override
  String get allergiesSaveSelection => 'Auswahl speichern';

  @override
  String get allergiesSelect => 'Auswählen';

  @override
  String get allergiesSelectKnownAllergensLactoseIsListedSeparately =>
      'Wähle bekannte Allergene aus. Laktose ist separat als Unverträglichkeit aufgeführt.';

  @override
  String get allergiesSeparateMultipleEntriesWithCommas =>
      'Mehrere Angaben mit Komma trennen.';

  @override
  String allergiesTheAvailableProductOrIngredientInformationMentions(
    String arg0,
  ) {
    return 'Die verfügbaren Produkt-/Zutatenangaben nennen: $arg0.';
  }

  @override
  String allergiesValueIfYouHaveAllergiesAlwaysCheck(String arg0) {
    return '$arg0 Prüfe bei Allergien immer die aktuelle Verpackung und mögliche Kreuzkontamination.';
  }

  @override
  String get allergiesWhatShouldTheAppTakeIntoAccount =>
      'Was soll die App beachten?';

  @override
  String get appConfirmedIfYouAlsoReceivedAnEmail =>
      'Bestätigt. Hast du auch an deine andere Adresse eine E-Mail bekommen, bestätige die Änderung dort ebenfalls.';

  @override
  String get appNoConnectionToTheServerYourLink =>
      'Keine Verbindung zum Server. Dein Link ist vermutlich noch gültig: Lade die Seite neu oder tippe den Link in der E-Mail noch einmal an.';

  @override
  String get appOpeningSemantics => 'Lookin wird geöffnet';

  @override
  String get appYourConfirmationLinkHasExpiredOrHas =>
      'Der Bestätigungslink ist abgelaufen oder wurde schon benutzt. Melde dich an. Ist deine Adresse noch nicht bestätigt, kannst du dort eine neue Bestätigungs-Mail anfordern.';

  @override
  String get appYourResetLinkHasExpiredOrHas =>
      'Der Link zum Zurücksetzen ist abgelaufen oder wurde schon benutzt. Fordere unter „Passwort vergessen?“ einen neuen an.';

  @override
  String get authAlmostThere => 'Fast geschafft!';

  @override
  String get authAnAccountAlreadyExistsForThisEmail =>
      'Für diese E-Mail gibt es bereits ein Konto.';

  @override
  String get authAtLeastEightCharacters => 'Mindestens acht Zeichen.';

  @override
  String get authBack => 'Zurück';

  @override
  String get authByTappingGetStartedForFreeYou =>
      'Mit „Kostenlos starten“ bestätigst du, dass du mindestens 18 Jahre alt bist, und akzeptierst die AGB. Hinweise zum Datenschutz findest du in der Datenschutzerklärung.';

  @override
  String get authCancelAndReturnToSignIn => 'Abbrechen und zum Login';

  @override
  String get authChangeAnswers => 'Antworten ändern';

  @override
  String get authCheckYourInbox => 'Schau in dein Postfach';

  @override
  String get authCheckingYourSignIn => 'Anmeldung wird geprüft';

  @override
  String get authChooseANewPasswordYouWillThen =>
      'Wähle ein neues Passwort. Danach meldest du dich damit erneut an.';

  @override
  String get authConnectionFailedPleaseTryAgain =>
      'Verbindung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authCreateYourFreeAccountLookinWillThen =>
      'Erstelle dein kostenloses Konto. Dann speichert Lookin deine Antworten und dein Tagebuch – auch auf deinen anderen Geräten.';

  @override
  String get authEatSimplyChooseClearly => 'Einfach essen. Klarer entscheiden.';

  @override
  String get authEmailAddress => 'E-Mail-Adresse';

  @override
  String get authEmailConfirmed => 'E-Mail bestätigt';

  @override
  String get authEnergy => 'ENERGIE';

  @override
  String get authEnterYourEmailAddressFirst =>
      'Gib zuerst deine E-Mail-Adresse ein.';

  @override
  String get authForgotPassword => 'Passwort vergessen?';

  @override
  String get authGetStartedForFree => 'Kostenlos starten';

  @override
  String get authHidePassword => 'Passwort verbergen';

  @override
  String get authIHaveConfirmedContinue => 'Ich habe bestätigt – weiter';

  @override
  String get authIfALookinAccountExistsWithThis =>
      'Falls es ein Lookin-Konto mit dieser Adresse gibt, haben wir dir einen Link zum Zurücksetzen geschickt. Schau auch im Spam-Ordner nach.';

  @override
  String get authIfNoLookinAccountExistsForThis =>
      ' geschickt, falls es dort noch kein Lookin-Konto gibt. Tippe auf den Link darin, um dein Konto zu aktivieren.';

  @override
  String get authIfYourAddressHasNotBeenConfirmed =>
      'Falls die Adresse noch nicht bestätigt ist, haben wir dir eine neue Bestätigungs-Mail geschickt. Schau auch im Spam-Ordner nach.';

  @override
  String get authNewPassword => 'Neues Passwort';

  @override
  String get authNothingArrivedCheckYourSpamFolderToo =>
      'Nichts angekommen? Schau auch im Spam-Ordner nach. Es kann ein bis zwei Minuten dauern. Hast du dich mit dieser Adresse schon einmal registriert? Dann melde dich an oder nutze dort „Passwort vergessen?“.';

  @override
  String get authOneAccountForYourGoalsNutritionAnd =>
      'Ein Konto für Ziele, Ernährung und Fortschritt.';

  @override
  String get authOpenYourInbox => 'Postfach öffnen';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authPersonal => 'Persönlich';

  @override
  String get authPleaseCheckYourEmailAddress =>
      'Bitte prüfe deine E-Mail-Adresse.';

  @override
  String get authPleaseEnterAValidEmailAddress =>
      'Bitte gib eine gültige E-Mail ein.';

  @override
  String get authPleaseEnterYourName => 'Bitte gib deinen Namen ein.';

  @override
  String get authPrivate => 'Privat';

  @override
  String get authQuick => 'Schnell';

  @override
  String get authRepeatPassword => 'Passwort wiederholen';

  @override
  String get authResendConfirmationEmail => 'Bestätigungs-Mail erneut senden';

  @override
  String get authSavePassword => 'Passwort speichern';

  @override
  String get authSecurelyStoredDeleteAtAnyTime =>
      'Sicher gespeichert · jederzeit löschbar';

  @override
  String authSendAgainInValueS(String arg0) {
    return 'Erneut senden in $arg0 s';
  }

  @override
  String get authShowPassword => 'Passwort anzeigen';

  @override
  String get authSignIn => 'Einloggen';

  @override
  String get authSignIn2 => 'Anmelden';

  @override
  String get authSignInAndPickUpWhereYou =>
      'Einloggen und direkt dort weitermachen, wo du aufgehört hast.';

  @override
  String get authSignInNow => 'Jetzt anmelden';

  @override
  String get authSignOutFailedPleaseTryAgain =>
      'Abmelden fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authSignUp => 'Registrieren';

  @override
  String get authTapConfirmEmail => 'Auf „E-Mail bestätigen“ tippen';

  @override
  String get authThatDidNotWorkJustNowPlease =>
      'Das hat gerade nicht geklappt. Bitte versuche es später erneut.';

  @override
  String get authTheEmailComesFromLookinNoreplyLookin =>
      'Die Mail kommt von Lookin (noreply@lookin-foodtracker.de).';

  @override
  String get authTheLinkCanOnlyBeUsedOnce =>
      'Der Link funktioniert nur einmal und ist begrenzt gültig.';

  @override
  String get authThePasswordsDoNotMatch =>
      'Die Passwörter stimmen nicht überein.';

  @override
  String get authThisPasswordIsTooEasyToGuess =>
      'Dieses Passwort ist zu unsicher. Wähle ein anderes.';

  @override
  String get authTipReturnToLookinInTheWindow =>
      'Tipp: Kehre einfach zu Lookin zurück, in dem Fenster oder der App, in der du dich registriert hast. Dort wirst du automatisch angemeldet.';

  @override
  String get authToday => 'HEUTE';

  @override
  String get authTooManyAttemptsPleaseWaitAMoment =>
      'Zu viele Versuche. Bitte warte kurz und versuche es dann erneut.';

  @override
  String get authTrackUnderstandAndMakeBetterChoicesWithout =>
      'Tracken, verstehen und besser entscheiden — ohne komplizierte Tabellen.';

  @override
  String get authUseADifferentEmailAddress => 'Andere E-Mail-Adresse verwenden';

  @override
  String get authUsingYourEmailAddressAndPassword =>
      'Mit deiner E-Mail-Adresse und deinem Passwort.';

  @override
  String get authWeHaveSentAConfirmationEmailTo =>
      'Wir haben eine Bestätigungs-Mail an ';

  @override
  String get authWelcomeBack => 'Willkommen zurück.';

  @override
  String get authYourAddressHasNotBeenConfirmedYet =>
      'Deine Adresse ist noch nicht bestätigt. Tippe zuerst auf den Link in der E-Mail und komm dann hierher zurück.';

  @override
  String get authYourDayYourRhythm => 'Dein Alltag.\nDein Rhythmus.';

  @override
  String get authYourEmailAddressHasNotBeenConfirmed =>
      'Deine E-Mail-Adresse ist noch nicht bestätigt. Tippe auf den Link in unserer E-Mail oder fordere unten eine neue an.';

  @override
  String get authYourEmailOrPasswordIsIncorrectIf =>
      'E-Mail oder Passwort ist nicht korrekt. Hast du dich mit dieser Adresse schon einmal registriert, gilt das damalige Passwort. Setze es sonst über „Passwort vergessen?“ zurück.';

  @override
  String get authYourFoodYourRhythm => 'Dein Essen.\nDein Rhythmus.';

  @override
  String get authYourLookinAccountIsNowActiveYou =>
      'Dein Lookin-Konto ist jetzt aktiv. Du kannst dich mit deiner E-Mail-Adresse und deinem Passwort anmelden.';

  @override
  String get authYourLookinAccountIsReady => 'Dein Lookin-Konto ist bereit.';

  @override
  String get authYourName => 'Dein Name';

  @override
  String get authYourNewPasswordHasBeenSavedSign =>
      'Dein neues Passwort ist gespeichert. Melde dich jetzt damit an.';

  @override
  String get authYourNewPasswordMustBeDifferentFrom =>
      'Das neue Passwort muss sich von deinem bisherigen unterscheiden.';

  @override
  String get authYourPasswordCouldNotBeSetRequest =>
      'Das Passwort konnte nicht gesetzt werden. Fordere unter „Passwort vergessen?“ einen neuen Link an.';

  @override
  String get authYourPasswordIsTooWeakPleaseUse =>
      'Das Passwort ist zu schwach. Wähle mindestens acht Zeichen.';

  @override
  String get authYourPasswordMustContainAtLeastEight =>
      'Das Passwort muss mindestens acht Zeichen haben.';

  @override
  String get authYourStart => 'Dein Start.';

  @override
  String get coachAiCanMakeMistakesNotMedicalAdvice =>
      'KI kann Fehler machen · Keine medizinische Beratung';

  @override
  String get coachAiCanMakeMistakesValuesAreEstimates =>
      'KI kann Fehler machen · Werte sind Schätzungen · Keine medizinische Beratung';

  @override
  String get coachAiNutritionFitness => 'KI · Ernährung & Fitness';

  @override
  String get coachAnalyseAFoodPhoto => 'Lebensmittel-Foto analysieren';

  @override
  String get coachAskAboutMealsNutritionOrTrainingAnswers =>
      'Frag nach Mahlzeiten, Nährwerten oder Training – die Antworten berücksichtigen dein Ziel und deine Tageswerte.';

  @override
  String get coachAskAboutMealsRecipesNutritionOrTraining =>
      'Frag nach Mahlzeiten, Rezepten, Nährwerten oder Training. Dein Ziel und deine heutigen Werte werden dabei berücksichtigt.';

  @override
  String get coachAskYourCoach => 'Frag deinen Coach …';

  @override
  String get coachCancel => 'Abbrechen';

  @override
  String get coachCoachIsTyping => 'Coach schreibt …';

  @override
  String get coachCoachSAnswer => 'Antwort vom Coach';

  @override
  String get coachDailyLimitReachedComeBackTomorrow =>
      'Tageslimit erreicht – morgen geht es weiter';

  @override
  String get coachDailyTarget => 'Tagesziel';

  @override
  String get coachDeleteChatHistory => 'Chatverlauf löschen?';

  @override
  String get coachDeleteHistory => 'Verlauf löschen';

  @override
  String get coachDeleteHistoryExplanation =>
      'Dein Chatverlauf wird dauerhaft aus deinem Konto gelöscht. Das lässt sich nicht rückgängig machen. Dein Tageslimit bleibt unverändert.';

  @override
  String get coachDeleteSavedCoachHistory =>
      'Gespeicherten Coach-Verlauf löschen';

  @override
  String get coachDinner => 'Abendessen';

  @override
  String get coachDismissNotice => 'Hinweis schließen';

  @override
  String get coachEachQuestionSendsYourGoalDailyTargets =>
      'Mit jeder Frage gehen dein Ziel, deine Tagesziele, heutigen Tageswerte, Ernährungsstil, Allergien und Aktivität an den KI-Dienst – nicht dein Name. Der Chat wird in deinem Konto gespeichert und lässt sich jederzeit löschen.';

  @override
  String get coachExample => 'Beispiel';

  @override
  String get coachExampleCoachConversationAvailableWithPremium =>
      'Beispiel eines Coach-Gesprächs, mit Premium verfügbar';

  @override
  String get coachFocusedOnNutritionFitnessAndAHealthy =>
      'Fokussiert auf Ernährung, Fitness und gesunden Alltag';

  @override
  String get coachFoodPhoto => 'Lebensmittel-Foto';

  @override
  String get coachFoodPhotoForAnalysis => '📷 Lebensmittel-Foto zur Analyse';

  @override
  String get coachGetEstimatesFromPhotosOfYourMeals =>
      'Fotos deiner Mahlzeiten einschätzen lassen';

  @override
  String get coachGiveMeASimpleHighProteinIdea =>
      'Gib mir eine einfache proteinreiche Idee.';

  @override
  String get coachHowCanISensiblyReachMyCalorie =>
      'Wie erreiche ich heute sinnvoll mein Kalorienziel?';

  @override
  String get coachIdeasThatFitYourRemainingCalories =>
      'Ideen, die zu deinen restlichen Kalorien passen';

  @override
  String get coachLoadingYourHistory => 'Dein Verlauf wird geladen …';

  @override
  String get coachMoreProtein => 'Mehr Protein';

  @override
  String get coachNewChatDeleteHistory => 'Neuer Chat (Verlauf löschen)';

  @override
  String get coachNewChatExplanation =>
      'Dafür wird dein bisheriger Chatverlauf dauerhaft aus deinem Konto gelöscht. Das lässt sich nicht rückgängig machen. Dein Tageslimit bleibt unverändert.';

  @override
  String get coachNotSent => 'Nicht gesendet';

  @override
  String get coachPremiumFeature => 'Premium-Funktion';

  @override
  String get coachProteinAndTrainingTipsForYourDay =>
      'Protein- und Trainingstipps für deinen Alltag';

  @override
  String get coachReportAnswer => 'Antwort melden';

  @override
  String get coachReportFailed =>
      'Die Meldung konnte gerade nicht gesendet werden. Bitte prüfe die Verbindung und versuche es noch einmal.';

  @override
  String get coachReportLimit =>
      'Du hast heute schon viele Antworten gemeldet, danke! Bitte melde weitere morgen.';

  @override
  String get coachReportReasonInappropriate => 'Unpassend oder beleidigend';

  @override
  String get coachReportReasonOther => 'Etwas anderes';

  @override
  String get coachReportReasonUnsafe =>
      'Unsicher oder gesundheitlich bedenklich';

  @override
  String get coachReportReasonWrong => 'Falsch oder irreführend';

  @override
  String get coachReportSend => 'Meldung senden';

  @override
  String get coachReportSheetText =>
      'Falsch, unpassend oder unsicher? Melde es hier direkt in der App. Wir prüfen jede Meldung und verbessern damit den Coach. Gespeichert werden der Grund, die gemeldete Antwort und dein Konto, höchstens 12 Monate.';

  @override
  String get coachReportSheetTitle => 'Antwort melden';

  @override
  String get coachReportThanks =>
      'Danke! Deine Meldung ist angekommen. Wir prüfen sie.';

  @override
  String get coachSendMessage => 'Nachricht senden';

  @override
  String get coachStartANewChat => 'Neuen Chat beginnen?';

  @override
  String get coachTheCoachCannotBeOpenedJustNow =>
      'Der Coach kann gerade nicht geöffnet werden.';

  @override
  String get coachTheCoachIsReplying => 'Der Coach antwortet …';

  @override
  String get coachTheCoachIsWritingAnAnswer =>
      'Der Coach schreibt eine Antwort';

  @override
  String get coachTheLookinCoachIsPartOfLookin =>
      'Der Lookin Coach ist Teil von Lookin Premium. Deine Testphase oder dein Abo ist nicht mehr aktiv.';

  @override
  String get coachThePhotoIsTooLargePleaseChoose =>
      'Das Foto ist zu groß. Bitte wähle ein kleineres Bild.';

  @override
  String get coachThisImageCouldNotBeRead =>
      'Dieses Bild konnte nicht gelesen werden.';

  @override
  String get coachThisIsTakingALittleLongerThan =>
      'Das dauert etwas länger als sonst …';

  @override
  String get coachTryAgain => 'Erneut versuchen';

  @override
  String get coachUnlockPremium => 'Premium freischalten';

  @override
  String coachValueDayFreeTrialEndsAutomaticallyNo(String arg0) {
    return '$arg0 Tage kostenlos testen · danach Abo, jederzeit kündbar';
  }

  @override
  String coachValueOfValueAiRequestsLeftToday(String arg0, String arg1) {
    return 'Noch $arg0 von $arg1 KI-Anfragen heute';
  }

  @override
  String coachValueOfValueCharactersRemaining(String arg0, String arg1) {
    return 'Noch $arg0 von $arg1 Zeichen frei';
  }

  @override
  String coachValuePermanentlyDeletedFromYourAccountThis(String arg0) {
    return '$arg0 dauerhaft aus deinem Konto gelöscht. Das lässt sich nicht rückgängig machen. Dein Tageslimit bleibt unverändert.';
  }

  @override
  String get coachViewPremium => 'Premium ansehen';

  @override
  String get coachWhatCanIStillEatThisEvening =>
      'Was kann ich heute Abend noch essen?';

  @override
  String get coachWhatDoYouNeedToday => 'Was brauchst du heute?';

  @override
  String get coachWithPremium => 'Mit Premium';

  @override
  String get coachYouHaveAbout650KcalLeftToday =>
      'Du hast heute noch etwa 650 kcal frei. Wie wäre eine Lachs-Bowl mit Reis und Gemüse? Das bringt dir rund 35 g Protein und hält lange satt.';

  @override
  String get coachYourChatHistoryHasBeenDeleted =>
      'Dein Chatverlauf wurde gelöscht.';

  @override
  String coachYourHistoryIsSavedInYourAccount(String arg0, String arg1) {
    return 'Dein Verlauf ist in deinem Konto gespeichert – höchstens die letzten $arg0 Nachrichten der letzten $arg1 Tage.';
  }

  @override
  String get coachYourPersonalAiCoach => 'Dein persönlicher KI-Coach';

  @override
  String get coachYourPremiumStatusCouldNotBeLoaded =>
      'Dein Premium-Status konnte nicht geladen werden. Bitte prüfe deine Internetverbindung.';

  @override
  String get coachYourQuestion => 'Deine Frage';

  @override
  String coachYourQuestionIsTooLongPleaseShorten(String arg0) {
    return 'Deine Frage ist zu lang. Bitte kürze sie auf höchstens $arg0 Zeichen.';
  }

  @override
  String get coachYourQuestionNotSent => 'Deine Frage, nicht gesendet';

  @override
  String get coachYourTrialHasEndedContinueChattingWith =>
      'Deine Testphase ist vorbei. Mit Premium schreibst du weiter mit deinem Coach.';

  @override
  String get commonAppTitle => 'Lookin – Ernährung';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonConnectionFailed =>
      'Verbindung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get commonContinue => 'Weiter';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonDone => 'Fertig';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonLater => 'Später';

  @override
  String get commonLoading => 'Wird geladen …';

  @override
  String get commonNo => 'Nein';

  @override
  String get commonOk => 'OK';

  @override
  String get commonPremium => 'Premium';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonUnknownError =>
      'Das hat gerade nicht geklappt. Bitte versuche es später erneut.';

  @override
  String get commonYes => 'Ja';

  @override
  String get consentAiCoachAndAiPhotoWillThen =>
      'KI-Coach und KI-Foto senden dann nichts mehr an OpenAI und fragen dich vor der nächsten Nutzung erneut.';

  @override
  String get consentCancel => 'Abbrechen';

  @override
  String get consentConsentCouldNotBeSaved =>
      'Deine Einwilligung konnte nicht gespeichert werden. Bitte prüfe die Verbindung und versuche es noch einmal.';

  @override
  String get consentConsents => 'Einwilligungen';

  @override
  String get consentContinueWithoutConsent => 'Ohne Einwilligung weiter';

  @override
  String get consentGiveConsent => 'Einwilligen';

  @override
  String get consentIConsentToLookinStoringMyOptional =>
      'Ich willige ein, dass Lookin meine freiwilligen Gesundheitsangaben (Gewicht, Taillenumfang, Zielgewicht, Allergien und Unverträglichkeiten sowie meine Antworten aus der Einführung wie Geburtstag, Größe, Geschlecht und einen optionalen Gesundheitshinweis) in meinem Konto speichert und für Richtwerte, Rezeptfilter und Warnhinweise nutzt. So muss ich sie auf einem neuen Gerät nicht noch einmal eingeben.';

  @override
  String get consentIExpresslyConsentToMyQuestionsPhotos =>
      'Ich willige ausdrücklich ein, dass meine Fragen, Fotos, die letzten Chat-Nachrichten und folgende Angaben zur Beantwortung an den KI-Dienst OpenAI übermittelt werden (Verarbeitung auch in den USA): Ziel, Tageswerte, Ernährungsstil, Aktivität, Angaben aus der Einführung (Motivation, Hürden, Erfahrung) und meine Allergien und Unverträglichkeiten, also Gesundheitsdaten. Name und E-Mail werden nicht übermittelt.';

  @override
  String get consentIExpresslyRequestThatLookinPremiumBegins =>
      'Ich verlange ausdrücklich, dass Lookin Premium sofort, also vor Ablauf der Widerrufsfrist, beginnt. Mir ist bekannt, dass ich bei einem Widerruf einen anteiligen Betrag für die bis dahin erbrachte Leistung zahle und mein Widerrufsrecht bei vollständiger Vertragserfüllung erlischt.';

  @override
  String get consentLookinAlsoWorksWithoutTheseConsentsWithout =>
      'Lookin funktioniert auch ohne diese Einwilligungen. Ohne sie bleiben Gesundheitsangaben nur auf diesem Gerät, und KI-Coach und KI-Foto fragen dich vor der ersten Nutzung noch einmal.';

  @override
  String get consentNotNow => 'Nicht jetzt';

  @override
  String get consentOptionalYouCanWithdrawEachConsentAt =>
      'Freiwillig. Du kannst jede Einwilligung jederzeit unter Profil › Datenschutz & Daten widerrufen.';

  @override
  String get consentSaveAndContinue => 'Speichern und weiter';

  @override
  String get consentSaveHealthInformation => 'Gesundheitsangaben speichern';

  @override
  String get consentSaveWeightTargetWeightAndAllergiesIn =>
      'Gewicht, Zielgewicht und Allergien im Konto speichern';

  @override
  String get consentSendQuestionsAndPhotosToOpenaiUsa =>
      'Fragen und Fotos an OpenAI (USA) senden';

  @override
  String get consentUseAiCoachAndAiPhoto => 'KI-Coach und KI-Foto nutzen';

  @override
  String get consentWeWillThenDeleteYourHealthInformation =>
      'Wir löschen dann deine Gesundheitsangaben in deinem Konto (Allergien, Zielgewicht, Gewichts- und Taillenwerte). Auf diesem Gerät bleiben deine Angaben erhalten.';

  @override
  String get consentWithdraw => 'Widerrufen';

  @override
  String get consentWithdrawAndDelete => 'Widerrufen und löschen';

  @override
  String get consentWithdrawConsent => 'Einwilligung widerrufen?';

  @override
  String get consentYourConsents => 'Deine Einwilligungen';

  @override
  String get coreAccountChanged => 'Konto geändert.';

  @override
  String get coreAiFeaturesNeedYourConsent =>
      'Die KI-Funktionen brauchen deine Einwilligung. Du kannst sie unter Profil › Exportieren, löschen, Einwilligungen erteilen.';

  @override
  String get coreBarcodeSearchDidNotReceiveAValid =>
      'Die Barcode-Suche hat gerade keine gültige Serverantwort erhalten. Bitte versuche es später erneut.';

  @override
  String get coreBarcodeSearchIsCurrentlyUnavailablePleaseTry =>
      'Die Barcode-Suche ist gerade nicht erreichbar. Bitte versuche es später erneut.';

  @override
  String coreCatalogueSourceValue(String arg0) {
    return 'Katalogquelle: $arg0';
  }

  @override
  String get coreImageAnalysisIsCurrentlyUnavailablePleaseTry =>
      'Die Bildanalyse ist gerade nicht erreichbar. Bitte versuche es erneut.';

  @override
  String get coreInvalidAiNutritionValue => 'Ungültiger KI-Nährwert.';

  @override
  String get coreInvalidRecognisedFood => 'Ungültiges erkanntes Lebensmittel.';

  @override
  String get coreLookinCatalogue => 'Lookin-Katalog';

  @override
  String coreMissingNutritionValueValue(String arg0) {
    return 'Nährwert fehlt: $arg0';
  }

  @override
  String get coreMustBeGreaterThan0 => 'Muss größer als 0 sein.';

  @override
  String get coreNoAccountAvailable => 'Konto fehlt.';

  @override
  String get coreNoConnectionToTheCoachPleaseCheck =>
      'Keine Verbindung zum Coach. Bitte prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get coreNoFoodsCouldBeConfidentlyRecognisedIn =>
      'Auf dem Foto konnten keine Lebensmittel sicher erkannt werden.';

  @override
  String get coreNoPermittedFoodsCouldBeConfidentlyRecognised =>
      'Auf dem Foto konnten keine erlaubten Lebensmittel sicher erkannt werden.';

  @override
  String get coreNothingCouldBeConfidentlyRecognisedInThis =>
      'Auf dem Foto konnte gerade nichts sicher erkannt werden.';

  @override
  String get coreNutritionValuesMustBeValidNumbersOf =>
      'Nährwerte müssen gültige Zahlen ab 0 sein.';

  @override
  String get corePhotoAnalysisDidNotReturnAValid =>
      'Die Fotoanalyse hat keine gültige Antwort erhalten.';

  @override
  String get corePhotoAnalysisIsCurrentlyUnavailablePleaseCheck =>
      'Die Fotoanalyse ist gerade nicht erreichbar. Bitte prüfe deine Verbindung.';

  @override
  String get corePhotoAnalysisIsCurrentlyUnavailablePleaseTry =>
      'Die Fotoanalyse ist gerade nicht erreichbar. Bitte versuche es erneut.';

  @override
  String get corePleaseAddSugarSaturatedFatAndSalt =>
      'Bitte Zucker, gesättigte Fettsäuren und Salz vom Etikett ergänzen.';

  @override
  String get corePleaseEnterAnAmountGreaterThan0 =>
      'Bitte eine Menge größer als 0 eingeben.';

  @override
  String get corePleaseEnterYourPassword => 'Bitte Passwort eingeben.';

  @override
  String get corePleaseRephraseYourQuestion =>
      'Bitte formuliere deine Frage etwas anders.';

  @override
  String get corePleaseSignInAgain => 'Bitte erneut anmelden.';

  @override
  String get corePleaseSignInAgainThenTryScanning =>
      'Bitte melde dich erneut an und versuche den Scan danach noch einmal.';

  @override
  String get corePleaseSignInAgainToUsePhoto =>
      'Bitte melde dich erneut an, um die Fotoanalyse zu verwenden.';

  @override
  String get corePleaseSignInBeforeSavingAnything =>
      'Bitte melde dich an, bevor du etwas speicherst.';

  @override
  String get corePleaseSignInFirst => 'Bitte melde dich zuerst an.';

  @override
  String get corePleaseSignInFirst2 => 'Bitte zuerst anmelden.';

  @override
  String get corePleaseWaitAMomentBeforeSearchingFor =>
      'Bitte kurz warten, bevor du den nächsten Barcode suchst.';

  @override
  String get coreSaturatedFatCannotExceedTotalFat =>
      'Gesättigte Fettsäuren dürfen nicht höher als Fett sein.';

  @override
  String get coreSugarCannotExceedCarbohydrates =>
      'Zucker darf nicht höher als die Kohlenhydrate sein.';

  @override
  String get coreTheAmountOrANutritionValueIs =>
      'Die Menge oder ein Nährwert ist zu groß.';

  @override
  String get coreTheCoachCouldNotPutTogetherAn =>
      'Der Coach konnte gerade keine Antwort formulieren. Bitte versuche es noch einmal.';

  @override
  String get coreTheCoachDidNotSendAValid =>
      'Der Coach hat keine gültige Antwort geschickt. Bitte versuche es noch einmal.';

  @override
  String get coreTheCoachIsCurrentlyUnavailablePleaseTry =>
      'Der Coach ist gerade nicht erreichbar. Bitte versuche es gleich noch einmal.';

  @override
  String get coreTheCoachIsTakingTooLongPlease =>
      'Der Coach braucht gerade zu lange. Bitte versuche es noch einmal.';

  @override
  String get coreTheCustomEntryHasNotBeenSaved =>
      'Der eigene Eintrag ist nicht gespeichert.';

  @override
  String get coreTheDataExportIsIncomplete =>
      'Der Datenexport ist unvollständig.';

  @override
  String get coreTheFoodEntryIsIncomplete =>
      'Der Lebensmitteleintrag ist unvollständig.';

  @override
  String get coreTheMealEntryHasNotBeenSaved =>
      'Der Mahlzeiteneintrag ist nicht gespeichert.';

  @override
  String get coreThePhotoIsTooLargePleaseChoose =>
      'Das Foto ist zu groß. Bitte wähle ein kleineres Bild.';

  @override
  String get coreThePhotoIsTooLargePleaseTake =>
      'Das Foto ist zu groß. Bitte nimm ein kleineres Bild auf.';

  @override
  String get coreTheProductResponseWasIncomplete =>
      'Die Produktantwort war unvollständig.';

  @override
  String get coreTheRecognisedValuesWereIncompletePleaseTry =>
      'Die erkannten Werte waren unvollständig. Bitte versuche es erneut.';

  @override
  String get coreTheServerResponseIsInvalid =>
      'Die Antwort des Servers ist ungültig.';

  @override
  String get coreTheSignedInAccountHasChanged =>
      'Das angemeldete Konto hat sich geändert.';

  @override
  String get coreThisAiFeatureIsPartOfLookin =>
      'Diese KI-Funktion ist Teil von Lookin Premium.';

  @override
  String get coreThisBarcodeIsInvalid => 'Dieser Barcode ist ungültig.';

  @override
  String get coreThisFoodCouldNoLongerBeFound =>
      'Das Lebensmittel konnte nicht mehr gefunden werden.';

  @override
  String get coreThisProductDoesNotMeetLookinS =>
      'Dieses Produkt entspricht nicht den Halal-Inhaltsregeln von Lookin.';

  @override
  String get coreThisProductWasNotFound =>
      'Dieses Produkt wurde nicht gefunden.';

  @override
  String get coreThisRecipeHasNoSavedIngredientsYet =>
      'Dieses Rezept hat noch keine gespeicherten Zutaten.';

  @override
  String get coreUnknownNutritionBasis => 'Unbekannte Nährwert-Basis.';

  @override
  String get coreUnknownNutritionDataVersion => 'Unbekannte Nährwert-Version.';

  @override
  String get coreUsdaFoodData => 'USDA-Lebensmitteldaten';

  @override
  String get coreWriteAShortQuestionFirst => 'Schreib zuerst eine kurze Frage.';

  @override
  String get coreYouHaveReachedTodaySAiLimit =>
      'Dein KI-Limit für heute ist erreicht. Morgen kannst du wieder analysieren.';

  @override
  String get coreYouHaveReachedYourDailyAiLimit =>
      'Dein KI-Tageslimit ist erreicht. Morgen kannst du wieder schreiben.';

  @override
  String get coreYourAccountCouldNotBeDeleted =>
      'Das Konto konnte nicht gelöscht werden.';

  @override
  String get coreYourAccountWasDeletedButSomeLocal =>
      'Das Konto wurde gelöscht, aber lokale Daten konnten nicht vollständig entfernt werden.';

  @override
  String get coreYourChatHistoryCouldNotBeDeleted =>
      'Dein Chatverlauf konnte gerade nicht gelöscht werden. Bitte versuche es gleich noch einmal.';

  @override
  String get coreYourChatHistoryCouldNotBeLoaded =>
      'Dein Chatverlauf konnte nicht geladen werden.';

  @override
  String get coreYourChatHistoryCouldNotBeLoaded2 =>
      'Dein Chatverlauf konnte gerade nicht geladen werden.';

  @override
  String coreYourMessageIsTooLongPleaseShorten(String arg0) {
    return 'Deine Nachricht ist zu lang. Bitte kürze sie auf höchstens $arg0 Zeichen.';
  }

  @override
  String get coreYourProfilePictureMustBeAJpeg =>
      'Das Profilbild muss ein JPEG mit höchstens 1 MB sein.';

  @override
  String get coreYourSessionHasExpiredPleaseSignIn =>
      'Deine Anmeldung ist abgelaufen. Bitte melde dich erneut an.';

  @override
  String get diary10GLess => '10 g weniger';

  @override
  String get diary10GMore => '10 g mehr';

  @override
  String get diaryAdd => 'Hinzufügen';

  @override
  String get diaryAddAtLeastOneFood =>
      'Füge mindestens ein Lebensmittel hinzu.';

  @override
  String get diaryAddManually => 'Selbst hinzufügen';

  @override
  String get diaryAddMeal => 'Mahlzeit hinzufügen';

  @override
  String get diaryAddToDiary => 'Zum Tagebuch hinzufügen';

  @override
  String diaryAddToValue(String arg0) {
    return 'Zu $arg0 hinzufügen';
  }

  @override
  String diaryAddToValueValueKcal(String arg0, String arg1) {
    return 'Zu $arg0 hinzufügen · $arg1 kcal';
  }

  @override
  String diaryAddedToValue(String arg0) {
    return 'Zu $arg0 hinzugefügt.';
  }

  @override
  String get diaryAiEstimate => 'KI-Schätzung';

  @override
  String get diaryAiIsRecognisingFoodsAndEstimatingAmounts =>
      'KI erkennt Lebensmittel und schätzt die Mengen …';

  @override
  String get diaryAiPhoto => 'KI-Foto';

  @override
  String get diaryAiPhotoRecognitionIsPartOfLookin =>
      'Die KI-Foto-Erkennung ist Teil von Lookin Premium. Du kannst die Mahlzeit trotzdem über „Suchen“ oder „Selbst hinzufügen“ eintragen.';

  @override
  String get diaryAiValuesAreEstimatesAPhotoCannot =>
      'KI-Werte sind Schätzungen. Ein Foto ersetzt keine Waage oder Verpackungsangabe – prüfe Mengen und Nährwerte vor dem Speichern.';

  @override
  String get diaryAll => 'Alle';

  @override
  String get diaryAllLabelValuesAreRequiredFibreIs =>
      'Alle Etikettwerte sind erforderlich. Ballaststoffe sind freiwillig.';

  @override
  String get diaryAllergensAccordingToProductData =>
      'Allergene laut Produktdaten';

  @override
  String get diaryAllergyNotice => 'Allergiehinweis';

  @override
  String diaryAllergyNoticeValue(String arg0) {
    return 'Allergiehinweis: $arg0';
  }

  @override
  String get diaryAlternativelyChooseAPhotoUsingGalleryBelow =>
      'Alternativ unten über „Galerie“ ein Foto auswählen.';

  @override
  String get diaryAmount => 'Menge';

  @override
  String get diaryAmountEaten => 'Gegessene Menge';

  @override
  String get diaryAnotherMeal => 'Weitere Mahlzeit';

  @override
  String get diaryCalories => 'Kalorien';

  @override
  String get diaryCameraAccessWasNotAllowedAllowThe =>
      'Der Kamerazugriff wurde nicht erlaubt. Erlaube die Kamera in den Browser- bzw. Geräteeinstellungen und versuche es erneut.';

  @override
  String get diaryCameraActiveHoldTheBarcodeInsideThe =>
      'Kamera aktiv – Barcode in den Rahmen halten';

  @override
  String get diaryCancel => 'Abbrechen';

  @override
  String get diaryCarbohydrates => 'Kohlenhydrate';

  @override
  String get diaryCarbs => 'Kohlenh.';

  @override
  String get diaryCarbsG => 'Kohlenhydrate g';

  @override
  String get diaryChangesAreSavedDirectlyToYourDiary =>
      'Änderungen werden direkt in deinem Tagebuch gespeichert.';

  @override
  String get diaryChickpeaRiceBowl => 'Kichererbsen-Reis-Bowl';

  @override
  String get diaryChooseFromGallery => 'Aus Galerie wählen';

  @override
  String get diaryClearSearch => 'Suche löschen';

  @override
  String get diaryClose => 'Schließen';

  @override
  String get diaryCopyTheNutritionValuesFromTheLabel =>
      'Übernimm die Nährwerte vom Etikett. Wir rechnen deine gegessene Menge automatisch aus.';

  @override
  String get diaryCustomEntry => 'Eigener Eintrag';

  @override
  String get diaryDay => 'Tag';

  @override
  String get diaryDelete => 'Löschen';

  @override
  String get diaryDeleteEntry => 'Eintrag löschen?';

  @override
  String get diaryDeleteEntry2 => 'Eintrag löschen';

  @override
  String get diaryDiary => 'Tagebuch';

  @override
  String get diaryDuplicate => 'Duplizieren';

  @override
  String get diaryEG05 => 'z. B. 0,5';

  @override
  String get diaryEG3017620422003 => 'z. B. 3017620422003';

  @override
  String get diaryEaten => 'Gegessen';

  @override
  String get diaryEditMeal => 'Mahlzeit bearbeiten';

  @override
  String get diaryEditRecipe => 'Rezept bearbeiten';

  @override
  String get diaryEditYourEntry => 'Deinen Eintrag bearbeiten';

  @override
  String get diaryEnergy => 'Energie';

  @override
  String get diaryEnterBarcode => 'Barcode eingeben';

  @override
  String get diaryEnterBarcodeManually => 'Barcode manuell eingeben';

  @override
  String get diaryEnterManually => 'Selbst eintragen';

  @override
  String get diaryEnterManually2 => 'Manuell eintragen';

  @override
  String get diaryEntryDeleted => 'Eintrag wurde gelöscht.';

  @override
  String get diaryFat => 'Fett';

  @override
  String get diaryFatG => 'Fett g';

  @override
  String get diaryFibre => 'Ballaststoffe';

  @override
  String get diaryFibreOptional => 'Ballaststoffe (optional)';

  @override
  String get diaryFindAPackagedProductUsingItsBarcode =>
      'Verpacktes Produkt über den Barcode finden';

  @override
  String get diaryFood => 'Lebensmittel';

  @override
  String get diaryFoodPhoto => 'Lebensmittel-Foto';

  @override
  String get diaryForExampleMyChocolateCereal =>
      'Zum Beispiel: Mein Schoko-Müsli';

  @override
  String get diaryForTheAmountYouAte => 'Für deine gegessene Menge';

  @override
  String get diaryForWhichMeal => 'Für welche Mahlzeit?';

  @override
  String get diaryFri => 'Fr';

  @override
  String get diaryFromSearch => 'Aus der Suche';

  @override
  String get diaryGallery => 'Galerie';

  @override
  String get diaryGreekYoghurt => 'Griechischer Joghurt';

  @override
  String get diaryHighInProtein => 'Proteinreich';

  @override
  String get diaryIngredientsList => 'Zutatenliste';

  @override
  String get diaryLeaveUnknownAdditionalValuesBlank =>
      'Unbekannte Zusatzwerte bleiben leer.';

  @override
  String get diaryLight => 'Leicht';

  @override
  String get diaryLightFoods => 'Leichte Lebensmittel';

  @override
  String get diaryLogAnyway => 'Trotzdem protokollieren';

  @override
  String get diaryLogInDiary => 'Ins Tagebuch eintragen';

  @override
  String get diaryMeal => 'Mahlzeit';

  @override
  String get diaryMealDuplicated => 'Mahlzeit wurde dupliziert.';

  @override
  String get diaryMealName => 'Name der Mahlzeit';

  @override
  String get diaryMealUpdated => 'Mahlzeit wurde aktualisiert.';

  @override
  String get diaryMeals => 'Mahlzeiten';

  @override
  String get diaryMon => 'Mo';

  @override
  String get diaryMoveMeal => 'Mahlzeit verschieben';

  @override
  String get diaryNewFood => 'Neues Lebensmittel';

  @override
  String get diaryNextWeek => 'Nächste Woche';

  @override
  String get diaryNoCameraIsAvailableOnThisDevice =>
      'Auf diesem Gerät ist keine Kamera verfügbar.';

  @override
  String get diaryNoCameraWasFound => 'Es wurde keine Kamera gefunden.';

  @override
  String get diaryNoFoodFoundYouCanAlsoLog =>
      'Kein Lebensmittel gefunden. Du kannst es auch über „Selbst hinzufügen“ eintragen.';

  @override
  String get diaryNoFoodsHaveBeenFoundInThis =>
      'In diesem Bereich wurden noch keine Lebensmittel gefunden.';

  @override
  String get diaryNoResultsCheckTheSpellingOrEnter =>
      'Kein Treffer. Prüfe die Schreibweise oder trage das Lebensmittel selbst ein.';

  @override
  String get diaryNothingSavedYetSaveFoodsFromTheir =>
      'Noch nichts gemerkt. Speichere Lebensmittel über die Detailansicht.';

  @override
  String get diaryNothingUsedYetFoodsYouAddWill =>
      'Noch nichts verwendet. Hinzugefügte Lebensmittel erscheinen später hier.';

  @override
  String get diaryNutrition => 'Nährwerte';

  @override
  String get diaryNutritionValuesApplyToTheAmountSelected =>
      'Nährwerte gelten für die oben eingestellte Menge.';

  @override
  String diaryNutritionValuesValue(String arg0) {
    return 'Nährwerte $arg0';
  }

  @override
  String get diaryOfWhichSaturates => 'davon gesättigte Fettsäuren';

  @override
  String get diaryOfWhichSugars => 'davon Zucker';

  @override
  String get diaryOnceYouEnterTheAmountEnergyAnd =>
      'Sobald Menge, Energie und Makros eingetragen sind, siehst du hier die Berechnung.';

  @override
  String get diaryPer100G => 'Pro 100 g';

  @override
  String get diaryPer100Ml => 'Pro 100 ml';

  @override
  String get diaryPerServing => 'Pro Portion';

  @override
  String get diaryPhotoAiCannotReliablyRecogniseHiddenAllergens =>
      'Die Foto-KI kann Allergene, die man nicht sieht, oder Spuren nicht zuverlässig erkennen. Zutatenliste und Verpackung selbst prüfen.';

  @override
  String get diaryPhotoFromGallery => 'Foto aus Galerie';

  @override
  String get diaryPhotographTheWholeMealClearlyFromAbove =>
      'Das ganze Essen gut sichtbar von oben aufnehmen.';

  @override
  String get diaryPleaseCheckBriefly => 'Bitte kurz prüfen';

  @override
  String get diaryPleaseCheckTheHighlightedFieldsAbove =>
      'Bitte prüfe die markierten Felder weiter oben.';

  @override
  String diaryPleaseCheckTheNutritionValuesForValue(String arg0) {
    return 'Bitte prüfe die Nährwerte von „$arg0“.';
  }

  @override
  String get diaryPleaseEnterANameAndValidPositive =>
      'Bitte Name und gültige, positive Werte eintragen.';

  @override
  String get diaryPleaseEnterAValidValueOf0 =>
      'Bitte einen gültigen Wert ab 0 eingeben.';

  @override
  String get diaryPleaseEnterAnAmountGreaterThan0 =>
      'Bitte eine Menge größer als 0 eingeben.';

  @override
  String diaryPleaseEnterAnAmountGreaterThan02(String arg0) {
    return 'Bitte gib für „$arg0“ eine Menge über 0 g an.';
  }

  @override
  String get diaryPleaseGiveEveryFoodAName =>
      'Bitte gib jedem Lebensmittel einen Namen.';

  @override
  String get diaryPleaseGiveYourFoodAName =>
      'Bitte deinem Lebensmittel einen Namen geben.';

  @override
  String get diaryPleaseUseNoMoreThan100Characters =>
      'Bitte höchstens 100 Zeichen verwenden.';

  @override
  String get diaryPleaseWaitAMomentBeforeSearchingFor =>
      'Bitte kurz warten, bevor du den nächsten Barcode suchst.';

  @override
  String get diaryPremiumFeature => 'Premium-Funktion';

  @override
  String get diaryPreviousWeek => 'Vorherige Woche';

  @override
  String get diaryProductInformation => 'Produktinfos';

  @override
  String get diaryProtein => 'Eiweiß / Protein';

  @override
  String get diaryProteinPasta => 'Protein-Pasta';

  @override
  String get diaryRecent => 'Zuletzt';

  @override
  String get diaryRecentlyUsed => 'Zuletzt verwendet';

  @override
  String get diaryRecogniseMeal => 'Mahlzeit erkennen';

  @override
  String get diaryRecognisedFoods => 'Erkannte Lebensmittel';

  @override
  String get diaryRecognisedWell => 'Gut erkannt';

  @override
  String get diaryRemaining => 'Übrig';

  @override
  String get diaryRemove => 'Entfernen';

  @override
  String get diaryRemoveFromSavedFoods => 'Von Merkliste entfernen';

  @override
  String get diarySalt => 'Salz';

  @override
  String get diarySat => 'Sa';

  @override
  String get diarySaturatedFat => 'gesättigte Fettsäuren';

  @override
  String get diarySaturatedFatCannotExceedTotalFat =>
      'Gesättigte Fettsäuren dürfen Fett nicht überschreiten.';

  @override
  String get diarySave => 'Speichern';

  @override
  String get diarySaveChanges => 'Änderungen speichern';

  @override
  String get diarySaveFood => 'Merken';

  @override
  String get diarySaved => 'Gemerkte';

  @override
  String get diarySavedFoods => 'Gemerkte Lebensmittel';

  @override
  String get diarySavedItemsRemoved =>
      'Bereits gespeicherte Einträge wurden aus der Liste entfernt.';

  @override
  String get diarySaving => 'Wird gespeichert …';

  @override
  String get diarySaving2 => 'Wird gespeichert ...';

  @override
  String get diarySavingDidNotWorkPleaseTryAgain =>
      'Das Speichern hat nicht geklappt. Bitte versuche es erneut.';

  @override
  String get diarySavingDidNotWorkYourInformationStays =>
      'Das Speichern hat nicht geklappt. Deine Angaben bleiben hier erhalten.';

  @override
  String get diarySavingFailedPleaseTryAgain =>
      'Speichern fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get diaryScanBarcode => 'Barcode scannen';

  @override
  String get diarySearch => 'Suchen';

  @override
  String get diarySearchFoods => 'Lebensmittel suchen';

  @override
  String get diarySearchForFoodsOrEnterThemYourself =>
      'Lebensmittel suchen oder selbst eintragen';

  @override
  String get diarySearchResults => 'Suchergebnisse';

  @override
  String get diarySearchingForProduct => 'Produkt wird gesucht ...';

  @override
  String get diarySelectMeal => 'Mahlzeit auswählen';

  @override
  String diaryServingBasis(int grams) {
    return 'BASIS: $grams G';
  }

  @override
  String get diaryServings => 'Portionen';

  @override
  String get diaryServingsEaten => 'Gegessene Portionen';

  @override
  String get diarySourceOpenFoodFactsInformationMayBe =>
      'Quelle: Open Food Facts. Angaben können fehlen oder sich ändern – bei Allergien und Unverträglichkeiten immer das Verpackungsetikett prüfen.';

  @override
  String get diarySugar => 'Zucker';

  @override
  String get diarySugarCannotExceedCarbohydrates =>
      'Zucker darf die Kohlenhydrate nicht überschreiten.';

  @override
  String get diarySun => 'So';

  @override
  String get diarySwitch => 'Wechseln';

  @override
  String get diaryTakeAMealPhoto => 'Mahlzeit fotografieren';

  @override
  String get diaryTakeANewPhoto => 'Neues Foto aufnehmen';

  @override
  String get diaryTakeAPhotoAiEstimatesFoodsAnd =>
      'Foto machen, KI schätzt Lebensmittel und Mengen';

  @override
  String get diaryTakeAPhotoOfYourMealAi =>
      'Fotografiere deine Mahlzeit – die KI schätzt Lebensmittel und Mengen.';

  @override
  String get diaryTakePhoto => 'Foto aufnehmen';

  @override
  String get diaryTapAFoodToChangeItsName =>
      'Tippe auf ein Lebensmittel, um Name und Nährwerte zu ändern. Wenn du die Menge änderst, passen sich Kalorien und Nährwerte automatisch an.';

  @override
  String diaryTheAvailableInformationMayMentionValueIf(String arg0) {
    return 'Die verfügbaren Angaben nennen möglicherweise: $arg0. Bei einer Allergie nicht als Empfehlung verstehen. Nur fortfahren, wenn du das Essen dokumentieren möchtest.';
  }

  @override
  String get diaryTheBarcodeCouldNotBeProcessedJust =>
      'Barcode konnte gerade nicht verarbeitet werden.';

  @override
  String get diaryTheCameraCouldNotBeStarted =>
      'Die Kamera konnte nicht gestartet werden.';

  @override
  String get diaryTheFoodCouldNotBeSaved =>
      'Das Lebensmittel konnte nicht gespeichert werden.';

  @override
  String get diaryTheLabelValuesBelowArePer100 =>
      'Unten stehen die Etikettwerte pro 100 g.';

  @override
  String get diaryTheLabelValuesBelowArePer1002 =>
      'Unten stehen die Etikettwerte pro 100 ml.';

  @override
  String get diaryTheMealCouldNotBeDuplicated =>
      'Die Mahlzeit konnte nicht dupliziert werden.';

  @override
  String get diaryTheMealCouldNotBeSaved =>
      'Die Mahlzeit konnte nicht gespeichert werden.';

  @override
  String diaryTheNameYouEnteredSuggestsAPossible(String arg0) {
    return 'Der eingegebene Name deutet auf einen möglichen Konflikt: $arg0. Die Nährwertangaben enthalten keine verlässliche Zutatenprüfung.';
  }

  @override
  String get diaryThePhotoCouldNotBeAnalysedJust =>
      'Das Foto konnte gerade nicht analysiert werden.';

  @override
  String get diaryThePhotoCouldNotBeTaken =>
      'Foto konnte nicht aufgenommen werden.';

  @override
  String diaryTheProductInformationMayMentionValueOnly(String arg0) {
    return 'Die Produktdaten nennen möglicherweise: $arg0. Nur fortfahren, wenn du das Lebensmittel bereits gegessen hast und es lediglich dokumentieren möchtest. Prüfe die Verpackung.';
  }

  @override
  String diaryTheRecognisedNamesMayMatchYourProfile(String arg0) {
    return 'Die erkannten Namen können zu deinem Profil passen: $arg0. KI-Fotos können versteckte Zutaten und Spuren nicht erkennen. Nur fortfahren, wenn du die Mahlzeit dokumentieren möchtest.';
  }

  @override
  String get diaryTheValuesBelowAreForAWhole =>
      'Unten stehen die Werte für eine ganze Portion. Eine halbe Portion ist 0,5.';

  @override
  String get diaryThisPhotoCouldNotBeRead =>
      'Dieses Foto konnte nicht gelesen werden.';

  @override
  String get diaryThisProductDoesNotMeetLookinS =>
      'Dieses Produkt entspricht nicht den Halal-Inhaltsregeln von Lookin.';

  @override
  String get diaryThisProductIsNotInTheData =>
      'Dieses Produkt ist noch nicht in der Datenquelle. Du kannst es selbst eintragen.';

  @override
  String get diaryThu => 'Do';

  @override
  String get diaryTotalKcal => 'kcal gesamt';

  @override
  String get diaryTryAgain => 'Erneut versuchen';

  @override
  String get diaryTue => 'Di';

  @override
  String get diaryUncertainPleaseCheck => 'Unsicher – bitte prüfen';

  @override
  String get diaryUnknown => 'Nicht bekannt';

  @override
  String diaryValueGCarbs(String arg0) {
    return '$arg0 g Kohlenhydrate';
  }

  @override
  String diaryValueGFat(String arg0) {
    return '$arg0 g Fett';
  }

  @override
  String diaryValueGProtein(String arg0) {
    return '$arg0 g Protein';
  }

  @override
  String diaryValueKcalCValueGPValue(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return '$arg0 kcal · K $arg1 g · P $arg2 g · F $arg3 g';
  }

  @override
  String diaryValueKcalValueGValueGProtein(
    String arg0,
    String arg1,
    String arg2,
  ) {
    return '$arg0 kcal · $arg1 g · $arg2 g Protein';
  }

  @override
  String diaryValueOf8Glasses(String arg0) {
    return '$arg0 von 8 Gläsern';
  }

  @override
  String diaryValueValuePValueCValueF(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return '$arg0$arg1 P · $arg2 K · $arg3 F';
  }

  @override
  String diaryValueWasAdded(String arg0) {
    return '$arg0 wurde hinzugefügt.';
  }

  @override
  String diaryValueWillBeRemovedFromYourDiary(String arg0) {
    return '„$arg0“ wird aus deinem Tagebuch entfernt.';
  }

  @override
  String get diaryVegetableOmelette => 'Gemüse-Omelett';

  @override
  String get diaryViewPremium => 'Premium ansehen';

  @override
  String get diaryWater => 'Wasser';

  @override
  String get diaryWed => 'Mi';

  @override
  String get diaryWhatDoTheValuesReferTo => 'Worauf beziehen sich die Werte?';

  @override
  String get diaryWhichMeal => 'Zu welcher Mahlzeit?';

  @override
  String get diaryWholemealBreadWithEgg => 'Vollkornbrot mit Ei';

  @override
  String get diaryYouAreAboveYourDailyTargetThis =>
      'Du liegst über deinem Tagesziel. Das ist eine Orientierung, keine Bewertung.';

  @override
  String get diaryYouCanChangeTheMealTypeIngredients =>
      'Die Mahlzeitenart kann angepasst werden. Zutaten und Werte bleiben mit dem Rezept verbunden.';

  @override
  String get diaryYourCustomFood => 'Dein eigenes Lebensmittel';

  @override
  String get diaryYourMeal => 'Deine Mahlzeit';

  @override
  String get diaryYourMealRhythm => 'Dein Mahlzeitenrhythmus';

  @override
  String get diaryYourMealsClearlyOrganisedAndEasyTo =>
      'Deine Mahlzeiten klar und ohne unnötigen Aufwand.';

  @override
  String get diaryYourPreferenceNotARequirementYouCan =>
      'Dein Wunsch, kein Muss. Du kannst jederzeit weitere Mahlzeiten eintragen.';

  @override
  String get diaryYourPreviousValuesApplyToOneServing =>
      'Deine bisherigen Werte gelten für eine Portion. Fehlende Etikettwerte kannst du ergänzen.';

  @override
  String get discover1Ingredient => '1 Zutat';

  @override
  String get discover1IngredientMissing => '1 Zutat fehlt';

  @override
  String get discover1Recipe => '1 Rezept';

  @override
  String discover1ServingIsNowListedUnderValue(String arg0) {
    return '1 Portion steht jetzt unter „$arg0“ im Tagebuch.';
  }

  @override
  String discover1ServingValueKcalValueGProtein(String arg0, String arg1) {
    return '1 Portion · $arg0 kcal · $arg1 g Protein';
  }

  @override
  String get discover1Step => '1 Schritt';

  @override
  String get discoverAdaptToMyTarget => 'An mein Ziel anpassen';

  @override
  String discoverAdaptToMyTargetValue(String arg0) {
    return 'An mein Ziel anpassen · $arg0';
  }

  @override
  String get discoverAddIngredient => 'Zutat hinzufügen';

  @override
  String get discoverAddToFavourites => 'Zu Favoriten hinzufügen';

  @override
  String get discoverAll => 'Alle';

  @override
  String get discoverAllRecipes => 'Alle Rezepte';

  @override
  String discoverAllergyLogWarning(String conflicts) {
    return 'Die Zutatenangaben nennen möglicherweise: $conflicts. Prüfe die Packungen und mögliche Kreuzkontamination. Möchtest du das Rezept trotzdem protokollieren?';
  }

  @override
  String get discoverAllergyNotice => 'Allergiehinweis';

  @override
  String get discoverAny => 'Egal';

  @override
  String get discoverApples => 'Äpfel';

  @override
  String get discoverApply => 'Übernehmen';

  @override
  String discoverApproxValue(String arg0) {
    return 'ca. $arg0';
  }

  @override
  String discoverApproxValueKcal(String arg0) {
    return 'ca. $arg0 kcal';
  }

  @override
  String discoverApproxValueValueProtein(String arg0, String arg1) {
    return 'ca. $arg0 · $arg1 Protein';
  }

  @override
  String get discoverAsInTheOriginalRecipe => 'wie im Originalrezept';

  @override
  String get discoverBack => 'Zurück';

  @override
  String get discoverBag => 'Beutel';

  @override
  String get discoverBalls => 'Kugeln';

  @override
  String get discoverBananas => 'Bananen';

  @override
  String discoverBasedOnValueMealsADayWith(String arg0, String arg1) {
    return 'Grundlage: $arg0 Mahlzeiten am Tag, davon $arg1 schon im Tagebuch. Das ist eine Schätzung zur Orientierung und keine Ernährungsberatung – hör auch auf deinen Hunger. „Übernehmen“ rechnet nur die Zutatenmengen um; ins Tagebuch wird weiterhin 1 Portion eingetragen.';
  }

  @override
  String get discoverBasicIngredients => 'Grundzutaten';

  @override
  String get discoverBasicIngredientsAreAvailable =>
      'Grundzutaten sind vorhanden';

  @override
  String get discoverBreadRoll => 'Brötchen';

  @override
  String get discoverBulbs => 'Knollen';

  @override
  String get discoverBunch => 'Bund';

  @override
  String get discoverCalculatedFromTheIngredientsValuesMayVary =>
      'Berechnet aus den Zutaten. Je nach Produkt und Zubereitung können die Werte abweichen.';

  @override
  String get discoverCancel => 'Abbrechen';

  @override
  String get discoverCarbohydrates => 'Kohlenhydrate';

  @override
  String get discoverCarrots => 'Karotten';

  @override
  String get discoverCarrots2 => 'Möhren';

  @override
  String get discoverChillies => 'Chilischoten';

  @override
  String get discoverClearSearch => 'Suche löschen';

  @override
  String get discoverClose => 'Schließen';

  @override
  String get discoverCloves => 'Zehen';

  @override
  String get discoverCommonIngredients => 'Häufige Zutaten';

  @override
  String get discoverCommonMistakes => 'Häufige Fehler';

  @override
  String get discoverContinue => 'Weiter';

  @override
  String get discoverCooking => 'Kochen';

  @override
  String discoverCookingModeValue(String arg0) {
    return 'Kochmodus · $arg0';
  }

  @override
  String get discoverCookingModeWithTimers => 'Kochmodus mit Timern';

  @override
  String get discoverCube => 'Würfel';

  @override
  String get discoverCucumbers => 'Gurken';

  @override
  String get discoverCups => 'Tassen';

  @override
  String get discoverDash => 'Spritzer';

  @override
  String get discoverDifficulty => 'Schwierigkeit';

  @override
  String get discoverDone => 'Fertig';

  @override
  String discoverDurationValue(String arg0) {
    return 'Dauer $arg0';
  }

  @override
  String get discoverEggs => 'Eier';

  @override
  String get discoverEnergy => 'Energie';

  @override
  String get discoverEnergyShare => 'Anteil an der Energie';

  @override
  String get discoverEnjoyYourMeal => 'Guten Appetit!';

  @override
  String get discoverEnterAnIngredientEGPotatoes =>
      'Zutat eingeben, z. B. Kartoffeln';

  @override
  String get discoverEquipment => 'Utensilien';

  @override
  String get discoverEverythingAvailable => 'Alles da';

  @override
  String get discoverExit => 'Beenden';

  @override
  String get discoverExitCookingMode => 'Kochmodus beenden?';

  @override
  String get discoverExitCookingMode2 => 'Kochmodus beenden';

  @override
  String get discoverExtraKnowledgeAboutThisRecipe =>
      'Extra-Wissen zu diesem Rezept.';

  @override
  String get discoverFat => 'Fett';

  @override
  String get discoverFavourites => 'Favoriten';

  @override
  String get discoverFibre => 'Ballaststoffe';

  @override
  String get discoverFillets => 'Filets';

  @override
  String get discoverFiltersAndSorting => 'Filter und Sortierung';

  @override
  String discoverFiltersAndSortingValueActive(String arg0) {
    return 'Filter und Sortierung, $arg0 aktiv';
  }

  @override
  String get discoverFiltersSorting => 'Filter & Sortierung';

  @override
  String get discoverFlatbreads => 'Fladenbrote';

  @override
  String get discoverForThisMeal => 'Für diese Mahlzeit';

  @override
  String discoverForValue(String arg0) {
    return 'für $arg0';
  }

  @override
  String get discoverForYou => 'Für dich';

  @override
  String get discoverGlasses => 'Gläser';

  @override
  String discoverGoToStepValue(String arg0) {
    return 'Zu Schritt $arg0';
  }

  @override
  String get discoverGuidelineValues => 'Richtwerte';

  @override
  String get discoverHandful => 'Handvoll';

  @override
  String discoverHiddenForAllergies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte',
      one: '1 Rezept',
    );
    return '$_temp0 wegen deiner Allergieangaben ausgeblendet.';
  }

  @override
  String get discoverHowThisSuggestionWasCalculated =>
      'So ist der Vorschlag entstanden';

  @override
  String get discoverIHaveThese => 'Das habe ich da';

  @override
  String get discoverIdeasThatFitYourGoalAndYour =>
      'Ideen, die zu deinem Ziel und deinem Alltag passen.';

  @override
  String get discoverIngredientAmountsHaveNotBeenAddedFor =>
      'Für dieses Rezept sind noch keine Zutatenmengen hinterlegt.';

  @override
  String get discoverIngredientSubstitutions => 'Austausch-Zutaten';

  @override
  String get discoverIngredients => 'Zutaten';

  @override
  String get discoverKeepCooking => 'Weiterkochen';

  @override
  String get discoverLeaves => 'Blätter';

  @override
  String get discoverLemons => 'Zitronen';

  @override
  String get discoverLimes => 'Limetten';

  @override
  String get discoverLog => 'Eintragen';

  @override
  String get discoverLog1ServingInDiary => '1 Portion zum Tagebuch';

  @override
  String get discoverLogAnyway => 'Trotzdem protokollieren';

  @override
  String get discoverLoggedToday => 'Heute eingetragen';

  @override
  String get discoverMatchingRecipes => 'Passende Rezepte';

  @override
  String get discoverMaximumPreparationTime => 'Maximale Zubereitungszeit';

  @override
  String get discoverMealPrepStorage => 'Meal-Prep & Aufbewahrung';

  @override
  String get discoverMealsStillToComeToday =>
      'Mahlzeiten, die heute noch kommen';

  @override
  String get discoverMethod => 'Zubereitung';

  @override
  String get discoverMissing => 'Fehlt';

  @override
  String discoverMissingNutrition(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zutaten haben keine Katalogwerte und fehlen hier.',
      one: '1 Zutat hat keine Katalogwerte und fehlt hier.',
    );
    return 'Pro Portion, aus den Katalogwerten der Zutaten. $_temp0';
  }

  @override
  String get discoverMoreKnowledgeForEveryRecipe =>
      'Mehr Wissen zu jedem Rezept';

  @override
  String get discoverNoInstructionsHaveBeenAddedForThis =>
      'Für dieses Rezept ist noch keine Anleitung hinterlegt.';

  @override
  String get discoverNoMatchingRecipes => 'Keine passenden Rezepte';

  @override
  String get discoverNoRecipeFoundWithTheseIngredients =>
      'Kein Rezept mit diesen Zutaten gefunden.';

  @override
  String get discoverNoRecipeMatchesYourSelection =>
      'Kein Rezept passt zu deiner Auswahl.';

  @override
  String get discoverNoSteps => 'Keine Schritte';

  @override
  String get discoverNotNow => 'Jetzt nicht';

  @override
  String get discoverNotSpecified => 'keine Angabe';

  @override
  String get discoverNutrition => 'Nährwerte';

  @override
  String get discoverOneServingLess => 'Eine Portion weniger';

  @override
  String get discoverOneServingMore => 'Eine Portion mehr';

  @override
  String get discoverOneStepPerPageLargeTextAnd =>
      'Ein Schritt pro Seite, große Schrift und Timer.';

  @override
  String get discoverOnions => 'Zwiebeln';

  @override
  String get discoverOpenTimerInCookingMode => 'Timer im Kochmodus öffnen';

  @override
  String get discoverOriginalAmount => 'Originalmenge';

  @override
  String get discoverPack => 'Pck.';

  @override
  String get discoverPack2 => 'Pkg.';

  @override
  String get discoverPacks => 'Packungen';

  @override
  String get discoverPause => 'Pausieren';

  @override
  String get discoverPaused => 'Pausiert';

  @override
  String get discoverPeppers => 'Paprika';

  @override
  String get discoverPerServing => 'pro Portion';

  @override
  String discoverPerServingBasedOnIngredientCatalogueValues(
    String arg0,
    String arg1,
  ) {
    return 'Pro Portion, aus den Katalogwerten der Zutaten. $arg0 $arg1 keine Katalogwerte und fehlt hier.';
  }

  @override
  String get discoverPerServingBasedOnIngredientCatalogueValues2 =>
      'Pro Portion, aus den Katalogwerten der Zutaten.';

  @override
  String get discoverPiece => 'Stk.';

  @override
  String get discoverPiece2 => 'Stück';

  @override
  String get discoverPinch => 'Msp.';

  @override
  String get discoverPinches => 'Prisen';

  @override
  String get discoverPinches2 => 'Messerspitzen';

  @override
  String get discoverPods => 'Schoten';

  @override
  String get discoverPot => 'Becher';

  @override
  String get discoverPotatoes => 'Kartoffeln';

  @override
  String get discoverPreparation => 'Vorbereitung';

  @override
  String get discoverProTip => 'Profi-Tipp: ';

  @override
  String get discoverProTipsForEveryStep => 'Profi-Tipps zu jedem Schritt';

  @override
  String get discoverQuickUnder15Min => 'Schnell unter 15 Min.';

  @override
  String get discoverRecipes => 'Rezepte';

  @override
  String get discoverRecipesUsingWhatYouHaveAtHome =>
      'Rezepte mit dem, was du zu Hause hast';

  @override
  String get discoverRemaining => 'Noch offen';

  @override
  String get discoverRemoveFromFavourites => 'Aus Favoriten entfernen';

  @override
  String discoverRemoveValue(String arg0) {
    return '$arg0 entfernen';
  }

  @override
  String discoverRemoveValue2(String arg0) {
    return '„$arg0“ entfernen';
  }

  @override
  String get discoverReset => 'Zurücksetzen';

  @override
  String get discoverResetAllFilters => 'Alle Filter zurücksetzen';

  @override
  String get discoverRestart => 'Neu starten';

  @override
  String get discoverResume => 'Fortsetzen';

  @override
  String get discoverRoughGuidelineValuesACompleteCalculationBased =>
      'Grobe Richtwerte. Eine vollständige Berechnung aus den Zutaten liegt für dieses Rezept noch nicht vor.';

  @override
  String get discoverRunning => 'Läuft';

  @override
  String get discoverRunningTimersWillBeStopped =>
      'Laufende Timer werden dabei gestoppt.';

  @override
  String get discoverSalt => 'Salz';

  @override
  String get discoverSaving => 'Wird gespeichert …';

  @override
  String get discoverSearchRecipesOrIngredients =>
      'Rezepte oder Zutaten suchen';

  @override
  String get discoverSelectWhatYouHaveAtHomeLookin =>
      'Wähle, was du zu Hause hast. Lookin zeigt Rezepte mit diesen Zutaten – die mit den wenigsten fehlenden zuerst.';

  @override
  String get discoverServing => 'Portion';

  @override
  String get discoverServingSuggestion => 'Serviervorschlag';

  @override
  String get discoverServingUnit => 'Portion';

  @override
  String get discoverServings => 'Portionen';

  @override
  String get discoverServingsUnit => 'Portionen';

  @override
  String get discoverShow => 'Zeigen';

  @override
  String get discoverShow1Recipe => '1 Rezept anzeigen';

  @override
  String get discoverShowIngredients => 'Zutaten anzeigen';

  @override
  String discoverShowValueRecipes(String arg0) {
    return '$arg0 Rezepte anzeigen';
  }

  @override
  String get discoverSlices => 'Scheiben';

  @override
  String get discoverSortBy => 'Sortieren nach';

  @override
  String discoverSortedByValue(String arg0) {
    return 'Sortiert: $arg0';
  }

  @override
  String discoverSortedForYouByValueSortingDoes(String arg0) {
    return 'Für dich sortiert nach $arg0. Die Sortierung blendet keine Rezepte aus.';
  }

  @override
  String discoverSpokenMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String discoverSpokenSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sekunden',
      one: '1 Sekunde',
    );
    return '$_temp0';
  }

  @override
  String get discoverSprigs => 'Zweige';

  @override
  String get discoverSpringOnions => 'Frühlingszwiebeln';

  @override
  String get discoverStartCookingMode => 'Kochmodus starten';

  @override
  String get discoverStartTimer => 'Timer starten';

  @override
  String discoverStepValue(String arg0) {
    return 'Schritt $arg0';
  }

  @override
  String discoverStepValueOfValue(String arg0, String arg1) {
    return 'Schritt $arg0 von $arg1';
  }

  @override
  String discoverStepValueTimeIsUp(String arg0) {
    return 'Schritt $arg0 · Zeit ist um';
  }

  @override
  String discoverStepValueValue(String arg0, String arg1) {
    return 'Schritt $arg0 · $arg1';
  }

  @override
  String get discoverSticks => 'Stangen';

  @override
  String get discoverSubstitutions => 'Austausch-Möglichkeiten';

  @override
  String get discoverSugar => 'Zucker';

  @override
  String get discoverSuggestion => 'Vorschlag';

  @override
  String get discoverSuggestionEstimate => 'VORSCHLAG · SCHÄTZUNG';

  @override
  String get discoverSweetPotatoes => 'Süßkartoffeln';

  @override
  String get discoverTapACommonIngredientOrEnterOne =>
      'Tippe auf eine häufige Zutat oder gib selbst etwas ein, zum Beispiel „Kartoffeln“.';

  @override
  String get discoverTbsp => 'EL';

  @override
  String discoverTheIngredientInformationMayMentionValueCheck(
    String arg0,
    String arg1,
  ) {
    return 'Die Zutatenangaben nennen möglicherweise: $arg0. Prüfe die Packungen und mögliche Kreuzkontamination. Möchtest du das Rezept trotzdem $arg1?';
  }

  @override
  String get discoverTheRecipeCouldNotBeLogged =>
      'Das Rezept konnte nicht eingetragen werden.';

  @override
  String get discoverTheServingCalculatorAndAllNutritionValues =>
      'Den Portionsrechner und alle Nährwerte kannst du weiterhin kostenlos nutzen.';

  @override
  String get discoverThingsToWatch => 'Darauf achten';

  @override
  String get discoverThisServingSizeIsASuggestionTo =>
      'Damit dieses Rezept gut zu deinem heutigen Tagesziel passt, wäre diese Portionsgröße ein Vorschlag:';

  @override
  String get discoverTickWhatYouAlreadyHaveTicksOnly =>
      'Hake ab, was du schon da hast. Die Haken gelten nur, solange dieses Rezept geöffnet ist.';

  @override
  String get discoverTimeIsUp => 'Zeit ist um!';

  @override
  String discoverTimeIsUpForStepValue(String arg0) {
    return 'Die Zeit für Schritt $arg0 ist um.';
  }

  @override
  String discoverTimeRemainingValue(String arg0) {
    return 'Verbleibende Zeit: $arg0';
  }

  @override
  String get discoverTins => 'Dosen';

  @override
  String get discoverTomatoes => 'Tomaten';

  @override
  String get discoverTotalTime => 'Gesamtzeit';

  @override
  String get discoverTryAnotherIngredientOrADifferentName =>
      'Probiere eine weitere Zutat oder einen anderen Namen, zum Beispiel „Nudeln“ statt „Spaghetti“.';

  @override
  String get discoverTryAnotherSearchTermOrRemoveA =>
      'Probiere einen anderen Suchbegriff oder entferne einen Filter.';

  @override
  String discoverTryValue(String arg0) {
    return '$arg0 testen';
  }

  @override
  String discoverTryValueFreeForValueDays(String arg0, String arg1) {
    return '$arg0 $arg1 Tage kostenlos testen';
  }

  @override
  String get discoverTsp => 'TL';

  @override
  String get discoverTubes => 'Tuben';

  @override
  String discoverUpToValueMin(String arg0) {
    return 'bis $arg0 Min.';
  }

  @override
  String discoverValueAnyway(String arg0) {
    return 'Trotzdem $arg0';
  }

  @override
  String discoverValueGProtein(String arg0) {
    return '$arg0 g Protein';
  }

  @override
  String discoverValueHiddenBecauseOfYourAllergyInformation(String arg0) {
    return '$arg0 wegen deiner Allergieangaben ausgeblendet.';
  }

  @override
  String discoverValueHr(String arg0) {
    return '$arg0 Std.';
  }

  @override
  String discoverValueHrValueMin(String arg0, String arg1) {
    return '$arg0 Std. $arg1 Min.';
  }

  @override
  String discoverValueIngredients(String arg0) {
    return '$arg0 Zutaten';
  }

  @override
  String discoverValueIngredientsMissing(String arg0) {
    return '$arg0 Zutaten fehlen';
  }

  @override
  String discoverValueKcalValueGProtein(String arg0, String arg1) {
    return '$arg0 kcal · $arg1 g Protein';
  }

  @override
  String discoverValueMin(String arg0) {
    return '$arg0 Min.';
  }

  @override
  String discoverValueOfValueAvailable(String arg0, String arg1) {
    return '$arg0 von $arg1 da';
  }

  @override
  String discoverValueOfValueIngredientsAvailable(String arg0, String arg1) {
    return '$arg0 von $arg1 Zutaten vorhanden';
  }

  @override
  String discoverValueRecipes(String arg0) {
    return '$arg0 Rezepte';
  }

  @override
  String discoverValueSteps(String arg0) {
    return '$arg0 Schritte';
  }

  @override
  String discoverValueValueProtein(String arg0, String arg1) {
    return '$arg0 · $arg1 Protein';
  }

  @override
  String get discoverVariations => 'Variationen';

  @override
  String discoverViewValue(String arg0) {
    return '$arg0 ansehen';
  }

  @override
  String get discoverWhatCanICook => 'Was kann ich kochen?';

  @override
  String get discoverWhatDoYouHaveAtHome => 'Was hast du zu Hause?';

  @override
  String get discoverWhereDoTheNutritionValuesComeFrom =>
      'Woher kommen die Nährwerte?';

  @override
  String get discoverWhichMeal => 'Zu welcher Mahlzeit?';

  @override
  String discoverWithValueLookinSuggestsAServingSize(String arg0) {
    return 'Mit $arg0 schlägt dir Lookin eine Portionsgröße vor, die zu deinem heutigen Tagesziel passt – geschätzt aus deinem Tagebuch. Die Zutatenmengen werden dafür automatisch umgerechnet.';
  }

  @override
  String discoverYouCanCookThisEntireRecipeFor(String arg0) {
    return 'Dieses Rezept kannst du komplett kostenlos nachkochen. $arg0 ergänzt:';
  }

  @override
  String get discoverYouHave => 'Hast du';

  @override
  String get discoverYouHaveNoFavouritesYetTapA =>
      'Du hast noch keine Favoriten. Tippe auf das Herz eines Rezepts, um es dir zu merken.';

  @override
  String get discoverYourDailyTarget => 'Dein Tagesziel';

  @override
  String get discoverYourDiaryShowsYouHaveAlreadyReached =>
      'Laut deinem Tagebuch ist dein Tagesziel heute schon erreicht. Wenn du Hunger hast, ist eine kleinere Portion eine Möglichkeit.';

  @override
  String get display1Fillet => '1 Filet';

  @override
  String get display1Year => '1 Jahr';

  @override
  String get display30Days => '30 Tage';

  @override
  String get display3Months => '3 Monate';

  @override
  String get display45MinutesOrMore => '45 Minuten und mehr';

  @override
  String get display6Months => '6 Monate';

  @override
  String get display7Days => '7 Tage';

  @override
  String get displayAConditionRequiringMedicalGuidanceOnNutrition =>
      'Erkrankung, bei der die Ernährung ärztlich begleitet wird';

  @override
  String get displayAQuickAfterWorkMeal => 'Schnelles Feierabendgericht';

  @override
  String get displayAbout30Minutes => 'Etwa 30 Minuten';

  @override
  String get displayActive => 'Aktiv';

  @override
  String get displayAddTheTopping => 'Toppen';

  @override
  String get displayAllTime => 'Alles';

  @override
  String get displayAllspice => 'Piment';

  @override
  String get displayAlmondFlour => 'Mandelmehl';

  @override
  String get displayAlmondMilk => 'Mandelmilch';

  @override
  String get displayApple => 'Apfel';

  @override
  String get displayApril => 'April';

  @override
  String get displayAubergine => 'Melanzani';

  @override
  String get displayAubergine2 => 'Aubergine';

  @override
  String get displayAugust => 'August';

  @override
  String get displayBalance => 'BALANCE';

  @override
  String get displayBall => 'Kugel';

  @override
  String get displayBanana => 'Banane';

  @override
  String get displayBasil => 'Basilikum';

  @override
  String get displayBasilLeaves => 'Basilikumblätter';

  @override
  String get displayBayLeaf => 'Lorbeerblatt';

  @override
  String get displayBayLeaf2 => 'Lorbeer';

  @override
  String get displayBayLeaves => 'Lorbeerblätter';

  @override
  String get displayBeARoleModelForFamilyChildren =>
      'Vorbild für Familie & Kinder';

  @override
  String get displayBeef => 'Rind';

  @override
  String get displayBetterHabits => 'Bessere Gewohnheiten';

  @override
  String get displayBreadcrumbs => 'Paniermehl';

  @override
  String get displayBreakfastInEightMinutes => 'Frühstück in acht Minuten';

  @override
  String get displayBringPlentyOfWaterWith1Tsp =>
      'Reichlich Wasser mit 1 TL Salz aufkochen und die Pasta nach Packungsangabe bissfest garen.';

  @override
  String get displayBrusselsSprouts => 'Rosenkohl';

  @override
  String get displayBulb => 'Knolle';

  @override
  String get displayButtermilk => 'Buttermilch';

  @override
  String get displayCaraway => 'Kümmel';

  @override
  String get displayCarrot => 'Möhre';

  @override
  String get displayCarrot2 => 'Karotte';

  @override
  String get displayCarrot3 => 'Mohrrübe';

  @override
  String get displayCarrot4 => 'Rübli';

  @override
  String get displayCauliflower => 'Karfiol';

  @override
  String get displayCauliflower2 => 'Blumenkohl';

  @override
  String get displayCelery => 'Sellerie';

  @override
  String get displayCerealsContainingGluten => 'Glutenhaltiges Getreide';

  @override
  String get displayChallenging => 'Anspruchsvoll';

  @override
  String get displayCheese => 'Käse';

  @override
  String get displayChicken => 'Hähnchen';

  @override
  String get displayChicken2 => 'Hühnchen';

  @override
  String get displayChicken3 => 'Huhn';

  @override
  String get displayChicken4 => 'Hendl';

  @override
  String get displayChickpea => 'Kichererbse';

  @override
  String get displayChickpeaFlour => 'Kichererbsenmehl';

  @override
  String get displayChickpeas => 'Kichererbsen';

  @override
  String get displayChilli => 'Chilischote';

  @override
  String get displayChilliFlakes => 'Chiliflocken';

  @override
  String get displayChilliPowder => 'Chilipulver';

  @override
  String get displayCinnamon => 'Zimt';

  @override
  String get displayCinnamonStick => 'Zimtstange';

  @override
  String get displayClove => 'Nelke';

  @override
  String get displayClove2 => 'Zehe';

  @override
  String get displayCocoaButter => 'Kakaobutter';

  @override
  String get displayCoconut => 'Kokosnuss';

  @override
  String get displayCoconutCream => 'Kokossahne';

  @override
  String get displayCoconutFlour => 'Kokosmehl';

  @override
  String get displayCoconutMilk => 'Kokosmilch';

  @override
  String get displayCoconutWater => 'Kokoswasser';

  @override
  String get displayCoconutYoghurt => 'Kokosjoghurt';

  @override
  String get displayCombine => 'Vermengen';

  @override
  String get displayCondensedMilk => 'Kondensmilch';

  @override
  String get displayConnectingToYourDiaryDidNotWork =>
      'Die Verbindung zu deinem Tagebuch hat gerade nicht geklappt. Bitte prüfe dein Internet und versuche es erneut.';

  @override
  String get displayCookThePasta => 'Pasta kochen';

  @override
  String get displayCottageCheese => 'Hüttenkäse';

  @override
  String get displayCourgette => 'Zucchetti';

  @override
  String get displayCourgette2 => 'Zucchini';

  @override
  String get displayCravingsSnacking => 'Heißhunger & Naschen';

  @override
  String get displayCream => 'Rahm';

  @override
  String get displayCream2 => 'Sahne';

  @override
  String get displayCream3 => 'Obers';

  @override
  String get displayCreamCheese => 'Frischkäse';

  @override
  String get displayCreamyProteinPasta => 'Cremige Protein-Pasta';

  @override
  String get displayCrustaceans => 'Krebstiere';

  @override
  String get displayCucumber => 'Gurke';

  @override
  String get displayCumin => 'Kreuzkümmel';

  @override
  String get displayCup => 'Tasse';

  @override
  String get displayCurryPowder => 'Currypulver';

  @override
  String get displayDrainThePastaMixWithTheSauce =>
      'Pasta abgießen, mit der Sauce vermengen und mit Pfeffer abschmecken.';

  @override
  String get displayEasy => 'Einfach';

  @override
  String get displayEatHealthier => 'Gesünder ernähren';

  @override
  String get displayEatHealthier2 => 'Gesünder essen';

  @override
  String get displayEatingDisorderCurrentOrPast =>
      'Essstörung – aktuell oder früher';

  @override
  String get displayEatingWhenStressed => 'Essen bei Stress';

  @override
  String get displayEgg => 'Ei';

  @override
  String get displayEggWhite => 'Eiklar';

  @override
  String get displayEggYolk => 'Eigelb';

  @override
  String get displayEntriesPlural => 'Einträge';

  @override
  String get displayEntrySingular => 'Eintrag';

  @override
  String get displayFeelBetterInMyBody => 'Wohler im eigenen Körper';

  @override
  String get displayFemale => 'Weiblich';

  @override
  String get displayFewestCalories => 'Wenigste kcal';

  @override
  String get displayFillet => 'Filet';

  @override
  String get displayFillingFreshAndRichInProtein =>
      'Sättigend, frisch und proteinreich';

  @override
  String get displayFish => 'Fisch';

  @override
  String get displayFishNoMeat => 'Mit Fisch, ohne Fleisch';

  @override
  String get displayFlatbread => 'Fladenbrot';

  @override
  String get displayFlour => 'Mehl';

  @override
  String get displayGarlic => 'Knoblauch';

  @override
  String get displayGarlicClove => 'Knoblauchzehe';

  @override
  String get displayGarlicPowder => 'Knoblauchpulver';

  @override
  String get displayGentle => 'Sanft';

  @override
  String get displayGinger => 'Ingwerknolle';

  @override
  String get displayGinger2 => 'Ingwer';

  @override
  String get displayGingerPowder => 'Ingwerpulver';

  @override
  String get displayGingerRoot => 'Ingwerwurzel';

  @override
  String get displayGlass => 'Glas';

  @override
  String get displayHerbesDeProvence => 'Kräuter der Provence';

  @override
  String get displayImproveMyFitness => 'Sportlich stärker werden';

  @override
  String get displayIngredientSingular => 'Zutat';

  @override
  String get displayIngredientsPlural => 'Zutaten';

  @override
  String get displayIrregularMeals => 'Unregelmäßige Mahlzeiten';

  @override
  String get displayItVaries => 'Mal so, mal so';

  @override
  String get displayItalianHerbs => 'Italienische Kräuter';

  @override
  String get displayKale => 'Grünkohl';

  @override
  String get displayLactoseIntolerance => 'Laktose (Unverträglichkeit)';

  @override
  String get displayLeaf => 'Blatt';

  @override
  String get displayLeek => 'Porree';

  @override
  String get displayLeek2 => 'Lauch';

  @override
  String get displayLemon => 'Zitrone';

  @override
  String get displayLemonJuice => 'Zitronensaft';

  @override
  String get displayLemongrass => 'Zitronengras';

  @override
  String get displayLentil => 'Linse';

  @override
  String get displayLentils => 'Linsen';

  @override
  String get displayLime => 'Limette';

  @override
  String get displayLimeJuice => 'Limettensaft';

  @override
  String get displayLittleTimeToCook => 'Wenig Zeit zum Kochen';

  @override
  String get displayLiveHealthier => 'Gesünder leben';

  @override
  String get displayLookinCoachPremium => 'LOOKIN COACH · PREMIUM';

  @override
  String get displayLupin => 'Lupinen';

  @override
  String get displayMale => 'Männlich';

  @override
  String get displayMarjoram => 'Majoran';

  @override
  String get displayMeatFromLandAnimalsIsOnlyIncluded =>
      'Fleisch von Landtieren wird nur mit eindeutiger Halal-Kennzeichnung aufgenommen.';

  @override
  String get displayMedium => 'Mittel';

  @override
  String get displayMilk => 'Milch';

  @override
  String get displayMint => 'Minze';

  @override
  String get displayMintLeaves => 'Minzblätter';

  @override
  String get displayMixTheOatsWith80MlOf =>
      'Haferflocken mit 80 ml Wasser verrühren und 3 Minuten quellen lassen.';

  @override
  String get displayMixTheSauce => 'Sauce rühren';

  @override
  String get displayMixed => 'Gemischt';

  @override
  String get displayMolluscs => 'Weichtiere';

  @override
  String get displayMoreConsistency => 'Mehr Regelmäßigkeit';

  @override
  String get displayMoreEnergyDayToDay => 'Mehr Energie im Alltag';

  @override
  String get displayMostProtein => 'Meistes Protein';

  @override
  String get displayMostlySeated => 'Meist sitzend';

  @override
  String get displayMotivationDoesNotLast => 'Motivation hält nicht lange';

  @override
  String get displayMushroom => 'Champignon';

  @override
  String get displayMushroom2 => 'Pilz';

  @override
  String get displayMushrooms => 'Champignons';

  @override
  String get displayMustard => 'Senf';

  @override
  String get displayNever => 'Noch nie';

  @override
  String get displayNewMealIdeas => 'Neue Essensideen';

  @override
  String get displayNonStickFryingPan => 'Beschichtete Pfanne';

  @override
  String get displayNovember => 'November';

  @override
  String get displayNutmeg => 'Muskatnuss';

  @override
  String get displayNutmeg2 => 'Muskat';

  @override
  String get displayNuts => 'Nüsse';

  @override
  String get displayOatCream => 'Hafersahne';

  @override
  String get displayOatMilk => 'Hafermilch';

  @override
  String get displayOats => 'Haferflocken';

  @override
  String get displayOats2 => 'Hafer';

  @override
  String get displayOftenEatOnTheGo => 'Viel unterwegs essen';

  @override
  String get displayOftenOnTheMove => 'Viel in Bewegung';

  @override
  String get displayOil => 'Öl';

  @override
  String get displayOnion => 'Zwiebel';

  @override
  String get displayOnionPowder => 'Zwiebelpulver';

  @override
  String get displayOpenProfile => 'Profil öffnen';

  @override
  String get displayPack => 'Packung';

  @override
  String get displayPanFryTheSalmon => 'Lachs braten';

  @override
  String get displayPaprika => 'Paprikapulver';

  @override
  String get displayPasta => 'Nudeln';

  @override
  String get displayPasta2 => 'Nudel';

  @override
  String get displayPatTheSalmonDryAndFrySkin =>
      'Den Lachs trocken tupfen und mit der Hautseite nach unten bei mittlerer Hitze 5 Minuten braten. Wenden und weitere 3 Minuten garen, bis er innen nicht mehr glasig ist.';

  @override
  String get displayPeanutButter => 'Erdnussbutter';

  @override
  String get displayPeanuts => 'Erdnüsse';

  @override
  String get displayPepper => 'Paprikaschote';

  @override
  String get displayPepper2 => 'Pfeffer';

  @override
  String get displayPeppercorns => 'Pfefferkörner';

  @override
  String get displayPiece => '½ Stück';

  @override
  String get displayPinch => 'Prise';

  @override
  String get displayPinch2 => 'Messerspitze';

  @override
  String get displayPleaseGiveYourFoodAName =>
      'Bitte gib deinem Lebensmittel einen Namen.';

  @override
  String get displayPod => 'Schote';

  @override
  String get displayPollock => 'Seelachs';

  @override
  String get displayPortionsPlural => 'Portionen';

  @override
  String get displayPotato => 'Kartoffel';

  @override
  String get displayPotatoes => 'Erdäpfel';

  @override
  String get displayPreferNotToSay => 'Möchte ich nicht angeben';

  @override
  String get displayPregnantOrBreastfeeding => 'Schwanger oder stillend';

  @override
  String get displayPreview => 'VORSCHAU';

  @override
  String get displayProtein => 'PROTEIN';

  @override
  String get displayProteinBerryOats => 'Protein-Beeren-Oats';

  @override
  String get displayProteinG => 'Protein g';

  @override
  String get displayPutTheRiceInABowlPlace =>
      'Reis in eine Schüssel geben, Lachs und Avocado darauf legen und sofort servieren.';

  @override
  String get displayQuark => 'Topfen';

  @override
  String get displayRecipe => 'Rezept';

  @override
  String get displayRiceCooked => 'Reis, gekocht';

  @override
  String get displayRiceFlour => 'Reismehl';

  @override
  String get displayRiceMilk => 'Reismilch';

  @override
  String get displayRoseWater => 'Rosenwasser';

  @override
  String get displayRosemary => 'Rosmarin';

  @override
  String get displayRosemarySprig => 'Rosmarinzweig';

  @override
  String get displayRosemarySprigs => 'Rosmarinzweige';

  @override
  String get displaySalmonFillet => 'Lachsfilet';

  @override
  String get displaySalmonPowerBowl => 'Lachs Power Bowl';

  @override
  String get displaySaltPepperOilWaterAndCommonSpices =>
      'Salz, Pfeffer, Öl, Wasser und gängige Gewürze wie Paprikapulver, Currypulver, Kreuzkümmel, Zimt oder Oregano';

  @override
  String get displaySavedRecipe => 'Gespeichertes Rezept';

  @override
  String get displayScatterTheBerriesOverTheTopAnd =>
      'Beeren darauf verteilen und sofort servieren.';

  @override
  String get displaySeptember => 'September';

  @override
  String get displayServe => 'Anrichten';

  @override
  String get displaySesame => 'Sesam';

  @override
  String get displaySheepSCheese => 'Schafskäse';

  @override
  String get displayShortOnTime => 'Wenig Zeit';

  @override
  String get displaySkyrWithAlmonds => 'Skyr mit Mandeln';

  @override
  String get displaySlice => 'Scheibe';

  @override
  String get displaySliced => 'in Scheiben';

  @override
  String get displaySmallSaucepanWithLid => 'Kleiner Topf mit Deckel';

  @override
  String get displaySoakTheOats => 'Hafer quellen lassen';

  @override
  String get displaySourCream => 'Sauerrahm';

  @override
  String get displaySourCream2 => 'Schmand';

  @override
  String get displaySoya => 'Soja';

  @override
  String get displaySoyaCream => 'Sojasahne';

  @override
  String get displaySoyaMilk => 'Sojamilch';

  @override
  String get displaySoyaYoghurt => 'Sojajoghurt';

  @override
  String get displaySpiceMix => 'Gewürzmischung';

  @override
  String get displaySpices => 'Gewürze';

  @override
  String get displaySprig => 'Zweig';

  @override
  String get displaySpringOnion => 'Frühlingslauch';

  @override
  String get displaySpringOnion2 => 'Frühlingszwiebel';

  @override
  String get displaySpringOnion3 => 'Lauchzwiebel';

  @override
  String get displayStepSingular => 'Schritt';

  @override
  String get displayStepsPlural => 'Schritte';

  @override
  String get displayStick => 'Stange';

  @override
  String get displayStirInTheSkyr => 'Skyr unterrühren';

  @override
  String get displayStirInTheSkyrUntilEvenlyCreamy =>
      'Skyr unterrühren, bis alles gleichmäßig cremig ist.';

  @override
  String get displayStirTheSkyrWithALittlePasta =>
      'Skyr mit etwas Nudelwasser glatt rühren, bis eine cremige Sauce entsteht.';

  @override
  String get displayStock => 'Brühe';

  @override
  String get displayStockCube => 'Brühwürfel';

  @override
  String get displaySugarSnapPea => 'Zuckerschote';

  @override
  String get displaySulphurDioxideSulphites => 'Schwefeldioxid / Sulfite';

  @override
  String get displaySweetPotato => 'Süßkartoffel';

  @override
  String get displayThisEntryContainsAnIngredientExcludedFrom =>
      'Dieser Eintrag enthält einen in Lookin ausgeschlossenen Bestandteil.';

  @override
  String get displayThisEntryDoesNotMeetLookinS =>
      'Dieser Eintrag entspricht nicht den Halal-Inhaltsregeln von Lookin.';

  @override
  String get displayThisFoodDoesNotMeetLookinS =>
      'Dieses Lebensmittel entspricht nicht den Halal-Inhaltsregeln von Lookin.';

  @override
  String get displayThisRecipeCouldNoLongerBeFound =>
      'Das Rezept konnte nicht mehr gefunden werden.';

  @override
  String get displayThisRecipeDoesNotMeetLookinS =>
      'Dieses Rezept entspricht nicht den Halal-Inhaltsregeln von Lookin.';

  @override
  String get displayThyme => 'Thymian';

  @override
  String get displayThymeSprig => 'Thymianzweig';

  @override
  String get displayThymeSprigs => 'Thymianzweige';

  @override
  String get displayTin => 'Dose';

  @override
  String get displayTinnedTomatoes => 'Dosentomaten';

  @override
  String get displayTomato => 'Tomate';

  @override
  String get displayTomatoes => 'Paradeiser';

  @override
  String get displayTreeNuts => 'Schalenfrüchte';

  @override
  String get displayTriedItBefore => 'Schon mal ausprobiert';

  @override
  String get displayTurkey => 'Pute';

  @override
  String get displayTurmeric => 'Kurkuma';

  @override
  String get displayUnsureWhatIsGoodForMe => 'Unsicher, was gut für mich ist';

  @override
  String get displayUpTo15Minutes => 'Bis 15 Minuten';

  @override
  String get displayVanilla => 'Vanille';

  @override
  String get displayVanillaPod => 'Vanilleschote';

  @override
  String get displayWarmTheCookedRiceWith1Tbsp =>
      'Den gekochten Reis mit 1 EL Wasser in einem kleinen Topf mit Deckel bei niedriger Hitze etwa 4 Minuten erwärmen.';

  @override
  String get displayWarmTheRice => 'Reis erwärmen';

  @override
  String get displayWatchMyBudget => 'Aufs Budget achten';

  @override
  String get displayWhippingCream => 'Schlagobers';

  @override
  String get displayWhiteBrinedCheese => 'Hirtenkäse';

  @override
  String get displayYesRegularly => 'Ja, regelmäßig';

  @override
  String get displayYoghurt => 'Joghurt';

  @override
  String get displayYoghurt2 => 'Jogurt';

  @override
  String get displayYourLocalProfilePictureCouldNotBe =>
      'Dein lokales Profilbild konnte nicht geladen werden.';

  @override
  String get displayYourPictureCouldNotBeRemovedPlease =>
      'Dein Bild konnte nicht entfernt werden. Bitte versuche es erneut.';

  @override
  String get displayYourPictureCouldNotBeSavedOn =>
      'Dein Bild konnte nur auf diesem Gerät nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get displayYourSelectionCouldNotBeSavedPermanently =>
      'Die Auswahl konnte nicht dauerhaft gespeichert werden.';

  @override
  String get displayYourStreakCouldNotBeLoaded =>
      'Deine Serie konnte nicht geladen werden.';

  @override
  String get displayYourStreakCouldNotBeUpdated =>
      'Deine Serie konnte nicht aktualisiert werden.';

  @override
  String homeAddValue(String name) {
    return '$name hinzufügen';
  }

  @override
  String get homeCarbohydrates => 'Kohlenhydrate';

  @override
  String get homeFat => 'Fett';

  @override
  String get homeFriday => 'Freitag';

  @override
  String homeHelloValue(String arg0) {
    return 'Hallo, $arg0';
  }

  @override
  String get homeKcalEaten => 'kcal gegessen';

  @override
  String get homeLoadingStreak => 'Serie wird geladen';

  @override
  String homeMealEntries(int count, String calories) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0 · $calories kcal';
  }

  @override
  String get homeMonday => 'Montag';

  @override
  String get homeNothingLoggedYet => 'Noch nichts eingetragen';

  @override
  String get homeReminders => 'Erinnerungen';

  @override
  String get homeSaturday => 'Samstag';

  @override
  String get homeSunday => 'Sonntag';

  @override
  String get homeTapAMealToLogFood =>
      'Tippe auf eine Mahlzeit, um Essen einzutragen.';

  @override
  String get homeThursday => 'Donnerstag';

  @override
  String get homeTuesday => 'Dienstag';

  @override
  String homeValueAbove(String arg0) {
    return '$arg0 darüber';
  }

  @override
  String homeValueDayTrackingStreak(String arg0) {
    return '$arg0 Tage Tracking-Serie';
  }

  @override
  String homeValueKcalAboveYourTarget(String arg0) {
    return '$arg0 kcal über deinem Ziel';
  }

  @override
  String homeValueKcalEaten(String arg0) {
    return '$arg0 kcal gegessen';
  }

  @override
  String homeValueKcalRemaining(String arg0) {
    return '$arg0 kcal übrig';
  }

  @override
  String homeValueKcalTarget(String arg0) {
    return '$arg0 kcal Ziel';
  }

  @override
  String homeValuePValueCValueF(String arg0, String arg1, String arg2) {
    return '$arg0 P · $arg1 K · $arg2 F';
  }

  @override
  String homeValueRemaining(String arg0) {
    return '$arg0 übrig';
  }

  @override
  String get homeWednesday => 'Mittwoch';

  @override
  String get homeYourDay => 'Dein Tag';

  @override
  String get homeYourMeals => 'Deine Mahlzeiten';

  @override
  String get languageContinue => 'Weiter auf Deutsch';

  @override
  String get languageDeviceActive => 'Handysprache';

  @override
  String get languageDeviceSubtitle => 'Automatisch Deutsch oder Englisch';

  @override
  String get languageDeviceTitle => 'Handysprache verwenden';

  @override
  String languageSelectedSemantics(String language) {
    return '$language, ausgewählt';
  }

  @override
  String get languageSettingsTitle => 'Sprache';

  @override
  String get languageSheetSubtitle =>
      'Die ganze App wechselt sofort, auch Rezepte und Lebensmittel.';

  @override
  String get languageSheetTitle => 'Sprache wählen';

  @override
  String get languageSubtitle =>
      'Du kannst sie später jederzeit im Profil ändern.';

  @override
  String get languageTitle => 'Wähle deine Sprache';

  @override
  String get navigationAdd => 'Hinzufügen';

  @override
  String get navigationAddMeal => 'Mahlzeit hinzufügen';

  @override
  String get navigationAi => 'KI';

  @override
  String get navigationDiary => 'Tagebuch';

  @override
  String get navigationProfile => 'Profil';

  @override
  String get navigationRecipes => 'Rezepte';

  @override
  String get navigationYourDayYourRhythm => 'Dein Alltag. Dein Rhythmus.';

  @override
  String get onboarding20Min => '20 Min.';

  @override
  String get onboarding560Kcal34GProtein => '560 kcal · 34 g Protein';

  @override
  String onboardingARoughEstimateAtAValuePace(String arg0) {
    return 'Grobe Schätzung bei $arg0 Tempo – dein Körper hält sich nicht an Kalender.';
  }

  @override
  String get onboardingARoughEstimateYourBodyDoesNot =>
      'Grobe Schätzung – dein Körper hält sich nicht an Kalender.';

  @override
  String get onboardingATargetThatFitsYouNotA =>
      'Ein Ziel, das zu dir passt – kein Muss. Du kannst es jederzeit ändern.';

  @override
  String get onboardingAddMeal => 'Mahlzeit hinzufügen';

  @override
  String get onboardingAddToDiary => 'Zum Tagebuch hinzufügen';

  @override
  String onboardingAddToLunchValueKcal(String arg0) {
    return 'Zu Mittagessen hinzufügen · $arg0 kcal';
  }

  @override
  String get onboardingAge => 'Alter';

  @override
  String get onboardingAgeBlockedText =>
      'Du hast angegeben, unter 18 zu sein. Deshalb kannst du Lookin nicht nutzen. Wenn du dich vertippt hast, schließe die App und öffne sie neu.';

  @override
  String get onboardingAgeBlockedTitle => 'Lookin ist erst ab 18';

  @override
  String get onboardingAgeGateNo => 'Nein';

  @override
  String get onboardingAgeGateText =>
      'Lookin ist für Personen ab 18 Jahren gedacht. Bitte bestätige dein Alter, bevor du weitermachst.';

  @override
  String get onboardingAgeGateTitle => 'Bist du mindestens 18 Jahre alt?';

  @override
  String get onboardingAgeGateYes => 'Ja, ich bin mindestens 18';

  @override
  String get onboardingAiEstimate => 'KI-Schätzung';

  @override
  String get onboardingAiEstimates => 'KI schätzt.';

  @override
  String get onboardingAiEstimatesFoods => 'KI schätzt Lebensmittel';

  @override
  String get onboardingAiNutritionFitness => 'KI · Ernährung & Fitness';

  @override
  String get onboardingAiPhoto => 'KI-Foto';

  @override
  String get onboardingAiPhotoPremium => 'KI-FOTO · PREMIUM';

  @override
  String get onboardingAiRecognisesFoodsAndEstimatesAmountsYou =>
      'Die KI erkennt Lebensmittel und schätzt die Mengen. Du prüfst Gramm und Nährwerte, ergänzt, was fehlt – und speicherst erst dann.';

  @override
  String get onboardingAlreadyAMember => 'Schon dabei? ';

  @override
  String get onboardingAlreadyHaveAnAccountSignIn =>
      'Schon ein Konto? Anmelden';

  @override
  String get onboardingAmount => 'Menge';

  @override
  String get onboardingAnswerTheQuestionsInYourProfileAt =>
      'Beantworte die Fragen jederzeit im Profil, dann passt sich Lookin an dich an.';

  @override
  String get onboardingAnswersAboutNutritionAndFitnessTailoredTo =>
      'Antworten zu Ernährung und Fitness, passend zu deinem Ziel und deinen Tageswerten.';

  @override
  String get onboardingAskYourCoach => 'Frag deinen Coach …';

  @override
  String get onboardingAtAGlance => 'Auf einen Blick.';

  @override
  String get onboardingAtHome => 'Zu Hause';

  @override
  String get onboardingBack => 'Zurück';

  @override
  String get onboardingBreakfast => 'Frühstück';

  @override
  String get onboardingBreakfastLunchDinnerAndSnacksInOne =>
      'Frühstück, Mittagessen, Abendessen und Snacks an einem Ort – mit Kalorien, Kohlenhydraten, Protein und Fett.';

  @override
  String get onboardingBuildMuscle => 'Muskeln aufbauen';

  @override
  String onboardingCalculateEnergyNeedsFromValue(String arg0) {
    return 'Energiebedarf aus $arg0 berechnen';
  }

  @override
  String get onboardingCarbohydrates => 'Kohlenhydrate';

  @override
  String get onboardingChangeAnswers => 'Antworten ändern';

  @override
  String get onboardingCheckTheEstimateThenSave =>
      'Schätzung prüfen, dann speichern';

  @override
  String get onboardingChooseTheUnitThatFeelsNaturalTo =>
      'Wähle die Einheit, die für dich natürlich ist, und wische zum passenden Wert.';

  @override
  String get onboardingClose => 'Schließen';

  @override
  String get onboardingContinue => 'Weiter';

  @override
  String get onboardingContinueForNow => 'Für jetzt fortfahren';

  @override
  String get onboardingCookSimply => 'Einfach kochen.';

  @override
  String get onboardingCookWithWhatYouHave => 'Kochen mit dem, was da ist';

  @override
  String onboardingCreatingPlanValuePerCent(String arg0) {
    return 'Plan wird erstellt, $arg0 Prozent';
  }

  @override
  String get onboardingCreatingYourPlan => 'Dein Plan wird erstellt …';

  @override
  String get onboardingDailyRoutine => 'Alltag';

  @override
  String get onboardingDailyTarget => 'Tagesziel';

  @override
  String get onboardingDateOfBirth => 'Geburtsdatum';

  @override
  String get onboardingDayStreak => 'Tage Serie';

  @override
  String get onboardingDec => 'Dez';

  @override
  String get onboardingDecember => 'Dezember';

  @override
  String get onboardingDinner => 'Abendessen';

  @override
  String get onboardingDragTheRulerLeftOrRightThis =>
      'Ziehe das Lineal nach links oder rechts. Es ist dein aktuelles Gewicht, kein Ziel.';

  @override
  String get onboardingDragTheRulerLeftOrRightYour =>
      'Ziehe das Lineal nach links oder rechts. Dein Gewicht wird nicht bewertet.';

  @override
  String get onboardingEggs => 'Eier';

  @override
  String get onboardingEnterManually => 'Manuell eintragen';

  @override
  String get onboardingEntriesToday => 'Einträge heute';

  @override
  String get onboardingEstimateProteinAndFatFromYourWeight =>
      'Eiweiß und Fett aus deinem Gewicht ableiten';

  @override
  String get onboardingEstimateTimeToYourTargetWeight =>
      'Zeit bis zu deinem Wunschgewicht abschätzen';

  @override
  String get onboardingEstimatesAreAlwaysLabelledAsEstimates =>
      'Schätzungen sind immer als Schätzung markiert.';

  @override
  String get onboardingEveryRoutineIsDifferent => 'Jeder Alltag ist anders.';

  @override
  String get onboardingEverythingIsBasedOnYourAnswersAnd =>
      'Alles basiert auf deinen Antworten und lässt sich jederzeit im Profil anpassen.';

  @override
  String get onboardingExampleView => 'Beispielansicht';

  @override
  String get onboardingFat => 'Fett';

  @override
  String get onboardingFebruary => 'Februar';

  @override
  String get onboardingFilterByQuickHighProteinOrVegetarian =>
      'Filtere nach Schnell, High Protein oder Vegetarisch und finde Rezepte mit dem, was du zu Hause hast.';

  @override
  String get onboardingFilterOutRecipesContainingYourAllergens =>
      'Rezepte mit deinen Allergenen aussortieren';

  @override
  String get onboardingFindProduct => 'Produkt finden';

  @override
  String get onboardingFindRecipes => 'Rezepte finden.';

  @override
  String get onboardingFocusedOnNutritionAndFitness =>
      'Konzentriert auf Ernährung und Fitness.';

  @override
  String get onboardingForExampleAlex => 'Zum Beispiel Alex';

  @override
  String get onboardingForYou => 'FÜR DICH';

  @override
  String get onboardingFourMealsOneOverview =>
      'Vier Mahlzeiten. Ein Überblick.';

  @override
  String get onboardingGiveYourCoachYourAnswersAsBackground =>
      'Deinem Coach deine Antworten als Hintergrund mitgeben';

  @override
  String get onboardingGuidelineValuesForOrientationNotMedicalAdvice =>
      'Richtwerte zur Orientierung, keine medizinische Beratung. Du kannst alles jederzeit im Profil anpassen.';

  @override
  String get onboardingGuidelineValuesOnlyIfYouWantThem =>
      'Richtwerte nur, wenn du möchtest';

  @override
  String get onboardingHaveYouCountedCaloriesBefore =>
      'Hast du schon einmal Kalorien gezählt?';

  @override
  String get onboardingHeight => 'Größe';

  @override
  String onboardingHelloValue(String arg0) {
    return 'Hallo, $arg0.';
  }

  @override
  String get onboardingHowActiveAreYouUsually => 'Wie aktiv bist du meistens?';

  @override
  String get onboardingHowDoYouEat => 'Wie isst du?';

  @override
  String get onboardingHowDoYouLikeToEatSet =>
      'Wie isst du gern? Richte deinen Rhythmus und deine Rezeptideen in wenigen Schritten ein.';

  @override
  String get onboardingHowTallAreYou => 'Wie groß bist du?';

  @override
  String get onboardingIdeasMarkedAsBudgetRecipesAppearHigher =>
      'Für deinen Einkauf stehen als Budget-Rezept markierte Ideen weiter oben.';

  @override
  String get onboardingIdeasMarkedAsBudgetRecipesMoveUp =>
      'Als Budget-Rezept markierte Ideen rücken nach vorne.';

  @override
  String get onboardingIfYouWishLookinCalculatesGuidelineValues =>
      'Wenn du möchtest, berechnet Lookin Richtwerte aus Alter, Größe und Gewicht. Deine Serie zeigt, wie regelmäßig du dabei bist.';

  @override
  String get onboardingInDiary => 'Im Tagebuch';

  @override
  String get onboardingIntentionallyLeaveOutCalorieTargetsForYou =>
      'Kalorienziele für dich bewusst weglassen';

  @override
  String get onboardingIsThereAnythingLookinShouldTakeInto =>
      'Gibt es etwas, worauf Lookin achten soll?';

  @override
  String get onboardingJanuary => 'Januar';

  @override
  String get onboardingJuly => 'Juli';

  @override
  String get onboardingJune => 'Juni';

  @override
  String get onboardingJustAsk => 'Frag einfach.';

  @override
  String get onboardingKcalToday => 'kcal heute';

  @override
  String get onboardingLetSGo => 'Los geht’s';

  @override
  String get onboardingLogInYourDiaryWithOneTap =>
      'Mit einem Tipp ins Tagebuch.';

  @override
  String get onboardingLogMealsThroughSearchOrBarcodeAnd =>
      'Mahlzeiten per Suche oder Barcode eintragen – mit Premium auch per Foto.';

  @override
  String get onboardingLookinDoesNotCalculateCalorieTargetsFor =>
      'Für dich berechnet Lookin keine Kalorienziele. Tagebuch, Rezepte und Coach kannst du trotzdem nutzen – deine Ziele besprichst du am besten mit einer Ärztin, einem Arzt oder einer Ernährungsfachkraft.';

  @override
  String get onboardingLookinDoesNotCalculateCalorieTargetsFor2 =>
      'Für Personen unter 18 Jahren berechnet Lookin keine Kalorienziele. Rezepte, Tagebuch und Tipps kannst du trotzdem nutzen.';

  @override
  String get onboardingLookinDoesNotCalculateDailyTargetsWithout =>
      'Ohne Alter, Größe und Gewicht berechnet Lookin keine Tagesziele. Du kannst sie jederzeit im Profil ergänzen.';

  @override
  String get onboardingLookinHidesRecipesContainingYourAllergens =>
      'Rezepte mit deinen Allergenen blendet Lookin aus.';

  @override
  String get onboardingLookinIsProcessingYourAnswers =>
      'Lookin verarbeitet gerade deine Antworten.';

  @override
  String get onboardingLookinOnlyOffersTargetsWithinTheHealthy =>
      'Lookin bietet nur Ziele im gesunden Bereich (BMI ab 18,5) und höchstens etwa ein halbes Kilo pro Woche an.';

  @override
  String get onboardingLookinWorksWithoutThisInformationToo =>
      'Ohne Angaben funktioniert Lookin genauso.';

  @override
  String get onboardingLunch => 'Mittagessen';

  @override
  String get onboardingMakeLookinFitYou => 'So passt Lookin zu dir';

  @override
  String get onboardingMar => 'Mär';

  @override
  String get onboardingMarch => 'März';

  @override
  String get onboardingMay => 'Mai';

  @override
  String get onboardingMealPrepForYourDay => 'Vorkochen für deinen Alltag';

  @override
  String get onboardingMetricCmKg => 'Metrisch · cm / kg';

  @override
  String get onboardingMoreProtein => 'Mehr Protein';

  @override
  String get onboardingMostlySeatedOfficeStudyCarOftenMoving =>
      'Meist sitzend: Büro, Studium, Auto. Viel in Bewegung: Pflege, Handwerk, Verkauf oder viele Wege zu Fuß.';

  @override
  String get onboardingMuscleGrowsSlowlyEnoughProteinAndTraining =>
      'Muskeln wachsen langsam. Genug Eiweiß und Training sind wichtiger als schnelle Zahlen.';

  @override
  String get onboardingMyDailyTargets => 'MEINE TÄGLICHEN ZIELE';

  @override
  String get onboardingNoneOfTheseApplySimplyTapContinue =>
      'Trifft nichts davon zu? Dann tippe einfach auf „Weiter“.';

  @override
  String get onboardingNutritionAndFitnessOnly => 'Nur Ernährung und Fitness';

  @override
  String get onboardingNutritionStyle => 'Ernährungsweise';

  @override
  String get onboardingOct => 'Okt';

  @override
  String get onboardingOctober => 'Oktober';

  @override
  String get onboardingOf2100 => 'von 2.100';

  @override
  String get onboardingOneMoment => 'Einen Moment …';

  @override
  String get onboardingOnlyUsedToEstimateYourEnergyNeeds =>
      'Nur für die Schätzung deines Energiebedarfs – Körper verbrauchen je nach Geschlecht unterschiedlich viel. Du kannst das auch offenlassen.';

  @override
  String get onboardingOpeningLookin => 'Lookin wird geöffnet';

  @override
  String get onboardingOptionalAndOnlyForYourSafetyThis =>
      'Freiwillig und nur für deine Sicherheit. Diese Angabe bleibt auf diesem Gerät, solange du der Speicherung im Konto nicht zustimmst.';

  @override
  String onboardingPageValueOfValue(String arg0, String arg1) {
    return 'Seite $arg0 von $arg1';
  }

  @override
  String get onboardingPersonalise => 'Persönlich einrichten';

  @override
  String get onboardingPescatarian => 'Pescetarisch';

  @override
  String get onboardingPhotoBarcodeOrManualEntry =>
      'Foto, Barcode oder selbst eintragen';

  @override
  String get onboardingPotatoes => 'Kartoffeln';

  @override
  String get onboardingPreparingYourLookin => 'Dein Lookin wird vorbereitet …';

  @override
  String get onboardingProtein => 'Eiweiß';

  @override
  String get onboardingQuick => 'Schnell';

  @override
  String get onboardingQuickToLog => 'SCHNELL EINGETRAGEN';

  @override
  String onboardingRecipeIdeasLabelledAsValueAppearFirst(String arg0) {
    return 'Passend gekennzeichnete $arg0 Rezeptideen erscheinen zuerst.';
  }

  @override
  String get onboardingRecipes => 'REZEPTE';

  @override
  String onboardingRecipesAreSortedByValue(String arg0) {
    return 'Rezepte erscheinen sortiert nach $arg0.';
  }

  @override
  String onboardingRecipesTakingUpToValueMinutesGet(String arg0) {
    return 'Rezepte bis $arg0 Minuten bekommen Vorrang, wenn passende vorhanden sind.';
  }

  @override
  String get onboardingRemovalDidNotWorkPleaseTryAgain =>
      'Entfernen hat nicht geklappt. Bitte versuche es erneut.';

  @override
  String get onboardingRemoveAnswers => 'Antworten entfernen';

  @override
  String get onboardingReplayAnimation => 'Animation wiederholen';

  @override
  String get onboardingRice => 'Reis';

  @override
  String get onboardingSalad => 'Salat';

  @override
  String get onboardingSalmon => 'Lachs';

  @override
  String get onboardingSalmonAvocadoRice => 'Lachs-Avocado-Reis';

  @override
  String get onboardingSaving => 'Wird gespeichert …';

  @override
  String get onboardingScanBarcode => 'Barcode scannen';

  @override
  String get onboardingSearchAndCustomFoodsIncluded =>
      'Suchen und eigene Lebensmittel inklusive.';

  @override
  String get onboardingSearchOrEnterManually => 'Suchen oder selbst';

  @override
  String get onboardingSeeWhatYouHaveAlreadyEatenToday =>
      'Sehen, was du heute schon gegessen hast.';

  @override
  String get onboardingSelectEverythingThatFitsItIsCompletely =>
      'Wähle alles, was passt – das ist völlig normal. Lookin gibt dir dazu passende Tipps.';

  @override
  String get onboardingSelectEverythingThatFitsYourCoachUses =>
      'Wähle alles, was passt. Dein Coach greift das auf, wenn es mal schwerfällt.';

  @override
  String get onboardingSetProteinAndFatToFitYour =>
      'Eiweiß und Fett passend zu deinem Ziel festlegen';

  @override
  String get onboardingSex => 'Geschlecht';

  @override
  String get onboardingShortOnTimeTodayQuickMealsAppear =>
      'Wenig Zeit heute? In deinen Rezeptideen stehen schnelle Gerichte weiter oben.';

  @override
  String get onboardingSignIn => 'Anmelden';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingSoLookinCanAddressYouProperly =>
      'Damit Lookin dich richtig anspricht.';

  @override
  String get onboardingSoRecipesSuggestionsAndTheCoachFit =>
      'Damit Rezepte, Vorschläge und der Coach zu dir passen.';

  @override
  String onboardingSortRecipesByValue(String arg0) {
    return 'Rezepte nach $arg0 sortieren';
  }

  @override
  String get onboardingSpaceForYou => 'Platz für dich.';

  @override
  String get onboardingSteadyPace => 'Ausgewogen';

  @override
  String get onboardingStillEmpty => 'Noch leer';

  @override
  String get onboardingSummariseYourAnswers => 'Deine Antworten zusammenfassen';

  @override
  String get onboardingSwipeTheWheelsUpOrDown =>
      'Wische direkt in den Rädern nach oben oder unten.';

  @override
  String get onboardingTakeAPhoto => 'Foto machen.';

  @override
  String get onboardingTakeAPhotoScanABarcodeOr =>
      'Foto machen, Barcode scannen oder selbst eintragen. Das Plus in der Mitte ist immer nur einen Tipp entfernt.';

  @override
  String get onboardingTapThePlus => 'Ein Tipp aufs Plus.';

  @override
  String get onboardingThankYouForSharingThisLookinDoes =>
      'Danke, dass du das teilst. Lookin berechnet für dich keine Kalorienziele und schlägt keine Diät vor. Tagebuch, Rezepte und Coach kannst du trotzdem nutzen – deine Ziele besprichst du am besten mit deiner Ärztin, deinem Arzt oder einer Ernährungsfachkraft.';

  @override
  String get onboardingThatDidNotWorkJustNowPlease =>
      'Das hat gerade nicht geklappt. Bitte versuche es noch einmal.';

  @override
  String get onboardingThatFitsUseThisValue =>
      'Passt genau so – Wert übernehmen';

  @override
  String get onboardingTheIntroductionMayAppearAgainAtThe =>
      'Die Einführung erscheint beim nächsten Start eventuell erneut.';

  @override
  String get onboardingThisHelpsLookinSuggestRecipesThatFit =>
      'So schlägt Lookin Rezepte vor, die in deinen Tag passen.';

  @override
  String get onboardingThreeWays => 'Drei Wege.';

  @override
  String get onboardingTimeToCookOnANormalDay =>
      'Zeit zum Kochen an einem normalen Tag';

  @override
  String onboardingTodayValue(String arg0) {
    return 'Heute · $arg0';
  }

  @override
  String get onboardingTryAgain => 'Erneut versuchen';

  @override
  String onboardingUpToValueMin(String arg0) {
    return 'Bis $arg0 Min.';
  }

  @override
  String onboardingValueAndValue(String arg0, String arg1) {
    return '$arg0 und $arg1';
  }

  @override
  String onboardingValueAroundValue(String arg0, String arg1) {
    return '$arg0 etwa im $arg1';
  }

  @override
  String onboardingValueKcalCValueGPValue(
    String arg0,
    String arg1,
    String arg2,
  ) {
    return '$arg0 kcal · K $arg1 g · P $arg2 g';
  }

  @override
  String onboardingValueKilocaloriesPerDay(String arg0) {
    return '$arg0 Kilokalorien pro Tag';
  }

  @override
  String onboardingValueMealsFitIntoYourDay(String arg0) {
    return '$arg0 Mahlzeiten passen in deinen Tag';
  }

  @override
  String onboardingValueUpToValueMin(String arg0, String arg1) {
    return '$arg0 · bis $arg1 Min.';
  }

  @override
  String onboardingValueValueKgWeek(String arg0, String arg1) {
    return '$arg0\n$arg1 kg/Woche';
  }

  @override
  String get onboardingVegetarian => 'Vegetarisch';

  @override
  String get onboardingViewRecipeIdeas => 'Rezeptideen ansehen';

  @override
  String get onboardingWeight => 'Gewicht';

  @override
  String get onboardingWhatCanIStillEatThisEvening =>
      'Was kann ich heute Abend noch essen?';

  @override
  String get onboardingWhatFeelsRightForYouMatters => 'Was dir guttut, zählt.';

  @override
  String get onboardingWhatHasHeldYouBackSoFar =>
      'Was hat dich bisher gebremst?';

  @override
  String get onboardingWhatIsYourGoal => 'Was ist dein Ziel?';

  @override
  String get onboardingWhatIsYourKitchenRoutine =>
      'Wie sieht es in deiner Küche aus?';

  @override
  String get onboardingWhatIsYourTargetWeight => 'Was ist dein Wunschgewicht?';

  @override
  String get onboardingWhatLookinDoesForYouNow =>
      'Das macht Lookin jetzt für dich';

  @override
  String get onboardingWhatShouldWeCallYouOptional =>
      'Wie dürfen wir dich nennen? (optional)';

  @override
  String get onboardingWhenIsYourBirthday => 'Wann hast du Geburtstag?';

  @override
  String get onboardingWhereAreYouNow => 'Wo stehst du gerade?';

  @override
  String get onboardingWhereWouldYouLikeToBe => 'Wohin möchtest du?';

  @override
  String get onboardingWhyDoesItMatterToYou => 'Warum ist dir das wichtig?';

  @override
  String get onboardingYouAreStartingWithACleanSlate =>
      'Du startest ganz neutral.';

  @override
  String get onboardingYouCanContinueTheQuestionsMayAppear =>
      'Du kannst weitermachen. Die Fragen erscheinen beim nächsten Start möglicherweise erneut.';

  @override
  String get onboardingYouCanSkipAboveLookinWorksWithout =>
      'Du kannst oben überspringen. Lookin funktioniert auch ohne diese Antworten.';

  @override
  String get onboardingYouChooseTheDirection => 'Du bestimmst die Richtung.';

  @override
  String get onboardingYouHaveAbout650KcalLeftToday =>
      'Du hast heute noch etwa 650 kcal frei. Wie wäre eine Lachs-Tomaten-Bowl? Rund 35 g Protein.';

  @override
  String get onboardingYouHaveNotProvidedAnyInformationLookin =>
      'Du hast keine Angaben gemacht. Darum berechnet Lookin noch keine Tagesziele und sortiert Rezepte nicht für dich. Sobald du im Profil etwas ergänzt, passt sich Lookin an.';

  @override
  String get onboardingYourAiCoach => 'Dein KI-Coach.';

  @override
  String get onboardingYourBudget => 'deinem Budget';

  @override
  String get onboardingYourChoices => 'DEINE AUSWAHL';

  @override
  String get onboardingYourCoachKnowsYourGoalsAndObstacles =>
      'Dein Coach kennt deine Ziele und Hürden und richtet Tipps daran aus.';

  @override
  String onboardingYourCoachTakesIntoAccountValue(String arg0) {
    return 'Dein Coach berücksichtigt: $arg0.';
  }

  @override
  String get onboardingYourCookingTime => 'deiner Zeit zum Kochen';

  @override
  String get onboardingYourDailyGuideline => 'Dein Tagesrichtwert';

  @override
  String get onboardingYourDay => 'DEIN TAG';

  @override
  String get onboardingYourDay2 => 'Dein Tag.';

  @override
  String get onboardingYourDayYourLookin => 'Dein Alltag. Dein Lookin.';

  @override
  String get onboardingYourDiary => 'DEIN TAGEBUCH';

  @override
  String onboardingYourFocusValue(String arg0) {
    return 'Dein Fokus: $arg0.';
  }

  @override
  String get onboardingYourGoal => 'deinem Ziel';

  @override
  String get onboardingYourGoals => 'Deine Ziele.';

  @override
  String get onboardingYourHeight => 'Deine Größe';

  @override
  String get onboardingYourInformationCouldNotBeSavedPlease =>
      'Deine Angaben konnten nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get onboardingYourLookinPlanIsReady => 'Dein Lookin-Plan ist bereit.';

  @override
  String get onboardingYourMealRhythmStaysFlexible =>
      'Dein Rhythmus bleibt flexibel';

  @override
  String get onboardingYourNameIsOptionalYouCanChange =>
      'Dein Name ist optional. Alle Angaben kannst du später im Profil ändern.';

  @override
  String get onboardingYourNormalEverydayRoutineWithoutDedicatedExercise =>
      'Dein ganz normaler Alltag, ohne gezieltes Training.';

  @override
  String get onboardingYourNutritionStyle => 'deiner Ernährungsweise';

  @override
  String get onboardingYourOptionalInformationHelpsLookinAndThe =>
      'Deine freiwilligen Angaben helfen Lookin und dem KI-Coach, Vorschläge persönlicher zu machen. Du kannst sie jederzeit ändern oder entfernen.';

  @override
  String get onboardingYourPreferencesAtAGlance =>
      'Deine Wünsche auf einen Blick.';

  @override
  String get onboardingYourProfile => 'Dein Profil';

  @override
  String get onboardingYourProfile2 => 'DEIN PROFIL';

  @override
  String get onboardingYourRecipeIdeasReflectThePreferencesYou =>
      'Deine Rezeptideen richten sich nach den Vorlieben, die du angegeben hast.';

  @override
  String get onboardingYourRecipeIdeasTakeYourCookingTime =>
      'Deine Rezeptideen berücksichtigen deine Kochzeit.';

  @override
  String get onboardingYourRhythmIsAGuideYouCan =>
      'Dein Rhythmus ist eine Orientierung. Du kannst ihn jederzeit ändern.';

  @override
  String onboardingYourRoutineValue(String arg0) {
    return 'Dein Alltag: $arg0.';
  }

  @override
  String get onboardingYourSettingsCouldNotBeLoaded =>
      'Deine Einstellungen konnten nicht geladen werden.';

  @override
  String get onboardingYourSetupAnswersHaveBeenRemovedFrom =>
      'Deine Einrichtungsantworten wurden von diesem Gerät entfernt.';

  @override
  String get onboardingYourSex => 'Dein Geschlecht';

  @override
  String get onboardingYourStreak => 'Deine Serie.';

  @override
  String get onboardingYourWeightIsAlreadyAtTheLower =>
      'Dein Gewicht liegt bereits im unteren gesunden Bereich. Lookin schlägt dir deshalb kein Abnehmziel vor – wir helfen dir, gut und ausgewogen zu essen.';

  @override
  String get profileALittlePieceOfYou => 'Ein kleines Stück von dir.';

  @override
  String get profileActivity => 'Aktivität';

  @override
  String get profileActivityLevel => 'Aktivitätsniveau';

  @override
  String get profileAiPhotoAiChat => 'KI-Foto & KI-Chat';

  @override
  String get profileAiService => 'KI-DIENST';

  @override
  String get profileAllergies => 'Allergien';

  @override
  String get profileAnswerQuestions => 'Fragen beantworten';

  @override
  String get profileAppPrivacy => 'App & Datenschutz';

  @override
  String get profileApplyChanges => 'Änderungen übernehmen';

  @override
  String get profileBalanced => 'Ausgewogen';

  @override
  String get profileBecauseYouIndicatedThatYourNutritionNeeds =>
      'Weil du angegeben hast, dass deine Ernährung gerade besondere Aufmerksamkeit braucht, berechnet Lookin keine Kalorienziele. Besprich deine Ziele bitte mit deiner Ärztin, deinem Arzt oder einer Ernährungsfachkraft. Tagebuch und Rezepte kannst du trotzdem nutzen.';

  @override
  String get profileBuildMuscle => 'Muskeln aufbauen';

  @override
  String profileCalorieTargetValueKcal(String arg0) {
    return 'Kalorienziel: $arg0 kcal';
  }

  @override
  String get profileCalories => 'Kalorien';

  @override
  String get profileCancel => 'Abbrechen';

  @override
  String get profileChangeInformation => 'Angaben ändern';

  @override
  String get profileChangeNutritionStyleAndActivityUnderChange =>
      'Ernährungsweise und Aktivität änderst du unter „Antworten ändern“.';

  @override
  String get profileChangeProfilePicture => 'Profilbild ändern';

  @override
  String get profileChangeYourPreferredNameAndPersonalPreferences =>
      'Rufname und persönliche Wünsche änderst du im Profil unter „Antworten ändern“. Die folgenden Zahlen sind deine separat eingestellten Ziele.';

  @override
  String get profileChooseAnImageNoLargerThan8 =>
      'Wähle ein Bild mit höchstens 8 MB.';

  @override
  String get profileChooseAnotherImage => 'Anderes Bild auswählen';

  @override
  String get profileChooseImage => 'Bild auswählen';

  @override
  String get profileClose => 'Schließen';

  @override
  String get profileComingSoon => 'Bald verfügbar';

  @override
  String get profileContactSupport => 'Support schreiben';

  @override
  String get profileContactSupportText =>
      'Fragen, Probleme oder eine Meldung zu einer Antwort? Wir antworten per E-Mail.';

  @override
  String get profileCropYourImageDragItOrUse =>
      'Bildausschnitt. Ziehe das Bild oder nutze die Regler.';

  @override
  String get profileDayStreak => 'Tag Serie';

  @override
  String get profileDayStreak2 => 'Tage Serie';

  @override
  String get profileDelete => 'Löschen';

  @override
  String get profileDeleteAccount => 'Konto löschen';

  @override
  String get profileDeleteAccountAndAccountData =>
      'Konto und Kontodaten löschen';

  @override
  String get profileDeleteDemoData => 'Lokale Daten löschen?';

  @override
  String get profileDeleteLocalDemoData => 'Lokale Daten löschen';

  @override
  String get profileDeletingYourAccountDoesNotCancelYour =>
      'Das Löschen des Kontos kündigt dein Abo nicht. Der Store bucht weiter ab, bis du es dort kündigst. Kündige zuerst, dann lösche das Konto.';

  @override
  String get profileDemoChangesLastUntilTheAppRestarts =>
      'Demo: Änderungen bleiben bis zum Neustart erhalten.';

  @override
  String get profileDeveloperPremium => 'Entwickler: Premium';

  @override
  String get profileDeviceOnly => 'NUR GERÄT';

  @override
  String get profileDoNotFollowDietOrCalorieTargets =>
      'Nutze keine Diät- oder Kalorienziele auf eigene Faust. Hole dir persönliche Hilfe bei medizinischem oder psychotherapeutischem Fachpersonal. Bei einem akuten Notfall wende dich an den örtlichen Notruf.';

  @override
  String get profileEatingDisorderOrAcuteSymptoms =>
      'Essstörung oder akute Beschwerden';

  @override
  String get profileEditProfile => 'Profil bearbeiten';

  @override
  String get profileEntriesToday => 'Einträge heute';

  @override
  String get profileEntryToday => 'Eintrag heute';

  @override
  String get profileExportDeleteConsents =>
      'Exportieren, löschen, Einwilligungen';

  @override
  String get profileExportFailedPleaseCheckYourConnectionAnd =>
      'Der Export hat nicht geklappt. Bitte prüfe deine Verbindung und versuche es erneut.';

  @override
  String get profileExportMyData => 'Meine Daten exportieren';

  @override
  String get profileFat => 'Fett';

  @override
  String get profileFineTuneTheCrop => 'Ausschnitt fein einstellen';

  @override
  String get profileFlexible => 'Flexibel';

  @override
  String get profileForLookinPremiumWithoutGivingAReason =>
      'Für Lookin Premium, ohne Angabe von Gründen';

  @override
  String get profileHealthAlwaysComesBeforeTracking =>
      'Gesundheit geht immer vor Tracking';

  @override
  String get profileHelpSafety => 'Hilfe & Sicherheit';

  @override
  String get profileHidePassword => 'Passwort verbergen';

  @override
  String get profileImages => 'Bilder';

  @override
  String get profileImprint => 'Impressum';

  @override
  String get profileImprintLegal => 'Impressum & Rechtliches';

  @override
  String get profileImprintTermsPrivacyWithdrawal =>
      'Impressum, AGB, Datenschutz, Widerruf';

  @override
  String get profileInAccount => 'IM KONTO';

  @override
  String get profileInformationAndContact => 'Hinweise und Kontakt';

  @override
  String get profileIntroductionQuestionsAndPremiumAsOnThe =>
      'Einführung, Fragen und Premium wie beim ersten Start';

  @override
  String get profileJpgOrPngUpTo8Mb =>
      'JPG oder PNG · bis 8 MB\nDein Profilbild ist nur für dein Konto sichtbar.';

  @override
  String get profileKcalToday => 'kcal heute';

  @override
  String get profileLeaveThisAccountOnThisDevice =>
      'Dieses Konto auf dem Gerät verlassen';

  @override
  String get profileLeftRight => 'Links – rechts';

  @override
  String get profileLegal => 'Rechtliches';

  @override
  String get profileLocalDataOverview => 'Lokale Datenübersicht';

  @override
  String profileLocalOverviewSummary(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Name: $arg0\nZiel: $arg1\nMahlzeiten: $arg2\nFavoriten: $arg3';
  }

  @override
  String get profileLookinDoesNotCalculateCalorieTargetsFor =>
      'Für Personen unter 18 Jahren berechnet Lookin keine Kalorienziele. Bei Fragen zur Ernährung wende dich bitte an eine Ärztin, einen Arzt oder eine Ernährungsfachkraft.';

  @override
  String get profileLookinSupportsHabitsButDoesNotDiagnose =>
      'Lookin unterstützt Gewohnheiten, stellt aber keine Diagnose und ersetzt keine Ärztin, keinen Arzt oder qualifizierte Ernährungsberatung.';

  @override
  String get profileLoseFat => 'Fett verlieren';

  @override
  String get profileLowActivity => 'Wenig aktiv';

  @override
  String get profileMaintainWeight => 'Gewicht halten';

  @override
  String get profileMealWaterAndWeeklyReviewRemindersWill =>
      'Erinnerungen an Mahlzeiten, Wasser und einen Wochenrückblick kommen mit einem der nächsten Updates. Bis dahin verschickt Lookin keine Benachrichtigungen.';

  @override
  String get profileMeals => 'Mahlzeiten';

  @override
  String get profileMealsFavouritesListsAndWaterTotalsAre =>
      'Mahlzeiten, Favoriten, Listen und Wasserstand werden auf diesem Gerät geleert. Ohne Konto erscheinen nach einem App-Neustart die Beispiel-Mahlzeiten wieder.';

  @override
  String get profileMealsNutrition => 'Mahlzeiten & Nährwerte';

  @override
  String get profileModeratelyActive => 'Moderat aktiv';

  @override
  String get profileMoveTheImageToChooseYourCrop =>
      'Verschiebe das Bild für deinen Ausschnitt.';

  @override
  String get profileMyDailyTargets => 'Meine täglichen Ziele';

  @override
  String get profileMyGoal => 'Mein Ziel';

  @override
  String get profileNoGoalSelectedYet => 'Noch kein Ziel gewählt';

  @override
  String get profileNotMedicalAdvice => 'Keine medizinische Beratung';

  @override
  String get profileNumbersAreAGuide => 'Zahlen sind Orientierung';

  @override
  String get profileNutritionProfile => 'Ernährungsprofil';

  @override
  String get profileNutritionStyle => 'Ernährungsstil';

  @override
  String get profileNutritionValuesAndTargetsAreEstimatesAlso =>
      'Nährwerte und Ziele sind Schätzungen. Achte zusätzlich auf Energie, Wohlbefinden, Schlaf und ein entspanntes Verhältnis zum Essen.';

  @override
  String get profileOneMoment => 'Einen Moment …';

  @override
  String get profileOnlyVisibleToYourDeveloperAccount =>
      'Nur für dein Entwickler-Konto sichtbar';

  @override
  String get profileOpenStoreSubscriptions => 'Abos im Store öffnen';

  @override
  String get profileOpensInBrowser => 'Öffnet sich im Browser';

  @override
  String get profilePasswordToConfirm => 'Passwort zur Bestätigung';

  @override
  String get profilePermanentlyDeleteAccount => 'Konto endgültig löschen?';

  @override
  String get profilePleaseChooseAJpgOrPngImage =>
      'Wähle bitte ein JPG- oder PNG-Bild.';

  @override
  String get profilePleaseChooseTheImageAgain =>
      'Wähle das Bild bitte erneut aus.';

  @override
  String get profilePremiumActive => 'Premium aktiv';

  @override
  String get profilePremiumCouldNotBeSwitchedJustNow =>
      'Premium konnte gerade nicht umgeschaltet werden.';

  @override
  String get profilePrivacyData => 'Datenschutz & Daten';

  @override
  String get profilePrivacyPolicy => 'Datenschutzerklärung';

  @override
  String get profileProfile => 'Profil';

  @override
  String get profileProfilePictureReminders => 'Profilbild & Erinnerungen';

  @override
  String get profileProfileTargets => 'Profil & Ziele';

  @override
  String get profileRemaining => 'Noch offen';

  @override
  String get profileReminders => 'Erinnerungen';

  @override
  String get profileRemoveProfilePicture => 'Profilbild entfernen';

  @override
  String get profileSaveNutritionProfile => 'Ernährungsprofil speichern';

  @override
  String get profileSaveProfilePicture => 'Profilbild speichern';

  @override
  String get profileSavedListsAndYourWaterTotalAre =>
      'Gespeicherte Listen und dein Wasserstand werden auf diesem Gerät geleert. Deine gespeicherten Mahlzeiten und Favoriten im Konto bleiben erhalten.';

  @override
  String get profileSavingCancelled => 'Speichern abgebrochen.';

  @override
  String get profileSelectTheCropAgain => 'Wähle den Bildausschnitt erneut.';

  @override
  String get profileShowPassword => 'Passwort anzeigen';

  @override
  String get profileSignOut => 'Abmelden';

  @override
  String get profileSignOut2 => 'Abmelden?';

  @override
  String get profileSignOutFailedPleaseTryAgain =>
      'Abmelden fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get profileStartFromTheBeginning => 'Von vorne zeigen';

  @override
  String profileSupportMailNotOpened(String address) {
    return 'Die E-Mail-App konnte nicht geöffnet werden. Schreib uns bitte an $address.';
  }

  @override
  String get profileSupportMailSubject => 'Lookin Support';

  @override
  String profileTargetWeightValueKg(String arg0) {
    return 'Zielgewicht: $arg0 kg';
  }

  @override
  String get profileTerms => 'AGB';

  @override
  String get profileTheExportAlsoContainsHealthAndChat =>
      'Der Export enthält auch Gesundheits- und Chatdaten. Bewahre die Datei sicher auf.';

  @override
  String get profileTheImageCouldNotBeOpenedTry =>
      'Das Bild ließ sich nicht öffnen. Versuche es mit einem anderen JPG oder PNG.';

  @override
  String get profileTheImageCouldNotBeResized =>
      'Das Bild konnte nicht verkleinert werden.';

  @override
  String get profileTheImageIsVeryLargeChooseA =>
      'Das Bild ist sehr groß. Wähle ein Foto mit höchstens 24 Megapixeln.';

  @override
  String get profileThisImageCouldNotBeOpened =>
      'Dieses Bild konnte nicht geöffnet werden.';

  @override
  String get profileTransparentAndUnderYourControl =>
      'Transparent und unter deiner Kontrolle';

  @override
  String get profileTrialActive => 'Testphase aktiv';

  @override
  String profileTrialActiveUntilValue(String arg0) {
    return 'Testphase aktiv bis $arg0';
  }

  @override
  String get profileUpDown => 'Oben – unten';

  @override
  String profileValueDayFreeTrial(String arg0) {
    return '$arg0 Tage kostenlos testen';
  }

  @override
  String profileValuePerDay(String arg0) {
    return '$arg0 pro Tag';
  }

  @override
  String profileValueValuePerCent(String arg0, String arg1) {
    return '$arg0: $arg1 Prozent';
  }

  @override
  String profileValueZoom(String arg0) {
    return '$arg0-fache Vergrößerung';
  }

  @override
  String get profileVegetarian => 'Vegetarisch';

  @override
  String get profileVeryActive => 'Sehr aktiv';

  @override
  String get profileViewLocalData => 'Lokale Daten ansehen';

  @override
  String get profileViewPlansAndBenefits => 'Pläne und Vorteile ansehen';

  @override
  String get profileWeCalculateTheseGuidelineValuesFromYour =>
      'Diese Richtwerte berechnen wir aus deinem Alter, deiner Größe, deinem Gewicht und deinem Alltag. Sie dienen zur Orientierung und ersetzen keine ärztliche Beratung.';

  @override
  String get profileWeCalculateYourDailyTargetsFromYour =>
      'Deine Tagesziele berechnen wir aus deinem Alter, deiner Größe, deinem Gewicht und deinem Alltag. Wenn du möchtest, beantworte dazu ein paar kurze Fragen. Du kannst Lookin aber auch ganz ohne Ziele nutzen.';

  @override
  String get profileWithdrawFromContract => 'Vertrag widerrufen';

  @override
  String get profileWithdrawalInformation => 'Widerrufsbelehrung';

  @override
  String get profileWithin14DaysOfPurchaseWithoutGiving =>
      'Innerhalb von 14 Tagen nach dem Kauf, ohne Grund';

  @override
  String get profileYourAccountCouldNotBeCompletelyDeleted =>
      'Das Konto konnte nicht vollständig gelöscht werden. Bitte prüfe, ob du noch angemeldet bist.';

  @override
  String get profileYourAccountCouldNotBeDeletedPlease =>
      'Das Konto konnte nicht gelöscht werden. Bitte versuche es erneut.';

  @override
  String profileYourAccountValueAndItsAssociatedData(String arg0) {
    return 'Dein Konto$arg0 und die dazugehörigen Daten werden gelöscht. Das kann nicht rückgängig gemacht werden. Ein späteres Store-Abo müsstest du separat im Store kündigen.';
  }

  @override
  String get profileYourCalorieTargetIsCalculatedFromYour =>
      'Dein Kalorienziel wird aus deinen Angaben berechnet.';

  @override
  String get profileYourDataHasBeenSavedAsA =>
      'Deine Daten wurden als JSON-Datei gespeichert.';

  @override
  String get profileYourPasswordIsIncorrectYourAccountWas =>
      'Das Passwort stimmt nicht. Dein Konto wurde nicht gelöscht.';

  @override
  String get profileYourPremiumSubscriptionWillContinue =>
      'Dein Premium-Abo läuft weiter!';

  @override
  String get profileYourProfilePicture => 'Dein Profilbild';

  @override
  String get profileYourProfilePictureCouldNotBeRemoved =>
      'Das Profilbild konnte nicht entfernt werden.';

  @override
  String get profileYourProfilePictureCouldNotBeRemoved2 =>
      'Das Profilbild konnte nicht entfernt werden. Versuche es erneut.';

  @override
  String get profileYourProfilePictureWasNotSavedPlease =>
      'Das Profilbild wurde nicht gespeichert. Versuche es erneut.';

  @override
  String get profileYourProfilePictureWasNotSavedYour =>
      'Das Profilbild wurde nicht gespeichert. Dein bisheriges Bild bleibt erhalten.';

  @override
  String get profileYourProfileTargetsAndDiaryAreSaved =>
      'Profil, Ziele und Tagebuch werden in deinem Lookin-Konto (Supabase) gespeichert, damit sie auf jedem Gerät verfügbar sind. Fotos für die KI-Foto-Analyse und Nachrichten an den KI-Coach werden über unseren Server an OpenAI übertragen; Fotos werden dabei nicht gespeichert. Profilbild, Erinnerungen und gemerkte Lebensmittel bleiben nur auf diesem Gerät. Unter den Optionen oben kannst du deine Kontodaten exportieren oder dein Konto endgültig löschen.';

  @override
  String get profileYourSavedAccountDataWillBeKept =>
      'Deine gespeicherten Kontodaten bleiben erhalten. Du kannst dich später wieder anmelden.';

  @override
  String get profileYourSavedProfileInformation =>
      'Deine gespeicherten Profilangaben';

  @override
  String get progressAMeasurementReplacesTheValueFromThe =>
      'Eine Messung ersetzt den Wert desselben Tages.';

  @override
  String get progressAnActualTrendStartsHereAutomaticallyAfter =>
      'Nach deinem ersten Tagebucheintrag entsteht hier automatisch ein echter Verlauf.';

  @override
  String get progressAverageOnTrackedDays => 'Durchschnitt an getrackten Tagen';

  @override
  String get progressAveragePerTimePeriodComparedWithYour =>
      'Durchschnitt pro Zeitabschnitt im Vergleich zu deinen Zielen';

  @override
  String get progressAvgKcalTrackedDay => 'Ø kcal / Track-Tag';

  @override
  String get progressAvgProteinTrackedDay => 'Ø Protein / Track-Tag';

  @override
  String get progressBodyTrend => 'Körperverlauf';

  @override
  String get progressCalories => 'KALORIEN';

  @override
  String get progressCarbohydrates => 'Kohlenhydrate';

  @override
  String get progressCheckYourConnectionAndTryAgain =>
      'Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get progressClearTrendsFromYourActualDiaryWithout =>
      'Klare Trends aus deinem echten Tagebuch – ohne Druck durch einzelne Tage.';

  @override
  String get progressClosenessToTarget => 'Zielnähe';

  @override
  String get progressCurrentStreak => 'Aktuelle Serie';

  @override
  String get progressDaysInCalorieRange => 'Tage im Kalorienbereich';

  @override
  String get progressFat => 'Fett';

  @override
  String get progressInTargetRange => 'im Zielbereich';

  @override
  String get progressLog => 'Eintragen';

  @override
  String get progressLogMealsAndAddYourWeightLookin =>
      'Trage Mahlzeiten ein und ergänze dein Gewicht. Lookin berechnet danach nur aus deinen echten Daten.';

  @override
  String get progressLogOrdinaryDaysTooThisMakesYour =>
      'Trage auch an normalen Tagen ein. So wird dein Trend ehrlich und nützlich.';

  @override
  String get progressLookAtWeightOverSeveralWeeksWater =>
      'Bewerte Gewicht über mehrere Wochen; Wasser und Salz verschieben einzelne Messungen.';

  @override
  String get progressMacroBalance => 'Makro-Balance';

  @override
  String get progressMeasurementCouldNotBeSaved =>
      'Messung konnte nicht gespeichert werden.';

  @override
  String get progressMeasurementSaved => 'Messung gespeichert.';

  @override
  String get progressNewMeasurement => 'Neue Messung';

  @override
  String get progressNoMeasurementYet => 'Noch keine Messung';

  @override
  String get progressNoNutritionTrendYet => 'Noch kein Ernährungstrend';

  @override
  String get progressNutritionTrend => 'Ernährungstrend';

  @override
  String get progressOneOrTwoMeasurementsAWeekAre =>
      'Ein bis zwei Messungen pro Woche reichen. Tages-Schwankungen sind normal.';

  @override
  String get progressOneOrTwoMeasurementsAWeekUnder =>
      'Für einen Gewichtstrend genügen ein bis zwei Messungen pro Woche unter ähnlichen Bedingungen.';

  @override
  String get progressPleaseEnterARealisticWeightBetween25 =>
      'Bitte gib ein realistisches Gewicht zwischen 25 und 400 kg ein.';

  @override
  String progressProteinWasCloseToTargetOnValue(String arg0) {
    return 'An $arg0 Tagen lag Protein nahe am Ziel. Eine feste Proteinquelle pro Mahlzeit kann helfen.';
  }

  @override
  String get progressRefresh => 'Aktualisieren';

  @override
  String get progressRegularTrackingHelpsYouUnderstandYourHabits =>
      'Regelmäßiges Tracken schafft zuerst Klarheit.';

  @override
  String get progressSaveMeasurement => 'Messung speichern';

  @override
  String get progressTarget100 => 'ZIEL = 100 %';

  @override
  String get progressTrackingConsistency => 'Tracking-Konstanz';

  @override
  String get progressTryAgain => 'Erneut versuchen';

  @override
  String get progressUpToTheLast28Days => 'Die letzten maximal 28 Tage';

  @override
  String progressValueDays(String arg0) {
    return '$arg0 Tage';
  }

  @override
  String progressValueDaysAlreadyGiveABetterFoundation(String arg0) {
    return '$arg0 Tage liefern bereits eine bessere Grundlage als ein einzelner Tageswert.';
  }

  @override
  String progressValueOfValueDaysWithEntriesValue(
    String arg0,
    String arg1,
    String arg2,
  ) {
    return '$arg0 von $arg1 Tagen mit Einträgen · $arg2 Mahlzeiten ausgewertet';
  }

  @override
  String progressValueValueKcalValueGProtein(
    String arg0,
    String arg1,
    String arg2,
  ) {
    return '$arg0: $arg1 kcal · $arg2 g Protein';
  }

  @override
  String progressValueValueKgInThisPeriod(String arg0, String arg1) {
    return '$arg0$arg1 kg im Zeitraum';
  }

  @override
  String progressValueValueNoEntry(String arg0) {
    return '$arg0 · kein Eintrag';
  }

  @override
  String get progressWaistCircumferenceMustBeBetween30And =>
      'Der Taillenumfang muss zwischen 30 und 300 cm liegen.';

  @override
  String get progressWaistOptional => 'Taille (optional)';

  @override
  String get progressWeight => 'Gewicht';

  @override
  String get progressWeightAndOptionalWaistCircumferenceViewedCalmly =>
      'Gewicht und optionaler Taillenumfang – ruhig und langfristig betrachtet';

  @override
  String get progressWhatYourDataSays => 'Was deine Daten sagen';

  @override
  String get progressYouAreHeadingInTheRightDirection =>
      'Deine Richtung stimmt – Beständigkeit bringt jetzt am meisten.';

  @override
  String get progressYouAreVeryCloseToYourPersonal =>
      'Du liegst sehr nah an deinen persönlichen Zielen.';

  @override
  String get progressYourActualTrendStartsHere =>
      'Dein echter Verlauf beginnt hier';

  @override
  String get progressYourAverageProteinIsCloseToYour =>
      'Dein Proteindurchschnitt liegt nah am Ziel. Das unterstützt Sättigung und Muskelerhalt.';

  @override
  String get progressYourFirstEntryMakesTrendsVisible =>
      'Dein erster Eintrag macht Trends sichtbar.';

  @override
  String get progressYourProgress => 'Dein Fortschritt';

  @override
  String get progressYourProgressDataCouldNotBeLoaded =>
      'Deine Fortschrittsdaten konnten nicht geladen werden.';

  @override
  String get progressYourRhythm => 'DEIN RHYTHMUS';

  @override
  String get sharedCatalogReload => 'Erneut laden';

  @override
  String get sharedCatalogReloading => 'Lädt …';

  @override
  String get sharedCatalogUnavailable =>
      'Der Katalog konnte nicht geladen werden. Du siehst vorerst nur Beispiele. Prüfe deine Verbindung.';

  @override
  String get sharedImprint => 'Impressum';

  @override
  String get sharedPrivacy => 'Datenschutz';

  @override
  String get sharedTerms => 'AGB';

  @override
  String get sharedTheLinkCouldNotBeOpenedPlease =>
      'Der Link konnte nicht geöffnet werden. Bitte versuche es später noch einmal.';

  @override
  String get sharedWithdrawFromContract => 'Vertrag widerrufen';

  @override
  String get sharedWithdrawal => 'Widerruf';

  @override
  String get subscriptionAiPhoto => 'KI-Foto';

  @override
  String get subscriptionAiPhotoIsPartOfPremium =>
      'KI-Foto ist Teil von Premium';

  @override
  String get subscriptionAiPhotoRecognition => 'KI-Foto-Erkennung';

  @override
  String get subscriptionAiPhotoYourPersonalCoachAndAll =>
      'KI-Foto, dein persönlicher Coach und alle Rezepte – für weniger Aufwand und mehr Klarheit beim Essen.';

  @override
  String get subscriptionAll => 'Alle';

  @override
  String get subscriptionAllRecipes => 'Alle Rezepte';

  @override
  String get subscriptionAllRecipesAreAvailableWithPremium =>
      'Alle Rezepte gibt es mit Premium';

  @override
  String get subscriptionAppleAccount => 'Apple Account';

  @override
  String get subscriptionAppleRefundButton => 'Rückzahlung bei Apple anfordern';

  @override
  String get subscriptionAppleRefundFallback =>
      'Falls sich nichts geöffnet hat: Fordere die Rückzahlung unter reportaproblem.apple.com an.';

  @override
  String get subscriptionAppleRefundSubmitted =>
      'Apple hat deine Anfrage erhalten und informiert dich über die Entscheidung.';

  @override
  String get subscriptionAppleRefundText =>
      'Dein Widerruf ist bei uns eingegangen. Zahlungen im App Store kann aber nur Apple erstatten. Fordere die Rückzahlung deshalb bei Apple an.';

  @override
  String get subscriptionAppleRefundTitle => 'Gekauft im App Store?';

  @override
  String get subscriptionBilledEveryMonth => 'jeden Monat berechnet';

  @override
  String subscriptionBilledOnceAYearSaveValueCompared(String arg0) {
    return 'einmal im Jahr berechnet – du sparst $arg0 gegenüber monatlich';
  }

  @override
  String get subscriptionCancelMonthly => 'monatlich kündbar';

  @override
  String get subscriptionChooseAPremiumSubscription => 'Premium-Abo wählen';

  @override
  String get subscriptionClose => 'Schließen';

  @override
  String get subscriptionComingSoon => 'Bald verfügbar';

  @override
  String get subscriptionConfirmWithdrawal => 'Widerruf bestätigen';

  @override
  String get subscriptionContinueWithTheFreeVersion =>
      'Weiter mit der kostenlosen Version';

  @override
  String get subscriptionDiaryMacrosStreak => 'Tagebuch, Makros & Serie';

  @override
  String get subscriptionDone => 'Fertig';

  @override
  String get subscriptionEmailForAcknowledgement =>
      'E-Mail für die Bestätigung';

  @override
  String subscriptionEquivalentToValuePerMonth(String arg0) {
    return 'entspricht $arg0 pro Monat';
  }

  @override
  String get subscriptionForExampleTheOrderNumberFromThe =>
      'Zum Beispiel die Bestellnummer aus der Kaufbestätigung von Google Play oder Apple';

  @override
  String get subscriptionFree => 'Kostenlos';

  @override
  String get subscriptionFreeOrPremium => 'Kostenlos oder Premium?';

  @override
  String subscriptionFreeTrialUntilValueItEndsAutomatically(
    String arg0,
    String arg1,
  ) {
    return 'Kostenlose Testphase bis $arg0. Danach beginnt das bezahlte Abo, wenn du nicht vorher in den Abo-Einstellungen von $arg1 kündigst.';
  }

  @override
  String subscriptionFreeTrialValueDaysStoreOnly(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Kostenlose Testphase: $arg0 Tage, einmal pro $arg2 und nur mit hinterlegtem Zahlungsmittel. Wenn du nicht vor Ende der Testphase in den Abo-Einstellungen von $arg3 kündigst, beginnt das bezahlte Abo und verlängert sich automatisch zum Preis des gewählten Tarifs.\n\n$arg1';
  }

  @override
  String get subscriptionGenerousAiAllowance => 'Großzügiges KI-Kontingent';

  @override
  String get subscriptionGet => 'Hol dir ';

  @override
  String get subscriptionGladYouAreHere => 'Schön, dass du da bist';

  @override
  String get subscriptionGoogleAccount => 'Google-Konto';

  @override
  String get subscriptionHereYouCanWithdrawFromYourLookin =>
      'Hier widerrufst du deinen Vertrag über Lookin Premium. Einen Grund musst du nicht angeben. Du bekommst sofort eine Eingangsbestätigung mit Datum und Uhrzeit.';

  @override
  String get subscriptionIncluded => 'enthalten';

  @override
  String get subscriptionLetSGo => 'Los geht’s';

  @override
  String get subscriptionLookinCoachAiChat => 'Lookin Coach (KI-Chat)';

  @override
  String get subscriptionManageSubscription => 'Abo verwalten';

  @override
  String get subscriptionMonthly => 'Monatlich';

  @override
  String get subscriptionMoreRecipesWithPremium => 'Mehr Rezepte mit Premium';

  @override
  String get subscriptionNew => 'Neues';

  @override
  String get subscriptionNoActiveSubscriptionWasFoundForThis =>
      'Für dieses Store-Konto wurde kein aktives Abo gefunden.';

  @override
  String get subscriptionNotADeveloperAccount => 'Kein Entwickler-Konto.';

  @override
  String get subscriptionNotIncluded => 'nicht enthalten';

  @override
  String get subscriptionOrderNumberOrNoteOptional =>
      'Bestellnummer oder Hinweis (freiwillig)';

  @override
  String get subscriptionPaymentIsHandledSecurelyByTheStore =>
      'Die Zahlung läuft sicher über den Store. Lookin sieht und speichert keine Zahlungsdaten.';

  @override
  String get subscriptionPaymentsAreBeingSetUp =>
      'Bezahlung wird gerade eingerichtet';

  @override
  String get subscriptionPerMonth => 'pro Monat';

  @override
  String get subscriptionPerYear => 'pro Jahr';

  @override
  String get subscriptionPleaseConfirmFirstThatLookinPremiumShould =>
      'Bitte bestätige zuerst, dass Lookin Premium sofort beginnen soll.';

  @override
  String get subscriptionPleaseTakeAScreenshotOfThisAcknowledgement =>
      'Bitte mach einen Screenshot dieser Bestätigung. Die E-Mail-Bestätigung konnte gerade nicht gesendet werden; wir schicken sie dir nach.';

  @override
  String subscriptionPopularSavings(String savings) {
    return ', beliebt, $savings Prozent günstiger als monatlich';
  }

  @override
  String subscriptionPopularValue(String arg0) {
    return 'Beliebt · −$arg0 %';
  }

  @override
  String get subscriptionPremiumInTheAndroidApp => 'Premium in der Android-App';

  @override
  String get subscriptionPremiumIsActive => 'Premium ist aktiv';

  @override
  String get subscriptionPremiumIsActiveThankYouForYour =>
      'Premium ist aktiv. Danke für deine Unterstützung!';

  @override
  String get subscriptionPreparingYourLookin =>
      'Dein Lookin wird vorbereitet …';

  @override
  String get subscriptionProfileDailyTargets => 'Profil & Tagesziele';

  @override
  String get subscriptionPurchaseBusy => 'Kauf wird vorbereitet …';

  @override
  String get subscriptionPurchaseCancelledNothingWasCharged =>
      'Kauf abgebrochen. Es wurde nichts berechnet.';

  @override
  String get subscriptionRecipes => 'Rezepte';

  @override
  String subscriptionReferenceNumberValue(String arg0) {
    return 'Vorgangsnummer: $arg0';
  }

  @override
  String get subscriptionRefundThroughGooglePlay =>
      'Die Rückzahlung erfolgt über Google Play auf das dort verwendete Zahlungsmittel.';

  @override
  String get subscriptionRestorePurchases => 'Käufe wiederherstellen';

  @override
  String get subscriptionRestorePurchasesComingSoon =>
      'Käufe wiederherstellen – bald verfügbar';

  @override
  String get subscriptionRestoringPurchasesIsOnlyAvailableInThe =>
      'Käufe wiederherstellen ist nur in der Lookin-App möglich, sobald die Bezahlung dort freigeschaltet ist. Hier gibt es keine Käufe, die wiederhergestellt werden müssten.';

  @override
  String get subscriptionSearchBarcodeCustomFoods =>
      'Suche, Barcode & eigene Lebensmittel';

  @override
  String get subscriptionSubscribeInTheLookinAppForAndroid =>
      'Das Abo schließt du in der Lookin-App für Android ab. Im Browser wird nichts gekauft oder berechnet.';

  @override
  String get subscriptionSubscribeMonthly => 'Monatlich abonnieren';

  @override
  String get subscriptionSubscribePaid => 'Kostenpflichtig abonnieren';

  @override
  String get subscriptionSubscribeYearly => 'Jährlich abonnieren';

  @override
  String get subscriptionSubscriptionBelongsToAnotherAccount =>
      'Dieses Abo gehört zu einem anderen Lookin-Konto. Melde dich mit diesem Konto an, um Premium zu nutzen. Es wurde nichts berechnet.';

  @override
  String get subscriptionSubscriptionManagementCouldNotBeOpenedOpen =>
      'Die Abo-Verwaltung konnte nicht geöffnet werden. Öffne die Abo-Einstellungen direkt im Store.';

  @override
  String get subscriptionSubscriptionPlans => 'Abo-Pläne';

  @override
  String subscriptionSubscriptionPricesValuePaymentAndBillingAre(
    String arg0,
    String arg1,
    String arg2,
  ) {
    return 'Abo-Preise: $arg0 Bezahlung und Abrechnung laufen über $arg1. Ein Abo verlängert sich automatisch zum selben Preis, bis du es kündigst. Du kündigst jederzeit in den Abo-Einstellungen von $arg2, wirksam zum Ende des Abrechnungszeitraums. Das Jahresabo läuft zunächst ein Jahr; danach verlängert es sich auf unbestimmte Zeit und ist jederzeit mit höchstens einem Monat Frist kündbar (AGB, Ziffer 5). Innerhalb von 14 Tagen kannst du den Vertrag widerrufen: Profil › „Vertrag widerrufen“. KI-Coach und KI-Foto brauchen deine Einwilligung zur Weitergabe an OpenAI.';
  }

  @override
  String subscriptionSubscriptionPricesValueValueASubscriptionRenews(
    String arg0,
    String arg1,
  ) {
    return 'Abo-Preise ($arg0): $arg1 Ein Abo verlängert sich automatisch zum selben Preis und ist jederzeit zum Ende des Abrechnungszeitraums kündbar.';
  }

  @override
  String get subscriptionSubscriptionsAreAvailableInTheLookinApp =>
      'Abos gibt es in der Lookin-App für Android. Im Browser wurde nichts gekauft und nichts berechnet.';

  @override
  String get subscriptionTakeAPhotoLookinEstimatesFoodsAnd =>
      'Foto machen – Lookin schätzt Lebensmittel und Mengen. Du prüfst alles vor dem Speichern.';

  @override
  String subscriptionTermsShort(String arg0) {
    return 'Abrechnung über den Store · verlängert sich automatisch · jederzeit in den Abo-Einstellungen von $arg0 kündbar, wirksam zum Ende des Abrechnungszeitraums';
  }

  @override
  String subscriptionTermsShortTrial(String arg0) {
    return 'Testphase nur mit hinterlegtem Zahlungsmittel · danach beginnt das Abo und verlängert sich automatisch · bis zum Ende der Testphase in den Abo-Einstellungen von $arg0 kündbar, dann wird nichts berechnet';
  }

  @override
  String get subscriptionTheAppStore => 'dem App Store';

  @override
  String get subscriptionTheAppStoreVia => 'den App Store';

  @override
  String get subscriptionTheLookinCoachIsPartOfPremium =>
      'Der Lookin Coach ist Teil von Premium';

  @override
  String get subscriptionTheStoreIsCurrentlyUnavailableNothingWas =>
      'Der Store ist gerade nicht erreichbar. Es wurde nichts berechnet – versuche es später noch einmal.';

  @override
  String subscriptionThenValue(String arg0) {
    return 'Danach kostenpflichtig: $arg0';
  }

  @override
  String get subscriptionUnexpectedResponse => 'Unerwartete Antwort.';

  @override
  String get subscriptionUnlockAllRecipes => 'Alle Rezepte freischalten';

  @override
  String get subscriptionUpTo100AiRequestsADay =>
      'Mit Abo bis zu 100 KI-Anfragen pro Tag (Coach und Foto zusammen), in der Testphase bis zu 50.';

  @override
  String subscriptionValueDayFreeTrial(String arg0) {
    return '$arg0 Tage kostenlos testen';
  }

  @override
  String subscriptionValueDayFreeTrialThenSubscription(String arg0) {
    return '$arg0 Tage kostenlos testen · danach Abo, jederzeit kündbar';
  }

  @override
  String subscriptionValueFreeValuePremiumValue(
    String arg0,
    String arg1,
    String arg2,
  ) {
    return '$arg0. Kostenlos: $arg1. Premium: $arg2.';
  }

  @override
  String subscriptionValueItEndsAutomaticallyAtNoCost(
    String arg0,
    String arg1,
  ) {
    return '$arg0 Danach beginnt das bezahlte Abo. Bis dahin kannst du jederzeit in den Abo-Einstellungen von $arg1 kündigen.';
  }

  @override
  String subscriptionValueNothingWasPurchasedOrChargedTry(String arg0) {
    return '$arg0. Es wurde nichts gekauft und nichts berechnet.';
  }

  @override
  String subscriptionValueUnlocked(String arg0) {
    return '$arg0 freigeschaltet';
  }

  @override
  String subscriptionValueUntilThenNothingIsPurchasedOr(String arg0) {
    return '$arg0 – bis dahin wird nichts gekauft oder berechnet.';
  }

  @override
  String subscriptionWeHaveSentAnAcknowledgementToValue(String arg0) {
    return 'Wir haben dir eine Eingangsbestätigung an $arg0 geschickt.';
  }

  @override
  String subscriptionWelcomeCoachText(String arg0) {
    return 'Persönliche Antworten – bis zu $arg0 Fragen pro Tag';
  }

  @override
  String get subscriptionWelcomeMember => 'Premium-Mitglied';

  @override
  String get subscriptionWelcomeMemberLabel => 'MITGLIED';

  @override
  String get subscriptionWelcomeNextRenewal => 'Nächste Verlängerung';

  @override
  String get subscriptionWelcomePhotoText =>
      'Mahlzeit fotografieren, Nährwerte in Sekunden schätzen lassen';

  @override
  String get subscriptionWelcomeRecipesText =>
      'Jedes Rezept mit Profi-Tipps zu jedem Schritt';

  @override
  String get subscriptionWelcomeRenewsNote =>
      'Verlängert sich automatisch · jederzeit im Store kündbar';

  @override
  String get subscriptionWelcomeThanks =>
      'Danke für deine Unterstützung! Dein Abo ist aktiv.';

  @override
  String get subscriptionWelcomeTitle => 'Willkommen bei Lookin Premium';

  @override
  String get subscriptionWelcomeTrialEnds => 'Testphase endet';

  @override
  String subscriptionWelcomeTrialPlan(String arg0) {
    return 'Premium-Test · $arg0 Tage';
  }

  @override
  String get subscriptionWelcomeUnlockedHeading =>
      'Jetzt für dich freigeschaltet';

  @override
  String get subscriptionWithPremiumAllRecipes => 'Mit Premium: alle Rezepte';

  @override
  String get subscriptionWithdrawFromContract => 'Vertrag widerrufen';

  @override
  String subscriptionWithoutASubscriptionValueValueOfRecipes(
    String arg0,
    String arg1,
  ) {
    return 'Ohne Abo: $arg0$arg1% der Rezepte';
  }

  @override
  String get subscriptionYearly => 'Jährlich';

  @override
  String subscriptionYearlyValueValueBilledOnceAYear(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
    String arg4,
  ) {
    return 'Jährlich $arg0 $arg1, einmal im Jahr berechnet ($arg2). Monatlich $arg3 $arg4. Alle Preise inkl. MwSt.';
  }

  @override
  String get subscriptionYourAiChatForNutritionAndFitness =>
      'Dein KI-Chat für Ernährung und Fitness, abgestimmt auf dein Ziel und deine Tageswerte.';

  @override
  String get subscriptionYourConsentCouldNotBeSavedJust =>
      'Deine Zustimmung konnte gerade nicht gespeichert werden. Bitte prüfe deine Verbindung und versuche es erneut. Es wurde nichts gekauft.';

  @override
  String subscriptionYourFreeTrialIsActiveItEnds(String arg0) {
    return 'Deine kostenlose Testphase läuft. Danach beginnt das bezahlte Abo, wenn du nicht vorher in den Abo-Einstellungen von $arg0 kündigst.';
  }

  @override
  String subscriptionYourFreeTrialLastsValueDays(String arg0) {
    return 'Deine kostenlose Testphase läuft $arg0 Tage.';
  }

  @override
  String subscriptionYourFreeTrialRunsUntilValue(String arg0) {
    return 'Deine kostenlose Testphase läuft bis $arg0.';
  }

  @override
  String get subscriptionYourName => 'Dein Name';

  @override
  String get subscriptionYourPaymentIsStillBeingReviewedPremium =>
      'Deine Zahlung ist noch in Prüfung. Premium wird freigeschaltet, sobald der Store sie bestätigt.';

  @override
  String get subscriptionYourPremiumSubscriptionIsActive =>
      'Dein Premium-Abo ist aktiv.';

  @override
  String subscriptionYourPremiumSubscriptionIsActiveUntilValue(String arg0) {
    return 'Dein Premium-Abo ist aktiv bis $arg0.';
  }

  @override
  String get subscriptionYourPurchaseHasBeenReceivedActivationIs =>
      'Dein Kauf ist angekommen. Die Freischaltung dauert noch einen Moment – öffne Lookin gleich noch einmal. Es wird nichts doppelt berechnet.';

  @override
  String get subscriptionYourWithdrawalCouldNotBeSubmittedJust =>
      'Der Widerruf konnte gerade nicht übermittelt werden. Bitte versuche es erneut oder widerrufe per E-Mail an lookinsupport@gmail.com. Es zählt, dass du die Erklärung innerhalb der Frist absendest.';

  @override
  String subscriptionYourWithdrawalWasReceivedOnValue(String arg0) {
    return 'Dein Widerruf ist am $arg0 eingegangen.';
  }

  @override
  String get valuesActivityActive => 'Aktiv';

  @override
  String get valuesActivityLow => 'Wenig aktiv';

  @override
  String get valuesActivityModerate => 'Moderat aktiv';

  @override
  String get valuesActivityVeryActive => 'Sehr aktiv';

  @override
  String get valuesAllergiesNone => 'Keine angegeben';

  @override
  String get valuesDifficultyEasy => 'Einfach';

  @override
  String get valuesDifficultyHard => 'Anspruchsvoll';

  @override
  String get valuesDifficultyMedium => 'Mittel';

  @override
  String get valuesGoalBuildMuscle => 'Muskeln aufbauen';

  @override
  String get valuesGoalEatHealthier => 'Gesünder ernähren';

  @override
  String get valuesGoalLoseFat => 'Fett verlieren';

  @override
  String get valuesGoalMaintain => 'Gewicht halten';

  @override
  String get valuesMealBreakfast => 'Frühstück';

  @override
  String get valuesMealDinner => 'Abendessen';

  @override
  String get valuesMealLunch => 'Mittagessen';

  @override
  String get valuesMealSnack => 'Snack';

  @override
  String get valuesNutritionBalanced => 'Ausgewogen';

  @override
  String get valuesNutritionPescatarian => 'Pescetarisch';

  @override
  String get valuesNutritionVegan => 'Vegan';

  @override
  String get valuesNutritionVegetarian => 'Vegetarisch';

  @override
  String get valuesTagBreakfast => 'Frühstück';

  @override
  String get valuesTagBudget => 'Budget';

  @override
  String get valuesTagDinner => 'Abendessen';

  @override
  String get valuesTagForYou => 'Für dich';

  @override
  String get valuesTagHighProtein => 'High Protein';

  @override
  String get valuesTagLunch => 'Mittagessen';

  @override
  String get valuesTagMealPrep => 'Meal Prep';

  @override
  String get valuesTagPescatarian => 'Pescetarisch';

  @override
  String get valuesTagQuick => 'Schnell';

  @override
  String get valuesTagSnack => 'Snack';

  @override
  String get valuesTagVegan => 'Vegan';

  @override
  String get valuesTagVegetarian => 'Vegetarisch';
}
