# Persönliche Einrichtung: Daten und Grenzen

Stand: 16. September 2026. Technische Dokumentation, keine abschließende
Datenschutzerklärung oder juristische Freigabe.

## Neu seit 1. Oktober 2026: Fragen vor der Registrierung

- **Reihenfolge:** Einführung → Fragen → Konto erstellen. Wer auf dem Gerät
  schon ein Konto genutzt hat oder „Schon ein Konto? Anmelden“ wählt, kommt
  direkt zur Anmeldung.
- **Vor dem Konto:** Die Antworten liegen nur auf diesem Gerät unter
  `livo.personalization.pending.v1` (geräteweit, da noch kein Konto
  existiert). Nichts wird vorher an Supabase, OpenAI oder Analyse-Dienste
  übertragen. Nach der Registrierung bzw. Anmeldung werden sie ins Konto
  übernommen und der Zwischenstand gelöscht. „Überspringen“ ersetzt nie
  Antworten, die ein bestehendes Konto schon hat. `livo.account_seen.v1`
  merkt sich nur, dass auf dem Gerät schon ein Konto genutzt wurde.
- **Neue Fragen:** Motivation, Geschlecht (nur für die Energie-Schätzung,
  „Möchte ich nicht angeben“ möglich), Zielgewicht und Tempo (nur bei
  Abnehm- oder Muskelziel), Kochzeit, Erfahrung mit dem Kalorienzählen,
  Hürden und ein freiwilliger Gesundheitshinweis (schwanger/stillend,
  Essstörung, ärztlich begleitete Ernährung). Am Ende fasst „Dein Lookin-Plan“
  Tagesrichtwert und eine als grobe Schätzung gekennzeichnete Zielzeit
  zusammen.
- **Schutzregeln:** Zielgewichte unter BMI 18,5 werden nicht angeboten,
  höchstens ca. 0,5 kg pro Woche, Defizit höchstens 20 % und nie unter dem
  Grundumsatz. Mit Gesundheitshinweis oder unter 18 berechnet Lookin keine
  Kalorienziele und verweist auf Fachleute. Keine Countdown-Timer,
  Rabatt-Tricks oder Schuld-Formulierungen.
- **Wohin nach der Registrierung:** In die Cloud (`public.profiles`) gehen
  wie bisher nur Ziel, Ernährungsstil, Allergien, Aktivität und Name.
  Geschlecht, Geburtstag, Größe, Gewicht, Zielgewicht, Tempo, Motivation,
  Hürden, Erfahrung und Gesundheitshinweis bleiben in der kontobezogenen
  Einrichtung auf diesem Gerät.
- **Offen vor echtem Betrieb:** Allergien in der Cloud und die lokalen
  Gesundheitsangaben sind Gesundheitsdaten (Art. 9 DSGVO). Bei der
  Registrierung braucht es eine ausdrückliche, widerrufbare Einwilligung.

## Was gespeichert wird

Alle Fragen sind freiwillig: optionaler Rufname/Spitzname (maximal 40 Zeichen),
Wunsch, selbst beschriebenes Aktivitätsmuster, bisherige und gewünschte Zahl
der Mahlzeiten, Ernährungsweise, verfügbare Kochzeit und aktueller Fokus.
„Flexibel“ und unbeantwortete Fragen erzeugen keine geschätzten Ersatzwerte.
Erkrankungen werden nicht abgefragt. Allergien und Unverträglichkeiten können
im letzten Schritt freiwillig ausgewählt werden (seit 29.09.2026; Details
`ALLERGY_SAFETY.md`).

Die Antworten werden erst bei „Meine Auswahl übernehmen“ als versioniertes
JSON mit SharedPreferencesAsync unter `livo.personalization.v1.<userId>`
gespeichert. Die ID ist die ID des angemeldeten Kontos. Ein gemeinsamer
Geräte-Schlüssel für alle Nutzer wird nicht verwendet. „Später“ speichert nur
eine kontobezogene Zurückstellungsmarkierung. Nicht übernommene Entwürfe bleiben
im Arbeitsspeicher. Dies betrifft ausschließlich die neue Einrichtung;
bestehende Auth-, Profil- und Tagebuch-Daten haben eigene Speicherwege.

## Zweck und tatsächliche Auswirkungen

