# LIVO Coach: Daten, Verlauf und Grenzen

Stand: 27. September 2026. Technische Dokumentation, keine abschließende
Datenschutzerklärung oder juristische Freigabe.

## Was an den KI-Dienst geht

Der Coach läuft ausschließlich über die Supabase Edge Function `ai-coach`.
Die App kennt keinen KI-Schlüssel. Mit jeder Frage überträgt die App:

- die Frage selbst (höchstens 600 Zeichen),
- Ziel, Kalorien- und Proteinziel,
- die heutigen Tagebuchwerte (Kalorien, verbleibende Kalorien, Protein,
  Kohlenhydrate, Fett). Sie fehlen, solange das heutige Tagebuch lädt oder
  nicht geladen werden konnte; es werden keine Nullwerte erfunden,
- Ernährungsstil, Allergien/Unverträglichkeiten und Aktivitätsniveau.

Name, E-Mail, Konto-ID, Geburtstag, Größe und Gewicht werden nicht an den
KI-Dienst geschickt. Die Edge Function ergänzt dieselben Profilfelder aus
`public.profiles` und schickt zusätzlich die letzten 12 gespeicherten
Nachrichten (je höchstens 1500 Zeichen) als Gesprächskontext an OpenAI
(`store: false`). Allergien können Gesundheitsdaten sein; vor echtem Betrieb
braucht es dafür eine passende Rechtsgrundlage, Einwilligung und einen
Auftragsverarbeitungsvertrag mit dem Anbieter.

Der Hinweis dazu steht im Coach selbst („Mit jeder Frage gehen …“).

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
Antwort. Bei komplett inaktiven Konten bleiben alte Nachrichten liegen, bis
das Konto wieder genutzt oder gelöscht wird; ein täglicher Aufräumjob
(z. B. `pg_cron`) ist noch offen.

Gespeichert werden nur Frage und Antwort als Text, nicht der mitgeschickte
App-Kontext und keine Fotos. Bei der Fotoanalyse im Coach steht als Frage nur
„📷 Lebensmittel-Foto zur Analyse“.

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

Die Systemanweisung verpflichtet den Coach auf: Deutsch, kurz und freundlich;
nur Ernährung, Fitness und Alltag; Halal-Inhaltsregel
(`HALAL_CONTENT_POLICY.md`); keine Diagnose, Behandlung, Medikamente,
Supplement-Dosierung, Heilversprechen oder extremen Diäten; bei
Minderjährigen, Schwangerschaft/Stillzeit, Essstörungen und relevanten
Erkrankungen keine Pläne, sondern Verweis auf qualifizierte Hilfe; bei akuter
Gefahr Notruf 112. Nährwerte sind Schätzungen („ca.“). Die App zeigt
dauerhaft „KI kann Fehler machen · Werte sind Schätzungen · Keine
medizinische Beratung“.

## Vor echtem Betrieb offen

- Rechtsgrundlage/Einwilligung für Gesundheitsdaten (Allergien, Tageswerte)
  und AV-Vertrag mit OpenAI prüfen.
- Datenexport des Chatverlaufs anbinden.
- Automatischen Aufräumjob für inaktive Konten einrichten.
