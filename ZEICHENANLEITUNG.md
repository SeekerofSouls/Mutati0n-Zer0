# Deine Zeichnungen in MUTATION / NULL

Öffne zuerst `ART_CATALOG.html`. Jede Karte zeigt den Dateinamen, die Verwendung und die exakten Pixelmaße. `ASSET_LIST.csv` enthält dieselben Informationen als Tabelle für Excel oder LibreOffice.

## Größen auf einen Blick

| Asset | Eine Zelle | Komplettes Bild | Anzahl |
|---|---:|---:|---:|
| Charakter | 48 × 48 px | 288 × 1152 px | 6 |
| Normaler Gegner | 48 × 48 px | 288 × 1152 px | 12 + 1 kopflos |
| Boss | 96 × 96 px | 576 × 2304 px | 10 |
| Item-Icon | 32 × 32 px | 32 × 32 px | 64 |
| Mutations-Layer am Charakter | 48 × 48 px | 288 × 1152 px | 64 |
| Bodenfliese | — | 64 × 64 px | 5 |
| Raumhintergrund | — | 920 × 584 px | 5 |
| Raumart-Dekoration | — | 920 × 584 px | 11 je Gebiet |
| Felsen | — | 64 × 64 px | 5 |
| Tür links/rechts | — | 64 × 96 px | offen/geschlossen je Gebiet |
| Tür oben/unten | — | 96 × 64 px | offen/geschlossen je Gebiet |
| Projektil / Pickup / Begleiter | — | 32 × 32 px | 12 |
| Dialog-Kopf | — | 96 × 96 px | 116 |
| Textkasten | — | 640 × 128 px | 1 |
| Kopfrahmen | — | 112 × 112 px | 1 |
| Anfangsbild | — | 960 × 480 px | 6 |
| Effektanimation | 32 × 32 px | 256 × 32 px | 8 |

Speichere als **PNG mit Transparenz (RGBA)**. Keine Abstände zwischen Zellen, keine zusätzlichen Ränder am Sheet, kein verändertes Seitenverhältnis. Das Spiel liest rechteckige Ausschnitte, nicht automatisch erkannte Figuren.

## Das Sprite-Sheet-Raster

Charaktere, Gegner, Bosse und Mutations-Layer haben **6 Spalten und 24 Zeilen**. Jede Animation bekommt vier Zeilen; die Blickrichtungen sind immer **unten, links, rechts, oben**.

| Zustand | Zeilen ab 0 | Richtungen | Benutzte Frames ab 0 | Tempo |
|---|---|---|---|---|
| `idle` – stehen/atmen | 0–3 | unten, links, rechts, oben | 0–1 | 3 FPS |
| `walk` – laufen | 4–7 | unten, links, rechts, oben | 0–5 | 10 FPS |
| `shoot` – im Stand schießen / Angriff | 8–11 | unten, links, rechts, oben | 0–2 | 12 FPS |
| `hurt` – getroffen | 12–15 | unten, links, rechts, oben | 0–1 | 10 FPS |
| `dash` – Dash / Spezialbewegung | 16–19 | unten, links, rechts, oben | 0–3 | 20 FPS |
| `death` – sterben | 20–23 | unten, links, rechts, oben | 0–5 | 10 FPS, endet auf Frame 5 |

**Beispiel:** NULL nach rechts laufen = Zeile **6**, sechs Frames von links nach rechts. Unten laufen = Zeile **4**. Nach oben stehen = Zeile **3**, nur die ersten beiden Frames.

Die unbenutzten Spalten kannst du mit Kopien des letzten gültigen Frames füllen. Kein Leerbild zwischen zwei echten Frames, außer du willst absichtlich Blinken oder Verschwinden.

### Vorlagen

- `art_templates/character_enemy_48_blank.png`: transparentes 288 × 1152 px Sheet.
- `art_templates/character_enemy_48_guide.png`: beschriftetes Referenzraster.
- `art_templates/boss_96_blank.png`: transparentes 576 × 2304 px Sheet.
- `art_templates/boss_96_guide.png`: beschriftetes Bossraster.
- `art_templates/item_icon_32_blank.png`: leeres Item-Icon.
- `art_templates/effect_8x32_blank.png`: acht Effektframes nebeneinander.

**Die beschrifteten Guides sind größer, weil sie Beschriftungsränder haben. Sie sind Referenzen, keine Dateien für das Spiel.** Zeichne auf dem Blank-Sheet oder übermale die passende Datei in `assets/`.

## Verankerung und Trefferzonen

Alle Frames werden über ihre Zellmitte positioniert. Bei 48 px ist das **(24, 24)**, bei 96 px **(48, 48)**. Behalte den Körper in allen Frames ungefähr an derselben Stelle; so springt er beim Animieren nicht.

