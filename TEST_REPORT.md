# Prüfbericht — Artist Edition v3

Lieferstand: 6. Oktober 2026.

## Ausgeführt

`python tests/static_checks.py`: **16 Prüfungen erfolgreich**. Geprüft sind Katalog und Effekt-Hooks für 64 Mutationen, sechs Charaktere, zehn Bosse, zwölf Gegner, Szene- und Ressourcenpfade, Token-Balance und eindeutige Funktionen, Speicherpunkte, Testmodus ohne echte Profildaten, Projektil-Aufteilung, Shop und Schatzwahl.

Alle **395 PNG-Dateien** wurden auf exakte Abmessungen und RGBA-Modus geprüft; 18 Effekt-WAVs und sechs Musik-WAVs auf Struktur und Konfigurationspfade. Neue Prüfungen decken 116 Kopfporträts, sechs Anfangsbilder, Dialog-Referenzen, fehlende Sprachwiedergabe, sechs Kombinationen, vier Sonderraum-Arten, Wegwahl und Speicherfelder ab.

Der JavaScript-Teil des Offline-Katalogs hat eine Syntaxprüfung mit Node bestanden. Eine echte Browserprüfung war mangels Browser-Binary nicht möglich. Einige Sprite-Sheets, Raster und die Dialog-Gestaltungsvorlage wurden als Bilder angesehen.

Beim Review wurden Laufanimationen beim Schießen, direkte Bluttreffer, Kopf-Belohnungen, Rückkehrprojektile, gespeicherter Boss-Schaden und die dauerhaften Opfer-/Instabilitätskosten berücksichtigt. JSON-Konfigurationen sind im Export-Preset eingeschlossen.

## Nicht ausgeführt

**Godot-Import, GDScript-Kompilierung, Engine-Test, echte Eingaben, Audiowiedergabe und vollständige Spielversuche.** Godot ist in dieser Umgebung nicht installiert. Statische Prüfungen bestätigen keine Laufzeitfehlerfreiheit und kein fertiges Balancing.

## Mitgelieferter Engine-Test

```sh
godot --headless --path <Projektordner> --import
godot --headless --path <Projektordner> -- --smoke-test
```

Der Test prüft 500 Raumgraphen, Mutationen, Boss-/Gegnerzweige, Enthauptung, direkten Blutschaden, Shop, Schatzwahl, Dialogzeit, Wegwahl und Sonderraum-Transaktionen. Im Testmodus wird nicht in echte Profildaten geschrieben. **Dieser Test wurde hier nicht ausgeführt.**

## Manuelle Abnahme in Godot

1. Import und F5: Menü, sechs Anfangsbilder, Weiter/Überspringen und erste Kammer prüfen.
2. Vier Bewegungsrichtungen und Stehen/Laufen/Schießen/Treffer/Sprint/Tod prüfen.
3. PNG-Kopf, Textkasten und Dialogtext ersetzen; im Spiel die geänderten Dateien prüfen.
4. Dreifachschuss aufnehmen; Spielertext und optionales Abschalten der Sprüche prüfen.
5. Blutläufer enthaupten: panische Phase, schädliche Blutgeschosse und ungefährliche Bodenspur.
6. Bosse besiegen, Übergangskammer betreten, beide Wegvarianten ausprobieren; alle fünf Gebiete abschließen.
7. Vier Sonderräume, sechs Kombinationen sowie Opferkosten und schnellere Feindgeschosse prüfen.
8. Speichern/Fortsetzen mit Wegwahl, instabiler Route, Opferkosten und angeschlagenem Boss.
9. Sieg, Freigaben, Musik/Sound-Austausch, Touch und Controller am Zielgerät testen.
10. Export mit JSON, PNG und WAV/OGG auf dem Zielsystem prüfen.

Profile und Freigaben aus v1/v2 bleiben kompatibel. Aktive v1/v2-Versuche werden absichtlich nicht geladen.
