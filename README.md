# LIVO – Ernährung & Fitness

LIVO ist ein eigenständiger Flutter-Prototyp für Ernährung, Mahlzeitenplanung
und persönliche Fitnessziele. Die aktuelle Version setzt auf eine ruhige,
kontrastreiche Dark UI, lokale Demo-Daten, echte Frontend-Interaktionen und
flüssige Animationen. Sie ist vollständig von der Quran-App getrennt.

## Was bereits enthalten ist

- responsive Navigation für Smartphone, Tablet, Web und Desktop
- fünf Hauptbereiche: Heute, Tagebuch, Rezepte, Fortschritt und Profil
- persönliches Dashboard mit Kalorien, Makros, Wasser und Mahlzeiten
- lokale Mahlzeitensuche mit Hinzufügen und Entfernen von Demo-Einträgen
- Rezeptsuche, Kategorien, Favoriten und animierte Detailseiten
- interaktive Einkaufsliste mit lokalem Status
- animierte Gewichts- und Ernährungsdiagramme mit Demo-Werten
- bearbeitbares Demo-Profil mit Name, Ziel, Kalorienziel und Zielgewicht
- lokal eingebundene Food-Bilder und ein Profilbild
- vorbereitete, aber bewusst noch nicht verbundene KI-Coach-Oberfläche

Alle Änderungen werden aktuell nur im Arbeitsspeicher gehalten und beim
Neustart zurückgesetzt. Es gibt noch keine Datenbank, Anmeldung, KI-API,
Zahlungen oder Übertragung persönlicher Daten. Der genaue Stand jeder Funktion
steht in [docs/FEATURE_STATUS.md](docs/FEATURE_STATUS.md).

## Starten

```powershell
cd "C:\Users\moham\fitness_ai_app"
flutter pub get
flutter run
```

Für den Browser kann beispielsweise Folgendes verwendet werden:

```powershell
flutter run -d chrome
```

## Technischer Aufbau

- `lib/core/models/`: typisierte lokale Modelle
- `lib/core/state/`: gemeinsamer In-Memory-Demo-State
- `lib/core/theme/`: Dark-Theme, Farben und Komponentenstile
- `lib/features/`: getrennte Produktbereiche
- `lib/shared/widgets/`: wiederverwendbare UI- und Motion-Komponenten
- `assets/images/`: lokal gebündelte und optimierte Bildmotive
- `docs/`: Produktplan und verbindlicher Funktionsstatus

Das UI basiert derzeit nur auf Flutter und Material 3. Externe Dienste werden
später hinter klaren Daten- und Serviceschnittstellen ergänzt; geheime Schlüssel
gehören niemals in den Flutter-Client.

## Produkt- und Sicherheitsrahmen

LIVO ist als Lifestyle-App für gesunde Erwachsene geplant. Die App darf keine
Diagnosen, Krankheitsbehandlungen, Medikamentenempfehlungen, Heilversprechen
oder extremen Diätpläne anbieten. Nährwerte aus späteren Foto- oder KI-Funktionen
müssen als Schätzung gekennzeichnet und vom Nutzer bestätigt werden.

`LIVO` ist weiterhin ein Arbeitsname und noch keine abschließend geprüfte Marke.
Die weitere Reihenfolge steht in [docs/PRODUCT_PLAN.md](docs/PRODUCT_PLAN.md).