- Spieler-Trefferkreis: Radius 14 px im Spiel; sichtbar wird das 48 × 48 Sheet.
- Normale Gegner: je nach Typ Radius 15–23 px; Sheet 48 × 48.
- Bosse: Radius 42 px; Sheet 96 × 96.
- Dekorative Haare, Hörner oder Effekte können außerhalb des Trefferkreises liegen.
- Beim Blutläufer liegt die Kopf-Trefferzone 14 px oberhalb der Körpermitte. Zeichne den Kopf daher im oberen Teil der Zelle.

Die gezeichneten Augen dürfen sich drehen. Die Körpermitte soll beim Drehen stabil bleiben. Beim gleichzeitigen Laufen und Schießen verwendet der Spieler die Laufzeile; ein separater Mündungseffekt zeigt den Schuss an.

## Mutationen malen

Jede Mutation hat zwei Dateien:

1. `assets/items/<id>.png` = **32 × 32 px Icon** auf dem Podest, im Inventar und im Archiv.
2. `assets/mutations/<id>.png` = **48 px Sprite-Sheet-Layer** über dem Spieler.

Der Layer verwendet exakt dieselbe Animation und Blickrichtung wie der Charakter. Zeichne nur zusätzliche Teile: ein Auge, Hörner, Panzer, Flammen, Kabel, ein anderes Bein oder eine Aura. **Keinen vollständigen Körper und keinen undurchsichtigen Hintergrund**: sonst verdeckst du andere Mutationen.

Die Reihenfolge beim Zeichnen im Spiel entspricht der Reihenfolge der aufgenommenen Items. Layer können überlappen. Ein komplett transparenter Mutations-Layer blendet nur die optische Änderung aus; das Icon und der Effekt bleiben erhalten. So kannst du zuerst Icons malen und die Körperänderungen später ergänzen.

Es gibt keine automatisch erzeugte separate Komplettfigur für jede Item-Kombination. Das Spiel kombiniert die transparenten Layer.

## Gegner und der abgeschossene Kopf

`assets/enemies/decapitator.png` ist der Blutläufer mit Kopf. `decapitator_headless.png` ist derselbe Körper ohne Kopf, am gleichen Ankerpunkt. Seine Laufzeilen werden im panischen Zustand benutzt. Das separate `assets/props/detached_head.png` fliegt bei einer Enthauptung weg.

- `assets/effects/blood_splash.png`: acht Frames für den Moment der Enthauptung.
- `assets/props/blood_shot.png`: fliegendes Blut, **verursacht direkten Trefferschaden**.
- `assets/effects/blood_puddle.png`: Bodenspur, **kein Schaden**.

Warnstrahlen, Trefferkreis-Markierungen und Boss-HP-Balken sind aus Code gezeichnete Spielanzeigen. Ihre Größen sind unabhängig von deinen Bildern.

## Räume nach jedem Boss

Jedes Gebiet hat einen eigenen Ordner:

`assets/rooms/incubator/`, `reactor/`, `marsh/`, `ossuary/`, `void/`.

Der Renderer baut einen Raum in dieser Reihenfolge auf:

1. Wiederholte `floor_tile.png`.
2. `room_background.png` – kann transparent sein oder den kompletten Raum abdecken.
3. Die Dekoration für die Raumart: `start_overlay`, `combat_overlay`, `treasure_overlay`, `shop_overlay`, `rest_overlay`, `boss_overlay` oder `transition_overlay`.
4. Türen, Felsen, Gegner, Pickups und Geschosse.

**Boden und Hintergrund beeinflussen keine Kollisionen.** Wenn du einen Felsen in den Hintergrund malst, blockiert er nichts. Kollidierende Felsen werden über `rock.png` dargestellt.

Die Übergangskammer ist ein echter separater Raum, nur mit dem Bossraum verbunden. Sie hat pro Gebiet eine eigene `transition_overlay.png`. Male dort z.B. eine Schleuse, ein Tor, eine Treppe oder eine Bahnstation. Das schwebende Portal ist `assets/props/portal.png`.

Halte die Türpositionen frei: links/rechts mittig bei y = 292; oben/unten mittig bei x = 460, bezogen auf das 920 × 584 px Raumbild.

## Effektanimationen

Effekte haben **8 Frames in einer Zeile**, jedes 32 × 32 px. Gesamtmaß 256 × 32 px. Explosion, Spritzer, Teleport, Spawn, Treffer und Mündung laufen vorwärts. Säure und Blutpfütze wiederholen ihre Frames, solange die Fläche aktiv ist. Die Bilder werden auf den jeweiligen Effekt-Radius skaliert.

## Deine Sounds

