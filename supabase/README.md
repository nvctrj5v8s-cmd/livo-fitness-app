# Supabase-Einrichtung für LIVO

1. Im Supabase-Dashboard den **SQL Editor** öffnen.
2. `migrations/0001_livo_schema.sql` vollständig ausführen.
3. Danach `seed.sql` ausführen.
4. Unter **Authentication → Providers** zunächst Email aktivieren.
5. Für Entwicklung kann die E-Mail-Bestätigung aktiviert bleiben; nach der Registrierung zeigt die App einen Bestätigungshinweis.

Die App verwendet ausschließlich die Project URL und den Publishable Key.
Secret- und `service_role`-Keys gehören niemals in Flutter oder Git.

Die Seed-Daten sind nur Entwicklungsdaten. Vor Veröffentlichung wird ein
lizenzierter, größerer Import mit Quellenangaben, Validierung und Versionierung
benötigt.
