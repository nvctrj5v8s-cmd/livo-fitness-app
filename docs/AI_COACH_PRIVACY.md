# Lookin Coach: Daten, Verlauf und Grenzen

## Ergänzung vom 29. Oktober 2026: Quellen und erneute KI-Einwilligung

Der Coach bekommt zusätzlich feste, geprüfte Zusammenfassungen aus
`supabase/functions/_shared/coach_sources.json`. Es werden keine Nutzerfragen
an Quellen-Webseiten oder eine Suchmaschine übertragen. Die KI wählt höchstens
drei passende Quellen-IDs; nur der Server ergänzt die zugehörigen festen URLs.
Quellenlinks werden als Teil der Antwort im bestehenden Chatverlauf und Export
gespeichert, mit denselben Zugriffsrechten und Löschfristen. Die App öffnet nur
die erlaubten HTTPS-Adressen nach Antippen im externen Browser. Dabei können
Verbindungsdaten beim Quellenanbieter anfallen; Lookin ergänzt keine Nutzer-
oder Chatdaten in den URLs. Weitere Datenfelder, Anbieter und Berechtigungen
werden nicht ergänzt.

Die Quelle belegt die allgemeine Information, nicht persönliche Kalorien- und
Proteinziele, Rezeptwerte oder Fotoschätzungen. Antworten ohne hinreichende
Grundlage werden begrenzt. Die technische Prüfung erkennt strukturelle Fehler,
fehlende Referenzen und unbekannte Quellen, sie kann die inhaltliche Wahrheit
einer KI-Aussage nicht garantieren. Alte Antworten werden nicht nachträglich
belegt. Übersicht und Hinweise: Coach › Buchsymbol „Quellen & Grenzen“.

Die neue KI-Einwilligung (`2026-10-29:de/en`) umfasst die Hinweise zu Schätzungen,
Quellen und medizinischen Grenzen sowie eine präzisere Erklärung der
Freitexteingaben: Name/E-Mail werden nicht als Profilfelder hinzugefügt,
können aber in selbst eingegebenen Nachrichten/Fotos vorkommen. Die App fragt
eine alte positive KI-Einwilligung erneut ab und der Server prüft die neue
Textversion. Ablehnungen/Widerrufe bleiben wirksam. Gesundheitsdaten- und
Abo-Einwilligungen behalten ihre bisherigen Versionen. Die übrige App bleibt
ohne KI-Einwilligung nutzbar. App und Edge Function müssen gemeinsam ausgerollt
werden; dieser Stand ist lokal vorbereitet, noch nicht live verifiziert.

Siehe auch `APP_STORE_REVIEW_1_4_1.md` und die aktualisierten Rechtsseiten.

Stand: 15. Oktober 2026. Technische Dokumentation, keine abschließende
Datenschutzerklärung oder juristische Freigabe.

## Was an den KI-Dienst geht

Der Coach läuft ausschließlich über die Supabase Edge Function `ai-coach`.
Die App kennt keinen KI-Schlüssel. Mit jeder Frage überträgt die App:

- die Frage selbst (höchstens 600 Zeichen),
- die aufgelöste App-Sprache (`de` oder `en`), damit Antworten und
  Foto-Beschreibungen in derselben Sprache erfolgen,
- Ziel, Kalorien- und Proteinziel. Berechnet Lookin bewusst keine Ziele (unter
  18 Jahren oder nach einem Gesundheitshinweis in den Einstiegsfragen),
  fehlen beide; stattdessen geht nur `calorie_targets_paused: true` mit –
  ohne den Grund,
- die heutigen Tagebuchwerte (Kalorien, verbleibende Kalorien, Protein,
  Kohlenhydrate, Fett). Sie fehlen, solange das heutige Tagebuch lädt oder
  nicht geladen werden konnte; es werden keine Nullwerte erfunden,
- Ernährungsstil, Allergien/Unverträglichkeiten und Aktivitätsniveau,
- falls beantwortet: Motivation, Hürden und Erfahrung mit dem
  Kalorienzählen (seit 01.10.2026).

Name, E-Mail, Konto-ID, Geburtstag, Größe, Gewicht, Geschlecht, Zielgewicht
und Gesundheitshinweise werden nicht an den KI-Dienst geschickt. Die Edge Function ergänzt dieselben Profilfelder aus
`public.profiles` und schickt zusätzlich die letzten 12 gespeicherten
Nachrichten (je höchstens 1500 Zeichen) als Gesprächskontext an OpenAI
(`store: false`). Allergien können Gesundheitsdaten sein; vor echtem Betrieb
braucht es dafür eine passende Rechtsgrundlage, Einwilligung und einen
Auftragsverarbeitungsvertrag mit dem Anbieter.

Der Hinweis dazu steht im Coach selbst („Mit jeder Frage gehen …“).

