# Bezahlung einrichten (Google Play über RevenueCat)

Stand: 2. Oktober 2026. Dieses Dokument beschreibt, wie Lookin Premium bezahlt
wird, was im Code schon fertig ist und was nur der Inhaber der Konten tun kann.
Der Funktionsstatus steht in `docs/FEATURE_STATUS.md`.

## So funktioniert es

1. Der Nutzer tippt in der Paywall auf „Abonnieren“. Die App fragt
   **RevenueCat** (SDK `purchases_flutter`) nach dem Paket und öffnet das
   **Google-Play-Bezahlfenster**. Karte, PayPal, Google Pay und Guthaben wählt
   der Nutzer dort; Lookin sieht und speichert keine Zahlungsdaten.
2. Google meldet den Kauf an RevenueCat. RevenueCat ruft die Supabase-Function
   `revenuecat-webhook` auf.
3. Die Function prüft das gemeinsame Geheimnis und schreibt über
   `apply_revenuecat_event()` (Migration `0016`) in `public.entitlements`.
4. Die App fragt `public.entitlements` ab. **Der Server entscheidet**, ob
   Premium gilt: KI-Coach, Foto-Erkennung und Premium-Rezepte prüfen dieselbe
   Tabelle. Bis der Webhook angekommen ist, fragt die App bis zu 8 Mal nach
   und sagt sonst ehrlich „Freischaltung dauert noch einen Moment“.

Die Konto-ID, die RevenueCat bekommt, ist die Supabase-Nutzer-ID. Andere Daten
(Profil, Tagebuch, Gesundheit) gehen nicht an RevenueCat.

Die kostenlose Testphase (7 Tage, ohne Zahlungsdaten) bleibt serverseitig in der
App (`start_premium_trial`). In der Play Console darf deshalb **kein**
zusätzliches Gratis-Angebot an den Abos hängen, sonst gäbe es 14 Tage gratis.

## Im Code fertig

- `lib/features/subscription/data/store_billing.dart`: austauschbare Schicht
  (`StoreBilling`), RevenueCat-Umsetzung und Stub für Web/Tests.
- `SubscriptionController.purchase/restore`: Kauf, Wiederherstellen und
  Server-Bestätigung.
- Paywall: Kaufen, „Käufe wiederherstellen“, „Abo verwalten“. Im Browser steht
  ehrlich, dass Abos in der Android-App abgeschlossen werden.
- `supabase/migrations/0016_store_billing_entitlements.sql` und
  `supabase/functions/revenuecat-webhook/`.
- Android: Internet-Berechtigung, Release-Signierung mit eigenem Schlüssel,
  Paketkennung `com.lookin.foodtracker`.

Ohne RevenueCat-Schlüssel verhält sich die App wie bisher: Die Paywall sagt,
dass die Bezahlung eingerichtet wird, und nichts wird gekauft.

## Was nur du tun kannst

Reihenfolge einhalten. Nichts davon gehört in Git oder in einen Chat.

### 0. Gewerbe und Händlerprofil

Abos in der Play Console lassen sich erst mit Händlerprofil (Zahlungsprofil)
anlegen. Dafür brauchst du ein angemeldetes Gewerbe, Steuerangaben und die IBAN,
auf die Google auszahlt. Bis dahin kannst du alles andere vorbereiten.

### 1. Play Console: App anlegen und hochladen

1. „App erstellen“: Name **Lookin – AI Food Tracker**, Standardsprache Deutsch,
   App (kein Spiel), kostenlos.
2. Die App muss mit der Paketkennung `com.lookin.foodtracker` hochgeladen
   werden. Die Kennung lässt sich danach nicht mehr ändern.
3. Baue die Datei (siehe Abschnitt „Bauen“) und lade
   `build/app/outputs/bundle/release/app-release.aab` im **internen Test** hoch.
   „Play App Signing“ annehmen.
4. Trage dich unter „Tester“ ein, und unter Einstellungen > Lizenztests deine
   Google-Mail als **Lizenztester**.

### 2. Play Console: Abos anlegen

Monetarisierung > Abos:

| Produkt-ID | Basis-Tarif | Preis (inkl. MwSt.) |
| --- | --- | --- |
| `lookin_premium_monthly` | monatlich, automatisch verlängernd | 6,99 € |
| `lookin_premium_yearly` | jährlich, automatisch verlängernd | 59,99 € |

- **Keine** Testphase oder Einführungsangebot hinzufügen.
- Die Preise müssen zu `lib/features/subscription/domain/subscription_plans.dart`
  passen. Ändert sich ein Preis, ändern sich Store und Datei gemeinsam.

### 3. RevenueCat

1. Projekt „Lookin“ anlegen, **Android-App** hinzufügen (Paket
   `com.lookin.foodtracker`).
