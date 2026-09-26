# Funktionsstatus

## Aktualisierung: Halal-Inhaltsregel, 26. September 2026

- Schweinefleisch, Alkohol, Gelatine und nicht eindeutig halal gekennzeichnetes
  Fleisch von Landtieren werden im Flutter-Katalog, bei Rezepten, Barcode-
  Ergebnissen, Selbsteinträgen und KI-Antworten blockiert.
- Die Supabase-Migration `0007_halal_content_guard.sql` muss noch im SQL Editor
  ausgeführt werden. Sie blendet ältere ausgeschlossene Katalogdaten per RLS
  aus und verhindert neue ausgeschlossene Katalogeinträge.
- Die technische Regel ist bewusst vorsichtig, aber keine religiöse
  Zertifizierung: Unklare Produkte müssen weiterhin anhand von Verpackung und
  Zertifizierung geprüft werden. Details: `HALAL_CONTENT_POLICY.md`.

## Aktualisierung: Neues Tagebuch, eigene Lebensmittel und Serie, 17. September 2026

- Die ruhige Tagebuchansicht ist jetzt die Startseite. Kalorien und Makros
  stehen vor vier klaren Bereichen für Frühstück, Mittagessen, Abendessen und
  Snacks; Wochenkarte, Schnellaktionen und mobiler Floating-Button wurden dort
  entfernt.
- Die Navigation enthält `Tagebuch`, `KI`, ein zentrales Plus, `Rezepte` und
  `Profil`. `Fortschritt` ist nicht mehr in der Navigation. Das Plus öffnet
  drei Wege: `KI-Foto` (Foto wird oben angezeigt, erkannte Lebensmittel sind
  als Schätzung markiert und vor dem Speichern in Name, Gramm und Nährwerten
  bearbeitbar, weitere Lebensmittel per Suche oder manuell ergänzbar,
  Mahlzeit wählbar), `Barcode scannen` und `Manuell eintragen` (Suche oder
  eigenes Lebensmittel). Die Mahlzeit wird nach Tageszeit vorausgewählt.
- KI-Foto-Kamera: Auf Android/iOS öffnet sich die System-Kamera
  (`image_picker`). Im Browser und auf Desktop öffnet LIVO eine eigene
  Live-Kamera (`camera`-Paket) mit Auslöser und Kamerawechsel; der Browser
  fragt dafür nach der Kamera-Berechtigung (nur über HTTPS oder localhost).
  „Aus Galerie wählen“ ist überall als getrennte Option vorhanden. Fotos
  werden nur im Speicher verarbeitet und nicht lokal abgelegt.
- Die Live-Kamera füllt den ganzen Bildschirm; das aufgenommene Foto wird auf
  der Ergebnisseite randlos und groß angezeigt.
- KI-Foto-Ergebnis: Mahlzeit per Chip wählbar, Gesamtwerte oben, jedes
  erkannte Lebensmittel mit Erkennungssicherheit („Gut erkannt“, „Bitte kurz
  prüfen“, „Unsicher“), Mengen-Stepper (±10 g oder direkte Eingabe) mit
  automatischer Umrechnung von kcal und Makros sowie aufklappbarer
  Bearbeitung von Name und Nährwerten. Lebensmittel lassen sich per Suche
  oder manuell ergänzen und entfernen. Schlägt das Speichern mittendrin fehl,
  werden bereits gespeicherte Einträge aus der Liste genommen, damit ein
  erneuter Versuch keine Duplikate erzeugt.
- Die Edge Function `ai-coach` unterstützt `action: meal_photo` (deployt als
  Version 5 am 2026-09-26). Fotos werden zur Analyse an OpenAI übertragen,
  nicht gespeichert, und zählen zum täglichen KI-Limit.
- Das Profil zeigt zentriert Profilbild, Name und Ziel, darunter echte
  Tageswerte (Einträge heute, Tage Serie, kcal heute). Der frühere Ziel-Ring
  mit festem Demo-Startgewicht wurde entfernt.
- „Meine täglichen Ziele“ (Kalorien, Protein, Fett) werden lokal als
  Richtwert aus Alter, Größe, Gewicht, Alltag und Ziel berechnet
  (Mifflin-St-Jeor mit geschlechtsneutraler Konstante, Abnehmen maximal
  15 % unter Erhalt und nie unter dem Grundumsatz). Fehlen Angaben, bleiben
  die Felder leer und ein Hinweis erklärt, dass die Fragen freiwillig sind.
  Für Personen unter 18 Jahren werden keine Ziele berechnet; stattdessen wird
  auf qualifizierte Beratung verwiesen. Berechnete Ziele gelten auch im
  Tagebuch; der manuelle Kalorienregler wird dann ausgeblendet.
