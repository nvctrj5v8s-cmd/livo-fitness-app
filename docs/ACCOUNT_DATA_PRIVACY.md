# Kontoexport und Kontolöschung

Stand: 1. Oktober 2026. Technische Dokumentation, kein Rechtstext.

## Speicherorte und Export

- Supabase Auth: Konto-ID, E-Mail und Metadaten des eigenen Kontos.
- Supabase-Datenbank: Profil, Premium-Status/Test, Mahlzeiten und Einträge,
  Rezeptfavoriten, Körpermessungen, KI-Chat-Verlauf und Nutzungszähler.
- Nur auf diesem Gerät: Einrichtungsantworten, Profilbild, lokale
  Lebensmittel-Shortcuts, Erinnerungsoptionen, alter Listenstand und
  Paywall-Marker. Der Export enthält das Profilbild als Base64.

Der Nutzer startet den Export selbst unter Profil -> Datenschutz. Die
`account-data` Edge Function liefert nur Daten zur durch Supabase Auth
bestätigten Konto-ID; sie akzeptiert keine fremde Konto-ID aus der Anfrage.
Jede Datenbanksektion wird in Seiten zu höchstens 200 Zeilen übertragen.
Die App erstellt daraus eine JSON-Datei, die Gesundheits- und Chatdaten
enthalten kann. Die Datei ist **nicht verschlüsselt**; deshalb weist die
Oberfläche auf sichere Aufbewahrung hin. Es gibt keine automatische
Übertragung an weitere Anbieter.

## Löschung

Vor endgültiger Löschung verlangt die App eine erneute Passworteingabe.
Der Server validiert sie gegen Supabase Auth und löscht nur das eigene
Konto. Fremdschlüssel mit `ON DELETE CASCADE` entfernen die personenbezogenen
Tabellenzeilen. Danach löscht die App ihre kontobezogenen lokalen Daten und
meldet die Sitzung auf dem Gerät ab. Allgemeine Katalogdaten bleiben
unverändert. Ein künftiges Apple-/Google-Store-Abo muss separat beim Store
gekündigt werden.

Bei Ausfall der lokalen Bereinigung kann das Serverkonto bereits gelöscht
sein, während Daten auf diesem Gerät verbleiben. In dem Fall App-Speicher
im Betriebssystem löschen bzw. die App deinstallieren. Ein Geräte-Backup
kann vorherige Datenkopien enthalten.

## Bereitstellung und offene Punkte

1. `supabase/migrations/0015_security_definer_search_paths.sql` auf dem
   richtigen Fitness-Supabase-Projekt ausführen.
2. `supabase/functions/account-data/index.ts` als Edge Function
   `account-data` deployen. Die Gateway-Option »Verify JWT with legacy
   secret« muss **aus** sein; die Funktion prüft das Bearer-Token selbst mit
   `auth.getUser(token)`. Den Service-Role-Schlüssel nie in die App kopieren.
3. Supabase Auth »Site URL« und erlaubte Redirect-URLs auf die tatsächlich
   genutzte Web-/App-Adresse setzen. Die derzeitige GitHub-Pages-Adresse ist
   `https://nvctrj5v8s-cmd.github.io/livo-fitness-app/` (vor Verwendung
   nochmals prüfen). Passwort-Reset mit einer echten Mail testen; die App
   erwartet nach dem Link ein neues Passwort und danach erneute Anmeldung.
   Supabase Flutter nutzt standardmäßig PKCE: Ein Reset-Link muss in den
   Browser bzw. die App zurückkehren, die den Reset angefordert hat. Das
   ist insbesondere auf Android/iOS ohne eingerichtete Deep Links noch
   nicht Ende-zu-Ende verifiziert.
4. In einem Testkonto Export, Löschung und An-/Abmeldung auf zwei Geräten
   prüfen. Produktive Nutzerkonten nicht als Testobjekte verwenden.

Nicht umgesetzt: formale DSGVO-Auskunfts- und Löschprozesse für Backups,
Aufbewahrungsfristen, gesetzliche Pflichten, Einwilligungswiderruf sowie
eine juristisch geprüfte Datenschutzerklärung. Die App darf daraus keine
vollständige rechtliche Konformität ableiten.
