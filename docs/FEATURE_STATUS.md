# Funktionsstatus

Stand: lokaler Dark-UI-Prototyp. Diese Datei trennt sichtbar funktionierende
Frontend-Flows von Funktionen, die externe Systeme oder weitere lokale Arbeit
benötigen.

## Wichtige Einschränkung

Alle veränderbaren Daten liegen derzeit ausschließlich im Arbeitsspeicher.
Mahlzeiten, Wasser, Favoriten, Einkaufsstatus und Profiländerungen bleiben beim
Navigieren erhalten, werden aber beim Neustart der App zurückgesetzt. Es gibt
keine Anmeldung, dauerhafte Speicherung oder Übertragung an externe Anbieter.

## Lokal funktionsfähig

| Bereich | Aktueller Umfang |
| --- | --- |
| Dark UI | Einheitlicher dunkler Hintergrund, abgestufte Oberflächen, helle Typografie und semantische Akzentfarben |
| Responsive Navigation | Fünf Bereiche per Bottom Navigation und FAB auf Mobilgeräten sowie Seitenleiste ab Desktopbreite |
| Seitenzustand | Gemeinsamer `AppController` aktualisiert abhängige Ansichten während der laufenden Sitzung |
| Heute | Persönliche Begrüßung, animierte Kalorien-/Makrowerte, Mahlzeitenübersicht, Wasseraktion und direkte Navigation |
| Mahlzeit hinzufügen | Lokale Textsuche in fünf Demo-Gerichten; Auswahl fügt eine Mahlzeit hinzu und berechnet Kalorien/Makros neu |
| Tagebuch | Tagesansicht, Bilanz, Mahlzeitenliste, Entfernen per Wischgeste sowie Wasser erhöhen und verringern |
| Rezepte | Suche nach Titel, Kategorienfilter, Favoriten, drei lokale Rezepte mit Bildern und Hero-Detailansicht |
| Einkaufsliste | Lokales Bottom Sheet mit Demo-Artikeln, Hinzufügen, Abhaken und Löschen per Wischgeste |
| Fortschritt | Animierter Gewichtsgraph mit Zielmarke; sieben Punkte sind antippbar und ändern den angezeigten Wert |
| Weitere Diagramme | Animierte Wochenbalken für Kalorien und Protein sowie lokale Statistik- und Meilensteinkarten |
| Profil | Profilansicht mit lokalem Avatar; Name, Ziel, Kalorienziel und Zielgewicht lassen sich bearbeiten |
| Ernährungsprofil | Stil, Allergien und Aktivitätsniveau lassen sich lokal bearbeiten |
| Planung & Vorräte | Wochenplan, Einkaufsliste und Vorräte lassen sich lokal pflegen |
| Einstellungen | Premium-Vorschau, Erinnerungs-Schalter, Datenübersicht, Löschdialog und Sicherheitshinweise |
| Animationen | Seitenwechsel, gestaffelte Reveals, Press-Feedback, Ringe, Zahlen, Balken, Favoriten und Coach-Orb |
| Bilder | Drei lokale Food-WebPs und ein lokales Profil-WebP; keine Bilder werden zur Laufzeit aus dem Internet geladen |

## Lokal vorbereitet oder nur teilweise funktionsfähig

