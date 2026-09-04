# Produktplan

## Vision

LIVO soll für gesunde Erwachsene der zentrale, leicht verständliche Begleiter
für Essen, Diätziele und alltägliche Planung werden. Nutzer sollen Mahlzeiten,
Nährwerte, Wasser, Rezepte, Einkauf, Ziele und Fortschritt in einer ruhigen App
finden, ohne mehrere Tracker und Notizen parallel zu benötigen.

Die App bleibt eine Lifestyle-Anwendung. Sie ersetzt keine medizinische,
psychologische oder qualifizierte Ernährungsberatung.

## Produktprinzipien

- einfach genug für die tägliche Nutzung, aber nicht leer
- dark-first, hochwertig, kontrastreich und ohne visuelle Überladung
- wichtige Tageswerte auf einen Blick, Details erst bei Bedarf
- schnelle, nachvollziehbare Eingaben statt langer Formulare
- echte Berechnungen aus strukturierten Daten; KI formuliert oder interpretiert,
  erfindet aber keine Nährwerte
- lokal nutzbare Oberfläche mit klarer Trennung zu späteren Cloud-Diensten
- sichere Grenzen vor Funktionsumfang

## Aktuelle Designrichtung

- Material-3-basierte Dark UI mit fast schwarzem Hintergrund
- abgestufte dunkle Oberflächen und helle Typografie
- Limettengrün als primärer Akzent; weitere Farben nur semantisch für Diagramme
- lokale Food-Fotografie und persönliches Profilbild
- responsive Bottom Navigation auf Mobilgeräten und Seitenleiste auf Desktop
- sanfte Seitenwechsel, gestaffeltes Einblenden, Press-Feedback, animierte
  Zahlen, Ringe, Balken und Diagrammpfade
- Unterstützung für reduzierte Bewegung wird schrittweise für alle Animationen
  vervollständigt

## Produktbereiche

### Heute

Persönliche Begrüßung, Profilzugang, Kalorien- und Makroübersicht,
Schnellaktionen, heutige Mahlzeiten, Wochenstatus und Einstieg zum späteren
KI-Coach.

### Tagebuch

Tagesauswahl, Tagesbilanz, Mahlzeiten, Wasser und ein schneller Dialog zum
Hinzufügen. Aktuell arbeitet dieser Bereich mit einer kleinen lokalen
Demo-Auswahl; später kommen manuelle Eingabe, echte Suche, Barcode und
KI-unterstützte Erfassung hinzu.

### Rezepte und Planung

Suche, Kategorien, Favoriten, bebilderte Rezeptkarten, Detailansicht und
Einkaufsliste. Ein vollständiger Wochenplan, individuelle Zutaten und Vorräte
werden als lokale Flows ergänzt, bevor eine KI personalisierte Pläne erstellt.

### Fortschritt

Animierter Gewichtsverlauf mit Zielmarke und auswählbaren Punkten,
Ernährungsbalken, Serien, Wasserstatus und Meilensteine. Zeiträume und Werte
werden derzeit mit Demo-Daten dargestellt und später an echte Verlaufsdaten
gebunden.

### Profil

Profilbild, Name, persönliches Ziel, Zielgewicht, Kalorien- und Proteinziel,
Ernährungsprofil sowie vorbereitete Einstellungen für Premium, Erinnerungen,
Datenschutz und Hilfe.

### KI-Coach

Die Oberfläche und ein Beispielgespräch zeigen die spätere Nutzererfahrung.
Die Eingabe bleibt deaktiviert, bis Backend, Sicherheitsregeln, Kostenlimits und
Datenschutzprüfung umgesetzt sind.

Der verbindliche Ist-Stand steht in [FEATURE_STATUS.md](FEATURE_STATUS.md).

## Umsetzungsphasen

### Phase 1 – Lokales Produkt vollständig machen

- Onboarding für Alterseignung, Ziel, Aktivität und Ernährungsvorlieben
- freie manuelle Mahlzeiteneingabe und Bearbeiten vorhandener Einträge
- echte Tages- und Datumsauswahl mit getrennten lokalen Tagesdaten
- lokale Wochenplanung und Vorratsverwaltung
- Profilbildauswahl sowie bearbeitbare Vorlieben, Allergien und Aktivität
- lokale Erinnerungseinstellungen ohne Cloud-Abhängigkeit
- vollständige Reduced-Motion-, Semantics- und Textskalierungsprüfung
- responsive Widget-, Interaktions- und Golden-Tests

Abnahmekriterium: Alle sichtbaren Kernaktionen funktionieren mit lokalen
Demo-Daten; nur externe Datenquellen, Konto, KI und Bezahlung fehlen.

### Phase 2 – Verlässliche Daten und Konto

- geeignete Lebensmitteldatenbank auswählen und Lizenz/Nutzungsbedingungen
  prüfen
- lokales persistentes Datenmodell und Migrationen
- Authentifizierung und Backend nur für notwendige Synchronisation
- Nutzerkonto, Gerätewechsel, Datenexport und vollständige Kontolöschung
- Datenschutztexte, ausdrückliche Einwilligungen und Verträge mit Anbietern
- Fehler-, Offline- und Ladezustände sowie Monitoring ohne Gesundheitsdaten in
  Werbe- oder Analyseprofilen

### Phase 3 – Sicher begrenzte KI

- Texteingaben serverseitig in strukturierte Lebensmittelvorschläge zerlegen
- Werte immer aus der Lebensmitteldatenbank beziehen und bestätigen lassen
- Coach mit Tageskontext, klaren Lifestyle-Grenzen und festen Antwortlimits
- Risikoerkennung für Essstörungen, extreme Ziele, Erkrankungen und andere
  ausgeschlossene Situationen
- Prompt-/Modellversionen, Sicherheitsfälle, Kostenlimits und Missbrauchsschutz
- Fotoanalyse erst später als ausdrücklich gekennzeichnete Schätzung

### Phase 4 – Premium und Veröffentlichung

- Monats- und Jahresabo mit sauberem Restore-/Kündigungsablauf
- Premium-Grenzen, Paywall und serverseitige Berechtigungsprüfung
- optionale Benachrichtigungen
- Store-Metadaten, Icons, Screenshots, Support und rechtliche Prüfung
- Crash-Reporting und datensparsame Produktanalyse
- später optional HealthKit, Health Connect und Spracheingabe

## Sicherheitsgrenzen

- Start nur für Erwachsene; Altersprüfung im Onboarding
- kein Medizinprodukt und keine Diagnose oder Behandlung
- keine automatischen Pläne bei Schwangerschaft, Essstörungen oder relevanten
  Erkrankungen ohne qualifizierte Begleitung
- keine Medikamenten- oder Supplementdosierung
- keine garantierten Ergebnisse oder extrem niedrigen Kalorienziele
- nachvollziehbare Quellen und normale Programmlogik für Berechnungen
- KI-Ausgaben und Fotoerkennung als fehlbare Vorschläge kennzeichnen
- Nutzer müssen vorgeschlagene Lebensmittel, Mengen und Nährwerte prüfen können

## Noch zu entscheiden

- endgültiger Name, Logo und Markenprüfung
- engste Startzielgruppe und stärkstes Alleinstellungsmerkmal
- Lebensmittel-Datenquelle und deren kommerzielle Lizenz
- lokale Persistenz, Backend-Standort und Aufbewahrungsfristen
- KI-Anbieter und Datenverarbeitung vor Übertragung echter Nutzerdaten
- Preis, kostenlose Grenzen und Inhalt des Premium-Abos
- konkrete juristische Prüfung und passende Haftpflichtversicherung