- Persönliche Begrüßung und nachvollziehbare Zusammenfassung in Home/Profil.
- Gewünschter Mahlzeitenrhythmus als Orientierung im Tagebuch, ohne Sperren.
- Reproduzierbare Sortierung von Rezepten nach expliziten Ernährungs-Tags,
  Kochzeit und Budget-Tag. Rezepte mit erkanntem Allergenkonflikt werden
  ausgeblendet; das ist eine Textprüfung, keine Allergiefreiheits- oder
  medizinische Eignungsprüfung. Bei fehlenden Tags werden Eigenschaften nicht
  erfunden.
- Aktivität und Wunsch werden angezeigt, aber nicht zur automatischen
  Berechnung von Kalorien oder Trainings-/Diätplänen verwendet.

## Übertragung und Gerätegrenzen

Keine Übertragung dieser neuen Antworten an Supabase, OpenAI oder andere
KI-Dienste. Keine neuen Analyse-SDKs, Werbe-Tracker oder zusätzlichen
Berechtigungen. Kein KI-Aufruf und keine KI-API-Kosten für die Einrichtung.
Die bestehenden Cloud-Profilfelder bleiben unverändert; diese Einrichtung
ist eine getrennte lokale Vorlieben-Ebene, kein Cloud-Profil-Update.

Shared Preferences ist kein verschlüsselter Tresor. Kontotrennung innerhalb
der App ist keine Verschlüsselung gegen Personen mit Zugriff auf das Gerät,
Browserprofil oder Entwicklertools. Browserdaten löschen/privater Modus,
Neuinstallation und Gerätewechsel können die Antworten entfernen bzw. nicht
übernehmen. Nutzer müssen deshalb über die lokale Speicherung informiert
werden. Der Hinweis steht vor Eingabe sowie vor Abschluss und im Profil.

## Ändern und Entfernen

Profil → „Antworten ändern“ öffnet die Zusammenfassung. Einzelne Antworten
können geändert oder abgewählt werden. „Schließen“ verwirft den Entwurf.
Profil → „Antworten entfernen“ entfernt nur diesen lokalen Vorlieben-Datensatz
des angemeldeten Kontos. Konto, Tagebuch, Rezeptfavoriten, andere Konten und
Cloud-Profil werden nicht gelöscht. Nach Entfernen kann die Einrichtung beim
nächsten Start erneut angeboten werden.

Bei Abmeldung werden Antworten nicht gelöscht, aber Controller und Navigation
werden beim Kontowechsel zurückgesetzt. Nur nach erneuter Anmeldung in diesem
Konto werden dessen Antworten wieder geladen. Ein automatisches Entfernen
aller lokalen Reste im späteren Konto-Löschprozess ist noch anzubinden.

## Speicherfehler

Ein nicht lesbarer Datensatz wird nicht automatisch überschrieben: Erneut
versuchen oder nur für diese Sitzung fortfahren. Scheitert das Speichern,
bleibt der Entwurf sichtbar und kann erneut übernommen werden. Scheitert nur
die „Später“-Markierung, ist die App zugänglich mit einem Hinweis, dass Fragen
beim nächsten Start erneut erscheinen können.

## Vor echter KI / Veröffentlichung offen

- Rechtsgrundlage, verständliche Datenschutzhinweise, Datenminimierung,
  Aufbewahrung, Export und vollständige Konto-Löschung prüfen/umsetzen.
- Für Cloud-Synchronisierung eigene Felder/Migration, RLS-Regeln und
  Konfliktverhalten entwickeln; keine lokalen Antworttexte blind übertragen.
- `toPreferenceContext()` ist lediglich ein später nutzbares DTO, kein
  Netzwerkdienst. Name und Konto-ID sind nicht enthalten, Antworten können
  dennoch personenbezogen/sensibel sein. Die Struktur ist nicht als anonym
  anzusehen. Nutzereinwilligungen und Backend-Prüfungen sind getrennt nötig.
- Schlüssel ausschließlich im Backend; Zugriff, Kostenlimits, Widerruf und
  geeignete Sicherheitsprüfungen vor dem ersten KI-Aufruf implementieren.
- Die Einrichtung nimmt keine medizinische Eignungsprüfung vor. Daher keine
  automatisierten Diätpläne/Defizite daraus erzeugen. Insbesondere für
  Minderjährige, Schwangerschaft, Essstörungen und relevante Erkrankungen
  sind zusätzliche Schutzmaßnahmen und qualifizierte Unterstützung nötig.
- KI-Vorschläge müssen erkennbar, begründet und bestätigungspflichtig sein;
  deklarative Flags im DTO ersetzen keine serverseitigen Schutzmaßnahmen.
