# Funktionsstatus

## Korrektur: nur echte Angaben zählen, 1. Oktober 2026

- **Fehler behoben:** Räder und Lineal (Geburtstag, Größe, Gewicht,
  Zielgewicht) zeigen Startwerte (25 Jahre, 175 cm, 70 kg). Beim
  Durchklicken wurden diese gespeichert und daraus Kalorien berechnet,
  obwohl nichts eingegeben war. Jetzt zählt ein Wert nur, wenn er bewegt
  oder mit „Passt genau so – Wert übernehmen“ bestätigt wurde. Solange auf
  einer Frage nichts gewählt ist, heißt der Knopf „Überspringen“.
- **Alles übersprungen:** keine „Plan wird erstellt“-Animation, keine Zahlen,
  sondern „Du startest ganz neutral“ mit dem ehrlichen Hinweis, dass noch
  nichts angepasst ist. Tempo wird nur mit einem selbst gewählten Zielgewicht
  gespeichert; ein Zielgewicht nur mit bekannter Größe und Gewicht.
- **Rezepte passen sich stärker an:** Neben Ernährungsweise und Kochzeit
  sortieren jetzt auch das Ziel (Abnehmen: eiweißreich und bis 500 kcal
  zuerst; Muskelaufbau: eiweißreich zuerst) und Hürden („Wenig Zeit“ →
  schnelle Rezepte, „Unregelmäßige Mahlzeiten“/„Viel unterwegs“ →
  Meal-Prep). `recipeSortingReasons` liefert dieselben Gründe für Plan,
  Checkliste und den Hinweis im Rezepte-Tab – Text und Logik können nicht
  auseinanderlaufen. Ohne wirksame Angaben steht dort nichts.

## Aktualisierung: Fragen vor der Registrierung, 1. Oktober 2026

- **Neue Reihenfolge:** Einführung → Fragen → Konto erstellen (wie Yazio,
  Lifesum oder Fastic). Die Anmeldeseite startet danach im Modus
  „Registrieren“ mit „Fast geschafft!“ und „Antworten ändern“. „Schon ein
  Konto? Anmelden“ auf der ersten Frage; auf Geräten, die schon ein Konto
  hatten, kommt direkt die Anmeldung.
- **Antworten vor dem Konto** bleiben nur auf dem Gerät und werden nach
  Registrierung/Anmeldung automatisch ins Konto übernommen.
- **Fragen (bis zu 14 Schritte):** Name, Ziel, Motivation, Geschlecht,
  Geburtstag, Größe, Gewicht, Zielgewicht + Tempo (nur bei Gewichtsziel),
  Aktivität, Ernährungsweise + Allergien, Kochzeit + Erfahrung, Hürden,
  Gesundheitshinweis, Zusammenfassung „Dein Lookin-Plan“. Auswahl auf Basis
  einer Recherche der Fragebögen von Noom, Lifesum, MacroFactor, Yazio,
  MyFitnessPal, Lose It!, Fastic u. a.
- **Wirkung:** Geschlecht verfeinert den Energiebedarf (Mifflin-St Jeor),
  das Tempo bestimmt das Defizit (höchstens 20 %, nie unter Grundumsatz).
  Motivation, Hürden und Erfahrung gehen als Kontext an den Coach;
  Kochzeit priorisiert Rezepte. Mit Gesundheitshinweis keine Kalorienziele
  – auch nicht im Coach (`calorie_targets_paused`, ohne Grund). Das gilt
  jetzt auch für unter 18-Jährige, die vorher noch den Standardwert an den
  Coach übermittelten.
- **Schutz:** kein Zielgewicht unter BMI 18,5, Zielzeit als grobe Schätzung
  gekennzeichnet, keine Countdown- oder Rabatt-Tricks. Details:
  `PERSONALIZATION_PRIVACY.md`.
- **Plan-Animation (letzter Schritt):** Rund 4 Sekunden „Dein Plan wird
  erstellt …“ mit Fortschrittsring und Checkliste. Die Wartezeit ist reine
  Darstellung – die Berechnung selbst dauert Millisekunden –, deshalb nennt
  jede Zeile nur, was die App mit den Antworten wirklich tut, und nur, wenn
  es zutrifft (z. B. „Rezepte mit deinen Allergenen aussortieren“ nur mit
  Allergien). Danach zählen Kalorien hoch, Eiweiß/Kohlenhydrate/Fett füllen
  sich (Kohlenhydrate = Rest der Energie), eine Kurve zeigt den Weg zum
  Wunschgewicht als „grobe Schätzung“. Beim zweiten Besuch und mit
  „Bewegung reduzieren“ erscheint der Plan sofort.
- **Offen:** ausdrückliche Einwilligung (Art. 9 DSGVO) bei der
  Registrierung.

## Aktualisierung: E-Mail-Links und Lookin-Mails, 1. Oktober 2026

- **Befund:** Die Site URL in Supabase Auth steht auf `http://localhost:3000`;
  Reset-Links führen auf dem Handy deshalb ins Leere. Behebung im Dashboard,
  Schritt für Schritt in `EMAIL_SETUP.md` (noch offen, nicht im Code lösbar).
