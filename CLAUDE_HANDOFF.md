# LIVO – Übergabe für Claude

## Projekt

LIVO ist eine eigenständige Flutter-App für Ernährung und Fitness. Das
Quran-Projekt ist ein anderes Projekt und darf nicht verändert oder mit LIVO
zusammengeführt werden.

Arbeite immer im Repository `fitness_ai_app`. Vor Änderungen zuerst den
aktuellen Code lesen und danach die Tests ausführen. Keine geheimen Schlüssel,
Passwörter oder `.env`-Dateien in Antworten, Commits oder Uploads anzeigen.

## Verbindliche Halal-Inhaltsregel

Schweinefleisch, Alkohol, Gelatine und andere klar nicht erlaubte Inhalte
dürfen weder als Lebensmittel, Rezept, Barcode-Ergebnis, Demo-Inhalt noch als
KI-Empfehlung in LIVO erscheinen. Fleisch von Landtieren ist nur erlaubt,
wenn die Daten ausdrücklich eine Halal-Kennzeichnung enthalten. Bei unklaren
Zutaten nicht raten, sondern den Eintrag blockieren oder auf die Verpackung
verweisen. Diese Regel nie entfernen oder abschwächen; Details:
`docs/HALAL_CONTENT_POLICY.md`.

## Technischer Stand

- Flutter/Dart-App für Android, iOS, Web und Desktop
- dunkles, responsives LIVO-Design
- fünfseitige Einführung und Authentifizierung über Supabase
- sechsstufige Personalisierung: Name, Ziel, Geburtstag, Größe, Gewicht und Alltag
- Geburtstag und Größe sind getrennte Seiten
- Datum- und Größenpicker sind direkt vertikal wischbar
- Gewicht wird über ein großes, horizontal ziehbares Lineal gewählt
- Profil mit lokalem Profilbild und Ernährungseinstellungen
- Tagebuch für Frühstück, Mittagessen, Abendessen und Snacks
- Kalorien-/Makroübersicht, Tracking-Serie und Flammenanimation
- eigene Lebensmittel mit vollständigen Nährwertfeldern
- Suche, Rezepte, Favoriten und Fortschrittsansicht
- Barcode-Scanner mit Open-Food-Facts-Daten
- geschützte Supabase Edge Function für Barcode-Abfragen

## Wichtige Ordner und Dateien

- `lib/features/onboarding/presentation/personalization_page.dart` –
  Personalisierungsseiten und Picker
- `lib/features/onboarding/domain/personalization_profile.dart` – Profildaten
- `lib/features/diary/` – Tagebuch, Lebensmittel und Barcode-Scanner
- `lib/features/profile/` – Profil, Einstellungen und lokales Avatarbild
- `lib/features/progress/` – Fortschrittsansicht
- `lib/features/coach/` – KI-/Coach-Bereich
- `lib/features/navigation/` – Hauptnavigation
- `supabase/migrations/` – Datenbankmigrationen
- `supabase/functions/` – Edge Functions
- `docs/BARCODE_LOOKUP.md` – Barcode-Konfiguration
- `docs/CATALOG_DATA_SOURCES.md` – Datenquellen und Lizenzen

## Starten und prüfen

```powershell
flutter pub get
flutter run -d chrome
flutter test
```

Vor jeder größeren Änderung zuerst `flutter test` ausführen und nach der
Änderung erneut. Bestehende Funktionalität und das dunkle LIVO-Design erhalten;
Änderungen klein und nachvollziehbar umsetzen.

## Nächste sinnvolle Aufgaben

1. Onboarding auf echtem Handy mit Wischen testen.
2. Tagebuch und tägliche Datumsgrenze prüfen.
3. Supabase-Datenzugriff und Offline-/Fehlerzustände verbessern.
4. KI-Coach ausschließlich auf Ernährung, Fitness und App-Daten begrenzen.
5. Fotoanalyse erst hinter einer sicheren Edge Function mit Rate-Limit ergänzen.

## Übergabe-Regel

Claude soll vor dem Bearbeiten kurz nennen, welche Dateien geändert werden,
keine Quran-Dateien anfassen und nach jeder Änderung die betroffenen Tests
ausführen. Nicht einfach alles neu schreiben; vorhandene Architektur und
Benutzerdaten schützen.
