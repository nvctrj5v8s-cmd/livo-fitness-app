// l10n-ignore-file: switch keys are canonical source data, not UI copy.
// Canonical source values remain unchanged in storage and safety checks.
import 'l10n.dart';

abstract final class DisplayText {
  static String allergies(String source) =>
      source.split(',').map((s) => of(s.trim())).join(', ');
  static String of(String source) => switch (source) {
    'Zutat' => L10n.current.displayIngredientSingular,
    'Zutaten' => L10n.current.displayIngredientsPlural,
    'Schritt' => L10n.current.displayStepSingular,
    'Schritte' => L10n.current.displayStepsPlural,
    'Eintrag' => L10n.current.displayEntrySingular,
    'Einträge' => L10n.current.displayEntriesPlural,
    'Portionen' => L10n.current.displayPortionsPlural,
    "Bitte melde dich zuerst an." => L10n.current.corePleaseSignInFirst,
    "Das angemeldete Konto hat sich geändert." =>
      L10n.current.coreTheSignedInAccountHasChanged,
    "Die Antwort des Servers ist ungültig." =>
      L10n.current.coreTheServerResponseIsInvalid,
    "Der Datenexport ist unvollständig." =>
      L10n.current.coreTheDataExportIsIncomplete,
    "Bitte Passwort eingeben." => L10n.current.corePleaseEnterYourPassword,
    "Das Konto konnte nicht gelöscht werden." =>
      L10n.current.coreYourAccountCouldNotBeDeleted,
    "Das Konto wurde gelöscht, aber lokale Daten konnten nicht vollständig entfernt werden." =>
      L10n.current.coreYourAccountWasDeletedButSomeLocal,
    "Ungültiger KI-Nährwert." => L10n.current.coreInvalidAiNutritionValue,
    "Ungültiges erkanntes Lebensmittel." =>
      L10n.current.coreInvalidRecognisedFood,
    "Diese KI-Funktion ist Teil von Lookin Premium." =>
      L10n.current.coreThisAiFeatureIsPartOfLookin,
    "Schreib zuerst eine kurze Frage." =>
      L10n.current.coreWriteAShortQuestionFirst,
    "Der Coach konnte gerade keine Antwort formulieren. Bitte versuche es noch einmal." =>
      L10n.current.coreTheCoachCouldNotPutTogetherAn,
    "Der Coach ist gerade nicht erreichbar. Bitte versuche es gleich noch einmal." =>
      L10n.current.coreTheCoachIsCurrentlyUnavailablePleaseTry,
    "Dein Chatverlauf konnte nicht geladen werden." =>
      L10n.current.coreYourChatHistoryCouldNotBeLoaded,
    "Dein Chatverlauf konnte gerade nicht geladen werden." =>
      L10n.current.coreYourChatHistoryCouldNotBeLoaded2,
    "Dein Chatverlauf konnte gerade nicht gelöscht werden. Bitte versuche es gleich noch einmal." =>
      L10n.current.coreYourChatHistoryCouldNotBeDeleted,
    "Das Foto ist zu groß. Bitte wähle ein kleineres Bild." =>
      L10n.current.coachThePhotoIsTooLargePleaseChoose,
    "Auf dem Foto konnte gerade nichts sicher erkannt werden." =>
      L10n.current.coreNothingCouldBeConfidentlyRecognisedInThis,
    "Die Bildanalyse ist gerade nicht erreichbar. Bitte versuche es erneut." =>
      L10n.current.coreImageAnalysisIsCurrentlyUnavailablePleaseTry,
    "Das Foto ist zu groß. Bitte nimm ein kleineres Bild auf." =>
      L10n.current.coreThePhotoIsTooLargePleaseTake,
    "Die Fotoanalyse hat keine gültige Antwort erhalten." =>
      L10n.current.corePhotoAnalysisDidNotReturnAValid,
    "Auf dem Foto konnten keine Lebensmittel sicher erkannt werden." =>
      L10n.current.coreNoFoodsCouldBeConfidentlyRecognisedIn,
    "Auf dem Foto konnten keine erlaubten Lebensmittel sicher erkannt werden." =>
      L10n.current.coreNoPermittedFoodsCouldBeConfidentlyRecognised,
    "Die erkannten Werte waren unvollständig. Bitte versuche es erneut." =>
      L10n.current.coreTheRecognisedValuesWereIncompletePleaseTry,
    "Bitte melde dich erneut an, um die Fotoanalyse zu verwenden." =>
      L10n.current.corePleaseSignInAgainToUsePhoto,
    "Dein KI-Limit für heute ist erreicht. Morgen kannst du wieder analysieren." =>
      L10n.current.coreYouHaveReachedTodaySAiLimit,
    "Die Fotoanalyse ist gerade nicht erreichbar. Bitte versuche es erneut." =>
      L10n.current.corePhotoAnalysisIsCurrentlyUnavailablePleaseTry,
    "Die Fotoanalyse ist gerade nicht erreichbar. Bitte prüfe deine Verbindung." =>
      L10n.current.corePhotoAnalysisIsCurrentlyUnavailablePleaseCheck,
    "Der Coach hat keine gültige Antwort geschickt. Bitte versuche es noch einmal." =>
      L10n.current.coreTheCoachDidNotSendAValid,
    "Der Coach braucht gerade zu lange. Bitte versuche es noch einmal." =>
      L10n.current.coreTheCoachIsTakingTooLongPlease,
    "Keine Verbindung zum Coach. Bitte prüfe deine Internetverbindung und versuche es erneut." =>
      L10n.current.coreNoConnectionToTheCoachPleaseCheck,
    "Deine Anmeldung ist abgelaufen. Bitte melde dich erneut an." =>
      L10n.current.coreYourSessionHasExpiredPleaseSignIn,
    "Dein KI-Tageslimit ist erreicht. Morgen kannst du wieder schreiben." =>
      L10n.current.coreYouHaveReachedYourDailyAiLimit,
    "Bitte formuliere deine Frage etwas anders." =>
      L10n.current.corePleaseRephraseYourQuestion,
    "Konto fehlt." => L10n.current.coreNoAccountAvailable,
    "Das Profilbild muss ein JPEG mit höchstens 1 MB sein." =>
      L10n.current.coreYourProfilePictureMustBeAJpeg,
    "Dieser Barcode ist ungültig." => L10n.current.coreThisBarcodeIsInvalid,
    "Die Produktantwort war unvollständig." =>
      L10n.current.coreTheProductResponseWasIncomplete,
    "Dieses Produkt wurde nicht gefunden." =>
      L10n.current.coreThisProductWasNotFound,
    "Dieses Produkt entspricht nicht den Halal-Inhaltsregeln von Lookin." =>
      L10n.current.diaryThisProductDoesNotMeetLookinS,
    "Bitte melde dich erneut an und versuche den Scan danach noch einmal." =>
      L10n.current.corePleaseSignInAgainThenTryScanning,
    "Bitte kurz warten, bevor du den nächsten Barcode suchst." =>
      L10n.current.diaryPleaseWaitAMomentBeforeSearchingFor,
    "Die Barcode-Suche hat gerade keine gültige Serverantwort erhalten. Bitte versuche es später erneut." =>
      L10n.current.coreBarcodeSearchDidNotReceiveAValid,
    "Die Barcode-Suche ist gerade nicht erreichbar. Bitte versuche es später erneut." =>
      L10n.current.coreBarcodeSearchIsCurrentlyUnavailablePleaseTry,
    "USDA-Lebensmitteldaten" => L10n.current.coreUsdaFoodData,
    "Lookin-Katalog" => L10n.current.coreLookinCatalogue,
    "Konto geändert." => L10n.current.coreAccountChanged,
    "Bitte melde dich an, bevor du etwas speicherst." =>
      L10n.current.corePleaseSignInBeforeSavingAnything,
    "Muss größer als 0 sein." => L10n.current.coreMustBeGreaterThan0,
    "Der Lebensmitteleintrag ist unvollständig." =>
      L10n.current.coreTheFoodEntryIsIncomplete,
    "Der Mahlzeiteneintrag ist nicht gespeichert." =>
      L10n.current.coreTheMealEntryHasNotBeenSaved,
    "Der eigene Eintrag ist nicht gespeichert." =>
      L10n.current.coreTheCustomEntryHasNotBeenSaved,
    "Dieses Rezept hat noch keine gespeicherten Zutaten." =>
      L10n.current.coreThisRecipeHasNoSavedIngredientsYet,
    "Bitte erneut anmelden." => L10n.current.corePleaseSignInAgain,
    "Bitte eine Menge größer als 0 eingeben." =>
      L10n.current.diaryPleaseEnterAnAmountGreaterThan0,
    "Bitte Zucker, gesättigte Fettsäuren und Salz vom Etikett ergänzen." =>
      L10n.current.corePleaseAddSugarSaturatedFatAndSalt,
    "Nährwerte müssen gültige Zahlen ab 0 sein." =>
      L10n.current.coreNutritionValuesMustBeValidNumbersOf,
    "Die Menge oder ein Nährwert ist zu groß." =>
      L10n.current.coreTheAmountOrANutritionValueIs,
    "Zucker darf nicht höher als die Kohlenhydrate sein." =>
      L10n.current.coreSugarCannotExceedCarbohydrates,
    "Gesättigte Fettsäuren dürfen nicht höher als Fett sein." =>
      L10n.current.coreSaturatedFatCannotExceedTotalFat,
    "Unbekannte Nährwert-Version." =>
      L10n.current.coreUnknownNutritionDataVersion,
    "Unbekannte Nährwert-Basis." => L10n.current.coreUnknownNutritionBasis,
    "Bitte zuerst anmelden." => L10n.current.corePleaseSignInFirst2,
    "Das Lebensmittel konnte nicht mehr gefunden werden." =>
      L10n.current.coreThisFoodCouldNoLongerBeFound,
    "Allergien & Unverträglichkeiten" =>
      L10n.current.allergiesAllergiesIntolerances,
    "Auswählen" => L10n.current.allergiesSelect,
    "Ändern" => L10n.current.allergiesChange,
    "Keine angegeben" => L10n.current.allergiesNoneSpecified,
    "Möglicher Allergenkonflikt" =>
      L10n.current.allergiesPossibleAllergenConflict,
    "Allergieangaben fehlen" => L10n.current.allergiesAllergyInformationMissing,
    "Bitte Zutatenliste prüfen" =>
      L10n.current.allergiesPleaseCheckTheIngredientsList,
    "Zu diesem Eintrag liegen keine verlässlichen Allergen- oder Zutatenangaben vor." =>
      L10n.current.allergiesNoReliableAllergenOrIngredientInformationIs,
    "In den vorhandenen Angaben wurde kein gewählter Auslöser erkannt. Das ist keine Sicherheitsgarantie." =>
      L10n.current.allergiesNoneOfYourSelectedTriggersWereRecognised,
    "Was soll die App beachten?" =>
      L10n.current.allergiesWhatShouldTheAppTakeIntoAccount,
    "Schließen" => L10n.current.subscriptionClose,
    "Wähle bekannte Allergene aus. Laktose ist separat als Unverträglichkeit aufgeführt." =>
      L10n.current.allergiesSelectKnownAllergensLactoseIsListedSeparately,
    "Weitere Allergien / Unverträglichkeiten" =>
      L10n.current.allergiesOtherAllergiesIntolerances,
    "z. B. Kokos, Histamin" => L10n.current.allergiesEGCoconutHistamine,
    "Mehrere Angaben mit Komma trennen." =>
      L10n.current.allergiesSeparateMultipleEntriesWithCommas,
    "Produktangaben können fehlen oder veraltet sein. Prüfe bei einer Allergie immer die aktuelle Verpackung und mögliche Kreuzkontamination." =>
      L10n.current.allergiesProductInformationMayBeMissingOrOutdated,
    "Freiwillige Gesundheitsangabe: Sie wird in deinem Konto gespeichert und dem Lookin Coach als Kontext mitgegeben, damit er nichts Unpassendes vorschlägt. Du kannst sie hier jederzeit ändern oder leeren." =>
      L10n.current.allergiesOptionalHealthInformationItIsSavedIn,
    "Auswahl speichern" => L10n.current.allergiesSaveSelection,
    "Anmeldung wird geprüft" => L10n.current.authCheckingYourSignIn,
    "Dein Lookin-Konto ist bereit." =>
      L10n.current.authYourLookinAccountIsReady,
    "Verbindung fehlgeschlagen. Bitte versuche es erneut." =>
      L10n.current.authConnectionFailedPleaseTryAgain,
    "Gib zuerst deine E-Mail-Adresse ein." =>
      L10n.current.authEnterYourEmailAddressFirst,
    "Falls die Adresse noch nicht bestätigt ist, haben wir dir eine neue Bestätigungs-Mail geschickt. Schau auch im Spam-Ordner nach." =>
      L10n.current.authIfYourAddressHasNotBeenConfirmed,
    "Falls es ein Lookin-Konto mit dieser Adresse gibt, haben wir dir einen Link zum Zurücksetzen geschickt. Schau auch im Spam-Ordner nach." =>
      L10n.current.authIfALookinAccountExistsWithThis,
    "E-Mail oder Passwort ist nicht korrekt. Hast du dich mit dieser Adresse schon einmal registriert, gilt das damalige Passwort. Setze es sonst über „Passwort vergessen?“ zurück." =>
      L10n.current.authYourEmailOrPasswordIsIncorrectIf,
    "Deine E-Mail-Adresse ist noch nicht bestätigt. Tippe auf den Link in unserer E-Mail oder fordere unten eine neue an." =>
      L10n.current.authYourEmailAddressHasNotBeenConfirmed,
    "Für diese E-Mail gibt es bereits ein Konto." =>
      L10n.current.authAnAccountAlreadyExistsForThisEmail,
    "Zu viele Versuche. Bitte warte kurz und versuche es dann erneut." =>
      L10n.current.authTooManyAttemptsPleaseWaitAMoment,
    "Dieses Passwort ist zu unsicher. Wähle ein anderes." =>
      L10n.current.authThisPasswordIsTooEasyToGuess,
    "Das Passwort muss mindestens acht Zeichen haben." =>
      L10n.current.authYourPasswordMustContainAtLeastEight,
    "Bitte prüfe deine E-Mail-Adresse." =>
      L10n.current.authPleaseCheckYourEmailAddress,
    "Das hat gerade nicht geklappt. Bitte versuche es später erneut." =>
      L10n.current.authThatDidNotWorkJustNowPlease,
    "Deine Adresse ist noch nicht bestätigt. Tippe zuerst auf den Link in der E-Mail und komm dann hierher zurück." =>
      L10n.current.authYourAddressHasNotBeenConfirmedYet,
    "Dein Start." => L10n.current.authYourStart,
    "Willkommen zurück." => L10n.current.authWelcomeBack,
    "Ein Konto für Ziele, Ernährung und Fortschritt." =>
      L10n.current.authOneAccountForYourGoalsNutritionAnd,
    "Einloggen und direkt dort weitermachen, wo du aufgehört hast." =>
      L10n.current.authSignInAndPickUpWhereYou,
    "Dein Name" => L10n.current.subscriptionYourName,
    "Bitte gib deinen Namen ein." => L10n.current.authPleaseEnterYourName,
    "E-Mail-Adresse" => L10n.current.authEmailAddress,
    "Bitte gib eine gültige E-Mail ein." =>
      L10n.current.authPleaseEnterAValidEmailAddress,
    "Passwort" => L10n.current.authPassword,
    "Passwort anzeigen" => L10n.current.profileShowPassword,
    "Passwort verbergen" => L10n.current.profileHidePassword,
    "Mindestens acht Zeichen." => L10n.current.authAtLeastEightCharacters,
    "Passwort vergessen?" => L10n.current.authForgotPassword,
    "Kostenlos starten" => L10n.current.authGetStartedForFree,
    "Einloggen" => L10n.current.authSignIn,
    "Mit „Kostenlos starten“ bestätigst du, dass du mindestens 18 Jahre alt bist, und akzeptierst die AGB. Hinweise zum Datenschutz findest du in der Datenschutzerklärung." =>
      L10n.current.authByTappingGetStartedForFreeYou,
    "Sicher gespeichert · jederzeit löschbar" =>
      L10n.current.authSecurelyStoredDeleteAtAnyTime,
    "Anmelden" => L10n.current.onboardingSignIn,
    "Registrieren" => L10n.current.authSignUp,
    "Dein Essen.\nDein Rhythmus." => L10n.current.authYourFoodYourRhythm,
    "Tracken, verstehen und besser entscheiden — ohne komplizierte Tabellen." =>
      L10n.current.authTrackUnderstandAndMakeBetterChoicesWithout,
    "Schnell" => L10n.current.onboardingQuick,
    "Persönlich" => L10n.current.authPersonal,
    "Privat" => L10n.current.authPrivate,
    "Fast geschafft!" => L10n.current.authAlmostThere,
    "Erstelle dein kostenloses Konto. Dann speichert Lookin deine Antworten und dein Tagebuch – auch auf deinen anderen Geräten." =>
      L10n.current.authCreateYourFreeAccountLookinWillThen,
    "Antworten ändern" => L10n.current.onboardingChangeAnswers,
    "Dein Alltag.\nDein Rhythmus." => L10n.current.authYourDayYourRhythm,
    "Einfach essen. Klarer entscheiden." =>
      L10n.current.authEatSimplyChooseClearly,
    "HEUTE" => L10n.current.authToday,
    "ENERGIE" => L10n.current.authEnergy,
    "Andere E-Mail-Adresse verwenden" =>
      L10n.current.authUseADifferentEmailAddress,
    "Schau in dein Postfach" => L10n.current.authCheckYourInbox,
    "Wir haben eine Bestätigungs-Mail an " =>
      L10n.current.authWeHaveSentAConfirmationEmailTo,
    " geschickt, falls es dort noch kein Lookin-Konto gibt. Tippe auf den Link darin, um dein Konto zu aktivieren." =>
      L10n.current.authIfNoLookinAccountExistsForThis,
    "Postfach öffnen" => L10n.current.authOpenYourInbox,
    "Die Mail kommt von Lookin (noreply@lookin-foodtracker.de)." =>
      L10n.current.authTheEmailComesFromLookinNoreplyLookin,
    "Auf „E-Mail bestätigen“ tippen" => L10n.current.authTapConfirmEmail,
    "Der Link funktioniert nur einmal und ist begrenzt gültig." =>
      L10n.current.authTheLinkCanOnlyBeUsedOnce,
    "Mit deiner E-Mail-Adresse und deinem Passwort." =>
      L10n.current.authUsingYourEmailAddressAndPassword,
    "Nichts angekommen? Schau auch im Spam-Ordner nach. Es kann ein bis zwei Minuten dauern. Hast du dich mit dieser Adresse schon einmal registriert? Dann melde dich an oder nutze dort „Passwort vergessen?“." =>
      L10n.current.authNothingArrivedCheckYourSpamFolderToo,
    "Ich habe bestätigt – weiter" => L10n.current.authIHaveConfirmedContinue,
    "Bestätigungs-Mail erneut senden" =>
      L10n.current.authResendConfirmationEmail,
    "E-Mail bestätigt" => L10n.current.authEmailConfirmed,
    "Dein Lookin-Konto ist jetzt aktiv. Du kannst dich mit deiner E-Mail-Adresse und deinem Passwort anmelden." =>
      L10n.current.authYourLookinAccountIsNowActiveYou,
    "Tipp: Kehre einfach zu Lookin zurück, in dem Fenster oder der App, in der du dich registriert hast. Dort wirst du automatisch angemeldet." =>
      L10n.current.authTipReturnToLookinInTheWindow,
    "Jetzt anmelden" => L10n.current.authSignInNow,
    "Zurück" => L10n.current.onboardingBack,
    "Dein neues Passwort ist gespeichert. Melde dich jetzt damit an." =>
      L10n.current.authYourNewPasswordHasBeenSavedSign,
    "Das neue Passwort muss sich von deinem bisherigen unterscheiden." =>
      L10n.current.authYourNewPasswordMustBeDifferentFrom,
    "Das Passwort ist zu schwach. Wähle mindestens acht Zeichen." =>
      L10n.current.authYourPasswordIsTooWeakPleaseUse,
    "Das Passwort konnte nicht gesetzt werden. Fordere unter „Passwort vergessen?“ einen neuen Link an." =>
      L10n.current.authYourPasswordCouldNotBeSetRequest,
    "Abmelden fehlgeschlagen. Bitte versuche es erneut." =>
      L10n.current.profileSignOutFailedPleaseTryAgain,
    "Neues Passwort" => L10n.current.authNewPassword,
    "Wähle ein neues Passwort. Danach meldest du dich damit erneut an." =>
      L10n.current.authChooseANewPasswordYouWillThen,
    "Passwort wiederholen" => L10n.current.authRepeatPassword,
    "Die Passwörter stimmen nicht überein." =>
      L10n.current.authThePasswordsDoNotMatch,
    "Passwort speichern" => L10n.current.authSavePassword,
    "Abbrechen und zum Login" => L10n.current.authCancelAndReturnToSignIn,
    "📷 Lebensmittel-Foto zur Analyse" =>
      L10n.current.coachFoodPhotoForAnalysis,
    "Dein Chatverlauf wurde gelöscht." =>
      L10n.current.coachYourChatHistoryHasBeenDeleted,
    "Der Lookin Coach ist Teil von Lookin Premium. Deine Testphase oder dein Abo ist nicht mehr aktiv." =>
      L10n.current.coachTheLookinCoachIsPartOfLookin,
    "Neuen Chat beginnen?" => L10n.current.coachStartANewChat,
    "Chatverlauf löschen?" => L10n.current.coachDeleteChatHistory,
    "Abbrechen" => L10n.current.profileCancel,
    "Verlauf löschen" => L10n.current.coachDeleteHistory,
    "Lebensmittel-Foto" => L10n.current.diaryFoodPhoto,
    "Dieses Bild konnte nicht gelesen werden." =>
      L10n.current.coachThisImageCouldNotBeRead,
    "Neuer Chat (Verlauf löschen)" => L10n.current.coachNewChatDeleteHistory,
    "Dein Verlauf wird geladen …" => L10n.current.coachLoadingYourHistory,
    "KI · Ernährung & Fitness" => L10n.current.onboardingAiNutritionFitness,
    "Der Coach kann gerade nicht geöffnet werden." =>
      L10n.current.coachTheCoachCannotBeOpenedJustNow,
    "Dein Premium-Status konnte nicht geladen werden. Bitte prüfe deine Internetverbindung." =>
      L10n.current.coachYourPremiumStatusCouldNotBeLoaded,
    "Erneut versuchen" => L10n.current.progressTryAgain,
    "Ideen, die zu deinen restlichen Kalorien passen" =>
      L10n.current.coachIdeasThatFitYourRemainingCalories,
    "Protein- und Trainingstipps für deinen Alltag" =>
      L10n.current.coachProteinAndTrainingTipsForYourDay,
    "Fotos deiner Mahlzeiten einschätzen lassen" =>
      L10n.current.coachGetEstimatesFromPhotosOfYourMeals,
    "Premium-Funktion" => L10n.current.diaryPremiumFeature,
    "Dein persönlicher KI-Coach" => L10n.current.coachYourPersonalAiCoach,
    "Frag nach Mahlzeiten, Nährwerten oder Training – die Antworten berücksichtigen dein Ziel und deine Tageswerte." =>
      L10n.current.coachAskAboutMealsNutritionOrTrainingAnswers,
    "Premium freischalten" => L10n.current.coachUnlockPremium,
    "Deine Testphase ist vorbei. Mit Premium schreibst du weiter mit deinem Coach." =>
      L10n.current.coachYourTrialHasEndedContinueChattingWith,
    "KI kann Fehler machen · Keine medizinische Beratung" =>
      L10n.current.coachAiCanMakeMistakesNotMedicalAdvice,
    "Gespeicherten Coach-Verlauf löschen" =>
      L10n.current.coachDeleteSavedCoachHistory,
    "Beispiel eines Coach-Gesprächs, mit Premium verfügbar" =>
      L10n.current.coachExampleCoachConversationAvailableWithPremium,
    "Beispiel" => L10n.current.coachExample,
    "Was kann ich heute Abend noch essen?" =>
      L10n.current.onboardingWhatCanIStillEatThisEvening,
    "Du hast heute noch etwa 650 kcal frei. Wie wäre eine Lachs-Bowl mit Reis und Gemüse? Das bringt dir rund 35 g Protein und hält lange satt." =>
      L10n.current.coachYouHaveAbout650KcalLeftToday,
    "Mit Premium" => L10n.current.coachWithPremium,
    "Abendessen" => L10n.current.onboardingDinner,
    "Mehr Protein" => L10n.current.onboardingMoreProtein,
    "Gib mir eine einfache proteinreiche Idee." =>
      L10n.current.coachGiveMeASimpleHighProteinIdea,
    "Tagesziel" => L10n.current.onboardingDailyTarget,
    "Wie erreiche ich heute sinnvoll mein Kalorienziel?" =>
      L10n.current.coachHowCanISensiblyReachMyCalorie,
    "Was brauchst du heute?" => L10n.current.coachWhatDoYouNeedToday,
    "Frag nach Mahlzeiten, Rezepten, Nährwerten oder Training. Dein Ziel und deine heutigen Werte werden dabei berücksichtigt." =>
      L10n.current.coachAskAboutMealsRecipesNutritionOrTraining,
    "Mit jeder Frage gehen dein Ziel, deine Tagesziele, heutigen Tageswerte, Ernährungsstil, Allergien und Aktivität an den KI-Dienst – nicht dein Name. Der Chat wird in deinem Konto gespeichert und lässt sich jederzeit löschen." =>
      L10n.current.coachEachQuestionSendsYourGoalDailyTargets,
    "Fokussiert auf Ernährung, Fitness und gesunden Alltag" =>
      L10n.current.coachFocusedOnNutritionFitnessAndAHealthy,
    "Deine Frage, nicht gesendet" => L10n.current.coachYourQuestionNotSent,
    "Deine Frage" => L10n.current.coachYourQuestion,
    "Antwort vom Coach" => L10n.current.coachCoachSAnswer,
    "Nicht gesendet" => L10n.current.coachNotSent,
    "Der Coach schreibt eine Antwort" =>
      L10n.current.coachTheCoachIsWritingAnAnswer,
    "Das dauert etwas länger als sonst …" =>
      L10n.current.coachThisIsTakingALittleLongerThan,
    "Coach schreibt …" => L10n.current.coachCoachIsTyping,
    "Hinweis schließen" => L10n.current.coachDismissNotice,
    "Premium ansehen" => L10n.current.diaryViewPremium,
    "Tageslimit erreicht – morgen geht es weiter" =>
      L10n.current.coachDailyLimitReachedComeBackTomorrow,
    "Der Coach antwortet …" => L10n.current.coachTheCoachIsReplying,
    "Frag deinen Coach …" => L10n.current.onboardingAskYourCoach,
    "Lebensmittel-Foto analysieren" => L10n.current.coachAnalyseAFoodPhoto,
    "Nachricht senden" => L10n.current.coachSendMessage,
    "KI kann Fehler machen · Werte sind Schätzungen · Keine medizinische Beratung" =>
      L10n.current.coachAiCanMakeMistakesValuesAreEstimates,
    "Gesundheitsangaben speichern" => L10n.current.consentSaveHealthInformation,
    "Ich willige ein, dass Lookin meine freiwilligen Gesundheitsangaben (Gewicht, Taillenumfang, Zielgewicht, Allergien und Unverträglichkeiten sowie meine Antworten aus der Einführung wie Geburtstag, Größe, Geschlecht und einen optionalen Gesundheitshinweis) in meinem Konto speichert und für Richtwerte, Rezeptfilter und Warnhinweise nutzt. So muss ich sie auf einem neuen Gerät nicht noch einmal eingeben." =>
      L10n.current.consentIConsentToLookinStoringMyOptional,
    "KI-Coach und KI-Foto nutzen" => L10n.current.consentUseAiCoachAndAiPhoto,
    "Ich willige ausdrücklich ein, dass meine Fragen, Fotos, die letzten Chat-Nachrichten und folgende Angaben zur Beantwortung an den KI-Dienst OpenAI übermittelt werden (Verarbeitung auch in den USA): Ziel, Tageswerte, Ernährungsstil, Aktivität, Angaben aus der Einführung (Motivation, Hürden, Erfahrung) und meine Allergien und Unverträglichkeiten, also Gesundheitsdaten. Name und E-Mail werden nicht übermittelt." =>
      L10n.current.consentIExpresslyConsentToMyQuestionsPhotos,
    "Ich verlange ausdrücklich, dass Lookin Premium sofort, also vor Ablauf der Widerrufsfrist, beginnt. Mir ist bekannt, dass ich bei einem Widerruf einen anteiligen Betrag für die bis dahin erbrachte Leistung zahle und mein Widerrufsrecht bei vollständiger Vertragserfüllung erlischt." =>
      L10n.current.consentIExpresslyRequestThatLookinPremiumBegins,
    "Freiwillig. Du kannst jede Einwilligung jederzeit unter Profil › Datenschutz & Daten widerrufen." =>
      L10n.current.consentOptionalYouCanWithdrawEachConsentAt,
    "Nicht jetzt" => L10n.current.consentNotNow,
    "Einwilligen" => L10n.current.consentGiveConsent,
    "Deine Einwilligungen" => L10n.current.consentYourConsents,
    "Lookin funktioniert auch ohne diese Einwilligungen. Ohne sie bleiben Gesundheitsangaben nur auf diesem Gerät, und KI-Coach und KI-Foto fragen dich vor der ersten Nutzung noch einmal." =>
      L10n.current.consentLookinAlsoWorksWithoutTheseConsentsWithout,
    "Speichern und weiter" => L10n.current.consentSaveAndContinue,
    "Ohne Einwilligung weiter" => L10n.current.consentContinueWithoutConsent,
    "Einwilligung widerrufen?" => L10n.current.consentWithdrawConsent,
    "Wir löschen dann deine Gesundheitsangaben in deinem Konto (Allergien, Zielgewicht, Gewichts- und Taillenwerte). Auf diesem Gerät bleiben deine Angaben erhalten." =>
      L10n.current.consentWeWillThenDeleteYourHealthInformation,
    "Widerrufen und löschen" => L10n.current.consentWithdrawAndDelete,
    "KI-Coach und KI-Foto senden dann nichts mehr an OpenAI und fragen dich vor der nächsten Nutzung erneut." =>
      L10n.current.consentAiCoachAndAiPhotoWillThen,
    "Widerrufen" => L10n.current.consentWithdraw,
    "Einwilligungen" => L10n.current.consentConsents,
    "Gewicht, Zielgewicht und Allergien im Konto speichern" =>
      L10n.current.consentSaveWeightTargetWeightAndAllergiesIn,
    "Fragen und Fotos an OpenAI (USA) senden" =>
      L10n.current.consentSendQuestionsAndPhotosToOpenaiUsa,
    "Kichererbsen-Reis-Bowl" => L10n.current.diaryChickpeaRiceBowl,
    "Vollkornbrot mit Ei" => L10n.current.diaryWholemealBreadWithEgg,
    "Griechischer Joghurt" => L10n.current.diaryGreekYoghurt,
    "Protein-Pasta" => L10n.current.diaryProteinPasta,
    "Gemüse-Omelett" => L10n.current.diaryVegetableOmelette,
    "Suchergebnisse" => L10n.current.diarySearchResults,
    "Lebensmittel" => L10n.current.diaryFood,
    "Zuletzt verwendet" => L10n.current.diaryRecentlyUsed,
    "Gemerkte Lebensmittel" => L10n.current.diarySavedFoods,
    "Proteinreich" => L10n.current.diaryHighInProtein,
    "Leichte Lebensmittel" => L10n.current.diaryLightFoods,
    "Lebensmittel suchen" => L10n.current.diarySearchFoods,
    "Suche löschen" => L10n.current.discoverClearSearch,
    "Barcode scannen" => L10n.current.onboardingScanBarcode,
    "Selbst eintragen" => L10n.current.diaryEnterManually,
    "Allergiehinweis" => L10n.current.discoverAllergyNotice,
    "Trotzdem protokollieren" => L10n.current.diaryLogAnyway,
    "Das Lebensmittel konnte nicht gespeichert werden." =>
      L10n.current.diaryTheFoodCouldNotBeSaved,
    "Speichern fehlgeschlagen. Bitte erneut versuchen." =>
      L10n.current.diarySavingFailedPleaseTryAgain,
    "Mahlzeit auswählen" => L10n.current.diarySelectMeal,
    "Kein Treffer. Prüfe die Schreibweise oder trage das Lebensmittel selbst ein." =>
      L10n.current.diaryNoResultsCheckTheSpellingOrEnter,
    "Noch nichts verwendet. Hinzugefügte Lebensmittel erscheinen später hier." =>
      L10n.current.diaryNothingUsedYetFoodsYouAddWill,
    "Noch nichts gemerkt. Speichere Lebensmittel über die Detailansicht." =>
      L10n.current.diaryNothingSavedYetSaveFoodsFromTheir,
    "In diesem Bereich wurden noch keine Lebensmittel gefunden." =>
      L10n.current.diaryNoFoodsHaveBeenFoundInThis,
    "Alle" => L10n.current.subscriptionAll,
    "Zuletzt" => L10n.current.diaryRecent,
    "Gemerkte" => L10n.current.diarySaved,
    "Leicht" => L10n.current.diaryLight,
    "Produkt wird gesucht ..." => L10n.current.diarySearchingForProduct,
    "Dieses Produkt ist noch nicht in der Datenquelle. Du kannst es selbst eintragen." =>
      L10n.current.diaryThisProductIsNotInTheData,
    "Barcode konnte gerade nicht verarbeitet werden." =>
      L10n.current.diaryTheBarcodeCouldNotBeProcessedJust,
    "Barcode eingeben" => L10n.current.diaryEnterBarcode,
    "z. B. 3017620422003" => L10n.current.diaryEG3017620422003,
    "Suchen" => L10n.current.diarySearch,
    "Kamera aktiv – Barcode in den Rahmen halten" =>
      L10n.current.diaryCameraActiveHoldTheBarcodeInsideThe,
    "Barcode manuell eingeben" => L10n.current.diaryEnterBarcodeManually,
    "Es wurde keine Kamera gefunden." => L10n.current.diaryNoCameraWasFound,
    "Der Kamerazugriff wurde nicht erlaubt. Erlaube die Kamera in den Browser- bzw. Geräteeinstellungen und versuche es erneut." =>
      L10n.current.diaryCameraAccessWasNotAllowedAllowThe,
    "Die Kamera konnte nicht gestartet werden." =>
      L10n.current.diaryTheCameraCouldNotBeStarted,
    "Auf diesem Gerät ist keine Kamera verfügbar." =>
      L10n.current.diaryNoCameraIsAvailableOnThisDevice,
    "Foto konnte nicht aufgenommen werden." =>
      L10n.current.diaryThePhotoCouldNotBeTaken,
    "Mahlzeit fotografieren" => L10n.current.diaryTakeAMealPhoto,
    "Das ganze Essen gut sichtbar von oben aufnehmen." =>
      L10n.current.diaryPhotographTheWholeMealClearlyFromAbove,
    "Galerie" => L10n.current.diaryGallery,
    "Wechseln" => L10n.current.diarySwitch,
    "Foto aufnehmen" => L10n.current.diaryTakePhoto,
    "Alternativ unten über „Galerie“ ein Foto auswählen." =>
      L10n.current.diaryAlternativelyChooseAPhotoUsingGalleryBelow,
    "Dein eigenes Lebensmittel" => L10n.current.diaryYourCustomFood,
    "Deinen Eintrag bearbeiten" => L10n.current.diaryEditYourEntry,
    "Deine bisherigen Werte gelten für eine Portion. Fehlende Etikettwerte kannst du ergänzen." =>
      L10n.current.diaryYourPreviousValuesApplyToOneServing,
    "Übernimm die Nährwerte vom Etikett. Wir rechnen deine gegessene Menge automatisch aus." =>
      L10n.current.diaryCopyTheNutritionValuesFromTheLabel,
    "Zum Beispiel: Mein Schoko-Müsli" =>
      L10n.current.diaryForExampleMyChocolateCereal,
    "Bitte deinem Lebensmittel einen Namen geben." =>
      L10n.current.diaryPleaseGiveYourFoodAName,
    "Bitte höchstens 100 Zeichen verwenden." =>
      L10n.current.diaryPleaseUseNoMoreThan100Characters,
    "Für welche Mahlzeit?" => L10n.current.diaryForWhichMeal,
    "Worauf beziehen sich die Werte?" =>
      L10n.current.diaryWhatDoTheValuesReferTo,
    "Pro 100 g" => L10n.current.diaryPer100G,
    "Pro 100 ml" => L10n.current.diaryPer100Ml,
    "Pro Portion" => L10n.current.diaryPerServing,
    "Unten stehen die Etikettwerte pro 100 g." =>
      L10n.current.diaryTheLabelValuesBelowArePer100,
    "Unten stehen die Etikettwerte pro 100 ml." =>
      L10n.current.diaryTheLabelValuesBelowArePer1002,
    "Unten stehen die Werte für eine ganze Portion. Eine halbe Portion ist 0,5." =>
      L10n.current.diaryTheValuesBelowAreForAWhole,
    "Gegessene Portionen" => L10n.current.diaryServingsEaten,
    "Gegessene Menge" => L10n.current.diaryAmountEaten,
    "Unbekannte Zusatzwerte bleiben leer." =>
      L10n.current.diaryLeaveUnknownAdditionalValuesBlank,
    "Alle Etikettwerte sind erforderlich. Ballaststoffe sind freiwillig." =>
      L10n.current.diaryAllLabelValuesAreRequiredFibreIs,
    "Energie" => L10n.current.discoverEnergy,
    "Fett" => L10n.current.progressFat,
    "davon gesättigte Fettsäuren" => L10n.current.diaryOfWhichSaturates,
    "Kohlenhydrate" => L10n.current.progressCarbohydrates,
    "davon Zucker" => L10n.current.diaryOfWhichSugars,
    "Eiweiß / Protein" => L10n.current.diaryProtein,
    "Salz" => L10n.current.discoverSalt,
    "Ballaststoffe (optional)" => L10n.current.diaryFibreOptional,
    "Für deine gegessene Menge" => L10n.current.diaryForTheAmountYouAte,
    "Sobald Menge, Energie und Makros eingetragen sind, siehst du hier die Berechnung." =>
      L10n.current.diaryOnceYouEnterTheAmountEnergyAnd,
    "Wird gespeichert …" => L10n.current.onboardingSaving,
    "Ins Tagebuch eintragen" => L10n.current.diaryLogInDiary,
    "Änderungen speichern" => L10n.current.diarySaveChanges,
    "Nicht bekannt" => L10n.current.diaryUnknown,
    "z. B. 0,5" => L10n.current.diaryEG05,
    "Bitte einen gültigen Wert ab 0 eingeben." =>
      L10n.current.diaryPleaseEnterAValidValueOf0,
    "Zucker darf die Kohlenhydrate nicht überschreiten." =>
      L10n.current.diarySugarCannotExceedCarbohydrates,
    "Gesättigte Fettsäuren dürfen Fett nicht überschreiten." =>
      L10n.current.diarySaturatedFatCannotExceedTotalFat,
    "Bitte prüfe die markierten Felder weiter oben." =>
      L10n.current.diaryPleaseCheckTheHighlightedFieldsAbove,
    "Das Speichern hat nicht geklappt. Deine Angaben bleiben hier erhalten." =>
      L10n.current.diarySavingDidNotWorkYourInformationStays,
    "Das Speichern hat nicht geklappt. Bitte versuche es erneut." =>
      L10n.current.diarySavingDidNotWorkPleaseTryAgain,
    "Eintrag löschen?" => L10n.current.diaryDeleteEntry,
    "Löschen" => L10n.current.profileDelete,
    "Eintrag löschen" => L10n.current.diaryDeleteEntry2,
    "Tagebuch" => L10n.current.navigationDiary,
    "Deine Mahlzeiten klar und ohne unnötigen Aufwand." =>
      L10n.current.diaryYourMealsClearlyOrganisedAndEasyTo,
    "Mahlzeit hinzufügen" => L10n.current.onboardingAddMeal,
    "Dein Mahlzeitenrhythmus" => L10n.current.diaryYourMealRhythm,
    "Dein Wunsch, kein Muss. Du kannst jederzeit weitere Mahlzeiten eintragen." =>
      L10n.current.diaryYourPreferenceNotARequirementYouCan,
    "Mahlzeiten" => L10n.current.profileMeals,
    "Hinzufügen" => L10n.current.navigationAdd,
    "Mo" => L10n.current.diaryMon,
    "Di" => L10n.current.diaryTue,
    "Mi" => L10n.current.diaryWed,
    "Do" => L10n.current.diaryThu,
    "Fr" => L10n.current.diaryFri,
    "Sa" => L10n.current.diarySat,
    "So" => L10n.current.diarySun,
    "Vorherige Woche" => L10n.current.diaryPreviousWeek,
    "Nächste Woche" => L10n.current.diaryNextWeek,
    "Gegessen" => L10n.current.diaryEaten,
    "Übrig" => L10n.current.diaryRemaining,
    "Du liegst über deinem Tagesziel. Das ist eine Orientierung, keine Bewertung." =>
      L10n.current.diaryYouAreAboveYourDailyTargetThis,
    "Weitere Mahlzeit" => L10n.current.diaryAnotherMeal,
    "Wasser" => L10n.current.diaryWater,
    "Rezept bearbeiten" => L10n.current.diaryEditRecipe,
    "Mahlzeit bearbeiten" => L10n.current.diaryEditMeal,
    "Die Mahlzeitenart kann angepasst werden. Zutaten und Werte bleiben mit dem Rezept verbunden." =>
      L10n.current.diaryYouCanChangeTheMealTypeIngredients,
    "Änderungen werden direkt in deinem Tagebuch gespeichert." =>
      L10n.current.diaryChangesAreSavedDirectlyToYourDiary,
    "Name der Mahlzeit" => L10n.current.diaryMealName,
    "Mahlzeit" => L10n.current.diaryMeal,
    "Tag" => L10n.current.diaryDay,
    "Menge" => L10n.current.onboardingAmount,
    "Nährwerte" => L10n.current.discoverNutrition,
    "Kohlenhydrate g" => L10n.current.diaryCarbsG,
    "Fett g" => L10n.current.diaryFatG,
    "Duplizieren" => L10n.current.diaryDuplicate,
    "Speichern" => L10n.current.diarySave,
    "Eintrag wurde gelöscht." => L10n.current.diaryEntryDeleted,
    "Bitte Name und gültige, positive Werte eintragen." =>
      L10n.current.diaryPleaseEnterANameAndValidPositive,
    "Die Mahlzeit konnte nicht gespeichert werden." =>
      L10n.current.diaryTheMealCouldNotBeSaved,
    "Mahlzeit wurde aktualisiert." => L10n.current.diaryMealUpdated,
    "Die Mahlzeit konnte nicht dupliziert werden." =>
      L10n.current.diaryTheMealCouldNotBeDuplicated,
    "Mahlzeit wurde dupliziert." => L10n.current.diaryMealDuplicated,
    "Mahlzeit verschieben" => L10n.current.diaryMoveMeal,
    "Von Merkliste entfernen" => L10n.current.diaryRemoveFromSavedFoods,
    "Merken" => L10n.current.diarySaveFood,
    "Wird gespeichert ..." => L10n.current.diarySaving2,
    "Zum Tagebuch hinzufügen" => L10n.current.onboardingAddToDiary,
    "Kalorien" => L10n.current.profileCalories,
    "gesättigte Fettsäuren" => L10n.current.diarySaturatedFat,
    "Zucker" => L10n.current.discoverSugar,
    "Ballaststoffe" => L10n.current.discoverFibre,
    "Produktinfos" => L10n.current.diaryProductInformation,
    "Allergene laut Produktdaten" =>
      L10n.current.diaryAllergensAccordingToProductData,
    "Zutatenliste" => L10n.current.diaryIngredientsList,
    "Quelle: Open Food Facts. Angaben können fehlen oder sich ändern – bei Allergien und Unverträglichkeiten immer das Verpackungsetikett prüfen." =>
      L10n.current.diarySourceOpenFoodFactsInformationMayBe,
    "Dieses Foto konnte nicht gelesen werden." =>
      L10n.current.diaryThisPhotoCouldNotBeRead,
    "Das Foto konnte gerade nicht analysiert werden." =>
      L10n.current.diaryThePhotoCouldNotBeAnalysedJust,
    "Füge mindestens ein Lebensmittel hinzu." =>
      L10n.current.diaryAddAtLeastOneFood,
    "Mahlzeit erkennen" => L10n.current.diaryRecogniseMeal,
    "Foto aus Galerie" => L10n.current.diaryPhotoFromGallery,
    "Neues Foto aufnehmen" => L10n.current.diaryTakeANewPhoto,
    "Deine Mahlzeit" => L10n.current.diaryYourMeal,
    "Die Foto-KI kann Allergene, die man nicht sieht, oder Spuren nicht zuverlässig erkennen. Zutatenliste und Verpackung selbst prüfen." =>
      L10n.current.diaryPhotoAiCannotReliablyRecogniseHiddenAllergens,
    "KI erkennt Lebensmittel und schätzt die Mengen …" =>
      L10n.current.diaryAiIsRecognisingFoodsAndEstimatingAmounts,
    "Erkannte Lebensmittel" => L10n.current.diaryRecognisedFoods,
    "Tippe auf ein Lebensmittel, um Name und Nährwerte zu ändern. Wenn du die Menge änderst, passen sich Kalorien und Nährwerte automatisch an." =>
      L10n.current.diaryTapAFoodToChangeItsName,
    "Selbst hinzufügen" => L10n.current.diaryAddManually,
    "KI-Werte sind Schätzungen. Ein Foto ersetzt keine Waage oder Verpackungsangabe – prüfe Mengen und Nährwerte vor dem Speichern." =>
      L10n.current.diaryAiValuesAreEstimatesAPhotoCannot,
    "Bitte gib jedem Lebensmittel einen Namen." =>
      L10n.current.diaryPleaseGiveEveryFoodAName,
    "KI-Schätzung" => L10n.current.onboardingAiEstimate,
    "Zu welcher Mahlzeit?" => L10n.current.discoverWhichMeal,
    "kcal gesamt" => L10n.current.diaryTotalKcal,
    "Kohlenh." => L10n.current.diaryCarbs,
    "Neues Lebensmittel" => L10n.current.diaryNewFood,
    "Nährwerte gelten für die oben eingestellte Menge." =>
      L10n.current.diaryNutritionValuesApplyToTheAmountSelected,
    "Entfernen" => L10n.current.diaryRemove,
    "Gut erkannt" => L10n.current.diaryRecognisedWell,
    "Bitte kurz prüfen" => L10n.current.diaryPleaseCheckBriefly,
    "Aus der Suche" => L10n.current.diaryFromSearch,
    "Eigener Eintrag" => L10n.current.diaryCustomEntry,
    "Unsicher – bitte prüfen" => L10n.current.diaryUncertainPleaseCheck,
    "10 g weniger" => L10n.current.diary10GLess,
    "10 g mehr" => L10n.current.diary10GMore,
    "Fotografiere deine Mahlzeit – die KI schätzt Lebensmittel und Mengen." =>
      L10n.current.diaryTakeAPhotoOfYourMealAi,
    "Aus Galerie wählen" => L10n.current.diaryChooseFromGallery,
    "Die KI-Foto-Erkennung ist Teil von Lookin Premium. Du kannst die Mahlzeit trotzdem über „Suchen“ oder „Selbst hinzufügen“ eintragen." =>
      L10n.current.diaryAiPhotoRecognitionIsPartOfLookin,
    "Kein Lebensmittel gefunden. Du kannst es auch über „Selbst hinzufügen“ eintragen." =>
      L10n.current.diaryNoFoodFoundYouCanAlsoLog,
    "KI-Foto" => L10n.current.subscriptionAiPhoto,
    "Foto machen, KI schätzt Lebensmittel und Mengen" =>
      L10n.current.diaryTakeAPhotoAiEstimatesFoodsAnd,
    "Verpacktes Produkt über den Barcode finden" =>
      L10n.current.diaryFindAPackagedProductUsingItsBarcode,
    "Manuell eintragen" => L10n.current.onboardingEnterManually,
    "Lebensmittel suchen oder selbst eintragen" =>
      L10n.current.diarySearchForFoodsOrEnterThemYourself,
    "EL" => L10n.current.discoverTbsp,
    "TL" => L10n.current.discoverTsp,
    "Msp." => L10n.current.discoverPinch,
    "Pck." => L10n.current.discoverPack,
    "Pkg." => L10n.current.discoverPack2,
    "Stk." => L10n.current.discoverPiece,
    "Stück" => L10n.current.discoverPiece2,
    "Bund" => L10n.current.discoverBunch,
    "Handvoll" => L10n.current.discoverHandful,
    "Becher" => L10n.current.discoverPot,
    "Spritzer" => L10n.current.discoverDash,
    "Beutel" => L10n.current.discoverBag,
    "Würfel" => L10n.current.discoverCube,
    "Brötchen" => L10n.current.discoverBreadRoll,
    "Paprika" => L10n.current.discoverPeppers,
    "Prisen" => L10n.current.discoverPinches,
    "Zehen" => L10n.current.discoverCloves,
    "Filets" => L10n.current.discoverFillets,
    "Dosen" => L10n.current.discoverTins,
    "Scheiben" => L10n.current.discoverSlices,
    "Tassen" => L10n.current.discoverCups,
    "Packungen" => L10n.current.discoverPacks,
    "Knollen" => L10n.current.discoverBulbs,
    "Zwiebeln" => L10n.current.discoverOnions,
    "Stangen" => L10n.current.discoverSticks,
    "Zweige" => L10n.current.discoverSprigs,
    "Blätter" => L10n.current.discoverLeaves,
    "Eier" => L10n.current.onboardingEggs,
    "Tomaten" => L10n.current.discoverTomatoes,
    "Kugeln" => L10n.current.discoverBalls,
    "Schoten" => L10n.current.discoverPods,
    "Tuben" => L10n.current.discoverTubes,
    "Messerspitzen" => L10n.current.discoverPinches2,
    "Gläser" => L10n.current.discoverGlasses,
    "Bananen" => L10n.current.discoverBananas,
    "Zitronen" => L10n.current.discoverLemons,
    "Limetten" => L10n.current.discoverLimes,
    "Karotten" => L10n.current.discoverCarrots,
    "Möhren" => L10n.current.discoverCarrots2,
    "Gurken" => L10n.current.discoverCucumbers,
    "Äpfel" => L10n.current.discoverApples,
    "Kartoffeln" => L10n.current.onboardingPotatoes,
    "Süßkartoffeln" => L10n.current.discoverSweetPotatoes,
    "Frühlingszwiebeln" => L10n.current.discoverSpringOnions,
    "Chilischoten" => L10n.current.discoverChillies,
    "Fladenbrote" => L10n.current.discoverFlatbreads,
    "Was kann ich kochen?" => L10n.current.discoverWhatCanICook,
    "Rezepte mit dem, was du zu Hause hast" =>
      L10n.current.discoverRecipesUsingWhatYouHaveAtHome,
    "Wähle, was du zu Hause hast. Lookin zeigt Rezepte mit diesen Zutaten – die mit den wenigsten fehlenden zuerst." =>
      L10n.current.discoverSelectWhatYouHaveAtHomeLookin,
    "Das habe ich da" => L10n.current.discoverIHaveThese,
    "Zutat eingeben, z. B. Kartoffeln" =>
      L10n.current.discoverEnterAnIngredientEGPotatoes,
    "Zutat hinzufügen" => L10n.current.discoverAddIngredient,
    "Häufige Zutaten" => L10n.current.discoverCommonIngredients,
    "Grundzutaten sind vorhanden" =>
      L10n.current.discoverBasicIngredientsAreAvailable,
    "Was hast du zu Hause?" => L10n.current.discoverWhatDoYouHaveAtHome,
    "Tippe auf eine häufige Zutat oder gib selbst etwas ein, zum Beispiel „Kartoffeln“." =>
      L10n.current.discoverTapACommonIngredientOrEnterOne,
    "Keine passenden Rezepte" => L10n.current.discoverNoMatchingRecipes,
    "Kein Rezept mit diesen Zutaten gefunden." =>
      L10n.current.discoverNoRecipeFoundWithTheseIngredients,
    "Probiere eine weitere Zutat oder einen anderen Namen, zum Beispiel „Nudeln“ statt „Spaghetti“." =>
      L10n.current.discoverTryAnotherIngredientOrADifferentName,
    "Alles da" => L10n.current.discoverEverythingAvailable,
    "1 Zutat fehlt" => L10n.current.discover1IngredientMissing,
    "Hast du" => L10n.current.discoverYouHave,
    "Fehlt" => L10n.current.discoverMissing,
    "Grundzutaten" => L10n.current.discoverBasicIngredients,
    "Zeigen" => L10n.current.discoverShow,
    "Kochmodus beenden?" => L10n.current.discoverExitCookingMode,
    "Laufende Timer werden dabei gestoppt." =>
      L10n.current.discoverRunningTimersWillBeStopped,
    "Weiterkochen" => L10n.current.discoverKeepCooking,
    "Beenden" => L10n.current.discoverExit,
    "Kochmodus beenden" => L10n.current.discoverExitCookingMode2,
    "Keine Schritte" => L10n.current.discoverNoSteps,
    "Zutaten anzeigen" => L10n.current.discoverShowIngredients,
    "Für dieses Rezept ist noch keine Anleitung hinterlegt." =>
      L10n.current.discoverNoInstructionsHaveBeenAddedForThis,
    "Fertig" => L10n.current.subscriptionDone,
    "Weiter" => L10n.current.onboardingContinue,
    "Zeit ist um!" => L10n.current.discoverTimeIsUp,
    "Läuft" => L10n.current.discoverRunning,
    "Pausiert" => L10n.current.discoverPaused,
    "Pausieren" => L10n.current.discoverPause,
    "Neu starten" => L10n.current.discoverRestart,
    "Timer starten" => L10n.current.discoverStartTimer,
    "Fortsetzen" => L10n.current.discoverResume,
    "Zurücksetzen" => L10n.current.discoverReset,
    "Passende Rezepte" => L10n.current.discoverMatchingRecipes,
    "Für dich" => L10n.current.discoverForYou,
    "Alle Rezepte" => L10n.current.subscriptionAllRecipes,
    "Rezepte" => L10n.current.subscriptionRecipes,
    "Ideen, die zu deinem Ziel und deinem Alltag passen." =>
      L10n.current.discoverIdeasThatFitYourGoalAndYour,
    "Rezepte oder Zutaten suchen" =>
      L10n.current.discoverSearchRecipesOrIngredients,
    "1 Rezept" => L10n.current.discover1Recipe,
    "Alle Filter zurücksetzen" => L10n.current.discoverResetAllFilters,
    "Schnell unter 15 Min." => L10n.current.discoverQuickUnder15Min,
    "Kein Rezept passt zu deiner Auswahl." =>
      L10n.current.discoverNoRecipeMatchesYourSelection,
    "Du hast noch keine Favoriten. Tippe auf das Herz eines Rezepts, um es dir zu merken." =>
      L10n.current.discoverYouHaveNoFavouritesYetTapA,
    "Probiere einen anderen Suchbegriff oder entferne einen Filter." =>
      L10n.current.discoverTryAnotherSearchTermOrRemoveA,
    "Aus Favoriten entfernen" => L10n.current.discoverRemoveFromFavourites,
    "Zu Favoriten hinzufügen" => L10n.current.discoverAddToFavourites,
    "Das Rezept konnte nicht eingetragen werden." =>
      L10n.current.discoverTheRecipeCouldNotBeLogged,
    "Guten Appetit!" => L10n.current.discoverEnjoyYourMeal,
    "Eintragen" => L10n.current.progressLog,
    "An mein Ziel anpassen" => L10n.current.discoverAdaptToMyTarget,
    "1 Portion zum Tagebuch" => L10n.current.discoverLog1ServingInDiary,
    "Gesamtzeit" => L10n.current.discoverTotalTime,
    "Vorbereitung" => L10n.current.discoverPreparation,
    "Kochen" => L10n.current.discoverCooking,
    "Schwierigkeit" => L10n.current.discoverDifficulty,
    "Portion" => L10n.current.discoverServing,
    "Richtwerte" => L10n.current.discoverGuidelineValues,
    "pro Portion" => L10n.current.discoverPerServing,
    "Berechnet aus den Zutaten. Je nach Produkt und Zubereitung können die Werte abweichen." =>
      L10n.current.discoverCalculatedFromTheIngredientsValuesMayVary,
    "Grobe Richtwerte. Eine vollständige Berechnung aus den Zutaten liegt für dieses Rezept noch nicht vor." =>
      L10n.current.discoverRoughGuidelineValuesACompleteCalculationBased,
    "keine Angabe" => L10n.current.discoverNotSpecified,
    "Utensilien" => L10n.current.discoverEquipment,
    "wie im Originalrezept" => L10n.current.discoverAsInTheOriginalRecipe,
    "Eine Portion weniger" => L10n.current.discoverOneServingLess,
    "Eine Portion mehr" => L10n.current.discoverOneServingMore,
    "Originalmenge" => L10n.current.discoverOriginalAmount,
    "1 Zutat" => L10n.current.discover1Ingredient,
    "Für dieses Rezept sind noch keine Zutatenmengen hinterlegt." =>
      L10n.current.discoverIngredientAmountsHaveNotBeenAddedFor,
    "Hake ab, was du schon da hast. Die Haken gelten nur, solange dieses Rezept geöffnet ist." =>
      L10n.current.discoverTickWhatYouAlreadyHaveTicksOnly,
    "Zubereitung" => L10n.current.discoverMethod,
    "1 Schritt" => L10n.current.discover1Step,
    "Kochmodus starten" => L10n.current.discoverStartCookingMode,
    "Ein Schritt pro Seite, große Schrift und Timer." =>
      L10n.current.discoverOneStepPerPageLargeTextAnd,
    "Timer im Kochmodus öffnen" => L10n.current.discoverOpenTimerInCookingMode,
    "Profi-Tipp: " => L10n.current.discoverProTip,
    "Darauf achten" => L10n.current.discoverThingsToWatch,
    "Austausch-Möglichkeiten" => L10n.current.discoverSubstitutions,
    "Meal-Prep & Aufbewahrung" => L10n.current.discoverMealPrepStorage,
    "Variationen" => L10n.current.discoverVariations,
    "Serviervorschlag" => L10n.current.discoverServingSuggestion,
    "Woher kommen die Nährwerte?" =>
      L10n.current.discoverWhereDoTheNutritionValuesComeFrom,
    "Extra-Wissen zu diesem Rezept." =>
      L10n.current.discoverExtraKnowledgeAboutThisRecipe,
    "Pro Portion, aus den Katalogwerten der Zutaten." =>
      L10n.current.discoverPerServingBasedOnIngredientCatalogueValues2,
    "Profi-Tipps zu jedem Schritt" => L10n.current.discoverProTipsForEveryStep,
    "Häufige Fehler" => L10n.current.discoverCommonMistakes,
    "Austausch-Zutaten" => L10n.current.discoverIngredientSubstitutions,
    "Kochmodus mit Timern" => L10n.current.discoverCookingModeWithTimers,
    "Mehr Wissen zu jedem Rezept" =>
      L10n.current.discoverMoreKnowledgeForEveryRecipe,
    "Favoriten" => L10n.current.discoverFavourites,
    "Filter und Sortierung" => L10n.current.discoverFiltersAndSorting,
    "Filter & Sortierung" => L10n.current.discoverFiltersSorting,
    "Sortieren nach" => L10n.current.discoverSortBy,
    "Maximale Zubereitungszeit" => L10n.current.discoverMaximumPreparationTime,
    "Egal" => L10n.current.discoverAny,
    "1 Rezept anzeigen" => L10n.current.discoverShow1Recipe,
    "Vorschlag" => L10n.current.discoverSuggestion,
    "Laut deinem Tagebuch ist dein Tagesziel heute schon erreicht. Wenn du Hunger hast, ist eine kleinere Portion eine Möglichkeit." =>
      L10n.current.discoverYourDiaryShowsYouHaveAlreadyReached,
    "Damit dieses Rezept gut zu deinem heutigen Tagesziel passt, wäre diese Portionsgröße ein Vorschlag:" =>
      L10n.current.discoverThisServingSizeIsASuggestionTo,
    "VORSCHLAG · SCHÄTZUNG" => L10n.current.discoverSuggestionEstimate,
    "So ist der Vorschlag entstanden" =>
      L10n.current.discoverHowThisSuggestionWasCalculated,
    "Dein Tagesziel" => L10n.current.discoverYourDailyTarget,
    "Heute eingetragen" => L10n.current.discoverLoggedToday,
    "Noch offen" => L10n.current.profileRemaining,
    "Mahlzeiten, die heute noch kommen" =>
      L10n.current.discoverMealsStillToComeToday,
    "Für diese Mahlzeit" => L10n.current.discoverForThisMeal,
    "Übernehmen" => L10n.current.discoverApply,
    "Den Portionsrechner und alle Nährwerte kannst du weiterhin kostenlos nutzen." =>
      L10n.current.discoverTheServingCalculatorAndAllNutritionValues,
    "Jetzt nicht" => L10n.current.discoverNotNow,
    "Montag" => L10n.current.homeMonday,
    "Dienstag" => L10n.current.homeTuesday,
    "Mittwoch" => L10n.current.homeWednesday,
    "Donnerstag" => L10n.current.homeThursday,
    "Freitag" => L10n.current.homeFriday,
    "Samstag" => L10n.current.homeSaturday,
    "Sonntag" => L10n.current.homeSunday,
    "Erinnerungen" => L10n.current.profileReminders,
    "Serie wird geladen" => L10n.current.homeLoadingStreak,
    "kcal gegessen" => L10n.current.homeKcalEaten,
    "Dein Tag" => L10n.current.homeYourDay,
    "Deine Mahlzeiten" => L10n.current.homeYourMeals,
    "Tippe auf eine Mahlzeit, um Essen einzutragen." =>
      L10n.current.homeTapAMealToLogFood,
    "Noch nichts eingetragen" => L10n.current.homeNothingLoggedYet,
    "KI" => L10n.current.navigationAi,
    "Profil" => L10n.current.profileProfile,
    "Dein Alltag. Dein Rhythmus." => L10n.current.navigationYourDayYourRhythm,
    "Dein Rhythmus bleibt flexibel" =>
      L10n.current.onboardingYourMealRhythmStaysFlexible,
    "Als Budget-Rezept markierte Ideen rücken nach vorne." =>
      L10n.current.onboardingIdeasMarkedAsBudgetRecipesMoveUp,
    "deinem Ziel" => L10n.current.onboardingYourGoal,
    "deiner Ernährungsweise" => L10n.current.onboardingYourNutritionStyle,
    "deiner Zeit zum Kochen" => L10n.current.onboardingYourCookingTime,
    "Vorkochen für deinen Alltag" => L10n.current.onboardingMealPrepForYourDay,
    "deinem Budget" => L10n.current.onboardingYourBudget,
    "Vier Mahlzeiten. Ein Überblick." =>
      L10n.current.onboardingFourMealsOneOverview,
    "Foto, Barcode oder selbst eintragen" =>
      L10n.current.onboardingPhotoBarcodeOrManualEntry,
    "Schätzung prüfen, dann speichern" =>
      L10n.current.onboardingCheckTheEstimateThenSave,
    "Nur Ernährung und Fitness" =>
      L10n.current.onboardingNutritionAndFitnessOnly,
    "Kochen mit dem, was da ist" => L10n.current.onboardingCookWithWhatYouHave,
    "Richtwerte nur, wenn du möchtest" =>
      L10n.current.onboardingGuidelineValuesOnlyIfYouWantThem,
    "Frühstück" => L10n.current.onboardingBreakfast,
    "Mittagessen" => L10n.current.onboardingLunch,
    "DEIN TAG" => L10n.current.onboardingYourDay,
    "von 2.100" => L10n.current.onboardingOf2100,
    "Noch leer" => L10n.current.onboardingStillEmpty,
    "KI schätzt Lebensmittel" => L10n.current.onboardingAiEstimatesFoods,
    "Produkt finden" => L10n.current.onboardingFindProduct,
    "Suchen oder selbst" => L10n.current.onboardingSearchOrEnterManually,
    "Reis" => L10n.current.onboardingRice,
    "Lachs" => L10n.current.onboardingSalmon,
    "Salat" => L10n.current.onboardingSalad,
    "Du hast heute noch etwa 650 kcal frei. Wie wäre eine Lachs-Tomaten-Bowl? Rund 35 g Protein." =>
      L10n.current.onboardingYouHaveAbout650KcalLeftToday,
    "FÜR DICH" => L10n.current.onboardingForYou,
    "Vegetarisch" => L10n.current.profileVegetarian,
    "20 Min." => L10n.current.onboarding20Min,
    "Lachs-Avocado-Reis" => L10n.current.onboardingSalmonAvocadoRice,
    "560 kcal · 34 g Protein" => L10n.current.onboarding560Kcal34GProtein,
    "Zu Hause" => L10n.current.onboardingAtHome,
    "Im Tagebuch" => L10n.current.onboardingInDiary,
    "Dein Profil" => L10n.current.onboardingYourProfile,
    "Muskeln aufbauen" => L10n.current.profileBuildMuscle,
    "Einträge heute" => L10n.current.profileEntriesToday,
    "Tage Serie" => L10n.current.profileDayStreak2,
    "kcal heute" => L10n.current.profileKcalToday,
    "MEINE TÄGLICHEN ZIELE" => L10n.current.onboardingMyDailyTargets,
    "Die Einführung erscheint beim nächsten Start eventuell erneut." =>
      L10n.current.onboardingTheIntroductionMayAppearAgainAtThe,
    "Lookin wird geöffnet" => L10n.current.onboardingOpeningLookin,
    "DEIN TAGEBUCH" => L10n.current.onboardingYourDiary,
    "Dein Tag." => L10n.current.onboardingYourDay2,
    "Auf einen Blick." => L10n.current.onboardingAtAGlance,
    "Frühstück, Mittagessen, Abendessen und Snacks an einem Ort – mit Kalorien, Kohlenhydraten, Protein und Fett." =>
      L10n.current.onboardingBreakfastLunchDinnerAndSnacksInOne,
    "Sehen, was du heute schon gegessen hast." =>
      L10n.current.onboardingSeeWhatYouHaveAlreadyEatenToday,
    "SCHNELL EINGETRAGEN" => L10n.current.onboardingQuickToLog,
    "Ein Tipp aufs Plus." => L10n.current.onboardingTapThePlus,
    "Drei Wege." => L10n.current.onboardingThreeWays,
    "Foto machen, Barcode scannen oder selbst eintragen. Das Plus in der Mitte ist immer nur einen Tipp entfernt." =>
      L10n.current.onboardingTakeAPhotoScanABarcodeOr,
    "Suchen und eigene Lebensmittel inklusive." =>
      L10n.current.onboardingSearchAndCustomFoodsIncluded,
    "KI-FOTO · PREMIUM" => L10n.current.onboardingAiPhotoPremium,
    "Foto machen." => L10n.current.onboardingTakeAPhoto,
    "KI schätzt." => L10n.current.onboardingAiEstimates,
    "Die KI erkennt Lebensmittel und schätzt die Mengen. Du prüfst Gramm und Nährwerte, ergänzt, was fehlt – und speicherst erst dann." =>
      L10n.current.onboardingAiRecognisesFoodsAndEstimatesAmountsYou,
    "Schätzungen sind immer als Schätzung markiert." =>
      L10n.current.onboardingEstimatesAreAlwaysLabelledAsEstimates,
    "Frag einfach." => L10n.current.onboardingJustAsk,
    "Dein KI-Coach." => L10n.current.onboardingYourAiCoach,
    "Antworten zu Ernährung und Fitness, passend zu deinem Ziel und deinen Tageswerten." =>
      L10n.current.onboardingAnswersAboutNutritionAndFitnessTailoredTo,
    "Konzentriert auf Ernährung und Fitness." =>
      L10n.current.onboardingFocusedOnNutritionAndFitness,
    "REZEPTE" => L10n.current.onboardingRecipes,
    "Rezepte finden." => L10n.current.onboardingFindRecipes,
    "Einfach kochen." => L10n.current.onboardingCookSimply,
    "Filtere nach Schnell, High Protein oder Vegetarisch und finde Rezepte mit dem, was du zu Hause hast." =>
      L10n.current.onboardingFilterByQuickHighProteinOrVegetarian,
    "Mit einem Tipp ins Tagebuch." =>
      L10n.current.onboardingLogInYourDiaryWithOneTap,
    "DEIN PROFIL" => L10n.current.onboardingYourProfile2,
    "Deine Ziele." => L10n.current.onboardingYourGoals,
    "Deine Serie." => L10n.current.onboardingYourStreak,
    "Wenn du möchtest, berechnet Lookin Richtwerte aus Alter, Größe und Gewicht. Deine Serie zeigt, wie regelmäßig du dabei bist." =>
      L10n.current.onboardingIfYouWishLookinCalculatesGuidelineValues,
    "Ohne Angaben funktioniert Lookin genauso." =>
      L10n.current.onboardingLookinWorksWithoutThisInformationToo,
    "Überspringen" => L10n.current.onboardingSkip,
    "Einen Moment …" => L10n.current.profileOneMoment,
    "Los geht’s" => L10n.current.subscriptionLetSGo,
    "Schon dabei? " => L10n.current.onboardingAlreadyAMember,
    "Beispielansicht" => L10n.current.onboardingExampleView,
    "Animation wiederholen" => L10n.current.onboardingReplayAnimation,
    "Platz für dich." => L10n.current.onboardingSpaceForYou,
    "Du bestimmst die Richtung." =>
      L10n.current.onboardingYouChooseTheDirection,
    "Jeder Alltag ist anders." =>
      L10n.current.onboardingEveryRoutineIsDifferent,
    "Was dir guttut, zählt." =>
      L10n.current.onboardingWhatFeelsRightForYouMatters,
    "Deine Wünsche auf einen Blick." =>
      L10n.current.onboardingYourPreferencesAtAGlance,
    "DEINE AUSWAHL" => L10n.current.onboardingYourChoices,
    "Dein Alltag. Dein Lookin." => L10n.current.onboardingYourDayYourLookin,
    "So passt Lookin zu dir" => L10n.current.onboardingMakeLookinFitYou,
    "Wie isst du gern? Richte deinen Rhythmus und deine Rezeptideen in wenigen Schritten ein." =>
      L10n.current.onboardingHowDoYouLikeToEatSet,
    "Rezeptideen ansehen" => L10n.current.onboardingViewRecipeIdeas,
    "Persönlich einrichten" => L10n.current.onboardingPersonalise,
    "Antworten entfernen" => L10n.current.onboardingRemoveAnswers,
    "Deine freiwilligen Angaben helfen Lookin und dem KI-Coach, Vorschläge persönlicher zu machen. Du kannst sie jederzeit ändern oder entfernen." =>
      L10n.current.onboardingYourOptionalInformationHelpsLookinAndThe,
    "Wenig Zeit heute? In deinen Rezeptideen stehen schnelle Gerichte weiter oben." =>
      L10n.current.onboardingShortOnTimeTodayQuickMealsAppear,
    "Für deinen Einkauf stehen als Budget-Rezept markierte Ideen weiter oben." =>
      L10n.current.onboardingIdeasMarkedAsBudgetRecipesAppearHigher,
    "Dein Rhythmus ist eine Orientierung. Du kannst ihn jederzeit ändern." =>
      L10n.current.onboardingYourRhythmIsAGuideYouCan,
    "Deine Rezeptideen berücksichtigen deine Kochzeit." =>
      L10n.current.onboardingYourRecipeIdeasTakeYourCookingTime,
    "Deine Rezeptideen richten sich nach den Vorlieben, die du angegeben hast." =>
      L10n.current.onboardingYourRecipeIdeasReflectThePreferencesYou,
    "Deine Einrichtungsantworten wurden von diesem Gerät entfernt." =>
      L10n.current.onboardingYourSetupAnswersHaveBeenRemovedFrom,
    "Entfernen hat nicht geklappt. Bitte versuche es erneut." =>
      L10n.current.onboardingRemovalDidNotWorkPleaseTryAgain,
    "Deine Einstellungen konnten nicht geladen werden." =>
      L10n.current.onboardingYourSettingsCouldNotBeLoaded,
    "Für jetzt fortfahren" => L10n.current.onboardingContinueForNow,
    "Dein Lookin wird vorbereitet …" =>
      L10n.current.subscriptionPreparingYourLookin,
    "Du kannst weitermachen. Die Fragen erscheinen beim nächsten Start möglicherweise erneut." =>
      L10n.current.onboardingYouCanContinueTheQuestionsMayAppear,
    "Mär" => L10n.current.onboardingMar,
    "Mai" => L10n.current.onboardingMay,
    "Okt" => L10n.current.onboardingOct,
    "Dez" => L10n.current.onboardingDec,
    "Passt genau so – Wert übernehmen" =>
      L10n.current.onboardingThatFitsUseThisValue,
    "Das hat gerade nicht geklappt. Bitte versuche es noch einmal." =>
      L10n.current.onboardingThatDidNotWorkJustNowPlease,
    "Deine Angaben konnten nicht gespeichert werden. Bitte versuche es erneut." =>
      L10n.current.onboardingYourInformationCouldNotBeSavedPlease,
    "Damit Lookin dich richtig anspricht." =>
      L10n.current.onboardingSoLookinCanAddressYouProperly,
    "Was ist dein Ziel?" => L10n.current.onboardingWhatIsYourGoal,
    "Warum ist dir das wichtig?" => L10n.current.onboardingWhyDoesItMatterToYou,
    "Dein Geschlecht" => L10n.current.onboardingYourSex,
    "Wann hast du Geburtstag?" => L10n.current.onboardingWhenIsYourBirthday,
    "Wie groß bist du?" => L10n.current.onboardingHowTallAreYou,
    "Wo stehst du gerade?" => L10n.current.onboardingWhereAreYouNow,
    "Wohin möchtest du?" => L10n.current.onboardingWhereWouldYouLikeToBe,
    "Was ist dein Wunschgewicht?" =>
      L10n.current.onboardingWhatIsYourTargetWeight,
    "Wie aktiv bist du meistens?" =>
      L10n.current.onboardingHowActiveAreYouUsually,
    "Wie isst du?" => L10n.current.onboardingHowDoYouEat,
    "Wie sieht es in deiner Küche aus?" =>
      L10n.current.onboardingWhatIsYourKitchenRoutine,
    "Was hat dich bisher gebremst?" =>
      L10n.current.onboardingWhatHasHeldYouBackSoFar,
    "Gibt es etwas, worauf Lookin achten soll?" =>
      L10n.current.onboardingIsThereAnythingLookinShouldTakeInto,
    "Du startest ganz neutral." =>
      L10n.current.onboardingYouAreStartingWithACleanSlate,
    "Dein Lookin-Plan ist bereit." =>
      L10n.current.onboardingYourLookinPlanIsReady,
    "Dein Plan wird erstellt …" => L10n.current.onboardingCreatingYourPlan,
    "Dein Name ist optional. Alle Angaben kannst du später im Profil ändern." =>
      L10n.current.onboardingYourNameIsOptionalYouCanChange,
    "Wähle alles, was passt. Dein Coach greift das auf, wenn es mal schwerfällt." =>
      L10n.current.onboardingSelectEverythingThatFitsYourCoachUses,
    "Nur für die Schätzung deines Energiebedarfs – Körper verbrauchen je nach Geschlecht unterschiedlich viel. Du kannst das auch offenlassen." =>
      L10n.current.onboardingOnlyUsedToEstimateYourEnergyNeeds,
    "Wische direkt in den Rädern nach oben oder unten." =>
      L10n.current.onboardingSwipeTheWheelsUpOrDown,
    "Wähle die Einheit, die für dich natürlich ist, und wische zum passenden Wert." =>
      L10n.current.onboardingChooseTheUnitThatFeelsNaturalTo,
    "Ziehe das Lineal nach links oder rechts. Es ist dein aktuelles Gewicht, kein Ziel." =>
      L10n.current.onboardingDragTheRulerLeftOrRightThis,
    "Ein Ziel, das zu dir passt – kein Muss. Du kannst es jederzeit ändern." =>
      L10n.current.onboardingATargetThatFitsYouNotA,
    "Dein ganz normaler Alltag, ohne gezieltes Training." =>
      L10n.current.onboardingYourNormalEverydayRoutineWithoutDedicatedExercise,
    "Damit Rezepte, Vorschläge und der Coach zu dir passen." =>
      L10n.current.onboardingSoRecipesSuggestionsAndTheCoachFit,
    "So schlägt Lookin Rezepte vor, die in deinen Tag passen." =>
      L10n.current.onboardingThisHelpsLookinSuggestRecipesThatFit,
    "Wähle alles, was passt – das ist völlig normal. Lookin gibt dir dazu passende Tipps." =>
      L10n.current.onboardingSelectEverythingThatFitsItIsCompletely,
    "Freiwillig und nur für deine Sicherheit. Diese Angabe bleibt auf diesem Gerät." =>
      L10n.current.onboardingOptionalAndOnlyForYourSafetyThis,
    "Beantworte die Fragen jederzeit im Profil, dann passt sich Lookin an dich an." =>
      L10n.current.onboardingAnswerTheQuestionsInYourProfileAt,
    "Alles basiert auf deinen Antworten und lässt sich jederzeit im Profil anpassen." =>
      L10n.current.onboardingEverythingIsBasedOnYourAnswersAnd,
    "Lookin verarbeitet gerade deine Antworten." =>
      L10n.current.onboardingLookinIsProcessingYourAnswers,
    "Wie dürfen wir dich nennen? (optional)" =>
      L10n.current.onboardingWhatShouldWeCallYouOptional,
    "Zum Beispiel Alex" => L10n.current.onboardingForExampleAlex,
    "Du kannst oben überspringen. Lookin funktioniert auch ohne diese Antworten." =>
      L10n.current.onboardingYouCanSkipAboveLookinWorksWithout,
    "Schon ein Konto? Anmelden" =>
      L10n.current.onboardingAlreadyHaveAnAccountSignIn,
    "Geburtsdatum" => L10n.current.onboardingDateOfBirth,
    "Deine Größe" => L10n.current.onboardingYourHeight,
    "Ziehe das Lineal nach links oder rechts. Dein Gewicht wird nicht bewertet." =>
      L10n.current.onboardingDragTheRulerLeftOrRightYour,
    "Meist sitzend: Büro, Studium, Auto. Viel in Bewegung: Pflege, Handwerk, Verkauf oder viele Wege zu Fuß." =>
      L10n.current.onboardingMostlySeatedOfficeStudyCarOftenMoving,
    "Ernährungsweise" => L10n.current.onboardingNutritionStyle,
    "Pescetarisch" => L10n.current.onboardingPescatarian,
    "Zeit zum Kochen an einem normalen Tag" =>
      L10n.current.onboardingTimeToCookOnANormalDay,
    "Hast du schon einmal Kalorien gezählt?" =>
      L10n.current.onboardingHaveYouCountedCaloriesBefore,
    "Dein Gewicht liegt bereits im unteren gesunden Bereich. Lookin schlägt dir deshalb kein Abnehmziel vor – wir helfen dir, gut und ausgewogen zu essen." =>
      L10n.current.onboardingYourWeightIsAlreadyAtTheLower,
    "Lookin bietet nur Ziele im gesunden Bereich (BMI ab 18,5) und höchstens etwa ein halbes Kilo pro Woche an." =>
      L10n.current.onboardingLookinOnlyOffersTargetsWithinTheHealthy,
    "Muskeln wachsen langsam. Genug Eiweiß und Training sind wichtiger als schnelle Zahlen." =>
      L10n.current.onboardingMuscleGrowsSlowlyEnoughProteinAndTraining,
    "Trifft nichts davon zu? Dann tippe einfach auf „Weiter“." =>
      L10n.current.onboardingNoneOfTheseApplySimplyTapContinue,
    "Danke, dass du das teilst. Lookin berechnet für dich keine Kalorienziele und schlägt keine Diät vor. Tagebuch, Rezepte und Coach kannst du trotzdem nutzen – deine Ziele besprichst du am besten mit deiner Ärztin, deinem Arzt oder einer Ernährungsfachkraft." =>
      L10n.current.onboardingThankYouForSharingThisLookinDoes,
    "Metrisch · cm / kg" => L10n.current.onboardingMetricCmKg,
    "Alter" => L10n.current.onboardingAge,
    "Größe" => L10n.current.onboardingHeight,
    "Gewicht" => L10n.current.progressWeight,
    "Geschlecht" => L10n.current.onboardingSex,
    "Alltag" => L10n.current.onboardingDailyRoutine,
    "Eiweiß und Fett passend zu deinem Ziel festlegen" =>
      L10n.current.onboardingSetProteinAndFatToFitYour,
    "Eiweiß und Fett aus deinem Gewicht ableiten" =>
      L10n.current.onboardingEstimateProteinAndFatFromYourWeight,
    "Zeit bis zu deinem Wunschgewicht abschätzen" =>
      L10n.current.onboardingEstimateTimeToYourTargetWeight,
    "Kalorienziele für dich bewusst weglassen" =>
      L10n.current.onboardingIntentionallyLeaveOutCalorieTargetsForYou,
    "Deine Antworten zusammenfassen" =>
      L10n.current.onboardingSummariseYourAnswers,
    "Rezepte mit deinen Allergenen aussortieren" =>
      L10n.current.onboardingFilterOutRecipesContainingYourAllergens,
    "Deinem Coach deine Antworten als Hintergrund mitgeben" =>
      L10n.current.onboardingGiveYourCoachYourAnswersAsBackground,
    "Januar" => L10n.current.onboardingJanuary,
    "Februar" => L10n.current.onboardingFebruary,
    "März" => L10n.current.onboardingMarch,
    "Juni" => L10n.current.onboardingJune,
    "Juli" => L10n.current.onboardingJuly,
    "Oktober" => L10n.current.onboardingOctober,
    "Dezember" => L10n.current.onboardingDecember,
    "Das macht Lookin jetzt für dich" =>
      L10n.current.onboardingWhatLookinDoesForYouNow,
    "Richtwerte zur Orientierung, keine medizinische Beratung. Du kannst alles jederzeit im Profil anpassen." =>
      L10n.current.onboardingGuidelineValuesForOrientationNotMedicalAdvice,
    "Rezepte mit deinen Allergenen blendet Lookin aus." =>
      L10n.current.onboardingLookinHidesRecipesContainingYourAllergens,
    "Dein Coach kennt deine Ziele und Hürden und richtet Tipps daran aus." =>
      L10n.current.onboardingYourCoachKnowsYourGoalsAndObstacles,
    "Mahlzeiten per Suche oder Barcode eintragen – mit Premium auch per Foto." =>
      L10n.current.onboardingLogMealsThroughSearchOrBarcodeAnd,
    "Eiweiß" => L10n.current.onboardingProtein,
    "Dein Tagesrichtwert" => L10n.current.onboardingYourDailyGuideline,
    "Du hast keine Angaben gemacht. Darum berechnet Lookin noch keine Tagesziele und sortiert Rezepte nicht für dich. Sobald du im Profil etwas ergänzt, passt sich Lookin an." =>
      L10n.current.onboardingYouHaveNotProvidedAnyInformationLookin,
    "Für dich berechnet Lookin keine Kalorienziele. Tagebuch, Rezepte und Coach kannst du trotzdem nutzen – deine Ziele besprichst du am besten mit einer Ärztin, einem Arzt oder einer Ernährungsfachkraft." =>
      L10n.current.onboardingLookinDoesNotCalculateCalorieTargetsFor,
    "Für Personen unter 18 Jahren berechnet Lookin keine Kalorienziele. Rezepte, Tagebuch und Tipps kannst du trotzdem nutzen." =>
      L10n.current.onboardingLookinDoesNotCalculateCalorieTargetsFor2,
    "Ohne Alter, Größe und Gewicht berechnet Lookin keine Tagesziele. Du kannst sie jederzeit im Profil ergänzen." =>
      L10n.current.onboardingLookinDoesNotCalculateDailyTargetsWithout,
    "Grobe Schätzung – dein Körper hält sich nicht an Kalender." =>
      L10n.current.onboardingARoughEstimateYourBodyDoesNot,
    "Wähle ein Bild mit höchstens 8 MB." =>
      L10n.current.profileChooseAnImageNoLargerThan8,
    "Wähle bitte ein JPG- oder PNG-Bild." =>
      L10n.current.profilePleaseChooseAJpgOrPngImage,
    "Dieses Bild konnte nicht geöffnet werden." =>
      L10n.current.profileThisImageCouldNotBeOpened,
    "Das Bild ist sehr groß. Wähle ein Foto mit höchstens 24 Megapixeln." =>
      L10n.current.profileTheImageIsVeryLargeChooseA,
    "Wähle den Bildausschnitt erneut." =>
      L10n.current.profileSelectTheCropAgain,
    "Wähle das Bild bitte erneut aus." =>
      L10n.current.profilePleaseChooseTheImageAgain,
    "Das Bild konnte nicht verkleinert werden." =>
      L10n.current.profileTheImageCouldNotBeResized,
    "Speichern abgebrochen." => L10n.current.profileSavingCancelled,
    "Deine Daten wurden als JSON-Datei gespeichert." =>
      L10n.current.profileYourDataHasBeenSavedAsA,
    "Der Export hat nicht geklappt. Bitte prüfe deine Verbindung und versuche es erneut." =>
      L10n.current.profileExportFailedPleaseCheckYourConnectionAnd,
    "Das Passwort stimmt nicht. Dein Konto wurde nicht gelöscht." =>
      L10n.current.profileYourPasswordIsIncorrectYourAccountWas,
    "Das Konto konnte nicht gelöscht werden. Bitte versuche es erneut." =>
      L10n.current.profileYourAccountCouldNotBeDeletedPlease,
    "Das Konto konnte nicht vollständig gelöscht werden. Bitte prüfe, ob du noch angemeldet bist." =>
      L10n.current.profileYourAccountCouldNotBeCompletelyDeleted,
    "Meine Daten exportieren" => L10n.current.profileExportMyData,
    "Der Export enthält auch Gesundheits- und Chatdaten. Bewahre die Datei sicher auf." =>
      L10n.current.profileTheExportAlsoContainsHealthAndChat,
    "Konto und Kontodaten löschen" =>
      L10n.current.profileDeleteAccountAndAccountData,
    "Konto endgültig löschen?" => L10n.current.profilePermanentlyDeleteAccount,
    "Dein Premium-Abo läuft weiter!" =>
      L10n.current.profileYourPremiumSubscriptionWillContinue,
    "Das Löschen des Kontos kündigt dein Abo nicht. Der Store bucht weiter ab, bis du es dort kündigst. Kündige zuerst, dann lösche das Konto." =>
      L10n.current.profileDeletingYourAccountDoesNotCancelYour,
    "Abos im Store öffnen" => L10n.current.profileOpenStoreSubscriptions,
    "Passwort zur Bestätigung" => L10n.current.profilePasswordToConfirm,
    "Konto löschen" => L10n.current.profileDeleteAccount,
    "Bilder" => L10n.current.profileImages,
    "Das Bild ließ sich nicht öffnen. Versuche es mit einem anderen JPG oder PNG." =>
      L10n.current.profileTheImageCouldNotBeOpenedTry,
    "Das Profilbild wurde nicht gespeichert. Versuche es erneut." =>
      L10n.current.profileYourProfilePictureWasNotSavedPlease,
    "Das Profilbild wurde nicht gespeichert. Dein bisheriges Bild bleibt erhalten." =>
      L10n.current.profileYourProfilePictureWasNotSavedYour,
    "Das Profilbild konnte nicht entfernt werden." =>
      L10n.current.profileYourProfilePictureCouldNotBeRemoved,
    "Das Profilbild konnte nicht entfernt werden. Versuche es erneut." =>
      L10n.current.profileYourProfilePictureCouldNotBeRemoved2,
    "Dein Profilbild" => L10n.current.profileYourProfilePicture,
    "Ein kleines Stück von dir." => L10n.current.profileALittlePieceOfYou,
    "Bildausschnitt. Ziehe das Bild oder nutze die Regler." =>
      L10n.current.profileCropYourImageDragItOrUse,
    "Verschiebe das Bild für deinen Ausschnitt." =>
      L10n.current.profileMoveTheImageToChooseYourCrop,
    "Ausschnitt fein einstellen" => L10n.current.profileFineTuneTheCrop,
    "Links – rechts" => L10n.current.profileLeftRight,
    "Oben – unten" => L10n.current.profileUpDown,
    "Bild auswählen" => L10n.current.profileChooseImage,
    "Anderes Bild auswählen" => L10n.current.profileChooseAnotherImage,
    "Profilbild speichern" => L10n.current.profileSaveProfilePicture,
    "Profilbild entfernen" => L10n.current.profileRemoveProfilePicture,
    "JPG oder PNG · bis 8 MB\nDein Profilbild ist nur für dein Konto sichtbar." =>
      L10n.current.profileJpgOrPngUpTo8Mb,
    "Meine täglichen Ziele" => L10n.current.profileMyDailyTargets,
    "Ernährungsprofil" => L10n.current.profileNutritionProfile,
    "App & Datenschutz" => L10n.current.profileAppPrivacy,
    "Profil bearbeiten" => L10n.current.profileEditProfile,
    "Noch kein Ziel gewählt" => L10n.current.profileNoGoalSelectedYet,
    "Profilbild ändern" => L10n.current.profileChangeProfilePicture,
    "Eintrag heute" => L10n.current.profileEntryToday,
    "Tag Serie" => L10n.current.profileDayStreak,
    "Diese Richtwerte berechnen wir aus deinem Alter, deiner Größe, deinem Gewicht und deinem Alltag. Sie dienen zur Orientierung und ersetzen keine ärztliche Beratung." =>
      L10n.current.profileWeCalculateTheseGuidelineValuesFromYour,
    "Deine Tagesziele berechnen wir aus deinem Alter, deiner Größe, deinem Gewicht und deinem Alltag. Wenn du möchtest, beantworte dazu ein paar kurze Fragen. Du kannst Lookin aber auch ganz ohne Ziele nutzen." =>
      L10n.current.profileWeCalculateYourDailyTargetsFromYour,
    "Für Personen unter 18 Jahren berechnet Lookin keine Kalorienziele. Bei Fragen zur Ernährung wende dich bitte an eine Ärztin, einen Arzt oder eine Ernährungsfachkraft." =>
      L10n.current.profileLookinDoesNotCalculateCalorieTargetsFor,
    "Weil du angegeben hast, dass deine Ernährung gerade besondere Aufmerksamkeit braucht, berechnet Lookin keine Kalorienziele. Besprich deine Ziele bitte mit deiner Ärztin, deinem Arzt oder einer Ernährungsfachkraft. Tagebuch und Rezepte kannst du trotzdem nutzen." =>
      L10n.current.profileBecauseYouIndicatedThatYourNutritionNeeds,
    "Angaben ändern" => L10n.current.profileChangeInformation,
    "Fragen beantworten" => L10n.current.profileAnswerQuestions,
    "Ernährungsstil" => L10n.current.profileNutritionStyle,
    "Allergien" => L10n.current.profileAllergies,
    "Aktivität" => L10n.current.profileActivity,
    "Flexibel" => L10n.current.profileFlexible,
    "Entwickler: Premium" => L10n.current.profileDeveloperPremium,
    "Nur für dein Entwickler-Konto sichtbar" =>
      L10n.current.profileOnlyVisibleToYourDeveloperAccount,
    "Premium konnte gerade nicht umgeschaltet werden." =>
      L10n.current.profilePremiumCouldNotBeSwitchedJustNow,
    "Vertrag widerrufen" => L10n.current.sharedWithdrawFromContract,
    "Innerhalb von 14 Tagen nach dem Kauf, ohne Grund" =>
      L10n.current.profileWithin14DaysOfPurchaseWithoutGiving,
    "Bald verfügbar" => L10n.current.subscriptionComingSoon,
    "Datenschutz & Daten" => L10n.current.profilePrivacyData,
    "Exportieren, löschen, Einwilligungen" =>
      L10n.current.profileExportDeleteConsents,
    "Hilfe & Sicherheit" => L10n.current.profileHelpSafety,
    "Hinweise und Kontakt" => L10n.current.profileInformationAndContact,
    "Impressum & Rechtliches" => L10n.current.profileImprintLegal,
    "Impressum, AGB, Datenschutz, Widerruf" =>
      L10n.current.profileImprintTermsPrivacyWithdrawal,
    "Von vorne zeigen" => L10n.current.profileStartFromTheBeginning,
    "Einführung, Fragen und Premium wie beim ersten Start" =>
      L10n.current.profileIntroductionQuestionsAndPremiumAsOnThe,
    "Abmelden" => L10n.current.profileSignOut,
    "Dieses Konto auf dem Gerät verlassen" =>
      L10n.current.profileLeaveThisAccountOnThisDevice,
    "Abmelden?" => L10n.current.profileSignOut2,
    "Deine gespeicherten Kontodaten bleiben erhalten. Du kannst dich später wieder anmelden." =>
      L10n.current.profileYourSavedAccountDataWillBeKept,
    "Testphase aktiv" => L10n.current.profileTrialActive,
    "Premium aktiv" => L10n.current.profilePremiumActive,
    "Pläne und Vorteile ansehen" => L10n.current.profileViewPlansAndBenefits,
    "Rufname und persönliche Wünsche änderst du im Profil unter „Antworten ändern“. Die folgenden Zahlen sind deine separat eingestellten Ziele." =>
      L10n.current.profileChangeYourPreferredNameAndPersonalPreferences,
    "Mein Ziel" => L10n.current.profileMyGoal,
    "Fett verlieren" => L10n.current.profileLoseFat,
    "Gewicht halten" => L10n.current.profileMaintainWeight,
    "Dein Kalorienziel wird aus deinen Angaben berechnet." =>
      L10n.current.profileYourCalorieTargetIsCalculatedFromYour,
    "Änderungen übernehmen" => L10n.current.profileApplyChanges,
    "Demo: Änderungen bleiben bis zum Neustart erhalten." =>
      L10n.current.profileDemoChangesLastUntilTheAppRestarts,
    "Impressum" => L10n.current.sharedImprint,
    "AGB" => L10n.current.sharedTerms,
    "Datenschutzerklärung" => L10n.current.profilePrivacyPolicy,
    "Widerrufsbelehrung" => L10n.current.profileWithdrawalInformation,
    "Öffnet sich im Browser" => L10n.current.profileOpensInBrowser,
    "Für Lookin Premium, ohne Angabe von Gründen" =>
      L10n.current.profileForLookinPremiumWithoutGivingAReason,
    "Erinnerungen an Mahlzeiten, Wasser und einen Wochenrückblick kommen mit einem der nächsten Updates. Bis dahin verschickt Lookin keine Benachrichtigungen." =>
      L10n.current.profileMealWaterAndWeeklyReviewRemindersWill,
    "Deine gespeicherten Profilangaben" =>
      L10n.current.profileYourSavedProfileInformation,
    "Ernährungsweise und Aktivität änderst du unter „Antworten ändern“." =>
      L10n.current.profileChangeNutritionStyleAndActivityUnderChange,
    "Ausgewogen" => L10n.current.profileBalanced,
    "Aktivitätsniveau" => L10n.current.profileActivityLevel,
    "Wenig aktiv" => L10n.current.profileLowActivity,
    "Moderat aktiv" => L10n.current.profileModeratelyActive,
    "Sehr aktiv" => L10n.current.profileVeryActive,
    "Ernährungsprofil speichern" => L10n.current.profileSaveNutritionProfile,
    "Transparent und unter deiner Kontrolle" =>
      L10n.current.profileTransparentAndUnderYourControl,
    "Profil & Ziele" => L10n.current.profileProfileTargets,
    "IM KONTO" => L10n.current.profileInAccount,
    "Mahlzeiten & Nährwerte" => L10n.current.profileMealsNutrition,
    "KI-Foto & KI-Chat" => L10n.current.profileAiPhotoAiChat,
    "KI-DIENST" => L10n.current.profileAiService,
    "Profilbild & Erinnerungen" => L10n.current.profileProfilePictureReminders,
    "NUR GERÄT" => L10n.current.profileDeviceOnly,
    "Lokale Datenübersicht" => L10n.current.profileLocalDataOverview,
    "Lokale Daten ansehen" => L10n.current.profileViewLocalData,
    "Lokale Demodaten löschen" => L10n.current.profileDeleteLocalDemoData,
    "Rechtliches" => L10n.current.profileLegal,
    "Profil, Ziele und Tagebuch werden in deinem Lookin-Konto (Supabase) gespeichert, damit sie auf jedem Gerät verfügbar sind. Fotos für die KI-Foto-Analyse und Nachrichten an den KI-Coach werden über unseren Server an OpenAI übertragen; Fotos werden dabei nicht gespeichert. Profilbild, Erinnerungen und gemerkte Lebensmittel bleiben nur auf diesem Gerät. Unter den Optionen oben kannst du deine Kontodaten exportieren oder dein Konto endgültig löschen." =>
      L10n.current.profileYourProfileTargetsAndDiaryAreSaved,
    "Demodaten löschen?" => L10n.current.profileDeleteDemoData,
    "Mahlzeiten, Favoriten, Listen und Wasserstand werden lokal geleert. Nach einem App-Neustart erscheinen die Beispiel-Mahlzeiten wieder." =>
      L10n.current.profileMealsFavouritesListsAndWaterTotalsAre,
    "Gespeicherte Listen und dein Wasserstand werden auf diesem Gerät geleert. Deine gespeicherten Mahlzeiten und Favoriten im Konto bleiben erhalten." =>
      L10n.current.profileSavedListsAndYourWaterTotalAre,
    "Gesundheit geht immer vor Tracking" =>
      L10n.current.profileHealthAlwaysComesBeforeTracking,
    "Keine medizinische Beratung" => L10n.current.profileNotMedicalAdvice,
    "Lookin unterstützt Gewohnheiten, stellt aber keine Diagnose und ersetzt keine Ärztin, keinen Arzt oder qualifizierte Ernährungsberatung." =>
      L10n.current.profileLookinSupportsHabitsButDoesNotDiagnose,
    "Essstörung oder akute Beschwerden" =>
      L10n.current.profileEatingDisorderOrAcuteSymptoms,
    "Nutze keine Diät- oder Kalorienziele auf eigene Faust. Hole dir persönliche Hilfe bei medizinischem oder psychotherapeutischem Fachpersonal. Bei einem akuten Notfall wende dich an den örtlichen Notruf." =>
      L10n.current.profileDoNotFollowDietOrCalorieTargets,
    "Zahlen sind Orientierung" => L10n.current.profileNumbersAreAGuide,
    "Nährwerte und Ziele sind Schätzungen. Achte zusätzlich auf Energie, Wohlbefinden, Schlaf und ein entspanntes Verhältnis zum Essen." =>
      L10n.current.profileNutritionValuesAndTargetsAreEstimatesAlso,
    "Deine Fortschrittsdaten konnten nicht geladen werden." =>
      L10n.current.progressYourProgressDataCouldNotBeLoaded,
    "Messung gespeichert." => L10n.current.progressMeasurementSaved,
    "Messung konnte nicht gespeichert werden." =>
      L10n.current.progressMeasurementCouldNotBeSaved,
    "Dein Fortschritt" => L10n.current.progressYourProgress,
    "Klare Trends aus deinem echten Tagebuch – ohne Druck durch einzelne Tage." =>
      L10n.current.progressClearTrendsFromYourActualDiaryWithout,
    "Aktualisieren" => L10n.current.progressRefresh,
    "Ernährungstrend" => L10n.current.progressNutritionTrend,
    "Durchschnitt pro Zeitabschnitt im Vergleich zu deinen Zielen" =>
      L10n.current.progressAveragePerTimePeriodComparedWithYour,
    "Körperverlauf" => L10n.current.progressBodyTrend,
    "Gewicht und optionaler Taillenumfang – ruhig und langfristig betrachtet" =>
      L10n.current.progressWeightAndOptionalWaistCircumferenceViewedCalmly,
    "Dein erster Eintrag macht Trends sichtbar." =>
      L10n.current.progressYourFirstEntryMakesTrendsVisible,
    "Du liegst sehr nah an deinen persönlichen Zielen." =>
      L10n.current.progressYouAreVeryCloseToYourPersonal,
    "Deine Richtung stimmt – Beständigkeit bringt jetzt am meisten." =>
      L10n.current.progressYouAreHeadingInTheRightDirection,
    "Regelmäßiges Tracken schafft zuerst Klarheit." =>
      L10n.current.progressRegularTrackingHelpsYouUnderstandYourHabits,
    "DEIN RHYTHMUS" => L10n.current.progressYourRhythm,
    "Trage Mahlzeiten ein und ergänze dein Gewicht. Lookin berechnet danach nur aus deinen echten Daten." =>
      L10n.current.progressLogMealsAndAddYourWeightLookin,
    "Zielnähe" => L10n.current.progressClosenessToTarget,
    "Ø kcal / Track-Tag" => L10n.current.progressAvgKcalTrackedDay,
    "Ø Protein / Track-Tag" => L10n.current.progressAvgProteinTrackedDay,
    "Tage im Kalorienbereich" => L10n.current.progressDaysInCalorieRange,
    "Aktuelle Serie" => L10n.current.progressCurrentStreak,
    "KALORIEN" => L10n.current.progressCalories,
    "ZIEL = 100 %" => L10n.current.progressTarget100,
    "Noch kein Ernährungstrend" => L10n.current.progressNoNutritionTrendYet,
    "Nach deinem ersten Tagebucheintrag entsteht hier automatisch ein echter Verlauf." =>
      L10n.current.progressAnActualTrendStartsHereAutomaticallyAfter,
    "Makro-Balance" => L10n.current.progressMacroBalance,
    "Durchschnitt an getrackten Tagen" =>
      L10n.current.progressAverageOnTrackedDays,
    "Tracking-Konstanz" => L10n.current.progressTrackingConsistency,
    "Die letzten maximal 28 Tage" => L10n.current.progressUpToTheLast28Days,
    "im Zielbereich" => L10n.current.progressInTargetRange,
    "Noch keine Messung" => L10n.current.progressNoMeasurementYet,
    "Dein echter Verlauf beginnt hier" =>
      L10n.current.progressYourActualTrendStartsHere,
    "Ein bis zwei Messungen pro Woche reichen. Tages-Schwankungen sind normal." =>
      L10n.current.progressOneOrTwoMeasurementsAWeekAre,
    "Trage auch an normalen Tagen ein. So wird dein Trend ehrlich und nützlich." =>
      L10n.current.progressLogOrdinaryDaysTooThisMakesYour,
    "Dein Proteindurchschnitt liegt nah am Ziel. Das unterstützt Sättigung und Muskelerhalt." =>
      L10n.current.progressYourAverageProteinIsCloseToYour,
    "Für einen Gewichtstrend genügen ein bis zwei Messungen pro Woche unter ähnlichen Bedingungen." =>
      L10n.current.progressOneOrTwoMeasurementsAWeekUnder,
    "Bewerte Gewicht über mehrere Wochen; Wasser und Salz verschieben einzelne Messungen." =>
      L10n.current.progressLookAtWeightOverSeveralWeeksWater,
    "Was deine Daten sagen" => L10n.current.progressWhatYourDataSays,
    "Bitte gib ein realistisches Gewicht zwischen 25 und 400 kg ein." =>
      L10n.current.progressPleaseEnterARealisticWeightBetween25,
    "Der Taillenumfang muss zwischen 30 und 300 cm liegen." =>
      L10n.current.progressWaistCircumferenceMustBeBetween30And,
    "Neue Messung" => L10n.current.progressNewMeasurement,
    "Eine Messung ersetzt den Wert desselben Tages." =>
      L10n.current.progressAMeasurementReplacesTheValueFromThe,
    "Taille (optional)" => L10n.current.progressWaistOptional,
    "Messung speichern" => L10n.current.progressSaveMeasurement,
    "Prüfe deine Verbindung und versuche es erneut." =>
      L10n.current.progressCheckYourConnectionAndTryAgain,
    "Kein Entwickler-Konto." => L10n.current.subscriptionNotADeveloperAccount,
    "Unerwartete Antwort." => L10n.current.subscriptionUnexpectedResponse,
    "Premium ist für dein Konto bereits aktiv." =>
      L10n.current.subscriptionPremiumIsAlreadyActiveForYourAccount,
    "Bitte bestätige zuerst deine E-Mail-Adresse über den Link in unserer E-Mail. Danach kannst du die Testphase starten." =>
      L10n.current.subscriptionPleaseConfirmYourEmailAddressUsingThe,
    "Du hast deine kostenlose Testphase bereits genutzt – sie gilt einmal pro E-Mail-Adresse." =>
      L10n.current.subscriptionYouHaveAlreadyUsedYourFreeTrial,
    "Die Testphase wird gerade eingerichtet. Bitte versuche es später noch einmal – es wurde nichts gestartet und nichts berechnet." =>
      L10n.current.subscriptionTheTrialIsBeingSetUpPlease,
    "Bitte melde dich an, um die Testphase zu starten." =>
      L10n.current.subscriptionPleaseSignInToStartYourTrial,
    "In der Vorschau ohne Konto startet keine Testphase. Melde dich an, um Premium kostenlos zu testen." =>
      L10n.current.subscriptionNoTrialStartsInThePreviewWithout,
    "Die Testphase konnte gerade nicht gestartet werden. Bitte prüfe deine Verbindung und versuche es erneut." =>
      L10n.current.subscriptionYourTrialCouldNotBeStartedJust,
    "Starte kostenlos" => L10n.current.subscriptionStartForFree,
    "Testphase bereits genutzt" => L10n.current.subscriptionTrialAlreadyUsed,
    "Premium kannst du abonnieren, sobald die Bezahlung eingerichtet ist." =>
      L10n.current.subscriptionYouCanSubscribeToPremiumOncePayments,
    "Weiter mit der kostenlosen Version" =>
      L10n.current.subscriptionContinueWithTheFreeVersion,
    "Schön, dass du da bist" => L10n.current.subscriptionGladYouAreHere,
    "Der Lookin Coach ist Teil von Premium" =>
      L10n.current.subscriptionTheLookinCoachIsPartOfPremium,
    "KI-Foto ist Teil von Premium" =>
      L10n.current.subscriptionAiPhotoIsPartOfPremium,
    "Alle Rezepte gibt es mit Premium" =>
      L10n.current.subscriptionAllRecipesAreAvailableWithPremium,
    "Hol dir " => L10n.current.subscriptionGet,
    "KI-Foto, dein persönlicher Coach und alle Rezepte – für weniger Aufwand und mehr Klarheit beim Essen." =>
      L10n.current.subscriptionAiPhotoYourPersonalCoachAndAll,
    "KI-Foto-Erkennung" => L10n.current.subscriptionAiPhotoRecognition,
    "Foto machen – Lookin schätzt Lebensmittel und Mengen. Du prüfst alles vor dem Speichern." =>
      L10n.current.subscriptionTakeAPhotoLookinEstimatesFoodsAnd,
    "Dein KI-Chat für Ernährung und Fitness, abgestimmt auf dein Ziel und deine Tageswerte." =>
      L10n.current.subscriptionYourAiChatForNutritionAndFitness,
    "Großzügiges KI-Kontingent" => L10n.current.subscriptionGenerousAiAllowance,
    "Mit Abo bis zu 100 KI-Anfragen pro Tag (Coach und Foto zusammen), in der Testphase bis zu 50." =>
      L10n.current.subscriptionUpTo100AiRequestsADay,
    "Testphase wird gestartet …" => L10n.current.subscriptionStartingTrial,
    "Deine kostenlose Testphase läuft. Sie endet automatisch – ohne Kosten." =>
      L10n.current.subscriptionYourFreeTrialIsActiveItEnds,
    "Dein Premium-Abo ist aktiv." =>
      L10n.current.subscriptionYourPremiumSubscriptionIsActive,
    "Premium ist aktiv" => L10n.current.subscriptionPremiumIsActive,
    "Premium-Abo wählen" => L10n.current.subscriptionChooseAPremiumSubscription,
    "Abo-Pläne" => L10n.current.subscriptionSubscriptionPlans,
    "Tagebuch, Makros & Serie" => L10n.current.subscriptionDiaryMacrosStreak,
    "Suche, Barcode & eigene Lebensmittel" =>
      L10n.current.subscriptionSearchBarcodeCustomFoods,
    "Profil & Tagesziele" => L10n.current.subscriptionProfileDailyTargets,
    "Lookin Coach (KI-Chat)" => L10n.current.subscriptionLookinCoachAiChat,
    "Kostenlos oder Premium?" => L10n.current.subscriptionFreeOrPremium,
    "Kostenlos" => L10n.current.subscriptionFree,
    "nicht enthalten" => L10n.current.subscriptionNotIncluded,
    "Käufe wiederherstellen" => L10n.current.subscriptionRestorePurchases,
    "Käufe wiederherstellen – bald verfügbar" =>
      L10n.current.subscriptionRestorePurchasesComingSoon,
    "Abo verwalten" => L10n.current.subscriptionManageSubscription,
    "Neues" => L10n.current.subscriptionNew,
    "Mit Premium: alle Rezepte" =>
      L10n.current.subscriptionWithPremiumAllRecipes,
    "Endet automatisch · keine Zahlungsdaten nötig · keine Kosten" =>
      L10n.current.subscriptionEndsAutomaticallyNoPaymentDetailsNeededNo,
    "Bezahlung wird gerade eingerichtet" =>
      L10n.current.subscriptionPaymentsAreBeingSetUp,
    "Jährlich" => L10n.current.subscriptionYearly,
    "Monatlich" => L10n.current.subscriptionMonthly,
    "Jährlich abonnieren" => L10n.current.subscriptionSubscribeYearly,
    "Monatlich abonnieren" => L10n.current.subscriptionSubscribeMonthly,
    "pro Jahr" => L10n.current.subscriptionPerYear,
    "pro Monat" => L10n.current.subscriptionPerMonth,
    "monatlich kündbar" => L10n.current.subscriptionCancelMonthly,
    "jeden Monat berechnet" => L10n.current.subscriptionBilledEveryMonth,
    "dem App Store" => L10n.current.subscriptionTheAppStore,
    "Die Zahlung läuft sicher über den Store. Lookin sieht und speichert keine Zahlungsdaten." =>
      L10n.current.subscriptionPaymentIsHandledSecurelyByTheStore,
    "Das Abo schließt du in der Lookin-App für Android ab. Im Browser wird nichts gekauft oder berechnet." =>
      L10n.current.subscriptionSubscribeInTheLookinAppForAndroid,
    "Käufe wiederherstellen ist nur in der Lookin-App möglich, sobald die Bezahlung dort freigeschaltet ist. Hier gibt es keine Käufe, die wiederhergestellt werden müssten." =>
      L10n.current.subscriptionRestoringPurchasesIsOnlyAvailableInThe,
    "Deine Zustimmung konnte gerade nicht gespeichert werden. Bitte prüfe deine Verbindung und versuche es erneut. Es wurde nichts gekauft." =>
      L10n.current.subscriptionYourConsentCouldNotBeSavedJust,
    "Bitte bestätige zuerst, dass Lookin Premium sofort beginnen soll." =>
      L10n.current.subscriptionPleaseConfirmFirstThatLookinPremiumShould,
    "Die Abo-Verwaltung konnte nicht geöffnet werden. Öffne die Abo-Einstellungen direkt im Store." =>
      L10n.current.subscriptionSubscriptionManagementCouldNotBeOpenedOpen,
    "Premium ist aktiv. Danke für deine Unterstützung!" =>
      L10n.current.subscriptionPremiumIsActiveThankYouForYour,
    "Dein Kauf ist angekommen. Die Freischaltung dauert noch einen Moment – öffne Lookin gleich noch einmal. Es wird nichts doppelt berechnet." =>
      L10n.current.subscriptionYourPurchaseHasBeenReceivedActivationIs,
    "Kauf abgebrochen. Es wurde nichts berechnet." =>
      L10n.current.subscriptionPurchaseCancelledNothingWasCharged,
    "Deine Zahlung ist noch in Prüfung. Premium wird freigeschaltet, sobald der Store sie bestätigt." =>
      L10n.current.subscriptionYourPaymentIsStillBeingReviewedPremium,
    "Für dieses Store-Konto wurde kein aktives Abo gefunden." =>
      L10n.current.subscriptionNoActiveSubscriptionWasFoundForThis,
    "Der Store ist gerade nicht erreichbar. Es wurde nichts berechnet – versuche es später noch einmal." =>
      L10n.current.subscriptionTheStoreIsCurrentlyUnavailableNothingWas,
    "Mehr Rezepte mit Premium" =>
      L10n.current.subscriptionMoreRecipesWithPremium,
    "Alle Rezepte freischalten" => L10n.current.subscriptionUnlockAllRecipes,
    "Der Widerruf konnte gerade nicht übermittelt werden. Bitte versuche es erneut oder widerrufe per E-Mail an lookinsupport@gmail.com. Es zählt, dass du die Erklärung innerhalb der Frist absendest." =>
      L10n.current.subscriptionYourWithdrawalCouldNotBeSubmittedJust,
    "Hier widerrufst du deinen Vertrag über Lookin Premium. Einen Grund musst du nicht angeben. Du bekommst sofort eine Eingangsbestätigung mit Datum und Uhrzeit." =>
      L10n.current.subscriptionHereYouCanWithdrawFromYourLookin,
    "E-Mail für die Bestätigung" =>
      L10n.current.subscriptionEmailForAcknowledgement,
    "Bestellnummer oder Hinweis (freiwillig)" =>
      L10n.current.subscriptionOrderNumberOrNoteOptional,
    "Zum Beispiel die Bestellnummer aus der Google-Play-Mail" =>
      L10n.current.subscriptionForExampleTheOrderNumberFromThe,
    "Widerruf bestätigen" => L10n.current.subscriptionConfirmWithdrawal,
    "Bitte mach einen Screenshot dieser Bestätigung. Eine Bestätigung per E-Mail folgt, sobald unser E-Mail-Versand eingerichtet ist. Die Rückzahlung erfolgt über Google Play." =>
      L10n.current.subscriptionPleaseTakeAScreenshotOfThisAcknowledgement,
    "Bestätigt. Hast du auch an deine andere Adresse eine E-Mail bekommen, bestätige die Änderung dort ebenfalls." =>
      L10n.current.appConfirmedIfYouAlsoReceivedAnEmail,
    "Keine Verbindung zum Server. Dein Link ist vermutlich noch gültig: Lade die Seite neu oder tippe den Link in der E-Mail noch einmal an." =>
      L10n.current.appNoConnectionToTheServerYourLink,
    "Der Link zum Zurücksetzen ist abgelaufen oder wurde schon benutzt. Fordere unter „Passwort vergessen?“ einen neuen an." =>
      L10n.current.appYourResetLinkHasExpiredOrHas,
    "Der Bestätigungslink ist abgelaufen oder wurde schon benutzt. Melde dich an. Ist deine Adresse noch nicht bestätigt, kannst du dort eine neue Bestätigungs-Mail anfordern." =>
      L10n.current.appYourConfirmationLinkHasExpiredOrHas,
    "Der Link konnte nicht geöffnet werden. Bitte versuche es später noch einmal." =>
      L10n.current.sharedTheLinkCouldNotBeOpenedPlease,
    "Datenschutz" => L10n.current.sharedPrivacy,
    "Widerruf" => L10n.current.sharedWithdrawal,
    "Hähnchen" => L10n.current.displayChicken,
    "Pute" => L10n.current.displayTurkey,
    "Rind" => L10n.current.displayBeef,
    "Fisch" => L10n.current.displayFish,
    "Ei" => L10n.current.displayEgg,
    "Käse" => L10n.current.displayCheese,
    "Süßkartoffel" => L10n.current.displaySweetPotato,
    "Nüsse" => L10n.current.displayNuts,
    "Dieser Eintrag enthält einen in Lookin ausgeschlossenen Bestandteil." =>
      L10n.current.displayThisEntryContainsAnIngredientExcludedFrom,
    "Fleisch von Landtieren wird nur mit eindeutiger Halal-Kennzeichnung aufgenommen." =>
      L10n.current.displayMeatFromLandAnimalsIsOnlyIncluded,
    "Rezept" => L10n.current.displayRecipe,
    "Einfach" => L10n.current.displayEasy,
    "Gespeichertes Rezept" => L10n.current.displaySavedRecipe,
    "7 Tage" => L10n.current.display7Days,
    "30 Tage" => L10n.current.display30Days,
    "3 Monate" => L10n.current.display3Months,
    "6 Monate" => L10n.current.display6Months,
    "1 Jahr" => L10n.current.display1Year,
    "Alles" => L10n.current.displayAllTime,
    "Deine Serie konnte nicht geladen werden." =>
      L10n.current.displayYourStreakCouldNotBeLoaded,
    "Deine Serie konnte nicht aktualisiert werden." =>
      L10n.current.displayYourStreakCouldNotBeUpdated,
    "Die Auswahl konnte nicht dauerhaft gespeichert werden." =>
      L10n.current.displayYourSelectionCouldNotBeSavedPermanently,
    "Dein Bild konnte nur auf diesem Gerät nicht gespeichert werden. Bitte versuche es erneut." =>
      L10n.current.displayYourPictureCouldNotBeSavedOn,
    "Dein Bild konnte nicht entfernt werden. Bitte versuche es erneut." =>
      L10n.current.displayYourPictureCouldNotBeRemovedPlease,
    "Gesünder ernähren" => L10n.current.displayEatHealthier,
    "Aktiv" => L10n.current.displayActive,
    "Protein-Beeren-Oats" => L10n.current.displayProteinBerryOats,
    "Lachs Power Bowl" => L10n.current.displaySalmonPowerBowl,
    "Skyr mit Mandeln" => L10n.current.displaySkyrWithAlmonds,
    "Sättigend, frisch und proteinreich" =>
      L10n.current.displayFillingFreshAndRichInProtein,
    "Mittel" => L10n.current.displayMedium,
    "Kleiner Topf mit Deckel" => L10n.current.displaySmallSaucepanWithLid,
    "Beschichtete Pfanne" => L10n.current.displayNonStickFryingPan,
    "Lachsfilet" => L10n.current.displaySalmonFillet,
    "1 Filet" => L10n.current.display1Fillet,
    "Reis, gekocht" => L10n.current.displayRiceCooked,
    "½ Stück" => L10n.current.displayPiece,
    "in Scheiben" => L10n.current.displaySliced,
    "Reis erwärmen" => L10n.current.displayWarmTheRice,
    "Den gekochten Reis mit 1 EL Wasser in einem kleinen Topf mit Deckel bei niedriger Hitze etwa 4 Minuten erwärmen." =>
      L10n.current.displayWarmTheCookedRiceWith1Tbsp,
    "Lachs braten" => L10n.current.displayPanFryTheSalmon,
    "Den Lachs trocken tupfen und mit der Hautseite nach unten bei mittlerer Hitze 5 Minuten braten. Wenden und weitere 3 Minuten garen, bis er innen nicht mehr glasig ist." =>
      L10n.current.displayPatTheSalmonDryAndFrySkin,
    "Anrichten" => L10n.current.displayServe,
    "Reis in eine Schüssel geben, Lachs und Avocado darauf legen und sofort servieren." =>
      L10n.current.displayPutTheRiceInABowlPlace,
    "Cremige Protein-Pasta" => L10n.current.displayCreamyProteinPasta,
    "Schnelles Feierabendgericht" => L10n.current.displayAQuickAfterWorkMeal,
    "Pasta kochen" => L10n.current.displayCookThePasta,
    "Reichlich Wasser mit 1 TL Salz aufkochen und die Pasta nach Packungsangabe bissfest garen." =>
      L10n.current.displayBringPlentyOfWaterWith1Tsp,
    "Sauce rühren" => L10n.current.displayMixTheSauce,
    "Skyr mit etwas Nudelwasser glatt rühren, bis eine cremige Sauce entsteht." =>
      L10n.current.displayStirTheSkyrWithALittlePasta,
    "Vermengen" => L10n.current.displayCombine,
    "Pasta abgießen, mit der Sauce vermengen und mit Pfeffer abschmecken." =>
      L10n.current.displayDrainThePastaMixWithTheSauce,
    "Frühstück in acht Minuten" => L10n.current.displayBreakfastInEightMinutes,
    "Hafer quellen lassen" => L10n.current.displaySoakTheOats,
    "Haferflocken mit 80 ml Wasser verrühren und 3 Minuten quellen lassen." =>
      L10n.current.displayMixTheOatsWith80MlOf,
    "Skyr unterrühren" => L10n.current.displayStirInTheSkyr,
    "Skyr unterrühren, bis alles gleichmäßig cremig ist." =>
      L10n.current.displayStirInTheSkyrUntilEvenlyCreamy,
    "Toppen" => L10n.current.displayAddTheTopping,
    "Beeren darauf verteilen und sofort servieren." =>
      L10n.current.displayScatterTheBerriesOverTheTopAnd,
    "Dein lokales Profilbild konnte nicht geladen werden." =>
      L10n.current.displayYourLocalProfilePictureCouldNotBe,
    "Dieser Eintrag entspricht nicht den Halal-Inhaltsregeln von Lookin." =>
      L10n.current.displayThisEntryDoesNotMeetLookinS,
    "Dieses Lebensmittel entspricht nicht den Halal-Inhaltsregeln von Lookin." =>
      L10n.current.displayThisFoodDoesNotMeetLookinS,
    "Bitte gib deinem Lebensmittel einen Namen." =>
      L10n.current.displayPleaseGiveYourFoodAName,
    "Das Rezept konnte nicht mehr gefunden werden." =>
      L10n.current.displayThisRecipeCouldNoLongerBeFound,
    "Dieses Rezept entspricht nicht den Halal-Inhaltsregeln von Lookin." =>
      L10n.current.displayThisRecipeDoesNotMeetLookinS,
    "Die Verbindung zu deinem Tagebuch hat gerade nicht geklappt. Bitte prüfe dein Internet und versuche es erneut." =>
      L10n.current.displayConnectingToYourDiaryDidNotWork,
    "Glutenhaltiges Getreide" => L10n.current.displayCerealsContainingGluten,
    "Krebstiere" => L10n.current.displayCrustaceans,
    "Erdnüsse" => L10n.current.displayPeanuts,
    "Soja" => L10n.current.displaySoya,
    "Milch" => L10n.current.displayMilk,
    "Schalenfrüchte" => L10n.current.displayTreeNuts,
    "Sellerie" => L10n.current.displayCelery,
    "Senf" => L10n.current.displayMustard,
    "Sesam" => L10n.current.displaySesame,
    "Schwefeldioxid / Sulfite" => L10n.current.displaySulphurDioxideSulphites,
    "Lupinen" => L10n.current.displayLupin,
    "Weichtiere" => L10n.current.displayMolluscs,
    "Laktose (Unverträglichkeit)" => L10n.current.displayLactoseIntolerance,
    "PROTEIN" => L10n.current.displayProtein,
    "BALANCE" => L10n.current.displayBalance,
    "Protein g" => L10n.current.displayProteinG,
    "Nudeln" => L10n.current.displayPasta,
    "Knoblauch" => L10n.current.displayGarlic,
    "Haferflocken" => L10n.current.displayOats,
    "Mehl" => L10n.current.displayFlour,
    "Dosentomaten" => L10n.current.displayTinnedTomatoes,
    "Linsen" => L10n.current.displayLentils,
    "Kichererbsen" => L10n.current.displayChickpeas,
    "Joghurt" => L10n.current.displayYoghurt,
    "Salz, Pfeffer, Öl, Wasser und gängige Gewürze wie Paprikapulver, Currypulver, Kreuzkümmel, Zimt oder Oregano" =>
      L10n.current.displaySaltPepperOilWaterAndCommonSpices,
    "Erdäpfel" => L10n.current.displayPotatoes,
    "Kartoffel" => L10n.current.displayPotato,
    "Paradeiser" => L10n.current.displayTomatoes,
    "Tomate" => L10n.current.displayTomato,
    "Möhre" => L10n.current.displayCarrot,
    "Karotte" => L10n.current.displayCarrot2,
    "Mohrrübe" => L10n.current.displayCarrot3,
    "Rübli" => L10n.current.displayCarrot4,
    "Nudel" => L10n.current.displayPasta2,
    "Porree" => L10n.current.displayLeek,
    "Lauch" => L10n.current.displayLeek2,
    "Karfiol" => L10n.current.displayCauliflower,
    "Blumenkohl" => L10n.current.displayCauliflower2,
    "Melanzani" => L10n.current.displayAubergine,
    "Aubergine" => L10n.current.displayAubergine2,
    "Zucchetti" => L10n.current.displayCourgette,
    "Zucchini" => L10n.current.displayCourgette2,
    "Topfen" => L10n.current.displayQuark,
    "Rahm" => L10n.current.displayCream,
    "Sahne" => L10n.current.displayCream2,
    "Obers" => L10n.current.displayCream3,
    "Schlagobers" => L10n.current.displayWhippingCream,
    "Sauerrahm" => L10n.current.displaySourCream,
    "Schmand" => L10n.current.displaySourCream2,
    "Jogurt" => L10n.current.displayYoghurt2,
    "Eigelb" => L10n.current.displayEggYolk,
    "Eiklar" => L10n.current.displayEggWhite,
    "Knoblauchzehe" => L10n.current.displayGarlicClove,
    "Paprikaschote" => L10n.current.displayPepper,
    "Chilischote" => L10n.current.displayChilli,
    "Vanilleschote" => L10n.current.displayVanillaPod,
    "Vanille" => L10n.current.displayVanilla,
    "Zimtstange" => L10n.current.displayCinnamonStick,
    "Zimt" => L10n.current.displayCinnamon,
    "Ingwerknolle" => L10n.current.displayGinger,
    "Ingwer" => L10n.current.displayGinger2,
    "Ingwerwurzel" => L10n.current.displayGingerRoot,
    "Lorbeerblatt" => L10n.current.displayBayLeaf,
    "Lorbeer" => L10n.current.displayBayLeaf2,
    "Lorbeerblätter" => L10n.current.displayBayLeaves,
    "Rosmarinzweig" => L10n.current.displayRosemarySprig,
    "Rosmarin" => L10n.current.displayRosemary,
    "Rosmarinzweige" => L10n.current.displayRosemarySprigs,
    "Thymianzweig" => L10n.current.displayThymeSprig,
    "Thymian" => L10n.current.displayThyme,
    "Thymianzweige" => L10n.current.displayThymeSprigs,
    "Basilikumblätter" => L10n.current.displayBasilLeaves,
    "Basilikum" => L10n.current.displayBasil,
    "Minzblätter" => L10n.current.displayMintLeaves,
    "Minze" => L10n.current.displayMint,
    "Pfefferkörner" => L10n.current.displayPeppercorns,
    "Pfeffer" => L10n.current.displayPepper2,
    "Hafer" => L10n.current.displayOats2,
    "Zwiebel" => L10n.current.displayOnion,
    "Linse" => L10n.current.displayLentil,
    "Hühnchen" => L10n.current.displayChicken2,
    "Huhn" => L10n.current.displayChicken3,
    "Hendl" => L10n.current.displayChicken4,
    "Hirtenkäse" => L10n.current.displayWhiteBrinedCheese,
    "Schafskäse" => L10n.current.displaySheepSCheese,
    "Brühe" => L10n.current.displayStock,
    "Brühwürfel" => L10n.current.displayStockCube,
    "Kichererbse" => L10n.current.displayChickpea,
    "Champignon" => L10n.current.displayMushroom,
    "Pilz" => L10n.current.displayMushroom2,
    "Champignons" => L10n.current.displayMushrooms,
    "Frühlingslauch" => L10n.current.displaySpringOnion,
    "Frühlingszwiebel" => L10n.current.displaySpringOnion2,
    "Lauchzwiebel" => L10n.current.displaySpringOnion3,
    "Zitronensaft" => L10n.current.displayLemonJuice,
    "Zitrone" => L10n.current.displayLemon,
    "Limettensaft" => L10n.current.displayLimeJuice,
    "Limette" => L10n.current.displayLime,
    "Zuckerschote" => L10n.current.displaySugarSnapPea,
    "Kokosmilch" => L10n.current.displayCoconutMilk,
    "Hafermilch" => L10n.current.displayOatMilk,
    "Sojamilch" => L10n.current.displaySoyaMilk,
    "Mandelmilch" => L10n.current.displayAlmondMilk,
    "Reismilch" => L10n.current.displayRiceMilk,
    "Buttermilch" => L10n.current.displayButtermilk,
    "Kondensmilch" => L10n.current.displayCondensedMilk,
    "Erdnussbutter" => L10n.current.displayPeanutButter,
    "Kakaobutter" => L10n.current.displayCocoaButter,
    "Muskatnuss" => L10n.current.displayNutmeg,
    "Kokosnuss" => L10n.current.displayCoconut,
    "Frischkäse" => L10n.current.displayCreamCheese,
    "Hüttenkäse" => L10n.current.displayCottageCheese,
    "Sojasahne" => L10n.current.displaySoyaCream,
    "Hafersahne" => L10n.current.displayOatCream,
    "Kokossahne" => L10n.current.displayCoconutCream,
    "Sojajoghurt" => L10n.current.displaySoyaYoghurt,
    "Kokosjoghurt" => L10n.current.displayCoconutYoghurt,
    "Kokoswasser" => L10n.current.displayCoconutWater,
    "Rosenwasser" => L10n.current.displayRoseWater,
    "Seelachs" => L10n.current.displayPollock,
    "Paniermehl" => L10n.current.displayBreadcrumbs,
    "Mandelmehl" => L10n.current.displayAlmondFlour,
    "Kokosmehl" => L10n.current.displayCoconutFlour,
    "Reismehl" => L10n.current.displayRiceFlour,
    "Kichererbsenmehl" => L10n.current.displayChickpeaFlour,
    "Rosenkohl" => L10n.current.displayBrusselsSprouts,
    "Grünkohl" => L10n.current.displayKale,
    "Zitronengras" => L10n.current.displayLemongrass,
    "Öl" => L10n.current.displayOil,
    "Gewürze" => L10n.current.displaySpices,
    "Gewürzmischung" => L10n.current.displaySpiceMix,
    "Paprikapulver" => L10n.current.displayPaprika,
    "Currypulver" => L10n.current.displayCurryPowder,
    "Chilipulver" => L10n.current.displayChilliPowder,
    "Chiliflocken" => L10n.current.displayChilliFlakes,
    "Knoblauchpulver" => L10n.current.displayGarlicPowder,
    "Zwiebelpulver" => L10n.current.displayOnionPowder,
    "Ingwerpulver" => L10n.current.displayGingerPowder,
    "Kreuzkümmel" => L10n.current.displayCumin,
    "Kümmel" => L10n.current.displayCaraway,
    "Majoran" => L10n.current.displayMarjoram,
    "Muskat" => L10n.current.displayNutmeg2,
    "Kurkuma" => L10n.current.displayTurmeric,
    "Piment" => L10n.current.displayAllspice,
    "Nelke" => L10n.current.displayClove,
    "Kräuter der Provence" => L10n.current.displayHerbesDeProvence,
    "Italienische Kräuter" => L10n.current.displayItalianHerbs,
    "Anspruchsvoll" => L10n.current.displayChallenging,
    "Wenig Zeit" => L10n.current.displayShortOnTime,
    "Meiste Protein" => L10n.current.displayMostProtein,
    "Wenigste kcal" => L10n.current.displayFewestCalories,
    "Prise" => L10n.current.displayPinch,
    "Zehe" => L10n.current.displayClove2,
    "Filet" => L10n.current.displayFillet,
    "Dose" => L10n.current.displayTin,
    "Scheibe" => L10n.current.displaySlice,
    "Tasse" => L10n.current.displayCup,
    "Packung" => L10n.current.displayPack,
    "Knolle" => L10n.current.displayBulb,
    "Stange" => L10n.current.displayStick,
    "Zweig" => L10n.current.displaySprig,
    "Blatt" => L10n.current.displayLeaf,
    "Kugel" => L10n.current.displayBall,
    "Schote" => L10n.current.displayPod,
    "Messerspitze" => L10n.current.displayPinch2,
    "Glas" => L10n.current.displayGlass,
    "Banane" => L10n.current.displayBanana,
    "Gurke" => L10n.current.displayCucumber,
    "Apfel" => L10n.current.displayApple,
    "Fladenbrot" => L10n.current.displayFlatbread,
    "Gesünder essen" => L10n.current.displayEatHealthier2,
    "Meist sitzend" => L10n.current.displayMostlySeated,
    "Mal so, mal so" => L10n.current.displayItVaries,
    "Viel in Bewegung" => L10n.current.displayOftenOnTheMove,
    "Gemischt" => L10n.current.displayMixed,
    "Mit Fisch, ohne Fleisch" => L10n.current.displayFishNoMeat,
    "Neue Essensideen" => L10n.current.displayNewMealIdeas,
    "Mehr Regelmäßigkeit" => L10n.current.displayMoreConsistency,
    "Aufs Budget achten" => L10n.current.displayWatchMyBudget,
    "Weiblich" => L10n.current.displayFemale,
    "Männlich" => L10n.current.displayMale,
    "Möchte ich nicht angeben" => L10n.current.displayPreferNotToSay,
    "Sanft" => L10n.current.displayGentle,
    "Gesünder leben" => L10n.current.displayLiveHealthier,
    "Mehr Energie im Alltag" => L10n.current.displayMoreEnergyDayToDay,
    "Wohler im eigenen Körper" => L10n.current.displayFeelBetterInMyBody,
    "Sportlich stärker werden" => L10n.current.displayImproveMyFitness,
    "Bessere Gewohnheiten" => L10n.current.displayBetterHabits,
    "Vorbild für Familie & Kinder" =>
      L10n.current.displayBeARoleModelForFamilyChildren,
    "Heißhunger & Naschen" => L10n.current.displayCravingsSnacking,
    "Wenig Zeit zum Kochen" => L10n.current.displayLittleTimeToCook,
    "Unregelmäßige Mahlzeiten" => L10n.current.displayIrregularMeals,
    "Viel unterwegs essen" => L10n.current.displayOftenEatOnTheGo,
    "Motivation hält nicht lange" => L10n.current.displayMotivationDoesNotLast,
    "Unsicher, was gut für mich ist" =>
      L10n.current.displayUnsureWhatIsGoodForMe,
    "Essen bei Stress" => L10n.current.displayEatingWhenStressed,
    "Noch nie" => L10n.current.displayNever,
    "Schon mal ausprobiert" => L10n.current.displayTriedItBefore,
    "Ja, regelmäßig" => L10n.current.displayYesRegularly,
    "Schwanger oder stillend" => L10n.current.displayPregnantOrBreastfeeding,
    "Essstörung – aktuell oder früher" =>
      L10n.current.displayEatingDisorderCurrentOrPast,
    "Erkrankung, bei der die Ernährung ärztlich begleitet wird" =>
      L10n.current.displayAConditionRequiringMedicalGuidanceOnNutrition,
    "LOOKIN COACH · PREMIUM" => L10n.current.displayLookinCoachPremium,
    "Bis 15 Minuten" => L10n.current.displayUpTo15Minutes,
    "Etwa 30 Minuten" => L10n.current.displayAbout30Minutes,
    "45 Minuten und mehr" => L10n.current.display45MinutesOrMore,
    "April" => L10n.current.displayApril,
    "August" => L10n.current.displayAugust,
    "September" => L10n.current.displaySeptember,
    "November" => L10n.current.displayNovember,
    "VORSCHAU" => L10n.current.displayPreview,
    "Profil öffnen" => L10n.current.displayOpenProfile,
    _ => source,
  };
}
