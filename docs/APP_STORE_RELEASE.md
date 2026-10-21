# iPhone-App: Schritt für Schritt in den App Store

Stand: 21. Oktober 2026. Im Code ist alles für iOS vorbereitet (Kauf, Testphase,
Wiederherstellen, Rückzahlung über Apple, Rechtstexte). Die folgenden Schritte
macht der Inhaber in den Konten bei Apple, RevenueCat und Codemagic. Die
Reihenfolge ist wichtig.

Feste Werte:

| Was | Wert |
| --- | --- |
| Bundle-ID | `com.lookin.foodtracker` |
| Abo-Produkt monatlich | `lookin_premium_monthly` (1 Monat, 6,99 €) |
| Abo-Produkt jährlich | `lookin_premium_yearly` (1 Jahr, 49,99 €) |
| Testphase | Einführungsangebot „Kostenlos“, 1 Woche, an beiden Abos |
| RevenueCat-Berechtigung | `premium` |
| RevenueCat-Angebot | `default` mit den Paketen „Monthly“ und „Annual“ |
| Geräte | nur iPhone (iPad nutzt die iPhone-Ansicht; keine iPad-Screenshots nötig) |

## 1. Apple-Entwicklerprogramm

Das Programm muss **aktiv** sein (Mail von Apple, kann bis zu 48 Stunden
dauern). Danach unter developer.apple.com › Account einmal anmelden und die
Bedingungen akzeptieren.

## 2. Verträge, Steuern, Bank (ohne das laden keine Abos)

App Store Connect › **Business** (früher „Verträge, Steuern und Bankdaten“):
den Vertrag **„Kostenpflichtige Apps“** akzeptieren, Bankkonto und
Steuerformulare ausfüllen. Solange der Vertrag nicht „Aktiv“ ist, zeigt die App
keine Abos an.

## 3. Bundle-ID anlegen

developer.apple.com › Certificates, Identifiers & Profiles › **Identifiers** ›
„+“ › App IDs › App:

- Description: `Lookin`
- Bundle ID: **Explicit**, `com.lookin.foodtracker`
- Capabilities: nichts zusätzlich ankreuzen (In-App-Käufe sind automatisch an).

## 4. App in App Store Connect anlegen

App Store Connect › Apps › „+“ › Neue App:

- Plattform: iOS
- Name: `Lookin – AI Food Tracker` (falls vergeben: `Lookin: AI Food Tracker`)
- Primäre Sprache: Deutsch
- Bundle-ID: `com.lookin.foodtracker`
- SKU: `lookin-foodtracker`
- Benutzerzugriff: Vollzugriff

Danach die **Apple-ID der App** (eine Zahl, steht unter App-Informationen)
notieren.

## 5. Abos anlegen

App › Monetarisierung › **Abonnements** › Abonnementgruppe erstellen:
`Lookin Premium`. In dieser Gruppe zwei Abos:

| Referenzname | Produkt-ID | Dauer | Preis |
| --- | --- | --- | --- |
| Lookin Premium monatlich | `lookin_premium_monthly` | 1 Monat | 6,99 € (Deutschland, andere Länder automatisch) |
| Lookin Premium jährlich | `lookin_premium_yearly` | 1 Jahr | 49,99 € |

Für jedes Abo:

- **Lokalisierung** Deutsch: Anzeigename „Lookin Premium monatlich“ bzw.
  „Lookin Premium jährlich“, Beschreibung „KI-Foto, Lookin Coach und alle
  Rezepte“. Englisch: „Lookin Premium monthly/yearly“, „AI photo, Lookin Coach
  and all recipes“.
- **Einführungsangebot** › „+“ › alle Länder › Start sofort, kein Ende ›
  Typ **Kostenlos** › Dauer **1 Woche**.
- **Informationen zur Überprüfung**: ein Screenshot der Premium-Seite der App
  (iPhone-Screenshot reicht) und als Notiz: „Lookin Premium schaltet KI-Foto,
  Lookin Coach und alle Rezepte frei.“
- Ab Version 1 werden die Abos **zusammen mit der App** zur Prüfung eingereicht
  (beim Einreichen der App die beiden Abos auswählen).

**Spätere Preiserhöhungen:** In App Store Connect bei bestehenden Abonnenten
**„Preise beibehalten“** wählen oder die Zustimmung einholen lassen. Die AGB
(Ziffer 12) versprechen, dass eine Erhöhung nur mit Zustimmung gilt.

