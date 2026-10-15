# Lookin auf Deutsch und Englisch: Regeln für die Übersetzung

Stand: 15. Oktober 2026. Gilt für jede Änderung an sichtbaren Texten.

## So funktioniert es

- **Sprache wählen:** Beim ersten Start gilt die Gerätesprache (`de` → Deutsch,
  sonst Englisch). Profil › Sprache bietet Automatik und eine manuelle Wahl.
  Gespeichert wird `system`, `de` oder `en` auf dem Gerät (`lookin.locale.v1`,
  `LocaleController`); die aufgelöste Sprache wird im Konto für E-Mails hinterlegt
  (`user_metadata.locale`). `LanguagePage` bleibt als optionale Ansicht verfügbar.
- **Texte:** Flutter-`gen-l10n` mit ARB. Quelle sind die Teil-Dateien
  `lib/l10n/parts/<bereich>_de.json` (Vorlage, optional mit `@key`-Metadaten)
  und `<bereich>_en.json` (nur Werte). `dart run tool/l10n_merge.dart` prüft
  sie, baut `lib/l10n/app_de.arb`/`app_en.arb` und erzeugt
  `lib/l10n/app_localizations*.dart`. **Nie** die `app_*.arb` oder die
  erzeugten Dart-Dateien von Hand bearbeiten.
- **Im Widget:** `import '…/l10n/l10n.dart';` und `context.l10n.schluessel`.
- **Ohne BuildContext** (Controller, Services, Formatierung): `L10n.current`.
  Funktionen, die nur in `build` aufgerufen werden, bekommen besser ein
  `AppLocalizations l10n` als Parameter.
- **Zahlen, Geld, Datum:** `AppFormat` (`lib/l10n/app_format.dart`):
  `AppFormat.integer(1240)` → `1.240`/`1,240`, `AppFormat.euro(699)`,
  `AppFormat.kcal(…)`, `AppFormat.grams(…)`, `AppFormat.date(…)`,
  `AppFormat.longDate(…)`, `AppFormat.time(…)`, `AppFormat.weekdayShort(…)`.
  Englisch nutzt britische, in Europa eindeutige Formate (`14 Oct 2026`,
  `14:30`).
- **Gespeicherte Werte** (Rezept-Tags, Schwierigkeit, Profil-Ziel,
  Ernährungsstil, Aktivität, „Keine angegeben“): Der Wert bleibt deutsch, die
  Anzeige läuft über `ValueLabels` und `DisplayText`. Mahlzeiten:
  `slot.labelOf(context.l10n)`.

## Katalog, KI, E-Mails und Rechtsseiten

- `CatalogText.load()` lädt vor dem ersten App-Bildschirm die lokalen Dateien
  unter `assets/l10n/`. `catalog_en.json` enthält die Übersetzungen aller Texte
  der 40 Rezepte und des kuratierten Katalogs. `usda_names_en.json` enthält die
  ursprünglichen englischen USDA-Bezeichnungen, nach denselben Inhaltsregeln
  gefiltert. Herkunft siehe `supabase/imports/i18n/` und `docs/CATALOG_DATA_SOURCES.md`.
- Widgets zeigen die `display…`-Getter der Modelle. Rohfelder bleiben für
  Speicherung, Berechnungen und Inhaltsprüfung unverändert. Neue Katalogtexte
  brauchen eine englische Zuordnung und einen Abdeckungstest. Eigene Einträge
  und bestehende Chatnachrichten bleiben in ihrer Originalsprache.
- Jede KI-Anfrage enthält einen begrenzten Sprachcode `de`/`en`. Die Edge
  Function wählt die Ausgabeanweisung und feste Antworten passend dazu;
  JSON-Schlüssel und Sicherheitsregeln bleiben gleich. Die Serveränderung
  muss zusammen mit der App veröffentlicht werden.
- Englische Rechtsseiten liegen unter `web/legal/en/`. Die Mailvorlagen
  wählen mit `{{ if eq .Data.locale "en" }}` die englische Fassung; sonst Deutsch.
  Vorlagen im Auth-Dashboard und die Edge Functions für Transaktionsmails
  benötigen eine eigene Veröffentlichung. Dokumentation der Vorlagenvariablen:
  https://supabase.com/docs/guides/auth/auth-email-templates
- Einwilligungen speichern die angezeigte Sprache als Suffix der Textversion.
  Sprachwahl ergänzt keine Berechtigung und keine externe Übersetzungsanfrage.

## Schlüssel