- Jede Mahlzeitenkarte öffnet die Suche mit der passenden Kategorie. Eigene
  Lebensmittel akzeptieren Etikettwerte pro 100 g, 100 ml oder Portion,
  rechnen die gegessene Menge ohne Zwischenrundung und speichern die Werte im
  bestehenden Supabase-Tagebuch. Frühere einfache eigene Einträge bleiben
  lesbar und bearbeitbar.
- Die Tracking-Serie wird aus wirklich gespeicherten Kalendertagen berechnet.
  Ein neuer heutiger Tag zeigt einmalig eine große, endliche
  Flammen-Animation; leere Mahlzeiten zählen nicht. Der lokale
  Schon-gezeigt-Marker enthält nur Konto-ID und Datum.
- Das Profil zeigt die echte Serie statt erfundener Levelwerte. Profilbilder
  können als JPG/PNG gewählt, lokal zugeschnitten, von Metadaten befreit und
  nur auf diesem Gerät gespeichert oder entfernt werden. Sie werden nicht zu
  Supabase hochgeladen und erscheinen daher nicht automatisch auf einem
  zweiten Gerät.
- Erinnerungsschalter werden lokal pro Konto gespeichert. Sie planen noch
  keine Betriebssystem-Push-Nachrichten; dieser Unterschied bleibt im Sheet
  ausdrücklich sichtbar.
- Animationen der neuen Oberfläche sind endlich und respektieren reduzierte
  Bewegung. Der Datenbankzugriff bleibt durch bestehende RLS-Regeln auf das
  angemeldete Konto beschränkt.

## Aktualisierung: Persönliche Einrichtung, 16. September 2026

- Nach Vorstellung und Anmeldung erscheinen einmalig acht freiwillige Schritte:
  Name, Wunsch, Alltag, bisheriger/gewünschter Mahlzeitenrhythmus, Ernährungsweise,
  Kochzeit, Fokus und eine bearbeitbare Zusammenfassung.
- Dunkle bestehende LIVO-Farbwelt, ein Lime-Akzent, animierte Vorschaukarten,
  Diagramme und Übergänge. Die Einrichtung respektiert reduzierte Bewegung.
- Antworten lassen sich im Profil nachholen, ändern und vom Gerät entfernen.
  Entwürfe bleiben ungespeichert, bis die Auswahl übernommen wird.
- Speicherung pro Konto auf diesem Gerät; kein neues Supabase-Schema und keine
  Synchronisierung dieser Einrichtungsantworten zwischen Geräten. Bestehende
  Cloud-Profilfelder und manuell eingestellte Kalorienziele bleiben unverändert.
- Startseite: gewählter Rufname und persönliche Zusammenfassung. Tagebuch:
  gewünschter Rhythmus ohne Pflicht oder automatische Begrenzung.
- „Für dich“ priorisiert Rezepte regelbasiert nach ausdrücklich hinterlegten
  Ernährungs-Tags, Kochzeit und Budget-Tag. Alle Rezepte bleiben zugänglich;
  Zutaten und Allergene müssen weiterhin geprüft werden. Es werden keine
  Ernährungs- oder Gesundheitsversprechen aus Tags abgeleitet.
- Noch keine KI angebunden: Nur eine versionierte Kontextstruktur ohne Name
  oder Konto-ID ist für eine spätere Backend-Anbindung vorbereitet. Es gibt
  keine automatischen Kalorienziele, Diätpläne oder medizinischen Ratschläge.
- Speicherung, Löschung und verbleibende Produktivvoraussetzungen:
  `PERSONALIZATION_PRIVACY.md`. Ältere Bestandsaufnahmen darunter bleiben als
  Historie erhalten; der jeweils neuere Eintrag hat Vorrang.
