# Persönliche Einrichtung: Daten und Grenzen

Stand: 16. September 2026. Technische Dokumentation, keine abschließende
Datenschutzerklärung oder juristische Freigabe.

## Was gespeichert wird

Alle Fragen sind freiwillig: optionaler Rufname/Spitzname (maximal 40 Zeichen),
Wunsch, selbst beschriebenes Aktivitätsmuster, bisherige und gewünschte Zahl
der Mahlzeiten, Ernährungsweise, verfügbare Kochzeit und aktueller Fokus.
„Flexibel“ und unbeantwortete Fragen erzeugen keine geschätzten Ersatzwerte.
Gewicht, Alter, Erkrankungen und Allergien werden hier nicht neu abgefragt.

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
  Kochzeit und Budget-Tag. Keine Allergiefreiheitsprüfung oder medizinische
  Eignungsprüfung. Bei fehlenden Tags werden Eigenschaften nicht erfunden.
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