## 6. Schlüssel bei Apple erzeugen

App Store Connect › Benutzer und Zugriff › **Integrationen**:

1. **App Store Connect API** › Team-Schlüssel › „+“: Name `Codemagic`, Zugriff
   **App Manager**. Die `.p8`-Datei herunterladen (geht nur einmal!), dazu
   **Issuer ID** und **Key ID** notieren. Für Codemagic.
2. **In-App-Kauf** › „+“: Name `RevenueCat`. Die `.p8`-Datei herunterladen und
   die Key ID notieren. Für RevenueCat.

Die Dateien nicht per Mail verschicken und nicht ins Projekt legen.

## 7. RevenueCat für iOS

RevenueCat › Projekt Lookin:

1. **Apps & providers** › „+ New“ › **App Store**: Name `Lookin iOS`,
   Bundle-ID `com.lookin.foodtracker`. Den In-App-Kauf-Schlüssel (`.p8`) aus
   Schritt 6.2 mit Key ID und Issuer ID hochladen.
2. **Products** › „+ New“: `lookin_premium_monthly` und `lookin_premium_yearly`
   für die iOS-App anlegen (oder importieren).
3. **Entitlements** › `premium` › „Attach“: beide iOS-Produkte anhängen.
4. **Offerings** › `default` › Paket **Monthly**: iOS-Produkt
   `lookin_premium_monthly` ergänzen; Paket **Annual**: `lookin_premium_yearly`.
5. In der iOS-App bei RevenueCat steht eine URL für **Apple Server
   Notifications**. Diese URL in App Store Connect › App › App-Informationen ›
   „App Store-Server-Benachrichtigungen“ bei **Produktion und Sandbox**
   eintragen (Version 2).
6. Den **öffentlichen iOS-Schlüssel** kopieren (beginnt mit `appl_`). Er ist für
   Apps gedacht und darf in Codemagic stehen. Den geheimen Schlüssel (`sk_`)
   nirgends eintragen.

Der Webhook zu Supabase gilt für das ganze Projekt; für iOS ist dort nichts zu
tun.

## 8. Codemagic (Workflow-Editor)

1. Codemagic › Benutzer-Einstellungen › **Integrations** › Developer Portal ›
   Connect: Name `Lookin`, Issuer ID, Key ID und die `.p8` aus Schritt 6.1.
2. App `livo-fitness-app` › Workflow Editor:
   - **Build for platforms:** nur iOS.
   - **Environment variables:** `REVENUECAT_IOS_KEY` = der `appl_…`-Schlüssel,
     „Secure“ anhaken.
   - **Build:** Flutter-Version `3.44.8` (oder „Stable“), Xcode „Latest“,
     Modus **Release**. Bei den **Build-Argumenten** für iOS eintragen:
     `--build-number=$BUILD_NUMBER --dart-define=REVENUECAT_IOS_KEY=$REVENUECAT_IOS_KEY`
   - **Tests:** dürfen aus bleiben (laufen vor jedem Upload lokal).
   - **Distribution › iOS code signing:** „Automatic“, Schlüssel `Lookin`,
     Profiltyp **App Store**, Bundle-ID `com.lookin.foodtracker`.
   - **Distribution › App Store Connect:** einschalten, Schlüssel `Lookin`,
     „Submit to TestFlight“ an.
3. **Start new build.** Dauer etwa 20 bis 30 Minuten. Danach verarbeitet Apple
   den Build noch etwa 10 bis 30 Minuten.

Ohne `REVENUECAT_IOS_KEY` baut die App, zeigt aber keine Abos.

## 9. Auf dem eigenen iPhone testen (TestFlight)

App Store Connect › App › **TestFlight** › Interne Tests › Gruppe anlegen, sich
selbst hinzufügen. Auf dem iPhone die App **TestFlight** installieren und
Lookin darüber öffnen. Käufe in TestFlight sind Testkäufe und kosten nichts.

Prüfen: Altersfrage, Registrierung, Tagebuch, Kamera/Barcode, Premium-Seite mit
„7 Tage kostenlos testen“, Kauf, Willkommens-Ansicht, „Käufe
wiederherstellen“, „Abo verwalten“, Konto löschen.

## 10. Store-Eintrag (App Store Connect › App › Version 1.0)

