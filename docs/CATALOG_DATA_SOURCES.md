# Datenquellen für den LIVO-Katalog

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
berechnet. `supabase/imports/curated_recipes.sql` enthält 10 originale
Starter-Rezepte ohne fremde Texte oder Bilder. Fremde Rezepttexte und Bilder
werden erst nach Lizenzprüfung übernommen. Die kleine Seed-Datei bleibt der
reproduzierbare Entwicklungsstart;
`supabase/imports/usda_foundation.sql` und `supabase/imports/usda_fndds.sql`
werden separat in Supabase importiert.