**Einwilligung wird auf dem Server geprüft (seit 15.10.2026):** Chat,
Foto-Erkennung und Foto-Analyse gehen nur an OpenAI, wenn die neueste
Entscheidung für „KI-Verarbeitung“ in `public.user_consents` „erteilt“ lautet.
Ohne Einwilligung (oder nach Widerruf) antwortet `ai-coach` mit HTTP 403 und
`consent_required`, ohne den KI-Dienst aufzurufen. Kann die Entscheidung nicht
gelesen werden, wird ebenfalls nichts gesendet (HTTP 503). Verlauf lesen und
löschen bleibt ohne Einwilligung möglich.

## Chatverlauf: Entscheidung

Der Verlauf wird **pro Konto gespeichert** und beim Öffnen des Coaches
geladen. Gründe: Nutzer erwarten von Coach-Chats (wie bei vergleichbaren
Apps) Kontinuität, Antworten können nachgelesen werden und der Coach kann auf
frühere Angaben eingehen. Dafür gelten feste Grenzen zur Datenminimierung:

| Regel | Wert |
| --- | --- |
| Gespeichert und angezeigt | höchstens die letzten 100 Nachrichten |
| Aufbewahrung | höchstens 90 Tage, ältere Nachrichten werden gelöscht |
| An die KI als Kontext | nur die letzten 12 Nachrichten |
| Länge einer gespeicherten Nachricht | höchstens 4000 Zeichen (Migration 0013) |

Die Aufräumregel läuft in der Edge Function bei jedem Laden und jeder neuen
Antwort. Zusätzlich löscht der tägliche Löschlauf (`pg_cron`,
`run_retention_cleanup()`, Migration 0024) Nachrichten älter als 90 Tage,
auch bei inaktiven Konten. Krisennachrichten werden nicht gespeichert.
Gemeldete Antworten liegen in `ai_answer_reports` (höchstens 12 Monate).

Gespeichert werden nur Frage und Antwort als Text, nicht der mitgeschickte
App-Kontext und keine Fotos. Bei der Fotoanalyse im Coach steht als Frage nur
„📷 Lebensmittel-Foto zur Analyse“ bzw. „📷 Food photo for analysis“.
Bestehende Nachrichten werden beim Sprachwechsel nicht nachträglich übersetzt.

## Löschen

- **Neuer Chat** (Symbol oben rechts) und **Verlauf löschen** (oben im Chat)
  löschen nach einer Rückfrage alle Coach-Nachrichten des Kontos endgültig
  auf dem Server (`action: clear_history`). Die App zeigt die Löschung erst,
  wenn der Server sie bestätigt hat.
- Auch ohne Premium (z. B. nach Ende der Testphase) bleibt „Gespeicherten
  Coach-Verlauf löschen“ im gesperrten Coach-Bereich erreichbar.
- Beim Löschen des Kontos entfernt `on delete cascade` alle Nachrichten.
- Der Tageszähler (`ai_chat_usage`) enthält keine Inhalte und bleibt beim
  Löschen des Verlaufs erhalten, damit das Tageslimit nicht umgangen wird.

## Zugriff und Sicherheit

- `ai_chat_messages`: Nutzer dürfen per RLS nur ihre eigenen Zeilen lesen
  (0005). Schreiben, Aufräumen und Löschen erledigt nur die Edge Function mit
  dem Service-Role-Schlüssel, der nie in der App liegt.
- `release_ai_chat_quota` (0013) gibt eine Anfrage des Tageslimits zurück,
  wenn die KI keine Antwort geliefert hat. Nur `service_role` darf sie
  aufrufen.
- Logs enthalten keine Nachrichteninhalte, nur Fehlercodes.

## Inhaltliche Grenzen

Die Systemanweisung verpflichtet den Coach auf: die ausgewählte App-Sprache
(Deutsch oder Englisch), kurz und freundlich;
nur Ernährung, Fitness und Alltag; Halal-Inhaltsregel
(`HALAL_CONTENT_POLICY.md`); keine Diagnose, Behandlung, Medikamente,
Supplement-Dosierung, Heilversprechen oder extremen Diäten; bei
Minderjährigen, Schwangerschaft/Stillzeit, Essstörungen und relevanten
Erkrankungen keine Pläne, sondern Verweis auf qualifizierte Hilfe; bei akuter
Gefahr qualifizierte Hilfe bzw. örtlichen Notruf (deutsche Fassung: 112).
Nährwerte sind Schätzungen („ca.“/„approx.“). Die App zeigt
dauerhaft „KI kann Fehler machen · Werte sind Schätzungen · Keine
medizinische Beratung“.

## Vor echtem Betrieb offen

- Rechtliche Prüfung der Einwilligungstexte (Gesundheitsdaten: Allergien,
  Tageswerte) und AV-Vertrag mit OpenAI prüfen.
- Datenexport des Chatverlaufs anbinden.
- Automatischen Aufräumjob für inaktive Konten einrichten.
