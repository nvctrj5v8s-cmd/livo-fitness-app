# Halal-Inhaltsregel für LIVO

## Verbindliche Produktregel

LIVO darf keine bekannten Inhalte mit Schweinefleisch, Alkohol oder Gelatine
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