- **App:** Links mit `token_hash` (aus den neuen Vorlagen) werden beim Start
  selbst eingelöst und funktionieren geräteübergreifend. Abgelaufene oder
  bereits benutzte Links zeigen einen Hinweis statt einer leeren Seite.
- **Vorlagen:** Deutsche E-Mails im Lookin-Stil für Passwort-Reset,
  Registrierung und E-Mail-Wechsel unter `supabase/templates/`. Wirksam erst
  nach dem Einfügen im Dashboard; ein eigener Absender „Lookin“ braucht eine
  eigene Domain und einen Mailversand-Dienst (SMTP).

## Aktualisierung: Kontodaten, Login und Sicherheitsprüfung, 1. Oktober 2026

- **Lokal umgesetzt, noch nicht live geschaltet:** Unter Profil -> Datenschutz
  kann ein angemeldeter Nutzer seine eigenen Konto- und Gerätedaten als JSON
  exportieren oder sein Konto nach erneuter Passworteingabe löschen. Dafür muss
  die neue Supabase Edge Function `account-data` noch bereitgestellt werden.
  Der Server prüft das Zugriffstoken selbst und verwendet die Konto-ID aus
  Supabase Auth, nicht aus einer Nutzereingabe. Die Löschung entfernt alle
  zugeordneten Tabellenzeilen per Foreign-Key-Cascade und die lokalen Daten
  dieses Kontos. Store-Abos müssen später separat gekündigt werden.
- **Login:** Abmelden im Profil; neuer Passwort-Setzen-Bildschirm für
  Supabase-Recovery-Links. Die Auth-Redirect-URLs müssen im Supabase-Dashboard
  zur tatsächlichen Web-/Mobiladresse passen. Ein echter Ende-zu-Ende-Test mit
  E-Mail-Link steht noch aus.
- **Lokale Essens-Shortcuts:** Favoriten und zuletzt genutzte Lebensmittel sind
  nun pro Konto bzw. Vorschau getrennt. Alte globale Shortcut-Werte können
  keinem Konto sicher zugeordnet werden und werden deshalb verworfen.
- **Sicherheitsmigration:** `0015_security_definer_search_paths.sql` setzt den
  Suchpfad älterer privilegierter Funktionen auf leer. Die Migration muss
  noch auf der produktiven Datenbank ausgeführt werden.
- **Barcode-Zugriff:** Ein bereits gecachtes Premium-Lebensmittel wurde durch
  die Service-Role-Cache-Abfrage ohne Premium-Prüfung ausgegeben. Die
  `barcode-lookup` Function prüft jetzt das eigene Entitlement vor der
  Ausgabe. Auch diese Function muss für die Live-Wirkung neu deployt werden.
- **Grenze der Prüfung:** Dies war eine Prüfung von Quellcode und Migrationen,
  keine Live-Prüfung der Supabase-Konfiguration oder veröffentlichter Builds.
  Rechtstexte, ausdrückliche Einwilligung für Gesundheitsdaten, echte
  Bezahlung, Store-Freigabe und Benachrichtigungen sind dadurch nicht erledigt.
  Details: `ACCOUNT_DATA_PRIVACY.md`.

## Aktualisierung: Allergien und Unverträglichkeiten, 29. September 2026

- **Auswahl im Profil:** 14 EU-Allergene plus Laktose (Unverträglichkeit)
  als Chips, dazu freie Angaben. In der Einrichtung (letzter Schritt) und
  unter Profil → Ernährungsprofil; Änderungen landen in Cloud-Profil und
  lokaler Einrichtung gleichermaßen. Ältere Freitext-Angaben („Erdnüsse,
  Laktose“) werden automatisch zugeordnet.
- **Rezepte:** Rezepte mit erkanntem Auslöser werden im Rezepte-Tab und in
  „Was kann ich kochen?“ nicht angezeigt; der Tab nennt die Anzahl.
  Direkt geöffnete Rezepte zeigen einen Warnhinweis, Eintragen ins Tagebuch
  nur nach Bestätigung.
- **Lebensmittel:** Warnhinweis in Suche, Detailseite, Barcode-Produkt,
  eigenem Eintrag und KI-Fotoanalyse; vor dem Speichern eines Treffers eine
  Rückfrage. Fehlen Zutatenangaben, heißt es „Allergieangaben fehlen“.
- **KI-Coach:** Allergien gelten im Prompt als feste Ausschlusskriterien;
  der Coach bestätigt nie Sicherheit bei unklaren Zutaten. Die geänderte
  Edge Function `ai-coach` ist deployt.
- **Erkennung** (`features/allergies/domain/allergy_safety.dart`): Wortlisten
  je Allergen inkl. zusammengesetzter Wörter (Käse, Sahne, Nudeln, Hafer,
  Erdnussbutter, Rührei …) und Ausnahmen (Kokosmilch, Buchweizen,
  Muskatnuss, veganer Käse, glutenfrei). 43 Unit-Tests.
- **Grenzen:** Textprüfung, keine Sicherheitsgarantie und keine medizinische
  Beratung; Spuren und Kreuzkontamination werden nicht erfasst. Details und
  offene Datenschutzpunkte (Art. 9 DSGVO): `ALLERGY_SAFETY.md`.

