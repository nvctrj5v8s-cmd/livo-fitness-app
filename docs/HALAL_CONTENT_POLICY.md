# Halal-Inhaltsregel für Lookin

## Verbindliche Produktregel

Lookin darf keine bekannten Inhalte mit Schweinefleisch, Alkohol oder Gelatine
anzeigen, empfehlen, als Rezept aufnehmen oder per Barcode in das Tagebuch
übernehmen. Fleisch von Landtieren wird nur akzeptiert, wenn die vorliegenden
Produktdaten es eindeutig als halal kennzeichnen. Fisch sowie vegetarische und
vegane Lebensmittel bleiben möglich.

## Technische Durchsetzung

- Die Flutter-App filtert den Katalog und verhindert Speichern über Suche,
  Barcode, Selbsteintrag, Duplizieren und Rezepte.
- Die Barcode-Edge-Function prüft Produktname, Marke, Zutaten und Labels vor
  dem Zwischenspeichern.
- Die KI darf keine ausgeschlossenen Lebensmittel empfehlen oder bewerten.
- Migration `0007_halal_content_guard.sql` versteckt ältere ausgeschlossene
  Katalogeinträge per RLS und blockiert neue Einträge bei Importen.
- Migration `0009_recipe_details.sql` prüft zusätzlich Schritt-Titel,
  Utensilien, Zutatennotizen und alle Premium-Extras (Tipps, Fehler, Austausch,
  Meal-Prep, Varianten, Serviervorschlag). Sie behebt außerdem einen Fehlalarm:
  „Beeren“ wurde vorher als „beer“ (Bier) blockiert.
- `tool/generate_recipe_sql.dart` prüft neue Rezeptinhalte vor dem Import mit
  derselben Regel und bricht ab, statt Zeilen still zu überspringen.
- Migration `0014_halal_terms_extended.sql` (27. September 2026) erweitert die
  Begriffslisten deutlich: Cocktails und Spirituosen (z. B. Daiquiri,
  Margarita, Martini, Tequila, Scotch, Bourbon, Sangria, Eggnog, Glühwein,
  Eierlikör), Schweine- und Wurstprodukte (z. B. Bologna, Bratwurst, Chorizo,
  Spam, Mortadella, Pancetta, Schinken, Schmalz, Leberwurst, Hot Dog),
  Fleischgerichte und Innereien (z. B. Hamburger, Cheeseburger, Steak, Ribs,
  Zunge, Kutteln, Leber, Kaninchen, Wachtel, Fasan, Gans, Bison, Frikadellen,
  Gyros, Döner) sowie Süßwaren, die meist Gelatine enthalten (Gummibärchen,
  Fruchtgummi, Marshmallows, Jelly Beans, Aspik, Panna cotta).
- Dieselben Listen stehen in `lib/core/data/halal_content_policy.dart`, in
  der Migration 0014 und in `supabase/functions/barcode-lookup/index.ts`. Ein
  Test (`test/halal_content_policy_test.dart`) prüft, dass alle drei gleich
  sind.

## Wie die Wortsuche funktioniert

- Text wird kleingeschrieben, Umlaute werden ersetzt (ä → ae, ö → oe,
  ü → ue, ß → ss), alle anderen Zeichen werden zu Leerzeichen.
- Harmlose Ausdrücke werden zuerst entfernt, z. B. „blood orange“,
  „goat cheese“, „hamburger bun“, „quail egg“, „cod liver“, „steak sauce“,
  „Fruchtfleisch“, „Butterschmalz“, „meatless“.
- Begriffe gelten nur als ganzes Wort: „gin“ sperrt nicht „ginger“, „rum“
  nicht „drum“ oder „serum“. Mehrwortbegriffe („bloody mary“, „hot dog“)
  müssen genau so vorkommen.
- Einige Wortstämme gelten auch am Wortanfang („Schweinefleisch“,
  „Gummibärchen“, „Tequila-Sunrise“) und einige deutsche Endungen auch am
  Wortende („Leberwurst“, „Hackfleisch“, „Rumpsteak“, „Eierlikör“).
- Im Zweifel wird gesperrt. Dadurch werden auch einige eigentlich harmlose
  Einträge blockiert, etwa „Hot dog, vegetarian“ oder „Margarita mix,
  nonalcoholic“. Das ist gewollt, bis eine geprüfte Ausnahme ergänzt wird.
- Bekannte Grauzonen ohne eindeutiges Wort bleiben erlaubt, zum Beispiel
  „Gravy, NFS“, „Burrito, NFS“ oder „Enchilada, NFS“. Hier müssen Nutzer die
  Zutaten selbst prüfen.

## Wichtige Grenze

Die Regel ist ein vorsichtiger technischer Filter, keine Halal-Zertifizierung.
Externe Datenquellen können unvollständige Zutaten oder fehlende Labels haben.
Bei unklaren Produkten müssen Nutzer die Verpackung und eine gegebenenfalls
vorhandene Halal-Zertifizierung selbst prüfen. Die App darf ein Produkt nicht
als halal zertifiziert bezeichnen, wenn diese Information nicht vorliegt.

## Pflege

Bei neuen Katalogen, Rezepten, Bildern, KI-Prompts oder Datenquellen muss die
Regel vor dem Import geprüft werden. Die Regel steht zusätzlich in `README.md`,
`AGENTS.md` und `CLAUDE_HANDOFF.md`, damit menschliche und KI-Mitwirkende sie
nicht übersehen.
