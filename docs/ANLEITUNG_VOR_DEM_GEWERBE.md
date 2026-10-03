# Anleitung: Alles, was du vor dem Gewerbe tun kannst

Stand: 3. Oktober 2026. Schritt für Schritt, in dieser Reihenfolge. Die
Bildschirme der Dienste ändern sich manchmal. Wenn eine Schaltfläche anders
heißt, such nach dem gleichen Sinn. Schick mir im Zweifel einen Screenshot.

Nichts davon kostet Geld, außer dem einmaligen Play-Konto (hast du schon).

---

## Schritt 1: Schlüssel sichern (5 Minuten)

**Wofür?** Beim Bauen der App wird sie mit einem Schlüssel „unterschrieben“.
Google erlaubt Updates nur mit demselben Schlüssel. Der Schlüssel besteht aus
zwei Dateien, die nur auf diesem Rechner liegen. Geht der Rechner kaputt, wären
sie weg.

**So geht es:** Auf deinem Desktop liegt der Ordner **Lookin-Sicherung** mit drei
Dateien:

- `upload-keystore.jks` (der Schlüssel)
- `key.properties` (das Passwort dazu)
- `Webhook-Geheimnis.txt` (kommt in Schritt 3 zum Einsatz)

1. Stecke einen USB-Stick an und kopiere den ganzen Ordner **Lookin-Sicherung**
   darauf. Alternativ lade die zwei Dateien in einen Passwortmanager hoch, der
   Dateianhänge kann (zum Beispiel Bitwarden).
2. Bewahre den Stick an einem sicheren Ort auf, nicht im Laptop-Rucksack.
3. Lösche den Ordner vom Desktop, sobald die Kopie sicher ist. Er enthält ein
   Passwort. Die Originale in `fitness_ai_app\android` bleiben unberührt.

Teile die Dateien mit niemandem und lade sie nirgends öffentlich hoch.

---

## Schritt 2: Migration 0016 anwenden (erledigt am 3. Oktober 2026)

**Was ist eine Migration?** Deine Datenbank bei Supabase hat feste Tabellen. Eine
Migration ist eine kleine Änderungsdatei, die die Datenbank erweitert. Die Datei
`0016` fügt eine Spalte hinzu und eine Funktion, mit der der Server nach einem
Kauf den Premium-Status einträgt. Sie ändert und löscht **nichts** Bestehendes.

**Warum noch nicht erledigt?** Sie liegt im Projekt, ist aber noch nicht in der
echten Datenbank. Ich durfte sie nicht selbst anwenden. Ohne sie funktioniert
später der Kauf nicht, die App läuft aber normal weiter.

**So geht es:**

1. Öffne in VS Code die Datei `supabase/migrations/0016_store_billing_entitlements.sql`.
   Drücke **Strg+A** (alles markieren) und **Strg+C** (kopieren).