## Aktualisierung: Wochenplan, Einkaufsliste und Vorräte entfernt, 29. September 2026

- Wochenplan, Einkaufsliste und Vorräte sind **komplett aus der App
  gelöscht** (Code, Tests und `KITCHEN_LISTS_PRIVACY.md`). Die folgenden
  älteren Abschnitte zu diesen Funktionen gelten nicht mehr.
- Entfernt: Bereich „Planen & vorbereiten“ im Rezepte-Tab, Wochenplan-Knopf
  und „Zutaten auf die Einkaufsliste“ in der Rezeptansicht, in „Was kann ich
  kochen?“ Vorräte und Einkaufsliste. Einführung und Löschdialog erwähnen
  die Funktionen nicht mehr.
- **Weiterhin aktiv:** „Was kann ich kochen?“ mit selbst gewählten Zutaten;
  der Schalter „Grundzutaten sind vorhanden“ gilt nur noch für die geöffnete
  Seite. Die Haken „schon da“ in der Zutatenliste eines Rezepts bleiben.
- **Datenminimierung:** Beim App-Start werden Listen, die frühere Versionen
  unter `livo.kitchen.v1.<Konto-ID>` auf dem Gerät gespeichert haben, für das
  angemeldete Konto gelöscht.

## Aktualisierung: Neue Einkaufsliste, 29. September 2026

- **Ein Eingabefeld für Name und Menge:** „500 g Reis“, „Reis 500g“,
  „Milch, 1 l“, „2 Eier“ oder „3x Joghurt“ werden in Artikel und Menge
  zerlegt; eine Vorschau zeigt vorher, wie der Eintrag gelesen wird. Was nicht
  eindeutig eine Menge ist („7-Korn Brot“, „Mehl Type 405“), bleibt
  unverändert Teil des Namens. Die Tastatur bleibt für den nächsten Artikel
  offen. Beim Tippen erscheinen Vorschläge aus Grundzutaten und Katalog,
  bei leerem Feld Schnellauswahl-Chips häufiger Artikel.
- **Nach Supermarkt-Abteilung sortiert:** Obst & Gemüse, Brot & Backwaren,
  Kühlregal & Eier, Fleisch & Fisch, Nudeln/Reis/Vorrat, Konserven & Gläser,
  Öl/Gewürze/Soßen, Tiefkühl, Getränke, Sonstiges. Die Zuordnung ist eine
  lokale Stichwortregel (`domain/shopping_aisles.dart`), keine KI und kein
  externer Dienst; Unbekanntes landet unter „Sonstiges“ statt geraten zu
  werden.
- **Abhaken und Fortschritt:** Fortschrittsring im Kopf, kurze Abhak-
  Animation, danach wandert der Artikel in den einklappbaren Bereich
  „Im Wagen“. Wenn alles abgehakt ist, erscheint ein Hinweis; eine feste
  Leiste bietet „In Vorräte übernehmen“ und „Erledigte löschen“.
- **Bearbeiten, Löschen mit Rückgängig, Teilen:** Name und Menge lassen sich
  nachträglich ändern (Halal-Prüfung wie beim Hinzufügen). Löschen per
  Wischen oder im Bearbeiten-Dialog, danach 5 Sekunden „Rückgängig“.
  „Liste als Text kopieren“ legt die offenen Artikel nach Abteilung in die
  Zwischenablage, z. B. zum Einfügen in einen Chat – die App sendet dabei
  selbst nichts.
- **Barrierefreiheit:** Bei „Bewegung reduzieren“ wird sofort abgehakt, ohne
  Einblend- oder Größenanimationen. Status steht immer auch als Text da
  („2 Artikel offen · 1 im Wagen“), nicht nur als Farbe. Auf kleinen Displays
  oder mit großer Schrift scrollen Untertitel und Eingabe mit der Liste.
- **Unverändert:** Speicherung wie bisher nur auf diesem Gerät (mit Konto)
  bzw. bis zum Neustart (ohne Konto); keine neuen Daten, Berechtigungen oder
  externen Dienste. Vorräte und Wochenplan folgen als nächste Schritte.

## Aktualisierung: Neue Alltagsrezepte, 27. September 2026

- 30 neue, selbst verfasste Rezepte mit Zutaten, die fast jeder zu Hause hat:
  Kartoffeln (8 Rezepte), Reis (7), Nudeln (4), Eier, Haferflocken, Linsen,
  Kichererbsen, Bohnen, Dosentomaten, Mehl, Milch, Joghurt/Quark, Brot,
  TK-Gemüse und Thunfisch. Mehrere kommen mit 3–6 Zutaten aus (z. B.
  Kartoffel-Tortilla, Pfannkuchen, Milchreis, geröstete Kichererbsen).
  Der Katalog umfasst damit 40 Rezepte.
- Kostenlos sind 12 von 40 Rezepten (30 %, wie in der App angegeben), darunter
  Pellkartoffeln mit Kräuterquark, Bratkartoffeln mit Spiegelei,
  Rote-Linsen-Dal mit Reis, Nudeln mit Tomatensauce, Apfel-Zimt-Porridge,
  Rührei auf Vollkornbrot und die Reis-Ei-Bowl (vorher Premium). Die beinahe
  doppelten Rezepte „Ei-Avocado-Frühstück“ und „Skyr-Hafer-Cup“ sind dafür
  jetzt Premium.
