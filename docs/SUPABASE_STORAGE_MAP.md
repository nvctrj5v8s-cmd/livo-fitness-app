# Was Supabase speichert

Lookin nutzt Supabase nur für Daten, die nach einem Gerätewechsel weiterhin zum
angemeldeten Konto gehören sollen.

| Bereich | Speicherort | Warum |
| --- | --- | --- |
| Anmeldung und Sitzung | Supabase Auth | Konto über mehrere Geräte hinweg |
| Name, Ziel, Kalorien- und Proteinziele, freiwillige Allergien/Unverträglichkeiten | `public.profiles` | persönliches Profil bleibt beim Gerätewechsel erhalten; Allergien: `ALLERGY_SAFETY.md` |
| Lebensmittel, Rezepte, Zutaten und Quellen | Katalogtabellen | gemeinsamer, versionierbarer Datenbestand |
| Premium-Rezeptextras (Profi-Tipps, Fehler, Austausch, Meal-Prep, Varianten) | `recipe_premium_details` | Katalogdaten; RLS gibt sie nur an Konten mit aktivem Premium oder Testphase heraus |
| Getrackte Mahlzeiten und Mengen | `meals`, `meal_items` | Tagebuch und Serie sollen geräteübergreifend stimmen |
| Rezeptfavoriten | `favorites` | gehören zum Konto |
| Lookin-Coach-Verlauf (höchstens 100 Nachrichten, 90 Tage, jederzeit löschbar) und KI-Tageszähler | `ai_chat_messages`, `ai_chat_usage` | Chat bleibt beim Gerätewechsel erhalten; Details `AI_COACH_PRIVACY.md` |
| Premium-Status | `entitlements` | später nur vom Kauf-Backend veränderbar |
| Genutzte 7-Tage-Testphase (nur Konto-ID, Start und Ende) | `premium_trials` | die kostenlose Testphase gilt einmal pro E-Mail-Adresse (Hash in `trial_claims`, max. 3 Jahre, auch nach Kontolöschung); keine Zahlungs- oder Gesundheitsdaten |
| Antworten der persönlichen Einrichtung (Geburtstag, Größe, Gewicht, Zielgewicht, Geschlecht, Motivation, Hürden, Gesundheitshinweis, Allergien) – nur mit Einwilligung in die Gesundheitsangaben | `personalization_answers` | Kopie für neue Geräte; wird bei Widerruf, Zurücksetzen und Konto-Löschung gelöscht |
| Einwilligungen und Nachweis zum Sofortbeginn (Art, Entscheidung, Zeit, Textversion mit Sprache) | `user_consents` | Nachweis nach Art. 7 DSGVO; wird mit dem Konto gelöscht |
| Widerrufe (Name, E-Mail, Vertragshinweis, Zeit, IP-Prüfwert höchstens 24 Stunden) | `withdrawal_requests` | Nachweis der Widerrufserklärung; Konto-ID wird beim Löschen entfernt |
| Hash der Testphasen-Adresse | `trial_claims` | verhindert eine zweite Testphase; höchstens 3 Jahre |

## Bleibt nur auf dem Gerät

- Profilbild
- Antworten aus der freiwilligen Einführung – nur ohne Einwilligung in die
  Gesundheitsangaben; mit Einwilligung liegt eine Kopie im Konto
  (`personalization_answers`, Migration `0022`)
- Erinnerungsschalter
- zuletzt verwendete und lokal gemerkte Lebensmittel
- vorübergehende UI-Zustände

Diese lokalen Daten werden nicht automatisch auf ein neues Handy übertragen.
Das Profilbild wird ausdrücklich nicht zu Supabase hochgeladen.

## Niemals in Flutter oder Supabase-Tabellen speichern

- OpenAI-API-Schlüssel oder andere Secret-/`service_role`-Keys
- unbestätigte KI-Fotoanalysen
- Gesundheitsdiagnosen oder medizinische Angaben ohne ein klar definiertes,
  geprüftes Datenschutz- und Sicherheitskonzept

Jede Tabelle mit persönlichen Daten nutzt Row Level Security (RLS), sodass ein
angemeldeter Nutzer nur seine eigenen Zeilen lesen oder ändern kann. Katalog-
daten sind gezielt lesbar, aber aus der App nicht schreibbar.
