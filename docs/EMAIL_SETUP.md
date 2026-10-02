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
| Reset Password | Dein neues Lookin-Passwort | `supabase/templates/recovery.html` |
| Confirm signup | Bestätige deine E-Mail für Lookin | `supabase/templates/confirmation.html` |
| Change Email Address | Bestätige deine neue E-Mail-Adresse | `supabase/templates/email_change.html` |

Die Vorlagen verlinken mit `{{ .SiteURL }}?token_hash=…&type=…`. Die App
(`lib/features/auth/data/email_link.dart`) löst den Link selbst ein. Anders
als der Standard-Link funktioniert er auch, wenn die Mail auf einem anderen
Gerät geöffnet wird als dem, auf dem sie angefordert wurde. Voraussetzung ist
Schritt 1 (die Site URL muss auf die Website zeigen).

Das Logo ist vorerst der Schriftzug „Lookin.“ als Text. Sobald ein Logo
existiert, als PNG (nicht SVG, das zeigen viele Mailprogramme nicht an) auf
der Website ablegen und per `<img>` mit absoluter URL einbinden.

## 4. Testen

„Passwort vergessen“ auf dem Computer anfordern, Mail auf dem iPhone öffnen,
neues Passwort setzen, mit dem neuen Passwort anmelden. Absender, Betreff und
Aussehen prüfen; auch den Spam-Ordner.