- Geprüft: Flutter-Analyse ohne Befund, 50 erfolgreiche Tests (inklusive
  bisheriger App/Einführung), Release-Web-Build erfolgreich. Neue Tests decken
  Fragen, Bearbeiten, Überspringen, Speicherfehler, veraltete Leseantworten,
  kontobezogene Speicherung, Rezeptsortierung und alle acht Schritte bei
  320 × 568, 390 × 844, 740 × 360 und 1280 × 800 ab; schmale/kurze Ansichten
  zusätzlich mit doppelter Schriftgröße und reduzierter Bewegung. Handy- und
  Desktopansichten wurden zusätzlich anhand temporärer Widget-Aufnahmen
  kontrolliert. Eine Live-Anmeldung mit echten Zugangsdaten wurde nicht
  automatisiert getestet.

## Aktualisierung: Deutschfreundlicher Lebensmittel-Katalog, 15. September 2026

- Die Suche erkennt haeufige deutsche und englische Begriffe im USDA-Katalog,
  zum Beispiel `Haehnchen`/`chicken`, `Haferflocken`/`oats` und
  `Joghurt`/`yogurt`. Der englische Originalname bleibt sichtbar, damit keine
  ungepruefte automatische Uebersetzung als Quelle ausgegeben wird.
- Lebensmittel haben eine Detailansicht mit Portion, Makros, Datenquelle und
  direktem Speichern in das Tagebuch. Filter zeigen zuletzt verwendete,
  auf diesem Geraet gemerkte, proteinreiche und leichte Lebensmittel.
- Die Merkliste und die zuletzt verwendeten Lebensmittel werden nur als IDs
  lokal auf dem jeweiligen Geraet gespeichert. Sie werden nicht an einen
  zusaetzlichen Anbieter uebertragen und sind nicht zwischen Geraeten synchron.

## Aktualisierung: Vollstaendiges Tagebuch und Rezeptdetails, 15. September 2026

- Gespeicherte Lebensmittel lassen sich in Gramm und Mahlzeitenart aendern,
  auf einen anderen Tag verschieben oder duplizieren. Eigene Mahlzeiten mit
  selbst eingetragenen Makros werden dauerhaft im vorhandenen Tagebuch
  gespeichert.
- Das Tagebuch kann zu frueheren und kuenftigen Wochen wechseln. Die
  Tageszusammenfassung zeigt Kalorien sowie Protein, Kohlenhydrate und Fett
  mit klaren Fortschrittsbalken. Werte dienen nur der Orientierung.
- Favorisierte Datenbank-Rezepte werden pro angemeldetem Konto in
  `favorites` gespeichert. Rezeptseiten lesen Zutaten, Mengen und Anleitungen
  aus dem Katalog; Vorschau-Rezepte behalten deutlich gekennzeichnete lokale
  Fallback-Inhalte.

## Aktualisierung: Dauerhafte Rezepte im Tagebuch, 15. September 2026

- Ein Rezept aus dem Supabase-Katalog wird als einzelne Mahlzeit mit seinen
  gespeicherten Zutaten in `meals` und `meal_items` gesichert.
- Kalorien und Makros werden aus den hinterlegten Zutaten berechnet, beim
  Neustart erneut geladen und mit einem Wischen wieder komplett geloescht.
- Die fest eingebauten Vorschau-Rezepte bleiben nur fuer Offline- und
  Widget-Vorschauen lokal; angemeldete Nutzer speichern die Datenbank-Rezepte.

## Aktualisierung: Wochenansicht im Tagebuch, 15. September 2026

- Die sieben Karten zeigen die echten Daten der aktuellen Kalenderwoche.
- Beim Antippen wird der jeweilige Tag aus Supabase geladen; neue Lebensmittel
  werden fuer den ausgewaehlten Tag gespeichert.
- Die Startseite bleibt bei den heutigen Werten. Ein Kalender fuer weitere
  Wochen und das Bearbeiten gespeicherter Mengen folgen als naechster
  Tagebuchschritt.

## Aktualisierung: Gespeichertes Tagebuch fuer heute, 15. September 2026

- Ein aus dem Supabase-Katalog ausgewaehltes Lebensmittel kann mit Mahlzeitenart
  und Menge (50 bis 300 g) in `meals` und `meal_items` gespeichert werden.
- Die heutige Liste wird beim Start erneut aus Supabase geladen. Das Entfernen
  einer gespeicherten Zeile loescht auch ihren Datenbankeintrag.
- Die Kalenderansicht und das dauerhafte Speichern von Rezepten sind umgesetzt;
  frei waehlbare Mengen ausserhalb von 50 bis 300 g folgen separat.

## Aktualisierung: Profil-Synchronisierung, 15. September 2026

