# Lokale App-Einführung

Stand: 14. September 2026. Technische Dokumentation der neuen Einführung,
keine vollständige Datenschutzerklärung für die gesamte App.

- Vor der Anmeldung werden fünf überspringbare Beispielansichten gezeigt.
  Zahlen und Rezeptkarten in diesen Ansichten sind Illustrationen, keine
  persönlichen Angaben oder echten Auswertungen.
- Bei Abschluss, Überspringen oder „Schon dabei? Anmelden“ wird nur die
  boolesche Markierung `livo.introduction.completed.v2 = true` im lokalen
  Einstellungsspeicher (`shared_preferences`) des Geräts/Browsers gespeichert.
- Die Markierung verhindert eine wiederholte Einführung auf diesem Gerät. Sie
  enthält keine Konto-, Ernährungs- oder Gesundheitsdaten und wird nicht mit
  Supabase oder anderen Diensten synchronisiert.
- Die überarbeitete fünfseitige Einführung erscheint einmal erneut, auch
  wenn Version 1 schon abgeschlossen wurde. Der alte Marker und andere
  App-Daten werden weder gelöscht noch verändert.
- Die Einführung greift nicht auf Kamera, Fotos oder Benachrichtigungen zu und
  führt keine KI-Aufrufe oder Nutzungsanalyse aus. Ihr Abschluss ist ausdrücklich
  keine Einwilligung in eine spätere Datenübertragung oder Fotoanalyse.
- Der bereits vorhandene App-Start initialisiert weiterhin Supabase; dieses
  Dokument betrifft die Einführung und deren lokale Markierung, nicht das
  Netzwerkverhalten der restlichen App.
- Durch Löschen der Website-/App-Daten wird auch die Markierung entfernt.
  Das entfernt möglicherweise weitere lokale Einstellungen und Sitzungen.
  Im privaten Browser oder nach einer Neuinstallation kann die Einführung
  erneut erscheinen. Bei einem Speicherfehler bleibt der Einstieg benutzbar.
- Zum gezielten Wiederholen in der Entwicklung kann nur diese Markierung
  entfernt werden; Auth-Tokens und andere Schlüssel dürfen dabei nicht
  pauschal gelöscht werden.
