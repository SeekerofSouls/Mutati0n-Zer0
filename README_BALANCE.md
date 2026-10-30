# MUTATI0N ZER0 – Balance Edition

Eine separate, spielbare Ideen-Version auf Grundlage deines hochgeladenen Projekts.

## Starten

1. ZIP in einen neuen Ordner entpacken.
2. In Godot das enthaltene `MutationZero_Balanced/project.godot` importieren.
3. Mit F5 das komplette Projekt starten.

Getestet mit Godot 4.4.1. Keine fertige Windows-EXE enthalten. Die Importdaten werden beim ersten Öffnen neu erstellt. Deine ursprüngliche Projektdatei und ihr ZIP wurden nicht verändert. Diese Edition verwendet eigene Profil- und Run-Dateien; deine alten Spielstände werden nicht überschrieben oder übernommen.

## Was du ausprobieren kannst

- Nach Boss 5: evakuieren und gewinnen oder mit deinem Genom weitermachen.
- Boss 6–10: dieselben fünf Gebiete in deiner gewählten Reihenfolge, aber jeweils die andere Bossart. Dadurch kommen alle zehn vorhandenen Bossarten in einem vollständigen Run vor.
- Nach Boss 10: Endless. Gebiete wechseln weiter, Bossarten wechseln pro Besuch, LP steigen weiter. Geschosstempo steigt behutsam bis zu einer Obergrenze. Evakuieren bleibt ab Boss 5 nach jedem Boss möglich.
- Mutationen: E nimmt sie auf; vorher wird ihre Wirkung eingeblendet. Danach erscheinen Erklärung oben und dein Originaldialog unten gleichzeitig.
- I öffnet dein pausiertes Genom mit allen aktiven Mutationen und Beschreibungen; I/Esc schließt es. Im Pausenmenü gibt es ebenfalls einen Button.
- Hauptmenü → Optionen → MUSIK: AN/AUS. Diese Einstellung wird gespeichert; Soundeffekte haben weiter die reguläre Audiolautstärke.
- Vier neue Gegnerverhalten ab Gebiet 2. Vorhandene Grafiken werden wiederverwendet; farbige Ringe und Namen unterscheiden die Varianten.
- Die fünf Böden sind jeweils eine durchgehende 920 × 584-Plattform, ohne wiederholte kleine Tiles.

## Schutz deiner Arbeit

416 vorhandene PNG/SVG/WAV/OGG-Dateien sind bytegenau unverändert. Nur fünf `floor_tile.png`-Dateien wurden geändert. Die fünf ursprünglichen Böden findest du unter `extras/original_floors/`. Alle bisherigen Dialogzeilen sind erhalten; vier neue Gegnerzeilen wurden ergänzt. Kein Asset-Generator wurde auf deine Dateien angewendet.

`IDEEN_UND_AENDERUNGEN.md` erklärt die Regeln und zeigt, wo jede Idee umgesetzt ist. `BALANCE_CHANGES.diff` enthält den Text-Patch. `previews/` enthält echte Godot-Screenshots. Die Dokumentation deiner ursprünglichen Version ist weiterhin vorhanden; ihre alten Testberichte beziehen sich auf die Ausgangsversion. Für diese Edition gilt `TEST_REPORT_BALANCE.md`.

Die Zahlen sind ein nachvollziehbarer erster Balance-Pass. Automatische Prüfungen ersetzen keine längeren Runs mit verschiedenen Builds. Du kannst jede Idee einzeln übernehmen und die Werte nach deinem Spielgefühl ändern.
