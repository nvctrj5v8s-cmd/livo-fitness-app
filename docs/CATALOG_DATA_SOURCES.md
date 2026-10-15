# Datenquellen für den Lookin-Katalog

## Englische Anzeige, 15. Oktober 2026

`assets/l10n/catalog_en.json` enthält lokale Übersetzungen der eigenen
Rezept- und Katalogtexte aus `supabase/imports/i18n/source/recipes_de.json`
und `curated_foods_de.json`. `assets/l10n/usda_names_en.json` übernimmt die
ursprünglichen englischen Namen aus `usda_en_part1.json` bis `part5.json`
derselben Importquelle; ausgeschlossene Inhalte werden nicht übernommen.
Die Dateien ergänzen ausschließlich die Anzeige, keinen neuen Katalog und
keine Nährwerte. Deutsches Original und Quellennachweise bleiben erhalten.

Das Supabase-Schema speichert bei jedem Lebensmittel Herkunft, Lizenz und
Prüfstatus: `source`, `source_url`, `source_license`, `source_attribution`,
`data_quality` und `verified_at`.

Der Importer `tool/import_usda_foundation.dart` liest mit `--type foundation`
einen offiziellen USDA FoodData Central Foundation JSON-Download oder mit
`--type fndds` den FNDDS-Download und erzeugt SQL für `public.foods`.
Die Foundation-Datei enthält 354 generische Lebensmittel; FNDDS enthält 5.431
zubereitete Lebensmittel. Beide Importe enthalten Nährwerte pro 100 g und
bleiben als getrennte Quellen nachvollziehbar.

Open Food Facts bleibt getrennt für Barcode-Produkte. Dort gelten eigene ODbL-,
Datenbank-, Bild-, Attribution-, Share-alike- und Rate-Limit-Regeln. Deshalb
wird es nicht blind mit geschützten oder nicht weiterverteilbaren Quellen
vermischt.

Rezepte werden zunächst selbst erstellt und aus den Lebensmittelwerten
berechnet. `supabase/content/livo_recipes.json` enthält alle 40 originalen
Lookin-Rezepte ohne fremde Texte (Fotos: Pexels, siehe
`assets/ASSET_SOURCES.md`) und erzeugt die Migration
`supabase/migrations/0010_recipe_content.sql`. Fremde Rezepttexte und Bilder
werden erst nach Lizenzprüfung übernommen. Die kleine Seed-Datei bleibt der
reproduzierbare Entwicklungsstart;
`supabase/imports/usda_foundation.sql` und `supabase/imports/usda_fndds.sql`
werden separat in Supabase importiert.
