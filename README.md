# MUTATION / NULL — Artist Edition v3

Ein editierbares Top-down-Roguelite für **Godot 4.4+ (Standard, kein .NET)**. Diese Version nutzt austauschbare PNG-Sprite-Sheets und WAV-/OGG-Sounds. Alle mitgelieferten Figuren und Räume sind bewusst einfache Platzhalter für deine eigenen Zeichnungen.

## Start

ZIP komplett entpacken → `project.godot` in Godot importieren → **F5**. Die Startszene ist `scenes/Main.tscn`. Das ZIP enthält Projektquellcode; eine exportierte EXE oder signierte IPA ist nicht enthalten.

## Hier startest du mit dem Malen

1. **`ART_CATALOG.html`** im Browser öffnen: durch alle Grafikdateien blättern, Animationen ansehen, Größen und Verwendung nachlesen. Funktioniert offline im entpackten Ordner.
2. **`ZEICHENANLEITUNG.md`** lesen: exakte Reihenfolge der Frames und Richtungen.
3. Eine PNG aus `assets/characters`, `assets/enemies`, `assets/bosses` oder `assets/items` in deinem Zeichenprogramm öffnen und übermalen. Größe, Dateiname und Transparenz erhalten.
4. Godot die PNG neu importieren lassen. Das Spiel verwendet deine Zeichnung automatisch.

**Die Generatoren nicht nach dem Übermalen ausführen:** `tools/generate_placeholders.py` und `tools/generate_story_placeholders.py` überschreibt vorhandene Grafik- und Sounddateien. Sie ist nur zum erneuten Erzeugen einer separaten Platzhalterkopie gedacht.

## Inhalt

- 64 Mutationen: 64 Item-Icons und 64 optionale animierte Charakter-Layer.
- 6 Charaktere mit verschiedenen Startwerten und Startmutationen.
- 12 normale Gegnertypen; Blutläufer mit zusätzlichem kopflosen Sprite-Sheet.
- 10 Bosse, je zwei mögliche Bosse pro Gebiet.
- 5 Gebiete: Inkubator, Reaktor, Modersumpf, Knochenarchiv und Nullkern. Die Reihenfolge der drei mittleren Gebiete wählst du über Portale. Jede Variante hat ihre eigenen Raumgrafiken.
- Nach jedem Boss: Tür zu einer eigenen Übergangskammer. Heilung nehmen, dann E am gewählten Portal. Später kannst du zwischen normaler und instabiler Route mit stärkeren Gegnern und mehr Beute wählen. Im fünften Gebiet schließt E den Versuch ab.
- 6 konkrete Mutations-Kombinationen, Nebenwirkungen einzelner Mutationen und 4 optionale Sonderraum-Arten: Tauschlabor, Opferkammer, versiegelte Probe und instabile Genbank.
- Komplett deutsche Oberfläche und stumme Textkästen mit Schreibeffekt: Spieler, Bosse, Gegner und Labor-KI. 116 austauschbare Kopfporträts.
- Anfangssequenz aus sechs austauschbaren Bildern, etwa 35 Sekunden; weiterschaltbar und überspringbar. Eigene Geschichte, kein Isaac-Name im Spiel.
- 395 Grafikdateien, 18 Soundeffekte und 6 Musik-Loops, alle mit benannten Austauschstellen.
- Seed, Minimap, Shop, Schatzwahl, permanente Freigaben und Versuch-Speicherung.

## Steuerung

| Aktion | Tastatur / Maus | Controller |
|---|---|---|
| Bewegen | WASD | Linker Stick |
| Schießen | Pfeile oder linke Maustaste halten | Rechter Stick |
| Dash | Leertaste | A |
| Bombe | Q | X |
| Nehmen / Kaufen / Portal | E | B |
| Karte | Tab halten | Back halten |
| Pause | Esc oder II | Start |

Touch unter Optionen aktivieren: links ziehen bewegt, rechts ziehen schießt; Aktionen haben eigene Tasten. Beim Bewegen läuft die Laufanimation auch während des Schießens. Im Stand erscheint die Schussanimation.

## Blutläufer

Der Kopf besitzt eine eigene Trefferzone oberhalb des Körpers und 7 Kopf-HP. Ein Treffer in dieser Zone reduziert zusätzlich die Kopf-HP. Wenn die Kopf-HP auf null sinken, während der Körper noch lebt, fliegt der Kopf weg. Der Körper läuft bis zu fünf Sekunden panisch umher und spritzt alle 0.32 Sekunden drei Blutgeschosse. **Direkte Blutgeschosse verursachen Schaden; die Blutspur am Boden ist dekorativ.** Der kopflose Körper kann normal besiegt werden.