- Jeder Bereich hat ein eigenes Teil-Paar; jeder Schlüssel beginnt mit dem
  Bereichsnamen: `auth…`, `onboarding…`, `diary…`, `recipe…`, `discover…`,
  `profile…`, `coach…`, `subscription…`, `core…`, `common…`, `values…`.
- lowerCamelCase, sprechend: `authSignInButton`, `diaryAddMealTitle`.
- `common…` (Speichern, Abbrechen, Weiter …) und `values…` gehören dem
  Fundament; neue gemeinsame Texte nicht dort, sondern im eigenen Bereich.
- Platzhalter: `"diaryCaloriesLeft": "Noch {kcal} kcal"` mit Metadaten
  `"@diaryCaloriesLeft": {"placeholders": {"kcal": {"type": "String"}}}`.
  Zahlen vorher mit `AppFormat` formatieren und als String übergeben.
- Mehrzahl mit ICU: `"{count, plural, =1{1 Mahlzeit} other{{count} Mahlzeiten}}"`
  (Typ `int`). Nie Sätze aus Bruchstücken zusammensetzen.

## Inhalt

- Der **deutsche Text bleibt wortgleich** wie bisher (Tests und Rechtstexte
  hängen daran). Nur Tippfehler dürfen korrigiert werden.
- Das **Englische** ist natürlich, freundlich, kurz, in der Du-Form („you“),
  ohne Übersetzungsdeutsch. Satzzeichen wie im Deutschen („…“ → "…", „“ → "").
- Rechtliche Aussagen (Einwilligungen, Widerruf, Preise, Abo-Bedingungen)
  inhaltlich exakt gleich übersetzen, nichts weglassen oder abschwächen.
- KI- und Fotowerte bleiben als **Schätzung** gekennzeichnet („estimate“).
- Halal-Regel gilt auch im Englischen: keine Schweinefleisch-, Alkohol- oder
  Gelatine-Beispiele in Texten.

## Wörterbuch (Deutsch → Englisch)

| Deutsch | Englisch |
| --- | --- |
| Tagebuch | Diary |
| Mahlzeit / Mahlzeiten | meal / meals |
| Frühstück, Mittagessen, Abendessen, Snack | Breakfast, Lunch, Dinner, Snack |
| eintragen / Eintrag | log / entry |
| Hinzufügen | Add |
| Lebensmittel | food / foods |
| Kalorien, kcal | calories, kcal |
| Eiweiß / Protein | protein |
| Kohlenhydrate | carbs |
| Fett | fat |
| Ballaststoffe | fibre |
| Zucker, Salz | sugar, salt |
| Makros | macros |
| Tagesziel(e), Richtwerte | daily target(s), guideline values |
| Portion | serving |
| Rezept / Rezepte | recipe / recipes |
| Zutaten, Schritte, Kochmodus | ingredients, steps, cook mode |
| Vorrat | pantry |
| Fortschritt, Gewicht, Taillenumfang | Progress, weight, waist |
| Profil, Einstellungen | Profile, Settings |
| Einführung, Fragen | introduction, questions |
| Lookin Coach / KI-Coach | Lookin Coach / AI Coach |
| KI-Foto, KI-Schätzung | AI photo, AI estimate |
| Barcode scannen | Scan barcode |
| Premium, Abo, Testphase | Premium, subscription, free trial |
| kündigen, Kündigung | cancel, cancellation |
| Widerruf, widerrufen | withdrawal, withdraw |
| Einwilligung | consent |
| Gesundheitsangaben | health details |
| Datenschutz, AGB, Impressum | Privacy, Terms, Imprint |
| Konto, anmelden, abmelden, registrieren | account, sign in, sign out, sign up |
| Passwort vergessen? | Forgot password? |
| Serie (Streak) | streak |
| Allergien und Unverträglichkeiten | allergies and intolerances |

## Prüfen

- `dart run tool/l10n_merge.dart` ohne Fehler.
- `flutter analyze` ohne Befund.
- Pro Bereich ein Test `test/l10n_scan_<bereich>_test.dart`:
  `expectNoHardcodedGerman(['lib/features/<bereich>'])` aus
  `test/support/l10n_scan.dart`. Zeilen mit Daten statt UI-Text bekommen
  `// l10n-ignore`, reine Datendateien `// l10n-ignore-file`.
- Wichtige Bildschirme einmal auf Englisch bei 320 px Breite pumpen
  (`MaterialApp(locale: L10n.english, localizationsDelegates:
  AppLocalizations.localizationsDelegates, supportedLocales: L10n.supported)`),
  damit nichts überläuft. Tests, die `L10n.use(L10n.english)` setzen, setzen es
  mit `addTearDown(() => L10n.use(L10n.german))` zurück.
