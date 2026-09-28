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
Lebensmitteln. Die Rezepte kommen aus `content/livo_recipes.json` (siehe unten).
Einen neuen Lebensmittelimport kann man lokal so erzeugen:

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

## Rezeptinhalte und Premium-Extras

`migrations/0009_recipe_details.sql` ergänzt Rezepte um Vorbereitungs- und
Kochzeit, Utensilien, Schritt-Titel und Schritt-Timer, Zutaten um
Haushaltsmaß und Notiz sowie die Tabelle `recipe_premium_details` (nur für
Konten mit aktivem Premium oder Testphase lesbar).

Die Rezepttexte selbst liegen geprüft als JSON in
`content/livo_recipes.json`. Nach einer Änderung die Migration neu erzeugen:

```text
dart run tool/generate_recipe_sql.dart --input supabase/content/livo_recipes.json --output supabase/migrations/0010_recipe_content.sql
```

Das Werkzeug bricht ab, wenn ein Text gegen die Halal-Regel verstößt, eine
Zutat fehlt oder „High Protein“ weniger als 20 % Energie aus Protein hat.
Migrationen werden mit der Supabase CLI eingespielt (`supabase db push
--linked`); alle Rezept-Migrationen sind wiederholbar.

Die JSON-Datei ist die einzige Quelle für alle Rezepte (aktuell 40, davon 12
kostenlos = 30 %). Sie enthält:

- `foods`: neue Katalog-Lebensmittel mit Werten je 100 g aus USDA FoodData
  Central (FDC-ID und USDA-Bezeichnung werden als Quelle gespeichert). Die neun
  ursprünglichen Seed-Lebensmittel (`oats`, `skyr`, `salmon`, `rice`, …) legt
  die Migration nur an, wenn sie fehlen, und verändert sie nie – so bleiben
  bestehende Tagebucheinträge unverändert.
- `recipes`: Titel, Beschreibung, Zeiten, Tags, Utensilien, Zutaten (Slug,
  Gramm für alle Portionen, Haushaltsmaß, Notiz), Schritte mit Titel und
  Timer sowie die Premium-Extras. Nährwerte werden nicht eingetragen, sondern
  in der App aus den Zutatenmengen berechnet.
- `retired_recipe_slugs`: alte Rezepte, die die Migration löscht.

Zutatennamen sind die Namen der Lebensmittel und werden vom Abgleich „Was
habe ich zu Hause?“ genutzt; deshalb einheitlich benennen (z. B. immer
„Kartoffeln“, Gewürzpaprika als „Paprikapulver, edelsüß“). Die Migration
prüft am Ende, dass alle Rezepte, Zutaten und Premium-Extras gespeichert
wurden, und bricht sonst ab. Fotos liegen lokal in
`../assets/images/recipes/livo-<slug>.webp` und werden in
`lib/core/data/recipe_images.dart` eingetragen.