2. Gehe auf [supabase.com/dashboard](https://supabase.com/dashboard) und melde dich
   an. Öffne das Projekt **fitniss app ai**.
3. Links im Menü: **SQL Editor**. Dann **New query** (neue Abfrage).
4. Drücke **Strg+V** (einfügen) und klicke unten rechts auf **Run**.
5. Erwartet wird die Meldung **Success. No rows returned**. Bei einem Fehler
   schick mir den Text.

**Alternative:** Sag mir im Chat „ja, wende die Migration mit `supabase db push`
an“. Dann mache ich es und prüfe das Ergebnis.

---

## Schritt 3: Webhook einrichten (15 Minuten)

**Was ist ein Webhook?** Wenn jemand in der App ein Abo kauft, meldet Google das
an RevenueCat. RevenueCat ruft dann eine Adresse bei Supabase auf („Webhook“) und
sagt: „Dieses Konto hat jetzt Premium.“ Die Adresse prüft ein gemeinsames
Passwort, damit niemand anderes Premium vortäuschen kann.

**Warum kann ich das nicht allein?** Beides liegt in deinen Konten
(Supabase-Dashboard und RevenueCat-Dashboard), und das Passwort darf nicht in
Git oder in den Chat. Die Function selbst habe ich schon bereitgestellt.

**Das gemeinsame Passwort:** Ich habe es für dich erzeugt. Es steht in
`Desktop\Lookin-Sicherung\Webhook-Geheimnis.txt`. Öffne die Datei und kopiere den
langen Wert unter „Wert:“.

### 3a: Passwort in Supabase eintragen

1. [supabase.com/dashboard](https://supabase.com/dashboard), Projekt **fitniss app
   ai**.
2. Links **Edge Functions**, oben oder seitlich **Secrets** (bei manchen
   Versionen: **Project Settings > Edge Functions**).
3. **Add new secret** (neues Secret).
4. **Name:** `REVENUECAT_WEBHOOK_SECRET` (genau so, nur Großbuchstaben).
5. **Value:** der kopierte Wert. **Save**.

### 3b: RevenueCat-Projekt anlegen

1. [app.revenuecat.com](https://app.revenuecat.com), melde dich an.
2. **Create new project**, Name: `Lookin`.
3. **+ Add app** und **Play Store** wählen. App-Name: `Lookin`, Paketname:
   `com.lookin.foodtracker`. Die Google-Zugangsdaten überspringst du, falls
   danach gefragt wird. Die kommen später (nach dem Gewerbe).

### 3c: Webhook in RevenueCat eintragen

1. Im Projekt links **Integrations** (oder **Project settings > Integrations**),
   dann **Webhooks**, **+ New** (neuer Webhook).
2. **Webhook URL:**
   `https://kypxutvvpklkvekciuen.supabase.co/functions/v1/revenuecat-webhook`
3. **Authorization header value:** derselbe Wert wie in 3a (nur der Wert, ohne das
   Wort „Bearer“).
4. **Environment:** Produktion **und** Sandbox. Events: alle.
5. Speichern, dann **Send test event** (Test-Ereignis senden).

**Erwartet:** Die Antwort enthält `"result":"ignored"`. Antwortet er mit `401`,
stimmt das Passwort nicht überein. Mit `503` fehlt das Secret in Supabase
(Schritt 3a). Danach kannst du die Datei `Webhook-Geheimnis.txt` löschen oder im
Passwortmanager aufbewahren.

---

## Schritt 4: Support-E-Mail (10 Minuten)

**Wofür?** Google verlangt im Store eine Kontakt-E-Mail, das Impressum braucht
sie, und Nutzer brauchen jemanden für Fragen. Verwende **nicht** deine private
Adresse.

1. Lege eine neue E-Mail-Adresse an, zum Beispiel bei Gmail oder Proton Mail.
   Sinnvoll ist etwas wie `lookin.support@…`. Später kannst du auf eine eigene
   Domain umstellen.
2. Notiere sie. Sie kommt in die Rechtstexte (Impressum, Datenschutz, Widerruf)
   und in die Play Console.

---

## Schritt 5: Testkonto für die Google-Prüfer (10 Minuten)

**Wofür?** Die App verlangt eine Anmeldung. Die Prüfer bei Google können sich
nicht selbst registrieren, also gibst du ihnen ein fertiges Konto.

1. Öffne die App (Web-Version reicht) und registriere ein normales Konto mit einer
   neuen E-Mail-Adresse, die du erreichen kannst. Bestätige die E-Mail.
2. Füge Beispieldaten ein (ein paar Mahlzeiten), damit die App nicht leer wirkt.
3. Gib dem Konto Premium für ein Jahr, damit die Prüfer die KI-Funktionen sehen.
   Dafür brauchst du den SQL Editor (siehe Schritt 2) und diese Abfrage. Ersetze
   die Adresse:

   ```sql
   update public.entitlements
      set plan = 'premium', status = 'active',
          expires_at = now() + interval '1 year',
          provider = 'review_account', updated_at = now()
    where user_id = (select id from auth.users where email = 'TESTKONTO@BEISPIEL.DE');
   ```

4. Schreibe E-Mail und Passwort auf. Du trägst sie später in der Play Console ein
   (Bereich „App-Zugriff“). In Git gehören sie nicht.

---

## Schritt 6: Verträge mit Dienstleistern (30 Minuten)

**Was ist das?** Wenn Dienste in deinem Auftrag Nutzerdaten verarbeiten, verlangt
die DSGVO einen Vertrag, den sogenannten **Auftragsverarbeitungsvertrag (AVV)**.
Bei den drei Diensten ist das meist eine Bestätigung online. Es ist **keine
Rechtsberatung**.

| Dienst | Wofür | Was du tust |
| --- | --- | --- |
| Supabase | Datenbank, Anmeldung | Der Vertrag gilt mit der Annahme der Nutzungsbedingungen. [Hier nachlesen und speichern](https://supabase.com/legal/dpa). Lade das PDF herunter. |
| OpenAI | KI-Coach, Foto | Im OpenAI-Konto den Auftragsverarbeitungsvertrag abschließen. [Hier das Formular](https://openai.com/policies/data-processing-addendum/). Speichere die Bestätigung. |
| RevenueCat | Kauf-Verwaltung | Teil der Nutzungsbedingungen. [Hier nachlesen](https://www.revenuecat.com/dpa) und speichern. |

Google Play ist für Zahlungen ein eigener Verantwortlicher, da brauchst du
nichts zu unterschreiben.

---

## Schritt 7: Marken-Check für „Lookin“ (20 Minuten)

**Wofür?** Wenn jemand anderes „Lookin“ schon als Marke für ähnliche Dienste hat,
kann er dich abmahnen. Das lässt sich vorher prüfen.

1. [register.dpma.de](https://register.dpma.de): Suche **Lookin** unter Marken.
2. [tmdn.org/tmview](https://www.tmdn.org/tmview): Suche **Lookin** (EU und
   international).
3. Achte auf Treffer, die **gleich oder sehr ähnlich klingen** und in den Klassen
   **9** (Software/Apps), **42** (Software als Dienst), **41** (Bildung/Training),
   **44** (Gesundheit) oder **29/30** (Lebensmittel) stehen.
4. Mache Screenshots. Bei einem Treffer sag mir Bescheid, und denk an eine kurze
   Beratung, bevor du Geld in den Namen steckst.

---

## Schritt 8: Rechtstexte ausfüllen (nach dem Gewerbe)

Die Texte liegen als Seiten in `web/legal/` und sind in der App verlinkt:

- Datenschutzerklärung, AGB, Widerrufsbelehrung, Impressum.
- Alle gelb markierten Stellen („BITTE AUSFÜLLEN“) musst du ausfüllen, wenn du dein
  Gewerbe hast: Name, Anschrift, E-Mail, Telefon, Steuerangaben, Datum.
- Lass die Texte vor dem öffentlichen Start von einer fachkundigen Person
  prüfen. Das sind **Entwürfe, keine Rechtsberatung**.
- Mit `dart run tool/check_legal_pages.dart` prüfst du, ob noch etwas offen ist.
  Solange das Skript „Nicht bereit“ meldet, ist nichts veröffentlichungsreif.
- Die öffentliche Adresse der Seiten (für die Play Console) ist
  `https://nvctrj5v8s-cmd.github.io/livo-fitness-app/legal/datenschutz.html`. Sie
  ist erst erreichbar, nachdem die Änderungen gepusht wurden und die Webseite neu
  gebaut ist. Sie enthält noch das Wort „livo“, weil das GitHub-Projekt so heißt.
  Mit einer eigenen Domain wird sie schöner.

---

## Danach: warten auf das Gewerbe

Sobald Schritt 1 bis 7 erledigt sind, gibt es nichts mehr, was du ohne Gewerbe
tun kannst, außer:

- Play Console: App anlegen, Paket hochladen, Store-Eintrag ausfüllen,
  geschlossenen Test mit 12 Personen starten und Screenshots machen. Das hast du
  für später eingeplant.
- Das Gewerbe anmelden.

Nach dem Gewerbe: Rechtstexte ausfüllen, Händlerprofil in der Play Console, Abos
anlegen, Google mit RevenueCat verbinden, Test-Käufe. Das steht in
`docs/BILLING_SETUP.md`.
