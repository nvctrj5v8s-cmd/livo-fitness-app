# Allergien und Unverträglichkeiten: Funktion, Daten und Grenzen

Stand: 29. September 2026. Technische Dokumentation, keine abschließende
Datenschutzerklärung, keine juristische oder medizinische Freigabe.

## Was die Funktion macht

- **Angabe im Profil:** In der Einrichtung (letzter Schritt) und unter
  Profil → Ernährungsprofil lassen sich die 14 in der EU kennzeichnungs-
  pflichtigen Allergene (LMIV Anhang II) sowie Laktose als Unverträglichkeit
  auswählen. Weitere Angaben (z. B. „Kiwi, Histamin“) sind als Freitext
  möglich. Alles ist freiwillig.
- **Rezepte:** Rezepte, deren Titel, Zutaten oder Allergen-Tags zu einem
  gewählten Auslöser passen, erscheinen weder im Rezepte-Tab noch in „Was
  kann ich kochen?“. Der Rezepte-Tab nennt die Zahl der ausgeblendeten
  Rezepte. Wer ein solches Rezept direkt öffnet (z. B. als Favorit), sieht
  einen Warnhinweis und muss das Eintragen ins Tagebuch ausdrücklich
  bestätigen.
- **Lebensmittel:** Suchergebnisse zeigen „Allergiehinweis: …“. Detailseite,
  Barcode-Produkte, eigene Einträge und KI-Fotoanalyse zeigen einen Hinweis;
  vor dem Speichern eines Treffers kommt eine Rückfrage („Trotzdem
  protokollieren“). Das Tagebuch dokumentiert, was gegessen wurde – es wird
  nichts blockiert, was bereits gegessen wurde.
- **KI-Coach und Fotoanalyse:** Die Angaben gehen wie bisher im
  „LIVO-Kontext“ mit (siehe `AI_COACH_PRIVACY.md`). Der Systemprompt
  behandelt sie als feste Ausschlusskriterien und verbietet, Sicherheit zu
  bestätigen, wenn Zutaten oder Spuren nicht verlässlich bekannt sind.

## Wie erkannt wird

`lib/features/allergies/domain/allergy_safety.dart`, reines Dart ohne
Netzwerk. Je Allergen gibt es eine Wortliste (z. B. Milch: Käse, Sahne,
Joghurt, Butter, Molke …; Gluten: Weizen, Hafer, Nudeln, Brot, Couscous …).
Wörter ab vier Buchstaben zählen auch in zusammengesetzten Wörtern
(„Erdnussbutter“, „Vollkornnudeln“). Ausnahmen verhindern offensichtliche
Fehltreffer („Kokosmilch“, „Buchweizen“, „Muskatnuss“, „veganer Käse“,
„glutenfreie Nudeln“, „laktosefreie Milch“ nur bei Laktose). Im Zweifel
warnt die Prüfung lieber einmal zu oft.

## Grenzen – so auch in der App benannt

- Es ist eine Textprüfung, keine Sicherheitsgarantie und keine medizinische
  Beratung. Fehlen Zutatenangaben, heißt es „Allergieangaben fehlen“, nicht
  „sicher“.
- Katalogrezepte haben meist nur Zutatennamen, keine Allergen- oder
  Spurenangaben der tatsächlich gekauften Produkte. „Kann Spuren enthalten“
  und Kreuzkontamination werden nicht erfasst.
- Fotos können versteckte Zutaten nicht erkennen.
- Unbekannte Produktnamen oder Übersetzungen können durchrutschen. Hinweis
  in der App: immer die aktuelle Verpackung prüfen.
- Keine Diagnose, keine Therapie, keine Aussage zu Schweregrad oder
  Anaphylaxie.

## Daten

- Gespeichert wird ein lesbarer Text, z. B. „Erdnüsse, Laktose
  (Unverträglichkeit), Kiwi“ – keine neue Datenart: Das Feld gab es bereits
  als Freitext.
- Ort: Supabase `public.profiles.allergies` (RLS, nur eigenes Konto) und die
  lokale Einrichtung (`livo.personalization.v1.<Konto-ID>`). Änderungen im
  Ernährungsprofil werden jetzt in beide geschrieben, damit sie nicht
  auseinanderlaufen.
- Übertragung an OpenAI nur im Rahmen der bestehenden Coach- und
  Fotoanalyse-Aufrufe, wie in `AI_COACH_PRIVACY.md` beschrieben.

## Vor echtem Betrieb offen

- Allergien sind Gesundheitsdaten (Art. 9 DSGVO): ausdrückliche Einwilligung
  bzw. Rechtsgrundlage, verständlicher Hinweis vor der Eingabe, Widerruf,
  Export und Löschung im Konto-Löschprozess prüfen und umsetzen.
- Spurenangaben (`traces`) aus Produktdaten ergänzen, sobald die Barcode-
  Quelle sie liefert.
- Fachliche Prüfung der Wortlisten, idealerweise mit Ernährungsfachkraft.
