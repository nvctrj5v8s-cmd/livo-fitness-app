# Lookin – lokale Vorstellungswebsite

Eigenständige, statische Marketingwebsite für die mobile App. Die Quelldateien
liegen direkt in `dist/`; für diese Website gibt es keinen Build-Schritt.
Die Flutter-Web-App in `web/` ist ein separates Produkt und wurde nicht geändert.

## Ansehen

`dist/index.html` im Browser öffnen. Alle Bilder, Schriften, Styles und Skripte
sind lokal; die Vorschau funktioniert ohne Server und ohne Internetverbindung.

Optional mit dem vorhandenen Dart-SDK über HTTP:

```powershell
& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' run website/tool/serve.dart
```

Danach `http://127.0.0.1:8787` öffnen. Beenden mit Strg+C.
Der Server ist nur über den eigenen Rechner erreichbar.

## Inhalt und Interaktion

- Bestehender Name und App-Icon aus `assets/branding/`.
- Farben aus `lib/core/theme/app_colors.dart`.
- Handy-Illustration: Tagebuch, Rezepte, Wochenüberblick; Beispielwerte.
- Featurebereich, Rezeptbilder, Einstieg, Datenkontrolle, FAQ und Download.
- Store-Buttons öffnen einen ehrlichen „Bald verfügbar“-Dialog.
- Responsives Menü, Tastaturbedienung, Dialog-Fokus, Scroll-Reveals.
- Reduzierte Bewegung wird respektiert. Foto-Scan läuft endlich und nur sichtbar.
- Kein Tracking, keine Cookies, keine Backend-Verbindung, keine Datenspeicherung.
- Kontakt öffnet das E-Mail-Programm; es wird keine Nachricht automatisch gesendet.

## Rechtstexte und Veröffentlichung

Die bestehenden Impressums- und App-Datenschutzentwürfe wurden für die lokale
Website kopiert. Die Inhalte bleiben Entwürfe. `legal/datenschutz.html` beschreibt
ausschließlich diese lokale Marketingvorschau. Vor einer Veröffentlichung:

1. Anbieterangaben und alle Rechtstexte prüfen und tatsächliches Hosting ergänzen.
2. `legal/app-datenschutz.html` und `legal/impressum.html` mit der verbindlichen
   Quelle in `web/legal/` abgleichen, wenn sich App-Verarbeitung oder Anbieter ändern.
3. Reale Store-Links in `index.html` einsetzen und Platzhalter-Dialog ersetzen.
4. App-Aussagen mit der tatsächlich veröffentlichten Store-Version abgleichen.
5. `noindex, nofollow` erst nach Freigabe entfernen; dann kanonische URL,
   Open-Graph-Bild, robots.txt und Sitemap für die endgültige Domain ergänzen.

Es wurde kein Site-Konto angelegt, nichts veröffentlicht, keine Git-Verbindung
geändert und nichts gepusht. Der bestehende GitHub-Pages-Workflow veröffentlicht
weiterhin `build/web`, nicht diese Website.

## Bildquellen

Siehe `ASSET_SOURCES.md`. Es wurden ausschließlich bereits vorhandene, dokumentierte
Projektbilder verwendet. Das App-Logo wurde unverändert übernommen.

## Prüfung

Abschlussprüfung am 10. Oktober 2026: Browserprüfung bestanden (320–1920 px,
Menü, Tabs, FAQ, Store-Dialoge, Tastatur, reduzierte Bewegung, lokale Assets
und Dateivorschau), `flutter analyze` ohne Hinweise, 22 passende Flutter-Tests
aus `brand_name_test.dart`, `legal_links_test.dart` und `widget_test.dart` bestanden.

`tool/check_site.dart` prüft mit dem vorhandenen Edge-Browser HTTP-Auslieferung,
lokale Links/Assets, responsive Layouts und Interaktionen. Es startet ausschließlich
einen temporären Loopback-Server und einen Browser ohne sichtbares Fenster, beendet
beides danach und schreibt Screenshots in ein temporäres Verzeichnis.

```powershell
& 'C:\flutter\bin\cache\dart-sdk\bin\dart.exe' run website/tool/check_site.dart
```
