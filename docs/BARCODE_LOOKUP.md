# Barcode-Produktabfrage

LIVO liest einen gescannten Lebensmittel-Barcode über die Supabase Edge
Function `barcode-lookup`. Die Funktion fragt Open Food Facts ab, speichert
die zurückgegebenen Produktdaten als gemeinsamen Katalogeintrag und zeigt dem
Nutzer erst eine kontrollierbare Detailansicht. Erst nach Auswahl von Menge
und Mahlzeit wird etwas in das persönliche Tagebuch geschrieben.

## Daten und Grenzen

- Quelle: Open Food Facts, mit Produktname, Marke, Zutaten, Allergentags,
  Nährwerten pro 100 g, Nutri-Score, NOVA-Gruppe und Verpackungsmenge, sofern
  die Quelle diese Daten hat.
- Die App lädt keine Produktfotos und schreibt keine Produktdaten zurück zu
  Open Food Facts.
- Produktangaben können unvollständig oder veraltet sein. Die Verpackung ist
  bei Allergien, Unverträglichkeiten und medizinischen Fragen maßgeblich.
- Nur eine noch nicht im Katalog vorhandene Nummer wird bei Open Food Facts
  abgefragt. Die Function erlaubt dafür höchstens zwölf externe Suchen pro
  Konto und Minute und schützt vor versehentlichen Endlosschleifen. Die
  Grenzen des Datenanbieters gelten zusätzlich pro Server-IP; bei sehr vielen
  Nutzern muss dieses Limit zentral weiter abgesenkt oder ein passender
  kommerzieller Datenanbieter verwendet werden.
- Gespeicherte Produktdaten enthalten sichtbar Quelle, Lizenz und Attribution.
  Open Food Facts-Daten unterliegen der Open Database License (ODbL); vor
  Veröffentlichung müssen die aktuellen Wiederverwendungsbedingungen geprüft
  und die Attribution in der App erhalten bleiben.

## Einmalig im Supabase-Dashboard ausführen

1. Im **SQL Editor** `migrations/0003_barcode_product_details.sql` vollständig
   ausführen. Das ergänzt die Produktfelder und das serverseitige Limit.
2. Unter **Edge Functions** auf **Deploy a new function** → **Via Editor**.
   Name: `barcode-lookup`. Den Inhalt von
   `supabase/functions/barcode-lookup/index.ts` vollständig einfügen und
   **Deploy function** drücken. JWT-Prüfung eingeschaltet lassen.
3. Unter **Edge Function Secrets** einen neuen Wert anlegen:
   `OFF_USER_AGENT` = `LIVO/0.1 (deine-echte-email@example.com)`.
   Die E-Mail muss später erreichbar sein; Open Food Facts verlangt einen
   eindeutig zuordenbaren User-Agent. Keine Supabase-Secret- oder
   service_role-Keys selbst eintragen – diese stellt Supabase der Function
   bereits intern bereit.
4. Bei Open Food Facts das API-Usage-Formular für deine App ausfüllen. Es gibt
   keinen API-Schlüssel und keinen Preis für diese Leseabfragen.
5. In der LIVO-App mit einem echten Konto anmelden, Barcode scannen und einen
   gängigen Verpackungscode testen. Ein nicht gefundener Code führt bewusst
   zurück zur manuellen Eingabe.

Die aktuelle offizielle Dokumentation:

- https://openfoodfacts.github.io/openfoodfacts-server/api/
- https://openfoodfacts.github.io/openfoodfacts-server/api/tutorials/license-be-on-the-legal-side/
- https://supabase.com/docs/guides/functions/quickstart-dashboard
