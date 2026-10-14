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

  /// No description provided for @appOpeningSemantics.
  ///
  /// In de, this message translates to:
  /// **'Lookin wird geöffnet'**
  String get appOpeningSemantics;

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

  /// Button on the first-start language page, names the selected language.
  ///
  /// In de, this message translates to:
  /// **'Weiter auf Deutsch'**
  String get languageContinue;

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
