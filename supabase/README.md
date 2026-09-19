# Supabase-Einrichtung für LIVO

1. Im Supabase-Dashboard den **SQL Editor** öffnen.
2. `migrations/0001_livo_schema.sql` vollständig ausführen.
3. Danach `seed.sql` ausführen.
4. Unter **Authentication → Providers** zunächst Email aktivieren.
5. Für Entwicklung kann die E-Mail-Bestätigung aktiviert bleiben; nach der Registrierung zeigt die App einen Bestätigungshinweis.

Profilbilder sind bewusst lokal auf dem jeweiligen Gerät gespeichert. Dafür
ist kein Supabase-Storage-Bucket und keine zusätzliche SQL-Migration nötig.

Eine klare Übersicht, welche Daten bewusst in Supabase und welche nur lokal
liegen, steht in `../docs/SUPABASE_STORAGE_MAP.md`. Nach der Einrichtung kann
`verify_setup.sql` im SQL Editor ausgeführt werden; es verändert keine Daten,
sondern zeigt RLS, Katalogmenge, Rezeptmenge und Policies an.

Für die produktive Barcode-Abfrage danach
`migrations/0003_barcode_product_details.sql` ausführen und die Edge Function
`functions/barcode-lookup/index.ts` bereitstellen. Die genauen, aktuellen
Dashboard-Schritte und die Lizenz-/Quellenhinweise stehen in
`../docs/BARCODE_LOOKUP.md`.

Die App verwendet ausschließlich die Project URL und den Publishable Key.
Secret- und `service_role`-Keys gehören niemals in Flutter oder Git.

Die Seed-Daten sind nur Entwicklungsdaten. Vor Veröffentlichung wird ein
lizenzierter, größerer Import mit Quellenangaben, Validierung und Versionierung
benötigt.

Für den geprüften Lebensmittelimport zuerst `migrations/0002_catalog_metadata.sql`
ausführen. Die erzeugten Dateien liegen bereits unter `imports/`: Foundation
mit 354 generischen Lebensmitteln und FNDDS mit 5.431 zubereiteten
Lebensmitteln. Zusätzlich enthält `imports/curated_recipes.sql` zwölf originale
Starter-Rezepte. Einen neuen Lebensmittelimport kann man lokal so erzeugen:

```text
dart run tool/import_usda_foundation.dart --input <foundation.json> --output supabase/imports/usda_foundation.sql
```

Für die bereits erzeugte FNDDS-Datei lautet der entsprechende Aufruf:

```text
dart run tool/import_usda_foundation.dart --type fndds --input <surveyDownload.json> --output supabase/imports/usda_fndds.sql
```

Die erzeugte Datei anschließend einmal im Supabase-SQL-Editor ausführen. Sie
enthält Herkunft an jedem Datensatz und keine geheimen Schlüssel. Die aktuellen
USDA-Nutzungs- und Attributionsbedingungen müssen vor Veröffentlichung geprüft
werden; Open-Food-Facts-Barcodedaten bleiben wegen eigener Lizenzpflichten eine
separate Quelle. Die aktuellen USDA-Nutzungs- und Attributionsbedingungen
müssen vor Veröffentlichung geprüft werden.