| Feld | Inhalt |
| --- | --- |
| Name | `Lookin – AI Food Tracker` |
| Untertitel (30 Zeichen) | `Kalorien & Makros per KI-Foto` |
| Kategorie | Gesundheit und Fitness (zweite: Essen und Trinken) |
| Schlüsselwörter (100 Zeichen) | `kalorienzähler,makros,ernährung,tagebuch,abnehmen,protein,rezepte,barcode,halal,coach` |
| Support-URL | `https://app.lookin-foodtracker.de/legal/impressum.html` |
| Datenschutz-URL | `https://app.lookin-foodtracker.de/legal/datenschutz.html` |
| Nutzungsbedingungen (in die Beschreibung) | `https://app.lookin-foodtracker.de/legal/agb.html` |
| Copyright | `2026 Mhd Khair Shikho` |

**Beschreibung:** den Text aus `docs/PLAY_STORE_LISTING.md` nehmen, dabei den
Premium-Absatz so ersetzen:

```
Premium kannst du 7 Tage kostenlos testen. Kündigst du nicht vorher in den Abo-Einstellungen deines iPhones, beginnt danach das Abo: 6,99 € pro Monat oder 49,99 € pro Jahr. Das Abo verlängert sich automatisch und ist jederzeit zum Ende des Abrechnungszeitraums kündbar.

Nutzungsbedingungen: https://app.lookin-foodtracker.de/legal/agb.html
Datenschutz: https://app.lookin-foodtracker.de/legal/datenschutz.html
```

Englisch entsprechend mit dem englischen Text aus `docs/PLAY_STORE_LISTING.md`
und den Links unter `/legal/en/`.

**Screenshots:** iPhone 6,9 Zoll (1320 × 2868 oder 1290 × 2796), 3 bis 10
Stück. Am einfachsten auf einem großen iPhone über TestFlight aufnehmen.

## 11. App-Datenschutz (App Store Connect › App › App-Datenschutz)

„Erheben Sie Daten?“ › **Ja**. Tracking: **Nein** bei allen Daten.

| Datentyp | Zweck | Mit Identität verknüpft |
| --- | --- | --- |
| Kontaktinfos › E-Mail-Adresse, Name | App-Funktionalität | Ja |
| Gesundheit und Fitness › Gesundheit, Fitness (Mahlzeiten, Nährwerte, Gewicht, Allergien, Antworten der Einrichtung mit Einwilligung) | App-Funktionalität | Ja |
| Nutzerinhalte › Fotos (Mahlzeitenfoto für die KI, Premium) | App-Funktionalität | Ja |
| Nutzerinhalte › Andere Nutzerinhalte (Coach-Fragen, gemeldete Antworten) | App-Funktionalität | Ja |
| Käufe › Kaufverlauf (Abo-Status) | App-Funktionalität | Ja |
| Kennungen › Nutzer-ID (Konto-ID, auch bei RevenueCat) | App-Funktionalität | Ja |
| Nutzungsdaten › Produktinteraktion (Zähler für KI-Anfragen) | App-Funktionalität | Ja |

Nicht erhoben: Standort, Kontakte, Browserverlauf, Suchverlauf,
Diagnosedaten, Werbedaten. Die Antworten müssen zur Datenschutzerklärung
passen.

## 12. Altersfreigabe

Fragebogen ehrlich beantworten: keine Gewalt, keine Glücksspiele, keine
Inhalte für Erwachsene; bei Gesundheits-/Wellness-Themen **Ja** (Ernährung).
Die App fragt beim Start selbst nach 18 Jahren; das ist zusätzlich.

## 13. Hinweise für die Prüfung (App Review Information)

- **Anmeldung erforderlich:** Ja. Ein eigenes Prüfkonto in der App
  registrieren (E-Mail bestätigen) und E-Mail und Passwort nur in dieses Feld
  eintragen, nicht in Git.
- **Notiz** (Englisch):

```
On first launch, Lookin asks whether you are at least 18; tap "Yes".
Sign in with the demo account above. Premium (AI photo, Lookin Coach, all recipes) is unlocked with an auto-renewable subscription; sandbox purchases are enabled for review. Restore purchases and Manage subscription are on the Premium screen.
AI features ask for consent before any data is sent to the AI provider.
Account deletion: Profile › Privacy & data › Delete account and account data.
```

## 14. Einreichen

Version 1.0 › Build aus TestFlight auswählen › die beiden Abos unter
„In-App-Käufe und Abonnements“ hinzufügen › **Zur Prüfung einreichen**. Die
Prüfung dauert meist 1 bis 3 Tage. Nach der Freigabe „Veröffentlichen“.
