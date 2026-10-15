# Google Play: Store-Eintrag (Entwurf)

Stand: 15. Oktober 2026. Entwurf zum Einfügen in die Play Console. Prüfe jede
Aussage vor dem Absenden gegen die App und gegen `docs/FEATURE_STATUS.md`.
Datenschutz- und Rechtsangaben sind **keine Rechtsberatung** und brauchen eine
Prüfung vor der Veröffentlichung.

## Grunddaten

| Feld | Wert |
| --- | --- |
| App-Name (max. 30 Zeichen) | `Lookin – AI Food Tracker` (24 Zeichen) |
| Standardsprache | Deutsch (Deutschland); zusätzlich Englisch (siehe unten) |
| Art | App (kein Spiel) |
| Preis | Kostenlos, mit In-App-Käufen (Abos) |
| Kategorie | Gesundheit & Fitness |
| Paketkennung | `com.lookin.foodtracker` (nach dem ersten Upload nicht mehr änderbar) |
| Kontakt-E-Mail | `lookinsupport@gmail.com` |
| Datenschutzerklärung (URL) | `https://app.lookin-foodtracker.de/legal/datenschutz.html` (erst eintragen, wenn die Platzhalter ausgefüllt sind; Prüfung: `dart run tool/check_legal_pages.dart`) |
| Kontolöschung (URL, Pflicht im Datensicherheits-Formular) | `https://app.lookin-foodtracker.de/legal/konto-loeschen.html` |
| Website | optional |

Der Name darf keine irreführenden Zusätze enthalten. „AI“ ist erlaubt, weil die
App KI-Funktionen hat (Premium).

## Kurzbeschreibung (max. 80 Zeichen)

```
Mahlzeiten tracken, Halal-Rezepte kochen und Fortschritt sehen – mit KI-Hilfe.
```

## Ausführliche Beschreibung (max. 4000 Zeichen)

```
Lookin ist dein Ernährungstagebuch mit KI-Unterstützung: übersichtlich, dunkel und ohne Druck.

DAS KANNST DU MIT LOOKIN
• Mahlzeiten eintragen: Suche im Lebensmittelkatalog, eigene Lebensmittel mit allen Nährwerten oder Barcode scannen (Produktdaten von Open Food Facts).
• Kalorien und Makros im Blick: Tagesübersicht mit Kalorien, Protein, Kohlenhydraten und Fett, dazu Wasser und deine Serie für regelmäßiges Eintragen.
• Rezepte entdecken: Filter, Favoriten, Zutaten und Zubereitung Schritt für Schritt.
• „Was kann ich kochen?“: Wähle, was du zu Hause hast, und sieh passende Rezepte.
• Fortschritt verfolgen: Gewicht und Wochenverläufe.
• Persönlich angepasst: Ein paar kurze, freiwillige Fragen zu Ziel und Alltag. Daraus berechnet Lookin Richtwerte. Du kannst Lookin auch ganz ohne Angaben nutzen.

HALAL-INHALTE
Im Lebensmittelkatalog und in den Rezepten gibt es kein Schweinefleisch, keinen Alkohol und keine Gelatine. Fleisch von Landtieren erscheint nur mit eindeutiger Halal-Kennzeichnung. Bei Fertigprodukten und Barcode-Treffern prüfe bitte immer die Verpackung. Bei unklaren Zutaten rät Lookin nicht, sondern weist darauf hin.

LOOKIN PREMIUM (OPTIONAL)
• KI-Foto-Erkennung: Foto machen, Lookin schätzt Lebensmittel und Mengen. Du prüfst und korrigierst alles, bevor es gespeichert wird.
• Lookin Coach: KI-Chat für Fragen rund um deine Ernährung. Jede Antwort kannst du direkt im Chat melden.
• Alle Rezepte.
Premium testest du 7 Tage kostenlos, ohne Zahlungsdaten. Danach 6,99 € pro Monat oder 49,99 € pro Jahr. Du kannst jederzeit in den Abo-Einstellungen von Google Play kündigen.

WICHTIG ZU WISSEN
• Werte aus KI und Fotos sind Schätzungen.
• Lookin stellt keine Diagnose und ersetzt keine ärztliche oder ernährungsmedizinische Beratung.
• Für Personen unter 18 Jahren und bei bestimmten Gesundheitshinweisen berechnet Lookin keine Kalorienziele. Bei Essstörungen, Schwangerschaft oder Erkrankungen wende dich bitte an qualifizierte Fachleute.
• Dein Konto und deine Daten kannst du in der App exportieren und löschen.
```

Vor dem Einfügen prüfen: Zeichenzahl (Limit 4000) und dass jede Funktion in der
ausgelieferten Version vorhanden ist.

## Englischer Store-Eintrag (zusätzliche Sprache)

Die App ist komplett auf Englisch nutzbar. Lege in der Play Console unter
„Store-Präsenz > Haupt-Store-Eintrag > Übersetzungen verwalten“ **Englisch
(Vereinigte Staaten)** an (Englisch UK nur, falls gewünscht, derselbe Text).
App-Name bleibt `Lookin – AI Food Tracker`. Screenshots getrennt in der
englischen Sprache hochladen (App auf Englisch stellen).