- Die zehn bisherigen Rezepte haben ausführliche Schritte, Timer, Utensilien,
  Haushaltsmaße und Premium-Extras bekommen. Fünf alte, doppelte bzw. wegen
  fehlender Halal-Kennzeichnung ohnehin ausgeblendete Einträge werden
  entfernt (`berry-protein-oats`, `salmon-power-bowl`, `vegetable-egg-pan`,
  `livo-chicken-rice-bowl`, `livo-chicken-avocado-plate`).
- Halal: kein Schweinefleisch, kein Alkohol (auch kein Essig, keine Sojasauce,
  kein Vanilleextrakt), keine Gelatine. Einziges Fleischrezept ist der
  „Halal-Hähnchen-Paprika-Reis“ mit ausdrücklich halal gekennzeichnetem
  Hähnchen. Bei Käse (Feta) weist die Zutat auf die Lab-Art auf der Packung
  hin. Alle Texte bestehen die erweiterte Halal-Prüfung (App und Migration
  `0014`).
- Nährwerte werden wie bisher aus den Zutatenmengen berechnet. Neue
  Lebensmittel (47, z. B. „Kartoffeln“, „Zwiebeln“, „Dosentomaten, gehackt“,
  „Paprikapulver, edelsüß“) stammen aus USDA FoodData Central mit FDC-ID an
  jedem Datensatz. „Magerquark“ ist ein Näherungswert (USDA fettarmer
  griechischer Joghurt), weil USDA keinen Quark führt; das steht in der
  Quellenangabe. „High Protein“ nur ab 20 % Energie aus Protein.
- Fotos: 25 neue echte Food-Fotos von Pexels (Lizenz auf jeder Fotoseite
  geprüft, Quellen in `assets/ASSET_SOURCES.md`). Fünf Rezepte ohne ehrlich
  passendes Foto nutzen vorerst das Standardbild.
- Technisch: Die Rezepte stehen jetzt geprüft in
  `supabase/content/livo_recipes.json`; daraus erzeugt
  `tool/generate_recipe_sql.dart` die wiederholbare Migration
  `supabase/migrations/0010_recipe_content.sql`. Die veraltete Datei
  `supabase/imports/curated_recipes.sql` wurde entfernt.
- **Noch nicht live:** Die Migration ist nicht eingespielt. Bis dahin zeigt
  die App die bisherigen zehn Kurzrezepte. Kein Einfluss auf Datenschutz:
  reine Kataloginhalte, keine Nutzer- oder Gesundheitsdaten.

## Aktualisierung: Premium-Preise und 7-Tage-Test, 27. September 2026

- Die kostenlose Testphase von Lookin Premium dauert jetzt 7 statt 3 Tage. Sie
  gilt weiterhin einmal pro Konto, fragt keine Zahlungsdaten ab und endet
  automatisch ohne Kosten und ohne Verlängerung.
- Neue Festpreise inkl. MwSt.: monatlich 4,99 € pro Monat, jährlich 45,99 €
  einmal pro Jahr. Die bisherigen Einführungsangebote (monatlich 7,99 € mit
  4,99 € in den ersten 3 Monaten, jährlich 71,88 € mit 65,88 € im ersten Jahr)
  entfallen ersatzlos.
- Die Paywall zeigt beim Jahresabo „entspricht 3,84 € pro Monat“ (45,99 € ÷ 12
  = 3,8325 €, auf den nächsten Cent aufgerundet, damit der Monatswert nie zu
  niedrig wirkt) und „du sparst 13,89 € gegenüber monatlich“ (12 × 4,99 € =
  59,88 €). Das Abzeichen „−23 %“ ist auf ganze Prozent gerundet (genau
  23,2 %). Alle Beträge werden aus
  `lib/features/subscription/domain/subscription_plans.dart` berechnet.
- Bezahlung ist weiterhin nicht angebunden (`storeBillingAvailable = false`):
  Kauf-Buttons sagen das offen, es wird nichts gekauft oder berechnet. Was
  kostenlos und was Premium ist, bleibt unverändert.
- Serverseitig legt die neue, wiederholbare Migration
  `supabase/migrations/0011_premium_trial_seven_days.sql` die Länge fest. Sie
  ist noch nicht eingespielt; bis dahin startet der Server weiterhin
  3-Tage-Tests, obwohl die App 7 Tage nennt. Die Migration daher vor oder
  zusammen mit dem App-Update ausführen. Bereits laufende Tests behalten ihr
  gespeichertes Enddatum.
- Datenschutz: unverändert. Für die Testphase speichert Lookin weiterhin nur
  Konto-ID, Start und Ende (`premium_trials`) und keine Zahlungsdaten.
- Geprüft: Flutter-Analyse ohne Befund; neue Tests in
  `test/subscription_plans_test.dart` decken Preise, Monatswert, Ersparnis,
  Paywall-Texte und die Paywall auf 390 px sowie 320 px mit doppelter
  Schriftgröße ab.

## Aktualisierung: KI-Coach-Chat, 27. September 2026

