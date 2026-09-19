# Profilbild: nur lokal auf dem Gerät

Profilbilder werden nicht zu Supabase oder einem anderen Dienst hochgeladen.
Das ausgewählte Original bleibt auf dem Gerät, wird quadratisch zugeschnitten,
auf 512 × 512 Pixel verkleinert und als neues JPEG gespeichert. EXIF-, GPS-
und Kommentar-Metadaten werden dabei nicht in die gespeicherte Datei übernommen.

Die App akzeptiert JPG oder PNG bis 8 MB und speichert das erzeugte JPEG bis
1 MB im lokalen App-Speicher (`SharedPreferences`/plattformabhängiger
Speicher). Das Bild ist pro
angemeldetem Konto auf diesem Gerät getrennt gespeichert.

Folge: Ein Profilbild erscheint nicht auf einem zweiten Handy oder nach einer
vollständigen App-/Gerätedatenlöschung. Über „Profilbild entfernen“ löscht die
App die lokale Kopie. Supabase erhält für diese Funktion keine Bilddatei und
keinen Bildpfad.