Kurzbeschreibung (74 Zeichen, Limit 80):

```
Track meals, cook halal recipes and follow your progress – with AI help.
```

Ausführliche Beschreibung (unter 4000 Zeichen):

```
Lookin is your food diary with AI support: clear, dark and free of pressure.

WHAT YOU CAN DO WITH LOOKIN
• Log meals: search the food catalogue, add your own foods with all nutrition values, or scan a barcode (product data from Open Food Facts).
• Keep calories and macros in view: a daily overview with calories, protein, carbohydrates and fat, plus water and your streak for logging regularly.
• Discover recipes: filters, favourites, ingredients and step-by-step instructions.
• "What can I cook?": pick what you have at home and see matching recipes.
• Follow your progress: weight and weekly trends.
• Personal: a few short, optional questions about your goal and daily life. Lookin uses them to calculate guide values. You can also use Lookin without giving any details.

HALAL CONTENT
The food catalogue and the recipes contain no pork, no alcohol and no gelatine. Meat from land animals only appears with a clear halal label. For packaged products and barcode results, please always check the packaging. If an ingredient is unclear, Lookin does not guess but points it out.

LOOKIN PREMIUM (OPTIONAL)
• AI photo recognition: take a photo and Lookin estimates foods and amounts. You check and correct everything before it is saved.
• Lookin Coach: an AI chat for questions about your nutrition. You can report any answer from inside the chat.
• All recipes.
Try Premium free for 7 days, no payment details needed. After that it costs €6.99 per month or €49.99 per year. You can cancel at any time in your Google Play subscription settings.

GOOD TO KNOW
• Values from AI and photos are estimates.
• Lookin does not diagnose and does not replace medical or dietetic advice.
• For people under 18 and for certain health notes, Lookin does not calculate calorie targets. If you have an eating disorder, are pregnant or have a medical condition, please talk to qualified professionals.
• You can export and delete your account and your data in the app.
```

## App-Zugriff für Prüfer (Pflichtfeld)

Die App verlangt ein Konto. Lege in Supabase ein **Testkonto** an (E-Mail und
Passwort) und trage die Zugangsdaten in der Play Console unter „App-Inhalte >
App-Zugriff“ ein. Die Zugangsdaten gehören **nicht** in Git oder in diese Datei.
Aktiviere für das Testkonto Premium zum Prüfen der KI-Funktionen (Eintrag in
`entitlements` mit Ablaufdatum). Das Testkonto muss eine **bestätigte**
E-Mail-Adresse haben (sonst startet der Test nicht), und die beiden
Einwilligungen sollten schon beantwortet sein, damit die Prüfer direkt in der
App landen. Prüfer sollen auch die englische Oberfläche sehen können (Profil >
Sprache oder Schalter „DE | EN“ vor der Anmeldung).

## Zielgruppe und Inhalte

- **Zielgruppe:** 18 Jahre und älter (die App berechnet für Minderjährige keine
  Ziele; so gibt es keinen Konflikt mit den Familienrichtlinien).
- **Werbung:** keine Werbung. **Werbe-ID:** wird nicht verwendet (die App
  fordert die Berechtigung `AD_ID` nicht an; im Formular „Werbe-ID“ mit Nein
  beantworten).
- **KI-generierte Inhalte:** Der Lookin Coach erzeugt Antworten mit KI. Googles
  Richtlinie verlangt, dass Nutzer anstößige KI-Inhalte in der App melden
  können: Unter jeder Coach-Antwort steht „Antwort melden“ (Grund wählen, die
  Mail-App öffnet sich mit der Antwort an `lookinsupport@gmail.com`). Im
  Formular „KI-generierte Inhalte“ dies angeben.
- **Länder und Preise:** Preise sind in Euro festgelegt (6,99 € und 49,99 €).
  Verfügbar machen für Deutschland, Österreich und die übrigen EU-Länder; keine
  Länder außerhalb der EU, solange die Rechtstexte (Widerruf, Datenschutz)
  dafür nicht geprüft sind. Die Preise für andere Währungen rechnet Google Play
  selbst um; danach in der Play Console kontrollieren.
- **Altersfreigabe (IARC):** Fragebogen ehrlich ausfüllen. Gewalt, Sex, Glücksspiel,
  Drogen: nein. Nutzergenerierte Inhalte: nein (der Coach-Chat ist privat, nicht
  öffentlich). Standort teilen: nein.
- **Gesundheits-App-Erklärung:** Die Console fragt nach Gesundheitsfunktionen.
  Wähle Ernährung und Gewichtsmanagement, und gib an, dass die App keine
  medizinischen Geräte oder Diagnosen anbietet.
- **Finanzfunktionen:** keine (nur Abos über Google Play).

## Datensicherheit (Entwurf für das Formular)

Sicherheitspraktiken:

- Daten werden bei der Übertragung verschlüsselt: **Ja** (HTTPS).
- Nutzer können die Löschung ihrer Daten beantragen: **Ja**, in der App
  (Konto löschen) mit Export vorher.