- Chat überarbeitet: „Coach schreibt …“-Anzeige, Eingabe und Senden während
  der Antwort gesperrt (kein Doppelsenden), Zeichenzähler bis 600 Zeichen,
  automatisches Scrollen (lange Antworten zeigen ihren Anfang), Eingabefeld
  sitzt auf dem Handy direkt über Tastatur bzw. Navigation.
- Klare deutsche Hinweise mit „Erneut versuchen“ für Verbindungsfehler,
  Zeitüberschreitung (55 s in der App, 45 s für die KI im Server) und
  Serverfehler; Tageslimit sperrt die Eingabe bis zum nächsten Tag ohne
  sinnlosen Wiederholen-Knopf; abgelaufenes Premium/Testphase führt zum
  Premium-Hinweis. Eine fehlgeschlagene Frage wird beim Wiederholen nicht
  doppelt angezeigt; nach einer Zeitüberschreitung wird eine inzwischen
  gespeicherte Antwort übernommen statt erneut bezahlt.
- Antworten mit Listen und **fett** werden sauber dargestellt, ohne rohe
  Sternchen. Leere oder unlesbare KI-Antworten werden abgefangen; fehlgeschlagene
  KI-Anfragen zählen nach Migration 0013 nicht mehr zum Tageslimit.
- Neue, strengere Systemanweisung (Lookin-Rolle, Halal-Regel, keine Diagnosen,
  Medikamente, Supplement-Dosierungen oder Extremdiäten, Verweis auf Hilfe
  bei Minderjährigen, Schwangerschaft, Essstörungen und Erkrankungen).
- Premium-Status nicht ladbar (offline): Hinweis mit „Erneut versuchen“ statt
  fälschlich der Paywall. Nach beendeter Testphase passt der Text.
- Verlauf: bleibt pro Konto gespeichert und wird beim Öffnen geladen (letzte
  100 Nachrichten, höchstens 90 Tage; an die KI gehen nur die letzten 12).
  „Neuer Chat“ bzw. „Verlauf löschen“ löscht nach Rückfrage alles endgültig
  auf dem Server – auch ohne Premium. Lange Antworten (über 1200 Zeichen)
  gingen bisher komplett aus dem Verlauf verloren; das ist behoben.
- Kontext „Kalorien heute“ nutzt jetzt wirklich den heutigen Tag, nicht den
  gerade im Tagebuch geöffneten Tag.
- Live noch nötig: zuerst Migration `0013_ai_coach_chat.sql` ausführen, dann
  die Edge Function `ai-coach` neu deployen. Die derzeit deployte Version
  (Stand vor dem Premium-Umbau) kennt weder Premium-Pflicht noch „Verlauf
  löschen“. Details: `AI_COACH_PRIVACY.md`.

## Aktualisierung: Fehlerbehebungen, 27. September 2026

- Lebensmittelsuche: Der Katalog wird jetzt seitenweise geladen. Bei der
  Standardgrenze von Supabase (1.000 Zeilen pro Abfrage) kamen vorher nur etwa
  ein Sechstel der rund 5.800 importierten Lebensmittel in der App an;
  Rezepte, deren Zutaten dahinter lagen, zeigten zu niedrige Nährwerte.
- Barcode: Produkte, die gegen die Halal-Regel verstoßen, zeigen wieder den
  richtigen Hinweis statt „keine gültige Serverantwort“. Nach einem
  Fehlschlag wird derselbe Barcode nicht mehrmals pro Sekunde erneut gesucht
  (das verbrauchte sonst das Abfragelimit).
- Gescannte Produkte lassen sich nach dem Eintragen wieder bearbeiten und
  duplizieren („Lebensmittel konnte nicht mehr gefunden werden“ ist behoben).
- Einträge lassen sich jetzt im Bearbeiten-Fenster löschen („Eintrag
  löschen“, mit Rückfrage) – auch auf der Startseite, wo es vorher keinen Weg
  zum Löschen gab. Gespeicherte Einträge werden auch in Supabase gelöscht.
- Ein schneller Doppeltipp auf „Hinzufügen“ erzeugt keine doppelten
  Tagebucheinträge mehr.
- Einträge eines Tages erscheinen in der Reihenfolge, in der sie eingetragen
  wurden (vorher nach dem Neuladen umgekehrt).
- Fehlermeldungen im Tagebuch sind deutsch statt technischer englischer
  Servertexte.
- Datenschutz-Fenster: Der falsche Satz „Aktuell verlässt kein Profil- oder
  Ernährungswert diese Demo“ wurde ersetzt. Es zeigt jetzt ehrlich, was im
  Konto (Supabase) liegt, was an den KI-Dienst (OpenAI) geht und was nur auf
  dem Gerät bleibt. „Lokale Demodaten löschen“ blendet bei angemeldeten
  Konten keine gespeicherten Mahlzeiten und Favoriten mehr aus, die gar nicht
  gelöscht wurden.
- Rezeptdetail: Keine Layoutfehler mehr bei großer Systemschrift auf
  schmalen Handys (Makro-Anteile und Zutatenmengen umbrechen jetzt).