Die Mutation Kopfgeldnerv gibt zwei Münzen für eine von dir ausgelöste Enthauptung. Vom Boss bereits kopflos erzeugte Läufer geben diese Belohnung nicht.

## Dialoge und Anfangssequenz

`assets/dialogue/dialogue_de.json` enthält Sprüche, Sprechtempo und Gesprächsabstand. `assets/dialogue/intro_de.json` enthält Texte, Dauer, Sprecher, Bild-ID und Gesichtsausdruck der sechs Anfangsbilder. Der Dreifachschuss bekommt den Spruch: „Ey Alter, wie geil ist das denn? Jetzt kann ich drei von den Viechern gleichzeitig wegfetzen!“

Keine Sprachaufnahmen und kein Schreibgeräusch. Wichtige Bossvorstellungen halten den Kampf kurz an; Item-Sprüche und gelegentliche Gegnertexte laufen während des Spiels. Unter Optionen lassen sich die gelegentlichen Sprüche abschalten. E schaltet Bossdialoge weiter. In der Anfangssequenz: E oder Eingabetaste weiter, Esc überspringen. Im Menü lässt sich die Vorgeschichte erneut ansehen.

## Zeichnungen und Sounds ersetzen

- Grafikgrößen stehen vollständig in `ASSET_LIST.csv` und im Offline-Katalog.
- Spielpfade und Sheet-Aufteilung stehen in `assets/asset_manifest.json`.
- Sounds liegen in `assets/audio`. Lautstärke je Sound und Musikpfade stehen in `assets/audio/audio_config.json`.
- Mutations-Layer lassen sich unter Optionen abschalten; die Item-Effekte bleiben aktiv. Zeichne in diesen Layern nur die Veränderung, nicht erneut den ganzen Charakter.
- PNG-Dateien dürfen größere transparente Ränder innerhalb der vorgegebenen Zelle haben. Die Größe des Sprite-Sheets selbst bleibt gleich.

## Speichern und Versionen

`user://profile.json` hält Unlocks, Statistik und Audio-Lautstärke dauerhaft. `user://run.dat` hält den Run bei Raumwechsel, Raumabschluss, Item-Interaktion und Pause. **Pause → Run speichern & Menü** und später **Run fortsetzen**.

Profile aus v1/v2 bleiben nutzbar. **Aktive Versuche aus v1/v2 werden nicht geladen**, weil fünf Gebiete und die neuen Gegner einen anderen Speicheraufbau haben. Einen neuen Run starten. Ein neuer Run ersetzt den vorherigen Run-Speicher.

Seed-Reproduzierbarkeit setzt denselben Charakter, Unlock-Stand und dieselbe Aktionsfolge voraus, da Karten, Kämpfe und Drops denselben Zufallsgenerator verwenden.

## Export

Windows und Linux sind vorbereitet. Passende Godot-Export-Vorlagen installieren und unter Projekt → Exportieren den Zielpfad wählen. Die JSON-Konfigurationen sind im Export-Preset eingeschlossen. Für iOS werden Apples Export- und Signierungsschritte separat benötigt.

## Umfang und Prüfstatus

Dies ist ein vollständiges Projekt mit Spielsystemen und Platzhaltergrafiken, kein fertig abgenommenes kommerzielles Spiel. Eigene Grafiken, Spieltests und Balancing gehören zur weiteren Fertigstellung.


16 statische Prüfungen sind bestanden; alle PNG-Abmessungen und WAV-Dateien wurden kontrolliert. Einige Sprite-Sheets und die Rasteranleitung wurden visuell geprüft. **Godot ist in der Erstellungsumgebung nicht verfügbar; Engine-Import, Laufzeit, Audio und Balancing sind hier nicht getestet.** Details stehen in `TEST_REPORT.md`.

Zum Prüfen in deiner Godot-Installation:

```sh
godot --headless --path <Projektordner> --import
godot --headless --path <Projektordner> -- --smoke-test
```

Der mitgelieferte Engine-Test prüft 500 Karten, alle Mutationen, Gegner, Bosse, kopfloses Verhalten und direkten Blutschaden sowie Shop und Schatzwahl. Im Testmodus werden keine echten Profildaten geschrieben.

## Dateien

`scripts/main.gd`: Spielablauf, Kampf, Eingabe und Darstellung. `catalog.gd`: Daten. `dungeon.gd`: Raumgraph. `art.gd`: austauschbare Texturen und Frames. `sound.gd`: konfigurierbare Audiowiedergabe. `profile.gd`: Speicherung. `speech.gd`: stumme Textkästen.

Projektcode und Platzhalter stehen unter der beiliegenden MIT-Lizenz. Für deine Zeichnungen kannst du deine eigene Lizenz festlegen.
