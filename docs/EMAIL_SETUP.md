# E-Mails von Lookin statt von Supabase

Stand: 1. Oktober 2026. Diese Einstellungen liegen im Supabase-Dashboard und
nicht im Code. Projekt: `kypxutvvpklkvekciuen`.

## 1. Links reparieren (Pflicht, 2 Minuten)

Befund vom 01.10.2026: Die Site URL steht auf `http://localhost:3000`, die
Website ist nicht als Ziel freigegeben. Deshalb öffnet der Link aus „Passwort
vergessen“ auf dem Handy eine nicht erreichbare Seite.

Dashboard → **Authentication → URL Configuration**:

- **Site URL:** `https://nvctrj5v8s-cmd.github.io/livo-fitness-app/`
  (mit Schrägstrich am Ende)
- **Redirect URLs → Add URL:** `https://nvctrj5v8s-cmd.github.io/livo-fitness-app/**`
- Speichern. Sobald es eine eigene Domain gibt, beide Einträge ergänzen.

## 2. Eigener Absender „Lookin“ (eigene Domain nötig)

Ohne eigenen Mailversand kommen Mails von „Supabase Auth“, sind stark
mengenbegrenzt und landen leichter im Spam.

1. **Domain kaufen**, z. B. bei IONOS, Strato oder Cloudflare. Erst nach der
   Markenprüfung von „Lookin“ endgültig festlegen.
2. **Mailversand-Dienst** anlegen, z. B. Resend (kostenloser Einstieg) oder
   Brevo. Domain dort hinzufügen und die angezeigten DNS-Einträge (SPF, DKIM)
   beim Domain-Anbieter eintragen. Warten, bis die Domain als „verified“ gilt.
3. Dashboard → **Authentication → Emails → SMTP Settings**:
   - Enable Custom SMTP: an
   - Sender email: `noreply@<deine-domain>`
   - Sender name: `Lookin`
   - Host, Port, Username, Password: aus dem Mailversand-Dienst
     (bei Resend: `smtp.resend.com`, Port `465`, Benutzer `resend`, Passwort =
     API-Schlüssel). Den Schlüssel nie in Code oder Chat einfügen.
4. Unter **Rate Limits** das E-Mail-Limit an die erwarteten Anmeldungen
   anpassen.

## 3. Vorlagen im Lookin-Stil

Dashboard → **Authentication → Emails → Templates**. Jeweils Betreff
eintragen und den Inhalt der Datei vollständig in „Message body“ kopieren:

| Vorlage | Betreff | Datei |
| --- | --- | --- |
| Reset Password | Neues Passwort für Lookin festlegen | `supabase/templates/recovery.html` |
| Confirm signup | Bestätige deine E-Mail für Lookin | `supabase/templates/confirmation.html` |
| Change Email Address | Änderung deiner E-Mail-Adresse bestätigen | `supabase/templates/email_change.html` |

Die Vorlagen verlinken mit `{{ .SiteURL }}?token_hash=…&type=…`. Die App
(`lib/features/auth/data/email_link.dart`) löst den Link selbst ein. Anders
als der Standard-Link funktioniert er auch, wenn die Mail auf einem anderen
Gerät geöffnet wird als dem, auf dem sie angefordert wurde. Voraussetzung ist
Schritt 1 (die Site URL muss auf die Website zeigen).

Die Bilder der Vorlagen (animiertes Logo, animierte Kopfbilder, Funktions-
Animationen, Rezeptfoto) liegen in `web/email/` und werden mit der Website
veröffentlicht. Erzeugt werden sie mit `dart run tool/email_assets.dart`
(Logo, Kopfbilder, Foto) und `flutter test tool/email_frames_test.dart`
(Tagebuch- und Coach-Animation, mit Flutter im App-Look gerendert). Die Animationen laufen
einmal ab und bleiben dann stehen. Zieht die Website auf die eigene Domain um,
die Bild-URLs in den drei Vorlagen anpassen.

## 3a. Pflicht-Einstellungen im Dashboard (Prüfung vom 11.10.2026)

- **Authentication → Sign In / Providers → Email:** „Confirm email“ an,
  „Secure email change“ an, „Minimum password length“ 8 (die App verlangt
  ebenfalls 8 Zeichen), „Email OTP Expiration“ 3600 Sekunden lassen.
- **Authentication → URL Configuration:** Site URL wie in Schritt 1.
- **Authentication → Rate Limits:** E-Mails pro Stunde auf etwa 30.
- Die Vorlagen „Magic Link“, „Invite“ und „Reauthentication“ nutzt die App
  nicht; sie bleiben Supabase-Standard.
- Eine Funktion „E-Mail-Adresse ändern“ gibt es in der App noch nicht. Die
  Vorlage ist vorbereitet; bei aktivem „Secure email change“ bekommen alte
  und neue Adresse dieselbe Mail und müssen beide bestätigen.
- Android: Die Links öffnen die Web-Version im Browser (keine App Links).
  Danach meldet man sich in der Android-App an.

## 4. Testen

„Passwort vergessen“ auf dem Computer anfordern, Mail auf dem iPhone öffnen,
neues Passwort setzen, mit dem neuen Passwort anmelden. Absender, Betreff und
Aussehen prüfen; auch den Spam-Ordner.

## 5. Kauf- und Widerrufsbestätigungen (Resend-API, seit 10.10.2026)

Die Functions `legal-actions` (Widerruf) und `revenuecat-webhook`
(Kaufbestätigung) schicken E-Mails direkt über die Resend-API
(`supabase/functions/_shared/mail.ts`). Ohne die zwei Secrets wird nichts
verschickt, und die App zeigt die Eingangsbestätigung nur auf dem Bildschirm.

Supabase → Edge Functions → Secrets:

- `RESEND_API_KEY`: API-Schlüssel aus Resend (nie in Code oder Chat)
- `MAIL_FROM`: verifizierter Absender, z. B. `Lookin <noreply@deine-domain.de>`

Benachrichtigungen über neue Widerrufe gehen an `lookinsupport@gmail.com`.
**Vor dem Verkauf an echte Kunden Pflicht:** Die Eingangsbestätigung eines
Widerrufs muss auf einem dauerhaften Datenträger kommen (§ 356a BGB).
