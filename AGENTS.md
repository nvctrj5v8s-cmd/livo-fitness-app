# Projektregeln

## Projektgrenze

- Dieses Projekt bleibt vollständig von `C:\Users\moham\quran app` getrennt.
- `build/`, `.dart_tool/` und andere generierte Ausgaben werden nicht manuell
  bearbeitet.
- Bestehende Nutzeränderungen und nicht zum Auftrag gehörende Dateien werden
  nicht überschrieben.
- `LIVO` ist ein visueller Arbeitsname, keine abschließend geprüfte Marke.

## Architektur und Daten

- UI, Fachlogik, lokaler Zustand, Datenzugriff und externe Dienste getrennt
  halten.
- Neue Ernährungswerte werden als numerische, typisierte Daten modelliert und
  erst in der UI formatiert.
- Der aktuelle `AppController` ist nur ein In-Memory-Demo-State. Lokale
  Änderungen dürfen nicht als dauerhaft gespeichert dargestellt werden.
- Externe Anbieter werden später über austauschbare Repository-/Service-Grenzen
  angebunden. Widgets rufen keine Anbieter-API direkt auf.
- Keine API-Schlüssel, Tokens oder sonstigen Geheimnisse in Flutter-Code,
  Assets, Logs oder Git. KI-Anfragen müssen später über ein kontrolliertes
  Backend laufen.

## Datenschutz und Gesundheit

- Gesundheits- und Ernährungsdaten nur nach dokumentierter Datenschutzprüfung
  und mit passender Rechtsgrundlage an externe Dienste übertragen.
- Änderungen an Speicherung, Tracking, APIs, Berechtigungen, Kamera,
  Benachrichtigungen oder Zahlungen müssen im Funktionsstatus und in den
  Datenschutzunterlagen dokumentiert werden.
- Datenminimierung, Export, Löschung, Einwilligungswiderruf und sichere
  Übertragung vor Verarbeitung echter Nutzerdaten einplanen.
- Keine Diagnose, Behandlung, Medikamenten- oder Supplementdosierung,
  Heilversprechen oder Förderung extremer Diäten implementieren.
- Für Minderjährige, Schwangerschaft, Essstörungen und relevante Erkrankungen
  keine automatischen Diätpläne erzeugen; stattdessen auf qualifizierte Hilfe
  verweisen.
- KI- und Fotowerte sind Schätzungen, müssen so bezeichnet werden und vor dem
  Speichern korrigierbar beziehungsweise bestätigungspflichtig sein.

## Dark UI, Bilder und Animation

- Die App bleibt dark-first: fast schwarzer Hintergrund, klar getrennte dunkle
  Flächen und helle, gut lesbare Typografie.
- Farben semantisch aus Theme beziehungsweise `AppColors` beziehen. Auf dunklen
  Flächen keine dunkle Schrift und auf hellen Akzentflächen keine unlesbare
  helle Schrift verwenden.
- Mindestens 4,5:1 Kontrast für normalen Text und ausreichend große
  Bedienflächen anstreben. Status nie ausschließlich über Farbe vermitteln.
- Animationen unterstützen die Orientierung und Interaktion; unnötige
  Dauerbewegung vermeiden. `MediaQuery.disableAnimations` respektieren und
  Animationen außerhalb des sichtbaren Screens pausieren.
- Bilder lokal, komprimiert und mit stabilem Fallback einbinden. Für fremde
  Assets Quelle und Nutzungsrecht dokumentieren; keine ungeklärten Bilder aus
  dem Internet übernehmen.

## Verbindlicher aktueller Stand

- Welche Funktionen tatsächlich lokal arbeiten und welche nur vorbereitet
  sind, wird in `docs/FEATURE_STATUS.md` gepflegt.
- Demo-Inhalte sind klar als Demo zu behandeln. In-Memory-Änderungen werden beim
  Neustart verworfen und aktuell nicht übertragen.
- Backend, Konto, dauerhafte Datenbank, echte Lebensmitteldaten, KI, Kamera,
  Barcode, Abonnement und Health-Integrationen sind noch nicht verbunden.
- Vor Abschluss einer Änderung mindestens `flutter analyze` und die passenden
  Flutter-Tests ausführen; wichtige responsive und interaktive Flows abdecken.
