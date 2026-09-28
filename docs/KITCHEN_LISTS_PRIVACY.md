# Wochenplan, Einkaufsliste und Vorräte: Daten und Grenzen

Stand: 27. September 2026. Technische Dokumentation, keine abschließende
Datenschutzerklärung oder juristische Freigabe.

## Was gespeichert wird

- Vorräte: Name, optionale Menge (Zahl und Einheit oder kurzer Text),
  Hinzufügedatum.
- Einkaufsliste: Name, optionale Menge, erledigt ja/nein, Herkunft (z. B.
  Rezepttitel) und eine interne Wochenmarkierung für aus dem Plan erstellte
  Einträge.
- Wochenplan: Datum, Mahlzeit, Rezept-ID, Rezepttitel und Portionen.
- Der Schalter „Grundzutaten sind vorhanden“.

Die Daten liegen als versioniertes JSON mit SharedPreferencesAsync unter
`livo.kitchen.v1.<Konto-ID>` – nur auf diesem Gerät bzw. in diesem
Browserprofil. Ohne Konto (Vorschau/Tests) wird nichts gespeichert.

## Übertragung

Keine Übertragung an Supabase, OpenAI oder andere Dienste. Keine neuen
Berechtigungen, SDKs oder Tracker. Der Abgleich „Was kann ich kochen?“ läuft
vollständig in der App mit dem bereits geladenen Rezeptkatalog.

## Grenzen

- SharedPreferences ist kein verschlüsselter Speicher; Personen mit Zugriff
  auf Gerät oder Browserprofil können die Daten lesen.
- Browserdaten löschen, privater Modus, Neuinstallation oder Gerätewechsel
  entfernen die Listen bzw. übertragen sie nicht.
- Planeinträge, die älter als acht Wochen sind, werden beim Laden entfernt;
  Listen sind auf je 300 Einträge begrenzt.

## Ändern und Löschen

Einträge lassen sich einzeln oder gesammelt („Alle entfernen“, „Liste
leeren“, „Woche leeren“) entfernen. „Lokale Demodaten löschen“ im Profil
löscht auch diesen Datensatz des angemeldeten Kontos. Bei Abmeldung bleiben
die Daten auf dem Gerät, werden aber erst nach erneuter Anmeldung desselben
Kontos wieder geladen. Nicht lesbare Daten werden nicht automatisch
überschrieben; „Zurücksetzen“ löscht sie bewusst.

## Vor einer Cloud-Synchronisierung offen

Eigene Tabellen mit RLS (nur eigene Zeilen), Migration, Konfliktverhalten
zwischen Geräten, Export und Löschung im Konto-Löschprozess. Die App spricht
nur mit der Schnittstelle `PlanningStore`, sodass die Gerätespeicherung dann
ersetzt werden kann.