- Tippfehler ohne Umlaute im Tagebuch korrigiert („Nährwerte“, „Änderungen“).
- Halal-Regel verschärft: Rund 200 weitere Katalogeinträge werden jetzt
  gesperrt, darunter Cocktails (Daiquiri, Margarita, Martini, Tequila),
  Wurst- und Schweineprodukte (Bologna, Bratwurst, Chorizo, Spam, Hot Dog),
  Burger, Steaks, Innereien, Wild und Geflügel ohne Halal-Kennzeichnung sowie
  Gummibärchen und Marshmallows. Gleichzeitig sind harmlose Einträge wieder
  sichtbar, die vorher fälschlich gesperrt waren (z. B. Ziegenkäse,
  Ziegenmilch, Entenei und fleischlose Gerichte mit „meatless“). Details:
  `HALAL_CONTENT_POLICY.md`.
- Die App-Änderungen wirken sofort. Für die Datenbank muss noch die Migration
  `0014_halal_terms_extended.sql` ausgeführt werden, und die Edge Function
  `barcode-lookup` muss neu deployt werden. Erst danach gelten die neuen
  Begriffe auch serverseitig.

## Aktualisierung: Wochenplan, Einkaufsliste, Vorräte und Kochen mit Vorhandenem, 27. September 2026

- **Speicherort:** Wochenplan, Einkaufsliste und Vorräte werden pro
  angemeldetem Konto **nur auf diesem Gerät** gespeichert
  (`livo.kitchen.v1.<Konto-ID>`, SharedPreferences). Sie überstehen einen
  Neustart, werden aber nicht in Supabase gespeichert und erscheinen nicht auf
  anderen Geräten. Die Sheets sagen das ausdrücklich. Ohne Konto (Vorschau)
  gelten die Listen nur bis zum Neustart. Es gibt keine Demo-Einträge mehr.
- **Warum lokal:** Das Schema hat keine passenden Tabellen; eine neue
  Migration müsste erst live ausgeführt werden, bevor die Funktion auf GitHub
  Pages nutzbar wäre. Die Speicherung liegt hinter `PlanningStore`, sodass
  später eigene Supabase-Tabellen mit RLS eingesetzt werden können.
- **Kontowechsel/Abmeldung:** Jedes Konto hat einen eigenen Schlüssel; beim
  Kontowechsel wird ein neuer Zustand geladen. Nicht lesbare Daten werden
  nicht überschrieben – Änderungen sind dann gesperrt, bis „Erneut versuchen“
  klappt oder die Listen bewusst zurückgesetzt werden. Speicherfehler werden
  angezeigt. „Lokale Demodaten löschen“ im Profil entfernt auch diese Listen.
  Planeinträge älter als acht Wochen werden beim Laden entfernt.
- **Vorräte:** Zutat mit optionaler Menge („500 g“, „1,5 kg“, „2 Stück“,
  „1 Dose“; Unklares bleibt als Text), Schnellauswahl häufiger Zutaten
  (Kartoffeln, Reis, Nudeln, Eier, Zwiebeln, Haferflocken, Milch, Mehl,
  Dosentomaten, Linsen …) zum An- und Abwählen, doppelte Einträge werden
  zusammengeführt, „Alle entfernen“.
- **Was kann ich kochen?** Prominent im Rezepte-Tab und in den Vorräten.
  Zutaten antippen, eintippen (mit Vorschlägen aus dem Katalog) oder Vorräte
  verwenden. Rezepte mit mindestens einer eigenen Zutat erscheinen nach Anteil
  vorhandener Zutaten, dann nach den wenigsten fehlenden sortiert; jede Karte
  zeigt „Hast du“, „Fehlt“ und vorausgesetzte Grundzutaten sowie „x von y
  da“ als Text. Der Abgleich ist tolerant (Groß-/Kleinschreibung, Umlaute und
  ae/oe/ue, Einzahl/Mehrzahl, Zusätze wie „festkochend“, Synonyme wie
  Erdäpfel/Paradeiser/Möhren) und hält ähnliche, aber andere Zutaten getrennt
  (Süßkartoffel, Kokosmilch, Kichererbsen, Frühlingszwiebeln). Salz, Pfeffer,
  Öl, Wasser und gängige Gewürze zählen standardmäßig als vorhanden; der
  Schalter ist sichtbar und wird gespeichert. Der Abgleich arbeitet mit der
  Zutatenliste jedes Katalogrezepts, ohne feste Rezept-IDs. Premium-Rezepte
  tragen das Plus-Abzeichen; freie Konten sehen wie im Katalog den
  Premium-Hinweis. „Fehlende Zutaten auf die Einkaufsliste“ ist je Rezept
  möglich. Der Abgleich ist eine Orientierung, keine Allergen- oder
  Halal-Prüfung.
- **Wochenplan:** echte Kalenderwochen (Montag–Sonntag) mit Vor/Zurück und
  „Zur aktuellen Woche“; Rezepte je Tag und Mahlzeit mit Portionen einplanen
  (auch direkt aus dem Rezept über das Kalender-Symbol), verschieben/ändern,
  entfernen, Woche leeren. Der Plan ist nutzergesteuert – es werden keine
  Pläne oder Kalorienvorgaben erzeugt. „Einkaufsliste aus Wochenplan
  erstellen“ addiert die Zutaten der Woche (gleiche Zutat, Gramm), zieht
  Vorräte (Gramm-Mengen werden verrechnet, andere Mengen gelten als
  vorhanden) und optional Grundzutaten ab und zeigt eine Zusammenfassung.
  Erneutes Erstellen ersetzt die Einträge derselben Woche statt sie zu
  verdoppeln; Einträge, die schon auf der Liste stehen, werden nicht doppelt
  angelegt.