Gesammelte Daten (jeweils für Kernfunktionen, nicht für Werbung). Seit Oktober 2026 wird mit der **ausdrücklichen Einwilligung in Gesundheitsangaben** eine Kopie der Antworten aus der Einrichtung im Konto gespeichert (`personalization_answers`), damit man auf einem neuen Gerät nicht alles noch einmal beantworten muss. Ohne Einwilligung bleiben diese Angaben auf dem Gerät und gelten nicht als „erhoben“. Das Profilbild bleibt immer auf dem Gerät.

| Kategorie | Daten | Zweck |
| --- | --- | --- |
| Persönliche Daten | E-Mail-Adresse, Name (Anzeigename), Nutzer-ID | Konto, App-Funktionen, Kontoverwaltung |
| Gesundheit und Fitness | Gewichtseinträge, Mahlzeiten und Nährwerte, Allergien/Unverträglichkeiten; mit Einwilligung zusätzlich Antworten der Einrichtung: Größe, Gewicht, Zielgewicht, Geburtsdatum, Geschlecht, Ziel, Aktivität, Ernährungsstil, Gesundheitshinweis | App-Funktionen, Personalisierung |
| Fotos und Videos | Mahlzeitenfotos (nur bei KI-Foto-Erkennung, Premium) | App-Funktionen |
| Nachrichten | Fragen und Antworten im Coach (Premium) | App-Funktionen |
| Finanzinfos | Kaufverlauf (Abo-Status; Zahlungsdaten verarbeitet nur Google Play) | Abwicklung des Abos |
| App-Aktivität / Geräte-IDs | Einwilligungsnachweise (Zeitpunkt, Textversion, Sprache), Hash der E-Mail für den einmaligen Test, technische Server-Protokolle | Nachweis, Missbrauchsschutz |

Das Gesundheits-Feld im Formular mit „Ja, erhoben“ beantworten (Gewicht, Mahlzeiten, Antworten mit Einwilligung), „optional: ja“ für die Antworten der Einrichtung und „nicht übertragen“ nur, wo es wirklich zutrifft. Wenn Nutzer die Einwilligung verweigern können, ist die Angabe optional.

Weitergabe an Dritte (Dienstleister, die in unserem Auftrag verarbeiten):

- Supabase (Hosting, Datenbank, Anmeldung).
- OpenAI (nur Coach-Fragen und Mahlzeitenfotos, nur mit Einwilligung in die KI-Verarbeitung, ohne Name und E-Mail).
- RevenueCat (Konto-ID und Kaufdaten).
- Resend (nur Versand von Konto-E-Mails: E-Mail-Adresse und Sprache).
- Open Food Facts (nur Barcode-Nummern; kein Nutzerbezug).

Prüfe vor dem Absenden mit der Datenschutzerklärung, welche dieser Weitergaben
nach Googles Definition als „Weitergabe“ gelten und welche als Verarbeitung im
Auftrag. Bei Zweifeln lieber offenlegen.

## Grafiken

Fertig in `assets/branding/`:

- `play_store_icon_512.png`: App-Symbol, 512 × 512 px.
- `feature_graphic_1024x500.png`: Titelbild, 1024 × 500 px.

Noch zu erstellen: **Screenshots** (mindestens 2, besser 6, Hochformat). Mache sie
auf einem Android-Handy aus dem internen Test. Empfohlene Motive, in dieser
Reihenfolge:

1. Heute-Übersicht mit Kalorien und Makros.
2. Mahlzeit hinzufügen (Suche oder Barcode).
3. Rezepte mit Filtern.
4. Rezeptdetail mit Zutaten.
5. Fortschritt mit Gewichtsverlauf.
6. Lookin Coach (Premium) oder die Paywall.

Verwende **Demo-Daten** und keine echten persönlichen Angaben.

## Checkliste vor dem Einreichen

- [ ] Support-E-Mail vorhanden
- [ ] Datenschutzerklärung online, Adresse eingetragen
- [ ] Testkonto für Prüfer angelegt und eingetragen
- [ ] Datensicherheit-Formular ausgefüllt
- [ ] Altersfreigabe-Fragebogen ausgefüllt
- [ ] Zielgruppe, Werbung, Gesundheits-App-Erklärung ausgefüllt
- [ ] Screenshots hochgeladen
- [ ] Händlerprofil und Abos (erst mit Gewerbe)
- [ ] Abos in der Play Console mit den Produkt-IDs `lookin_premium_monthly` und `lookin_premium_yearly` angelegt und in RevenueCat verknüpft (siehe `docs/BILLING_SETUP.md`)
- [ ] Länder auf EU eingeschränkt, Preise kontrolliert
- [ ] Englischer Store-Eintrag und englische Screenshots
- [ ] Formular „KI-generierte Inhalte“ und „Werbe-ID: Nein“
- [ ] Testkonto mit bestätigter E-Mail und Premium
- [ ] Name des Entwicklers in Play (Mohammad shikho) und im Impressum (Mhd Khair Shikho) angleichen oder bewusst so lassen
- [ ] Mindestens 12 Tester über 14 Tage im geschlossenen Test (private Konten;
      aktuelle Regel in der Console prüfen)
