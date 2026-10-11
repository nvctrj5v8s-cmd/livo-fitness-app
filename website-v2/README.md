# Lookin – Website Version 2

Neue, eigenständige Marketingwebsite für die mobile Lookin-App. Version 1 in
`website/` bleibt erhalten. Die Quelldateien stehen direkt in `dist/`, ohne
Paketinstallation oder Build-Schritt. Die Flutter-App wurde nicht geändert.

## Ansehen und vergleichen

`../website-compare/index.html` im Browser öffnen. Oben zwischen **Version 1**
und **Version 2** wechseln; die Handyansicht zeigt die Website mit 390 px Breite.
Beide Entwürfe lassen sich auch einzeln öffnen. Version 2 ist vorausgewählt.

Direkt: `dist/index.html`. Alle Dateien sind lokal. Die Vorschau funktioniert
auch ohne Server oder Internetverbindung.

Optionaler lokaler HTTP-Server:

```powershell
& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' website-v2/tool/serve.dart
```

Dann `http://127.0.0.1:8788` öffnen. Beenden mit Strg+C. Nur der eigene Rechner
kann den Server erreichen.

## Inhalt

- Größerer Einstieg mit interaktiver Handyillustration und animierten App-Karten.
- Ausführliche Funktionsvorstellung, persönliche Einrichtung und Tagebuch.
- Bedienbare Produktführung: Foto-Vorschlag, Barcode, Zutatenabgleich und Kalender.
- Sechs echte Rezeptvorschauen mit Filtern, Zutaten, Zubereitung und Nährwerten.
- Drei vorbereitete Coach-Beispiele, keine echten KI-Anfragen.
- Free/Premium-Vergleich, geplante Tarife und Umschaltung Monat/Jahr.
- Datenkontrolle, 13 FAQ-Antworten mit Kategorien, Store-Platzhalter und Support.
- Impressum, Datenschutz, AGB, Widerruf und Kontolöschung als lokale Entwürfe.
- Vorhandenes Lookin-Logo und Farben aus `lib/core/theme/app_colors.dart`.

Scroll-Effekte, Bildübergänge, animierte Zahlen, Scan-Führungen und Hover-Effekte
haben einen Pausenknopf. Systemeinstellungen für reduzierte Bewegung werden
respektiert; Führungsanimationen pausieren außerhalb des sichtbaren Bereichs
und bei ausgeblendetem Tab. Kein Zwang zum Warten bei reduzierter Bewegung.

## Grenzen der Vorschau

Diese Website stellt die mobile App vor. Sämtliche App-Ansichten auf der Website
sind Beispiele ohne Kontozugriff und ohne dauerhafte Speicherung. Keine API,
Kamera, Zahlungsfunktion, Cookies, Analysedienste oder externen Schriften.
Kontaktlinks öffnen nur das E-Mail-Programm.

Store-Buttons sind Platzhalter. Die Premium-Tarife stammen aus dem aktuellen
App-Code (6,99 €/Monat, 49,99 €/Jahr); sie werden als geplant gekennzeichnet.
Die kostenlose 7-Tage-Testphase ist laut App-Code einmalig pro Konto, endet
automatisch und wird nicht zum kostenpflichtigen Abo.

Die Rechtstexte stammen aus den vorhandenen Projektentwürfen. Die lokale
Widerrufsseite sendet nichts an den bestehenden App-Service. Vor dem öffentlichen
Start müssen Rechtstexte, tatsächlich veröffentlichte App-Funktionen, Store-Links
und Hosting abgeglichen werden. `noindex, nofollow` bleibt für die Vorschau aktiv.

Nichts veröffentlicht oder gepusht. Keine Änderungen an DNS, Cloudflare, GitHub
oder dem bestehenden GitHub-Pages-Workflow. Vergleichsseite und Version 2 sind
vollständig lokal.

## Quellen und Prüfung

Bildquellen: `ASSET_SOURCES.md`. Produktangaben wurden mit dem aktuellen App-Code
und `docs/FEATURE_STATUS.md` abgeglichen. Es gibt keine erfundenen Nutzerzahlen,
Bewertungen, Abnehmergebnisse oder garantierten gesundheitlichen Wirkungen.

`tool/check_site.dart` prüft Ressourcen, Interaktionen, Tastatur, Animationen,
reduzierte Bewegung und responsive Ansichten mit Edge. Es startet einen
temporären lokalen Server und einen unsichtbaren Browser, beendet beide danach
und legt Screenshots in TEMP ab.

```powershell
& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' website-v2/tool/check_site.dart
```

Abschlussprüfung am 11. Oktober 2026: **80 Browser- und Ressourcenprüfungen
bestanden**, einschließlich echter Pointer-Klicks auf der Handyansicht,
Versionsvergleich, aller vier Produktführungen, Rezeptdialoge, Tarife,
Tastaturbedienung, reduzierter Bewegung und Dateivorschau. Acht Breiten von
320 bis 1920 px wurden in allen vier Führungsmodi geprüft; kein horizontaler
Überlauf, keine JavaScript-Fehler und keine Drittanbieteranfragen.

Desktop- und Handy-Screenshots visuell geprüft. `flutter analyze --no-pub`
meldet keine Hinweise. Alle 22 passenden Flutter-Tests aus
`brand_name_test.dart`, `legal_links_test.dart` und `widget_test.dart` bestanden.
Die drei Hauptdateien von Version 1 behalten ihre ursprünglichen SHA-256-Hashes.