- **Einkaufsliste:** hinzufügen mit optionaler Menge, abhaken, löschen,
  „Erledigte löschen“, „Liste leeren“, erledigte Artikel in die Vorräte
  übernehmen (Mengen gleicher Einheit werden addiert); Herkunft („für
  Linsen-Dal“) wird angezeigt.
- Selbst eingegebene Einträge folgen der Halal-Inhaltsregel (wie beim
  Selbsteintrag im Tagebuch).
- Geprüft: `flutter analyze` ohne Befund; neue Unit-Tests für Abgleich,
  Mengen, Wochenplan→Einkaufsliste, Controller und Gerätespeicher sowie
  Widget-Tests für alle Abläufe bei 390 × 844, 320 × 568 mit doppelter
  Schrift, 740 × 360 und 1280 × 800 mit reduzierter Bewegung. Zwei bereits
  vorher fehlschlagende Tests in `recipe_detail_test.dart` (Profi-Tipp-Text,
  Überlauf der Rezeptdetail-Zeilen bei großer Schrift) sind unverändert und
  gehören nicht zu dieser Änderung. Details zu Daten: `KITCHEN_LISTS_PRIVACY.md`.

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
  (`image_picker`). Im Browser und auf Desktop öffnet Lookin eine eigene
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
- Dunkle bestehende Lookin-Farbwelt, ein Lime-Akzent, animierte Vorschaukarten,
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

## Aktualisierung: App-Einführung, 26. September 2026

- Die Einführung hat jetzt sechs Seiten, die nur echte Funktionen zeigen:
  Tagebuch mit vier Mahlzeiten und Makros, Plus-Menü (KI-Foto, Barcode,
  manuell), KI-Foto mit bearbeitbarer Menge, Lookin Coach, Rezepte mit
  Wochenplan und Einkaufsliste sowie Profil mit Serie und Tageszielen.
  Wasser- und Fortschrittsseite wurden entfernt, weil diese Funktionen in der
  App derzeit nicht nutzbar sind.
- Animationen dauern 2,4 Sekunden pro Seite, bleiben endlich, wiederholbar
  und respektieren `MediaQuery.disableAnimations`.
- Der Marker `livo.introduction.completed.v3` zeigt die neue Einführung
  einmal auch Geräten, die die alte Version schon gesehen haben.

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
| Einkaufsliste | **Entfernt am 29.09.2026.** Ein Eingabefeld für Name und Menge („500 g Reis“), Schnellauswahl und Vorschläge, Sortierung nach Supermarkt-Abteilung, Abhaken mit Fortschrittsring und Bereich „Im Wagen“, Bearbeiten, Löschen mit Rückgängig, Liste als Text kopieren, erledigte Artikel in die Vorräte übernehmen, fehlende Zutaten aus Rezepten und „Was kann ich kochen?“ sowie aus dem Wochenplan übernehmen; mit Konto nur auf diesem Gerät gespeichert (Stand 29.09.2026) |
| Fortschritt | Animierter Gewichtsgraph mit Zielmarke; sieben Punkte sind antippbar und ändern den angezeigten Wert |
| Weitere Diagramme | Animierte Wochenbalken für Kalorien und Protein sowie lokale Statistik- und Meilensteinkarten |
| Profil | Profilansicht mit lokalem Avatar; Name, Ziel, Kalorienziel und Zielgewicht lassen sich bearbeiten |
| Ernährungsprofil | Stil, Allergien und Aktivitätsniveau lassen sich lokal bearbeiten |
| Planung & Vorräte | **Entfernt am 29.09.2026.** Wochenplan, Einkaufsliste und Vorräte werden pro Konto auf diesem Gerät gespeichert und überstehen einen Neustart; keine Cloud-Synchronisierung (Stand 27.09.2026) |
| Was kann ich kochen? | Zutaten wählen oder Vorräte nutzen; Katalogrezepte nach Anteil vorhandener Zutaten sortiert, fehlende Zutaten sichtbar und auf die Einkaufsliste übertragbar (Stand 27.09.2026) |
| Einstellungen | Premium-Vorschau, Erinnerungs-Schalter, Datenübersicht, Löschdialog und Sicherheitshinweise |
| Animationen | Seitenwechsel, gestaffelte Reveals, Press-Feedback, Ringe, Zahlen, Balken, Favoriten und Coach-Orb |
| Bilder | Drei lokale Food-WebPs und ein lokales Profil-WebP; keine Bilder werden zur Laufzeit aus dem Internet geladen |

## Lokal vorbereitet oder nur teilweise funktionsfähig