Ersetze z.B. `assets/audio/shoot.wav` oder `head_pop.wav` durch deine Aufnahme. Die Dateinamen können gleich bleiben. Alternativ trägst du den neuen Pfad in `assets/audio/audio_config.json` ein, z.B. `res://assets/audio/my_shot.ogg`.

- Effekte: WAV oder OGG. PCM 16-bit WAV, Mono, 22.05 oder 44.1 kHz ist ein einfacher Ausgangspunkt.
- Musik: WAV oder OGG, möglichst sauber geschnittener Loop.
- `effects.<id>.volume`: Lautstärke dieses Effekts, meist 0.0–1.0.
- `music_volume`: relative Musiklautstärke.
- `pitch_randomness`: 0 für immer exakt dieselbe Tonhöhe; sonst leichte Variation.
- Musik-Schlüssel: `menu`, `incubator`, `reactor`, `marsh`, `ossuary`, `void`.

Soundlängen sind frei; die gelieferten WAVs sind nur kurze Testtöne und einfache Hintergrund-Loops. Godot lädt die Dateien beim Spielstart. Nach einem Austausch den laufenden Run stoppen und neu starten. Bei WAV/OGG kann zusätzlich die Loop-Funktion in Godots Import-Einstellungen aktiviert werden; andernfalls startet das Spiel Musik nach ihrem Ende erneut.

## Empfohlene Reihenfolge beim Zeichnen

1. NULL: zuerst Stehen unten und die sechs Laufbilder unten.
2. Restliche drei Richtungen, dann Schießen / Treffer / Dash / Tod.
3. Inkubator-Boden und Blutläufer mit/ohne Kopf.
4. Ein Boss-Sheet und seine Übergangskammer.
5. Item-Icons; danach Mutations-Layer.
6. Weitere Gebiete, Charaktere, Gegner und eigene Sounds.

Die Platzhalter füllen alle übrigen Stellen aus, während du Schritt für Schritt ersetzt.

## Textkästen und Köpfe

Die Köpfe sind **einzelne PNGs, keine Sprite-Sheets**. Es gibt vier Ausdrücke: `neutral.png`, `happy.png`, `angry.png`, `hurt.png`. Du kannst jeden Ausdruck frei zeichnen, solange Größe und transparenter Hintergrund erhalten bleiben.

| Figur | Ordner | Maße je Datei |
|---|---|---|
| Spieler | `assets/portraits/character/<id>/` | 96 × 96 px |
| Gegner | `assets/portraits/enemy/<id>/` | 96 × 96 px |
| Boss | `assets/portraits/boss/<kind>/` | 96 × 96 px |
| Labor-KI | `assets/portraits/ai/` | 96 × 96 px |

`assets/ui/dialogue_box.png` ist der **640 × 128 px** große Textkasten; das Spiel skaliert ihn auf die jeweils benötigte Breite. Halte seine Mitte ruhig und dunkel, damit der Text lesbar bleibt. `assets/ui/portrait_frame.png` (**112 × 112 px**) liegt hinter dem Kopf. Rahmen und Köpfe sind unabhängig austauschbar. Die Schrift und der Sprechername werden vom Spiel darübergelegt.

`art_templates/DIALOG_BEISPIEL.png` zeigt die Anordnung als Gestaltungsvorlage, nicht als Screenshot eines ausgeführten Spiels. Die tatsächlichen Dialogtexte stehen in `assets/dialogue/dialogue_de.json`. Ändere Texte, aber erhalte IDs und gültige JSON-Syntax. Es gibt ausdrücklich keine vertonten Stimmen.

## Die sechs Anfangsbilder

Alle sechs Bilder in `assets/cutscene/` haben **960 × 480 px**. Zeichne nur das Bild; der Textkasten sitzt getrennt darunter. Reihenfolge, Bild-IDs, Sprecher, Ausdruck, Text und Anzeigedauer stehen in `assets/dialogue/intro_de.json`. Insgesamt dauert die mitgelieferte Sequenz etwa 35 Sekunden. Sie kann jederzeit weitergeschaltet oder übersprungen werden.

## Neue Sonderraum-Grafiken

Jedes der fünf Gebiete hat `lab_overlay.png`, `sacrifice_overlay.png`, `challenge_overlay.png` und `unstable_overlay.png`, jeweils **920 × 584 px**. Dazu kommen die vier 32 × 32 px großen Interaktionsobjekte `assets/props/event_lab.png`, `event_sacrifice.png`, `event_challenge.png` und `event_unstable.png`. Die Raumdekoration bestimmt das Aussehen; Regeln und Kollisionsobjekte bestimmt das Spiel.

**Beide Generatoren überschreiben eigene Bilder.** `generate_story_placeholders.py` ist wie der Basisgenerator nur zur Wiederherstellung einer separaten Platzhalterkopie gedacht.