- Angemeldete Profilwerte werden beim Start aus `public.profiles` geladen.
- Name, Ziel, Kalorienziel, Zielgewicht, Proteinziel, Ernaehrungsstil,
  Allergien und Aktivitaetsniveau werden nach einer Bearbeitung wieder in
  Supabase gespeichert.
- Bei einem Netzwerkfehler bleibt die lokale Sitzung nutzbar.

## Aktualisierung: App-Einführung, 14. September 2026

- Neu: fünfseitige, responsive Vorstellung vor dem bestehenden Login:
  Tagesübersicht, Rezepte, Trinkroutinen, Fortschritt und persönliches Profil.
  Weiter, Zurück, Wischen, Seitenindikatoren, Pfeiltasten und Überspringen
  funktionieren. Am Ende führt „Los geht’s“ zum bisherigen Anmeldeablauf.
- Einheitliche dunkle Farbwelt mit Lime-Akzent, nummerierte Themen und fünf
  animierte Produktvorschauen. Werte zählen hoch, Karten erscheinen versetzt,
  Wasser und Diagramme bauen sich sichtbar auf (1,8 Sekunden pro Vorstellung).
- Endliche Animationen mit optionalem Wiederholen-Knopf; die Animationen
  respektieren `MediaQuery.disableAnimations` und pausieren außerhalb der
  aktiven Seite. Bei reduzierter Bewegung entfällt der Wiederholen-Knopf.
- Nur eine lokale Abschlussmarkierung wird dauerhaft gespeichert, damit die
  Einführung beim nächsten Öffnen nicht erneut erscheint. Bei Speicherausfall
  bleibt die App zugänglich. Details: `INTRODUCTION_PRIVACY.md`.
- Der Marker für Version 2 zeigt den überarbeiteten Einstieg einmal erneut,
  ohne bestehende Kontositzungen oder persönliche Daten anzutasten.
- Die Vorschauen sind als Beispiele gekennzeichnet. Dieser Schritt fügt keine
  Altersprüfung, KI-Verbindung, Fotoanalyse oder Zahlungsfunktion hinzu.
- Verifiziert am 14. September: 22 erfolgreiche Widget-Tests, Flutter-Analyse
  ohne Befund und erfolgreicher Release-Web-Build. Alle fünf Seiten wurden
  bei 390 × 844 Pixeln im Browser kontrolliert, außerdem die Desktopansicht
  bei 1280 × 800 Pixeln und eine Zwischenaufnahme der Wasseranimation.
  Tests decken zusätzlich 320-Pixel-Displays mit doppelter Schriftgröße,
  Screenreader-Aktionen, Wiederholen und Änderungen an Reduced Motion ab.
- Die ältere Bestandsaufnahme darunter beschreibt den ursprünglichen
  In-Memory-Prototyp. Insbesondere die pauschalen Aussagen „keine Anmeldung“
  und „keine Übertragung“ sind für den heutigen Gesamtcode nicht mehr aktuell:
  AuthGate und Supabase-Katalogzugriff sind bereits vorhanden. Ihr aktueller
  Remote-/Deployment-Status der neuen Importdateien muss noch im Dashboard
  ausgeführt und anschließend geprüft werden.

## Aktualisierung: Katalogimport, 14. September 2026

- Das Schema enthält jetzt Herkunfts-, Lizenz- und Prüfstatusfelder für
  Lebensmittel sowie Herkunft und Anleitungen für Rezepte.
- `supabase/imports/usda_foundation.sql` enthält 354 generische USDA-
  Foundation-Lebensmittel; `supabase/imports/usda_fndds.sql` enthält 5.431
  USDA-FNDDS-Lebensmittel. Beide Dateien sind reproduzierbare SQL-Importe mit
  Quellenangabe.
- Die tatsächliche Cloud-Datenbank ist erst nach diesem SQL-Schritt gefüllt.
  Barcode-Daten aus Open Food Facts und Rezepttexte bleiben getrennte Quellen
  mit eigener Lizenzprüfung.
- `supabase/imports/curated_recipes.sql` ergänzt zehn selbst verfasste
  Starter-Rezepte mit Zutaten und Anweisungen; daraus ergeben sich zusammen
  mit dem Seed 15 Rezepte. Ein Katalog mit tausenden Rezepten braucht weitere
  redaktionelle Arbeit oder eine separat geprüfte kommerzielle Lizenz.

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

- Altersprüfung (App-Vorstellung siehe Aktualisierung oben)
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
