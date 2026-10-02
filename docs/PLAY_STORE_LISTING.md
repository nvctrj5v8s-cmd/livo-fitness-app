# Google Play: Store-Eintrag (Entwurf)

Stand: 2. Oktober 2026. Entwurf zum Einfügen in die Play Console. Prüfe jede
Aussage vor dem Absenden gegen die App und gegen `docs/FEATURE_STATUS.md`.
Datenschutz- und Rechtsangaben sind **keine Rechtsberatung** und brauchen eine
Prüfung vor der Veröffentlichung.

## Grunddaten

| Feld | Wert |
| --- | --- |
| App-Name (max. 30 Zeichen) | `Lookin – AI Food Tracker` (24 Zeichen) |
| Standardsprache | Deutsch (Deutschland) |
| Art | App (kein Spiel) |
| Preis | Kostenlos, mit In-App-Käufen (Abos) |
| Kategorie | Gesundheit & Fitness |
| Paketkennung | `com.lookin.foodtracker` (nach dem ersten Upload nicht mehr änderbar) |
| Kontakt-E-Mail | **noch offen**: eigene Support-Adresse anlegen |
| Datenschutzerklärung (URL) | **noch offen**: Pflicht, öffentlich erreichbar |
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
• Lookin Coach: KI-Chat für Fragen rund um deine Ernährung.
• Alle Rezepte.
Premium testest du 7 Tage kostenlos, ohne Zahlungsdaten. Danach 6,99 € pro Monat oder 59,99 € pro Jahr. Du kannst jederzeit in den Abo-Einstellungen von Google Play kündigen.

WICHTIG ZU WISSEN
• Werte aus KI und Fotos sind Schätzungen.
• Lookin stellt keine Diagnose und ersetzt keine ärztliche oder ernährungsmedizinische Beratung.
• Für Personen unter 18 Jahren und bei bestimmten Gesundheitshinweisen berechnet Lookin keine Kalorienziele. Bei Essstörungen, Schwangerschaft oder Erkrankungen wende dich bitte an qualifizierte Fachleute.
• Dein Konto und deine Daten kannst du in der App exportieren und löschen.
```

Vor dem Einfügen prüfen: Zeichenzahl (Limit 4000) und dass jede Funktion in der
ausgelieferten Version vorhanden ist.

## App-Zugriff für Prüfer (Pflichtfeld)

Die App verlangt ein Konto. Lege in Supabase ein **Testkonto** an (E-Mail und
Passwort) und trage die Zugangsdaten in der Play Console unter „App-Inhalte >
App-Zugriff“ ein. Die Zugangsdaten gehören **nicht** in Git oder in diese Datei.
Aktiviere für das Testkonto Premium zum Prüfen der KI-Funktionen (Eintrag in
`entitlements` mit Ablaufdatum).

## Zielgruppe und Inhalte

- **Zielgruppe:** 18 Jahre und älter (die App berechnet für Minderjährige keine
  Ziele; so gibt es keinen Konflikt mit den Familienrichtlinien).
- **Werbung:** keine Werbung.
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

Gesammelte Daten (jeweils erforderlich für Kernfunktionen, nicht für Werbung):

| Kategorie | Daten | Zweck |
| --- | --- | --- |
| Persönliche Daten | E-Mail-Adresse, Name (Anzeigename), Nutzer-ID | Konto, App-Funktionen |
| Gesundheit und Fitness | Gewicht, Größe, Geburtstag, Ziel, Allergien, Mahlzeiten und Nährwerte, Wasser | App-Funktionen, Personalisierung |
| Fotos und Videos | Mahlzeitenfotos (nur bei KI-Foto-Erkennung, Premium) | App-Funktionen |
| Nachrichten | Fragen und Antworten im Coach (Premium) | App-Funktionen |
| Finanzinfos | Kaufverlauf (Abo-Status) | Abwicklung des Abos |

Weitergabe an Dritte (Dienstleister, die in unserem Auftrag verarbeiten):

- Supabase (Hosting, Datenbank, Anmeldung).
- OpenAI (nur Coach-Fragen und Mahlzeitenfotos, ohne Name und E-Mail).
- RevenueCat (Konto-ID und Kaufdaten).
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
- [ ] Mindestens 12 Tester über 14 Tage im geschlossenen Test (private Konten;
      aktuelle Regel in der Console prüfen)