2. Google-Zugang: In der Play Console unter „Einrichtung > API-Zugriff“ ein
   Dienstkonto anlegen (Google Cloud), ihm in der Play Console Rechte für
   „Finanzdaten ansehen“ und „Bestellungen und Abos verwalten“ geben und den
   JSON-Schlüssel in RevenueCat hochladen. Die JSON-Datei nie in Git ablegen.
3. Produkte importieren, dann ein **Entitlement** mit der ID `premium`
   anlegen und beide Produkte daran hängen.
4. **Offering** `default` (als „Current“) mit zwei Paketen: **Monthly**
   (`lookin_premium_monthly`) und **Annual** (`lookin_premium_yearly`). Die
   App erkennt die Pakete am Typ Monthly/Annual.
5. Den **öffentlichen Android-SDK-Schlüssel** (`goog_…`) kopieren. Er darf in den
   Build, ein Secret Key (`sk_…`) nie.

### 4. Webhook zu Supabase

1. Denke dir ein langes zufälliges Geheimnis aus.
2. Supabase > Edge Functions > Secrets: `REVENUECAT_WEBHOOK_SECRET` = dein
   Geheimnis.
3. Migration `0016_store_billing_entitlements.sql` im SQL Editor ausführen,
   falls sie noch nicht angewendet ist.
4. Die Function `revenuecat-webhook` deployen.
5. RevenueCat > Integrationen > Webhooks: URL
   `https://kypxutvvpklkvekciuen.supabase.co/functions/v1/revenuecat-webhook`,
   Authorization-Header = dein Geheimnis, Umgebungen Produktion und Sandbox.
   „Send test event“ muss mit `ignored` antworten.

### 5. Bauen

```powershell
flutter build appbundle --release --dart-define=REVENUECAT_ANDROID_KEY=goog_DEIN_SCHLUESSEL
```

Ohne `--dart-define` entsteht ein Build ohne Bezahlung. Den Webbuild (GitHub
Pages) brauchst du dafür nicht anzufassen; Web kauft nichts.

### 6. Testen

Mit dem Lizenztester-Konto auf einem echten Android-Gerät aus dem internen Test
installieren, Monats- und Jahresabo kaufen (Testkarte, es wird nichts
abgebucht), dann prüfen:

- Paywall zeigt nach dem Kauf „Premium ist aktiv“, KI-Coach ist freigeschaltet.
- In Supabase `entitlements`: `provider = revenuecat`, Status `active`, Ablauf
  in der Zukunft.
- „Abo verwalten“ öffnet die Play-Abos, Kündigen lässt den Zugang bis zum
  Laufzeitende bestehen.
- App löschen, neu installieren, anmelden, „Käufe wiederherstellen“.
- Testabos erneuern sich im Testmodus schnell (Minuten); danach folgt
  `EXPIRATION` und der Zugang endet.

## Sicherungen und Schlüssel

- **Upload-Schlüssel:** `android/app/upload-keystore.jks` und
  `android/key.properties` liegen nur auf diesem Rechner und sind von Git
  ignoriert. **Sichere beide Dateien an einem zweiten Ort** (zum Beispiel
  Passwortmanager oder verschlüsselter USB-Stick). Geht der Schlüssel verloren,
  kann Google den Upload-Schlüssel nur über einen Support-Antrag zurücksetzen.
- Das Geheimnis des Webhooks, der Secret Key von RevenueCat und der Google-
  Dienstkonto-Schlüssel stehen nur in den jeweiligen Dashboards.

## Datenschutz

- RevenueCat (RevenueCat, Inc., USA) bekommt die Konto-ID, Kaufdaten
  (Produkt, Zeitpunkte, Store, Land) und technische Daten wie die IP-Adresse.
  Keine Gesundheits-, Profil- oder Tagebuchdaten.
- Vor dem Start nötig: Auftragsverarbeitungsvertrag (DPA) mit RevenueCat
  abschließen, Drittlandübermittlung (USA) in der Datenschutzerklärung nennen,
  RevenueCat und Google Play als Empfänger aufführen.
- Zahlungsdaten verarbeitet allein der Store (Google). Lookin speichert nur,
  ob und bis wann Premium gilt.
- Kontolöschung entfernt `entitlements` samt Konto, **kündigt aber kein
  Store-Abo**. Die App muss das vor dem Löschen deutlich sagen.

## Bekannte Grenzen

- Ein Store-Konto, das auf ein anderes Lookin-Konto wechselt (RevenueCat
  `TRANSFER`), wird nicht automatisch übernommen. Das Ereignis ändert nichts.
- `BILLING_ISSUE` (Zahlung fehlgeschlagen) behält den Zugang bis zum Ablauf,
  danach folgt `EXPIRATION`.
- Testkäufe (Sandbox) schalten Premium auch im echten Projekt frei. Das ist
  für Tests gewollt.
- iOS ist noch nicht eingerichtet: Es braucht Apple-Entwicklerkonto,
  App-Store-Connect-Abos und einen eigenen `REVENUECAT_IOS_KEY`.