| Bereich | Was bereits sichtbar ist | Was noch fehlt |
| --- | --- | --- |
| Tagesauswahl | Sieben auswählbare Tage | Eigene Mahlzeiten und Summen je Datum; echte Kalenderdaten |
| Mahlzeitenerfassung | Demo-Suche und schnelles Hinzufügen | Freier Eintrag, Mengen, Bearbeiten, eigene Lebensmittel und Validierung |
| Rezeptdetails | Bild, Kennzahlen, Zutaten- und Zubereitungsansicht; Rezept kann ins Tagebuch übernommen werden | Rezeptspezifische Zutaten/Zubereitung und Portionseditor |
| Tagesplan | Sieben Tage, Rezepte auswählen und freilassen | Verschieben per Drag & Drop und Summen pro Tag |
| Vorräte | Zutaten hinzufügen und entfernen | Mengen, Ablaufdaten und lokaler Rezeptabgleich |
| Fortschrittszeiträume | Auswahl für 4 Wochen, 3 Monate und 1 Jahr | Je Zeitraum unterschiedliche Daten und Achsen |
| Profilbild | Lokaler Avatar und Kameraindikator | Bildauswahl, Zuschneiden, Berechtigungen und Speicherung |
| Ernährungsprofil | Ernährungsstil, Allergien, Aktivität und Mahlzeitenrhythmus sichtbar und editierbar | Nutzung in personalisierten Berechnungen |
| Einstellungen | Premium, Erinnerungen, Datenschutz und Hilfe mit lokalen Sheets | Store-Abrechnung, echter Export und Supportkanal |
| Benachrichtigungen | Symbol öffnet lokale Erinnerungsschalter | Betriebssystem-Berechtigung und geplante Benachrichtigungen |
| Reduced Motion | Navigation, Reveal und Press-Feedback beachten die Systemeinstellung | Diagramm-, Ring-, Balken- und Coach-Animationen vollständig anpassen |
| KI-Coach | Dark-UI, Beispielchat, Sicherheitsnotiz und Eingabefeld | Echte Nachrichten, Kontext, Sicherheitslogik und KI-Antworten |

## Benötigt später Backend, Datenbank oder externe Dienste

| Funktion | Benötigte Grundlage |
| --- | --- |
| Dauerhafte Speicherung | Lokale Datenbank und bei Bedarf verschlüsselte Synchronisation |
| Benutzerkonto | Authentifizierung, Backend, Session- und Löschkonzept |
| Verlässliche Lebensmittelsuche | Lizenzierte Nährwertdatenbank/API, Portions- und Einheitenmodell |
| Barcode-Scanner | Kamera-Berechtigung, Scanner und Produktdatenquelle |
| KI-Texterfassung | Serverseitige KI-Anbindung, strukturierte Ausgabe, Bestätigung und Kostenlimits |
| KI-Coach | Backend-Kontext, Sicherheitsfilter, Richtlinien, Monitoring und Nutzungsgrenzen |
| Mahlzeitenfoto | Kamera/Bildauswahl, serverseitige Bildanalyse und klare Schätzungskennzeichnung |
| Abonnement | Apple-/Google-In-App-Käufe, Berechtigungsprüfung und Restore-Ablauf |
| Datenexport und Kontolöschung | Persistenter Datenspeicher, Identitätsprüfung und Backend-Prozesse |
| Push-Benachrichtigungen | Berechtigungen und gegebenenfalls Push-Dienst; lokale Erinnerungen können vorher umgesetzt werden |
| HealthKit/Health Connect | Plattformberechtigungen, Datentrennung und Datenschutzprüfung |
| Analytics/Crash-Reporting | Datensparsame Konfiguration ohne unzulässige Gesundheitsprofile |

## Noch nicht vorhanden

- Onboarding und Altersprüfung
- echte Konten oder mehrere Profile
- dauerhafte lokale oder Cloud-Speicherung
- freie manuelle Mahlzeitenerstellung und Bearbeiten
- portionsgenaue Tages-/Wochenberechnung und Rezepteditor
- echte KI-, Kamera- oder Barcodefunktion
- Premium-Paywall und Abonnementverwaltung
- vollständige Datenschutz-, Export-, Lösch-, Hilfe- und Support-Flows
- HealthKit, Health Connect und Spracheingabe

## Definitionen

- **Lokal funktionsfähig:** Die Interaktion verändert während der laufenden
  Sitzung echten App-State; dafür wird kein externer Dienst benötigt.
- **Teilweise funktionsfähig:** Die Oberfläche oder ein Teilablauf arbeitet,
  aber sichtbare Schritte nutzen noch Demo-Daten oder Platzhalter.
- **Später extern:** Für den verlässlichen Produktbetrieb werden Backend,
  Persistenz, eine lizenzierte Datenquelle, Plattformdienste oder KI benötigt.