| Bereich | Was bereits sichtbar ist | Was noch fehlt |
| --- | --- | --- |
| Tagesauswahl | Sieben auswählbare Tage | Eigene Mahlzeiten und Summen je Datum; echte Kalenderdaten |
| Mahlzeitenerfassung | Demo-Suche und schnelles Hinzufügen | Freier Eintrag, Mengen, Bearbeiten, eigene Lebensmittel und Validierung |
| Rezeptdetails | Bild, Kennzahlen, Zutaten- und Zubereitungsansicht; Rezept kann ins Tagebuch übernommen werden | Rezeptspezifische Zutaten/Zubereitung und Portionseditor |
| Wochenplan | **Entfernt am 29.09.2026.** Echte Kalenderwochen, Rezepte je Tag und Mahlzeit mit Portionen einplanen, verschieben, entfernen, Woche leeren, Einkaufsliste aus der Woche erstellen | Synchronisierung zwischen Geräten, Drag & Drop, Übernahme ins Tagebuch |
| Vorräte | **Entfernt am 29.09.2026.** Hinzufügen/Entfernen, optionale Menge, Schnellauswahl häufiger Zutaten, Rezeptabgleich „Was kann ich kochen?“ | Ablaufdaten, automatische Verbrauchsbuchung beim Kochen, Synchronisierung zwischen Geräten |
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

## Aktualisierung: Name Lookin und neue Preise, 2. Oktober 2026

- Die App heißt jetzt **Lookin – AI Food Tracker** (Store-Titel, 25 Zeichen);
  im UI, in den KI-Anweisungen, E-Mail-Vorlagen, Web-Manifest, Android-Label
  und iOS-Namen steht „Lookin“. Die Marke ist weiterhin **nicht** geprüft
  (DPMA/EUIPO-Recherche steht aus, siehe `AGENTS.md`).
- Die Paketkennung ist jetzt `com.lookin.foodtracker` (Android und iOS). Sie
  ist nach der ersten Veröffentlichung nicht mehr änderbar.
- Absichtlich unverändert, damit nichts verloren geht: lokale
  Speicherschlüssel `livo.*`, bereits ausgeführte Datenbank-Migrationen,
  Bilddateinamen `livo-*.webp` und der Trial-Anbieter `livo_trial`. Das sind
  technische Namen, die Nutzer nicht sehen. Die Einführung hat einen neuen
  Marker (`v4`) und wird einmal erneut gezeigt.
- Neue Festpreise inkl. MwSt.: monatlich 6,99 €, jährlich 59,99 €. Die
  Paywall zeigt „entspricht 5,00 € pro Monat“ (59,99 € ÷ 12 = 4,9992 €,
  aufgerundet) und „du sparst 23,89 € gegenüber monatlich“ (12 × 6,99 € =
  83,88 €), Abzeichen „−28 %“ (genau 28,5 %). Alles wird aus
  `subscription_plans.dart` berechnet.
- Die geplanten Store-Produkt-IDs heißen jetzt `lookin_premium_monthly` und
  `lookin_premium_yearly`. Bezahlung ist weiterhin **nicht** angebunden
  (`storeBillingAvailable = false`).
- Der Release-Build ist weiterhin mit dem Debug-Schlüssel signiert. Vor dem
  Play-Store-Upload braucht es einen eigenen Upload-Schlüssel.

## Aktualisierung: Store-Bezahlung vorbereitet, 2. Oktober 2026

- **Gebaut, aber noch nicht live:** Kauf, „Käufe wiederherstellen“ und „Abo
  verwalten“ laufen über RevenueCat (`purchases_flutter`) hinter der
  austauschbaren Schicht `StoreBilling`. Ohne `REVENUECAT_ANDROID_KEY` im Build
  verhält sich die App wie vorher: Die Paywall sagt, dass die Bezahlung
  eingerichtet wird, und nichts wird gekauft. Im Browser steht, dass Abos in
  der Android-App abgeschlossen werden. iOS ist nicht eingerichtet.
- Premium gilt erst, wenn der **Server** es bestätigt: Die Function
  `revenuecat-webhook` (deployed, ohne gesetztes Geheimnis lehnt sie alles mit
  503 ab) schreibt über `apply_revenuecat_event()` in `public.entitlements`.
  Die Migration `0016_store_billing_entitlements.sql` liegt im Repository und
  **ist noch nicht auf die Produktionsdatenbank angewendet**; sie muss vor dem
  ersten Kauf laufen.
- Nach einem Kauf fragt die App den Server bis zu 8 Mal; kommt der Webhook
  später, sagt sie ehrlich „Freischaltung dauert noch einen Moment“.
- Die App-Testphase (7 Tage, ohne Zahlungsdaten) bleibt serverseitig. In der
  Play Console darf an den Abos kein eigenes Gratis-Angebot hängen.
- Android: Internet-Berechtigung ergänzt (fehlte im Release-Manifest, eine
  Release-App hätte Supabase nicht erreicht), Release-Signierung mit eigenem
  Upload-Schlüssel (`android/key.properties`, Keystore; beides von Git
  ignoriert). Ein Release-Bundle (`app-release.aab`, 72 MB) wurde erfolgreich
  gebaut; auf einem echten Gerät ist es noch nicht getestet.
- Neue Datenempfänger: RevenueCat (Konto-ID, Kaufdaten) und Google Play. Vor
  dem Start sind Auftragsverarbeitungsvertrag, Datenschutzerklärung, Händlerprofil
  und Gewerbe nötig. Details und Einrichtung: `docs/BILLING_SETUP.md`.
