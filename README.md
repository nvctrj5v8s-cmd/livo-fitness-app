# LIVO – Ernährungs- und Fitness-App

LIVO ist eine eigenständige Flutter-App für Ernährung, Tagebuch, Rezepte,
Fortschritt und persönliche Ziele. Die Quran-App ist ein getrenntes Projekt.

## Aktueller Stand

- dunkle, responsive Oberfläche für Smartphone, Tablet und Web
- fünfseitige Einführung und Anmeldung mit Supabase
- persönliches Profil mit lokalem Profilbild
- Tagebuch für Frühstück, Mittagessen, Abendessen und Snacks
- Kalorien- und Makroübersicht, Tracking-Serie und Flammen-Animation
- eigener Eintrag für Lebensmittel mit Nährwerten
- Suche, Rezeptdetails, Favoriten und Fortschritt
- Barcode-Scanner mit Open-Food-Facts-Produktdaten
- Supabase Edge Function für geschützte Barcode-Abfragen

Die Barcode-Verbindung benötigt die einmaligen Supabase-Schritte aus
`docs/BARCODE_LOOKUP.md`. Geheime Schlüssel gehören nicht in die Flutter-App.

## Halal-Inhaltsregel

LIVO zeigt und speichert keine bekannten Schweinefleisch-, Alkohol- oder
Gelatine-Inhalte. Fleisch von Landtieren wird nur zugelassen, wenn die
Produktdaten eine eindeutige Halal-Kennzeichnung enthalten. Diese technische
Sperre ist keine religiöse Zertifizierung: Bei unklaren Zutaten oder
Zertifizierungen bitte immer die Verpackung prüfen. Details stehen in
`docs/HALAL_CONTENT_POLICY.md`.

## Lokal starten

```powershell
flutter pub get
flutter run -d chrome
```

## Web-Version

Der GitHub-Pages-Workflow baut die Flutter-Web-App automatisch bei Pushes auf
`master`. Die fertige URL wird nach dem ersten erfolgreichen Lauf unter
Repository → **Settings → Pages** angezeigt.

## Datenquellen

Barcode-Produktdaten kommen aus Open Food Facts und werden mit sichtbarer
Quellen- und Lizenzangabe zwischengespeichert. Details stehen in
`docs/BARCODE_LOOKUP.md` und `docs/CATALOG_DATA_SOURCES.md`.
