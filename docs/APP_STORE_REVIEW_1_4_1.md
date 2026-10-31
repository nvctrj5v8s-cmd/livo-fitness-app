# Apple-Review 1.4.1: Quellen im Coach

Submission: `8a38dff5-551f-4ea2-8772-be2ffc3b0862`, beanstandet am 29.10.2026,
geprüfte Version 1.0 (6), iPad Air 11-inch (M3).

## In der App finden

1. **Coach:** oben das Buchsymbol „Quellen & Grenzen“ öffnen. Funktioniert
   auch ohne Premium. Enthält medizinische Grenzen, Quellenumfang und Links.
2. **Neue Coach-Antwort:** gesundheitsbezogene allgemeine Hinweise haben
   Referenzen `[1]` usw. und unmittelbar darunter „Quellen zu dieser Antwort“
   mit Link, Herausgeber und Thema. Beispiel: „Wie kann ich mehr Abwechslung
   in mein Essen bringen?“; Quelle sollte zur Aussage passen. Rezepte ohne
   Gesundheitsbehauptung, App-Bedienung und Ablehnungen brauchen keine
   sachfremden Referenzen. Nicht jeder Antwort wird pauschal dieselbe Liste
   angehängt. Alte Antworten bekommen keine erfundenen Belege.
3. **Profil › Datenschutz & Daten › Einwilligungen:** KI ein-/ausschalten;
   beim Erteilen sind Hinweise, Quellenübersicht, AGB und Datenschutz sichtbar.
   Alte positive KI-Einwilligung wird mit dem Update erneut abgefragt.
4. **Registrieren:** eigenes Pflicht-Häkchen für Alter, AGB sowie Kenntnisnahme
   der Datenschutz-/Gesundheitshinweise. Optionales KI-/Gesundheitsdaten-
   Einverständnis bleibt getrennt. Keine pauschale Datenschutz-Zustimmung.
5. **Tagebuch › Hinzufügen › Eigenes Lebensmittel:** Verpackungswerte eintragen,
   „Für später als eigene Vorlage merken“ auswählen, ins Tagebuch eintragen.
   Später im selben Editor unter „Eigene gemerkte Lebensmittel“ auswählen,
   Menge ändern und erneut eintragen. Papierkorb löscht nur die Vorlage.
   „Quelle: deine eigene Eingabe“ macht den ungeprüften Ursprung klar.

## Geprüfte Primärquellen

- WHO, Healthy diet: https://www.who.int/news-room/fact-sheets/detail/healthy-diet
- WHO, Physical activity: https://www.who.int/news-room/fact-sheets/detail/physical-activity
- NHS, Understanding calories: https://www.nhs.uk/live-well/healthy-weight/managing-your-weight/understanding-calories/
- EFSA, Dietary reference values: https://www.efsa.europa.eu/en/topics/topic/dietary-reference-values

Abgerufen am 29.10.2026. Die KI bekommt begrenzte redaktionelle Paraphrasen,
keine vollständigen Webseiten. Diese Quellen bestätigen keine individuellen
Ziele oder konkreten KI-/Rezeptnährwerte. Neue Themen nur nach Quellenprüfung
ergänzen. Keine medizinische Behandlung, Medikamente oder Supplementdosierung.

## Veröffentlichung

- `tool/sync_coach_sources.dart` erzeugt aus dem gemeinsamen Quellenkatalog die
  Dart-Liste und die deutschen/englischen Quellen-Webseiten.
- Neue App mit generierten Übersetzungen bauen und als neuen iOS-Build
  hochladen. Die Versionsnummer/Buildnummer dieser Arbeitskopie wurde nicht
  hochgesetzt, weil die eingereichte 1.0 (6) nicht dieser lokalen Nummer
  entspricht; für den Upload eine freie höhere Buildnummer wählen.
- `ai-coach` mit `supabase/functions/_shared/coach_citations.ts` und
  `coach_sources.json` wurde am 31.10.2026 im verknüpften Fitness-Projekt als
  Version 22 veröffentlicht und der heruntergeladene Stand verglichen. Keine Migration
  neu nötig, bestehende Chat-/Einwilligungsmigrationen müssen angewendet sein.
  Die neue Funktion akzeptiert nur die neue KI-Einwilligung; deshalb Rollout
  mit der App abstimmen. Ältere App-Versionen können diese neue Zustimmung
  nicht erfassen und würden bis zum Update für KI-Anfragen gesperrt.
- Rechtsseiten und `gesundheit-quellen.html` in beiden Sprachen zusammen mit
  dem Webauftritt veröffentlichen. Die Links in den produktiven Rechtsseiten
  dürfen nicht auf noch unveröffentlichte Dateien zeigen.
- Im tatsächlichen neuen iOS-Build: Einwilligung ablehnen/erteilen/widerrufen,
  neuen Chat senden, Quelle antippen, Chat neu öffnen und Referenzen prüfen.
  Erkrankungs-/Medikamentenfragen müssen auf Fachleute verweisen; eigene
  Produktwerte müssen bearbeitbar bleiben. Quellenzuordnung am Inhalt prüfen,
  nicht nur am Vorhandensein eines Links. Keine echten Gesundheitsdaten zum
  Testen benutzen. Lokale Tests ersetzen keine Live-KI- oder Geräteprüfung.

Die Veröffentlichung des neuen iOS-Builds, eine Nachricht an Apple und eine
Live-KI-Abfrage sind weiterhin nicht erfolgt. Die rechtlichen Ergänzungen
beschreiben die implementierten Abläufe; sie sind keine juristische Freigabe.
Eine Zustimmung ersetzt weder sachliche Belege noch Apples erneute Prüfung.

## Lokale Prüfungen

Lokale Prüfung am 29.10.2026: `flutter analyze --no-pub` ohne Befunde;
85 Flutter-Tests in den betroffenen Bereichen bestanden (Registrierung,
Quellen auf 320/834 Pixeln, Chat, Einwilligungen, Vorlagen, Englisch und
Rechtslinks). `deno check supabase/functions/ai-coach/index.ts` erfolgreich;
drei Tests in `_shared/coach_citations_test.ts` bestanden. Übersetzungs- und
Rechtsseitenprüfung sowie `git diff --check` erfolgreich. Der anfängliche
generierte SDK-Cache war veraltet und wurde durch `flutter clean`/`pub get`
erneuert; keine Abhängigkeiten aktualisiert. Live-KI und physisches iOS-Gerät
wurden nicht geprüft.

## Antwortentwurf – erst nach tatsächlicher Veröffentlichung verwenden

Thank you for your feedback regarding Guideline 1.4.1. We have updated the
Lookin Coach to show relevant citations directly below health-related general
nutrition and movement guidance, with clickable links to WHO, NHS and EFSA
references. Numbered references connect statements to their sources. The
source overview and medical limitations are accessible through the book icon
(“Sources & limits”) at the top of the Coach screen, including without Premium.

We have limited the coach to supported general information and practical app
and meal assistance. It does not provide diagnoses, treatment, medication or
supplement dosages, or new individual dietary/training prescriptions. AI photo
and portion values remain clearly labelled estimates that users review before
saving; the cited references are not presented as validating those estimates.
Users are reminded to consult a qualified professional before medical decisions.

We also updated the AI consent notices, Terms and Privacy Policy. AI processing
requires separate, explicit consent. Please review the new build and updated
backend. To find the citations, open Coach, ask a general nutrition question,
and use the source links directly below the answer, or open “Sources & limits”.
