# Testbericht – Balance Edition

Geprüft mit Godot 4.4.1 unter Linux.

## Bestanden

- Godot importiert das Projekt; keine GDScript-Parsefehler.
- 16 Python-Strukturprüfungen: Assetabmessungen, Referenzen, Audio-Dateiformate, Inhalte, Synergien, Save-Felder, Boss-/Gegnerpfade und Schutz der Test-Spielstände.
- Engine-Smoke-Test: 1000 erzeugte Raumgraphen mit verbundenen Wegen, zwei Schatzkammern, einem Boss und einer ausschließlich über diesen Boss zugänglichen Schleuse.
- 64 Mutations-Aufnahmeversuche mit den vorgesehenen Ausschlüssen; Treffer- und Kinderprojektilpfade werden im Kampf ausgeführt.
- Alle 16 normalen Gegner-KI-Pfade und alle zehn Bossmuster werden ausgeführt; Boss-Tod bereinigt Gegner und Gefahren.
- Einkäufe, exklusive Schatzwahl und blockierte Käufe ohne Abbuchung.
- Doppelte Items und unvereinbare Mehrfachschuss-, Element- und Nutzlastkombinationen.
- Leerer Mutationspool wird zu Heilung; Grundwertgrenzen werden eingehalten.
- Überlappende Blut-/Säureflächen vervielfachen ihren Schaden nicht.
- Übergänge über 15 Gebiete bis zum nächsten Start: alle zehn Bossarten in den ersten zehn Gebieten genau einmal; Endless und Evakuierungsoption funktionieren; Sieg wird nur einmal gezählt.
- Serialisierung und tatsächliches Wiederaufnehmen über `continue_run()` mit einem speicherlosen Testprofil.
- Separater Musikschalter pausiert den Musikplayer und verändert die Soundeffektlautstärke nicht; erneutes Einschalten hebt die Pause auf.
- Fünf echte Godot-Screenshots: Aufnahme mit gleichzeitigem Dialog, Optionen, Genom, Endless-Schleuse und vier neue Gegner. Darstellung geprüft; überlange Optionsbeschriftung gekürzt.
- Assetvergleich gegen Upload: 416 Grafik-/Audiodateien unverändert; genau fünf erlaubte Bodenbilder ersetzt. Alte Bodenbilder zusätzlich gesichert.

## Grenzen

Die Engine-Tests prüfen Funktionen, keine subjektiv perfekte Balance oder kompletten manuell gespielten Runs. Audioinhalte wurden auf unveränderte Bytes und gültige WAV-Dateien geprüft; hier stand kein Lautsprecher für einen Hörtest zur Verfügung. Mobile Geräte, Controller-Hardware, Windows-Export und Godot 4.7 wurden nicht direkt getestet.

Der headless Test kann beim sofortigen Engine-Ende Warnungen zu noch gehaltenen WAV-Audioplaybacks ausgeben. Der Funktionstest endet trotzdem erfolgreich; es wurden keine GDScript-Laufzeitfehler während der geprüften Spielabläufe gemeldet. Die Vorschau-Aufnahmen sind absichtlich lautlos.

## Wiederholen

`python3 tests/static_checks.py`

`godot --headless --path . -- --smoke-test`

Das verwendete Godot-Kommando kann bei dir anders heißen. Die Tests schreiben keine normalen Profil- oder Run-Dateien.
