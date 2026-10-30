# Ideen und Umsetzung

## 1. Warum Mutationen vorher so leicht eskalierten

Wenn der alte Item-Pool leer wurde, konnten bereits besessene Mutationen erneut angeboten werden. Ihre Stat-Boni wurden erneut addiert, während viele Spezialeffekte nur über `has_item()` geprüft wurden und deshalb nicht entsprechend mehrfach wirkten. Zwilling und Dreifach konnten zudem sechs Schüsse pro Angriff erzeugen. Splitter übernahmen kritischen Schaden und konnten selbst erneut kritisch treffen. Überlappende Blutspuren verursachten jeweils eigenen Flächenschaden. Spiegelprobe konnte pro eintreffendem Projektil sofort zurückschießen.

Diese Edition macht die Regeln ausdrücklich sichtbar und prüft sie sowohl beim Angebot als auch beim tatsächlichen Aufnehmen. Das ist wichtig: Ein im alten Raum liegendes Angebot kann nach einer neuen Mutation unvereinbar werden.

## 2. Mutationsregeln

| Regel | Wirkung | Umsetzung |
|---|---|---|
| Jede Mutation einmal | Keine mehrfachen Stat-Boni durch identische Items | `main.gd`: `mutation_block_reason`, `take_item` |
| Zwilling / Dreifach | Entweder zwei parallele Schüsse mit je 65% Schaden oder drei Richtungen mit je 50% Schaden | `mutation_block_reason`, `fire`, `catalog.gd` |
| Gift / Glut / Kälte | Eine elementare Spezialisierung pro Build | `mutation_block_reason` |
| Explosion / Splitter | Eine Hauptnutzlast statt einer kombinierbaren Projektil-Explosion-Kaskade | `mutation_block_reason` |
| Lebensopfer | Mindestens 2 maximale LP müssen erhalten bleiben | `mutation_block_reason`, `interact_event` |
| Leerer Pool | Heilung statt verbotener Duplikate | `roll_item`, `make_pickup` |
| Shop-Schutz | Blockierte Käufe kosten nichts und verbrauchen kein Angebot | `interact` |
| Labor | Die letzte Mutation wird erst für den Ersatz-Pool entfernt; bei fehlendem Ersatz werden Inventar und Werte vollständig zurückgesetzt | `interact_event` |
| Instabile Genbank | Prüft zwei kompatible Mutationen, bevor der Preis bezahlt wird | `interact_event` |

Synergien wie Giftknall, Eisbrecher, Sturmring und Rückruf bleiben möglich. Gift und Explosion dürfen also weiterhin gemeinsam genutzt werden. Die Ausschlüsse sind bewusst klein und betreffen die stärksten sich überlagernden Hauptmechaniken.

## 3. Werte und Schaden

| Wert | Grenze / Regel |
|---|---|
| Maximale LP | 16 vor Opferkosten, mindestens 2 danach |
| Grundschaden | Ab 10 zählt weiterer Bonus zu 45%; harte Grenze 18 |
| Feuerrate | Ab 5/s zählt weiterer Bonus zu 50%; harte Grenze 8/s |
| Ruhepol | Weiterhin +35% beim Stillstehen, insgesamt höchstens 10/s |
| Kritische Chance | 60% |
| Abwehrchance | 45%; Chitinpanzer gibt 20% |
| Bewegungstempo | 130–340 |
| Projektiltempo | 150–850 |
| Reichweite | 200–1200 |
| Mutantenkrone | +0.2 je Mutation, maximal +4 |
| Explosion | 45% des Projektilschadens als zusätzlicher Flächenschaden |
| Eigene Schadenszonen | Überlappung desselben Typs erhöht Schaden/Zugkraft nicht: Blut/Säure 5/s, Giftfläche 3/s plus Giftstatus, Leere 4/s |
| Splitter | Übernehmen ihren Anteil am Schaden, rollen aber keinen weiteren kritischen Treffer |
| Spiegelprobe | Maximal ein Reflexionsschuss alle 0.45 s |
| Projektilmenge | Neue Spielerschüsse ab 256 aktiven Schüssen begrenzt; Gesamtgrenze 384 lässt Platz für gegnerische Angriffe |
| Genbank-Fluch | Höchstens 175% Basis-Geschosstempo; tatsächlicher Zuwachs wird angezeigt |

Diese Grenzen beziehen sich auf Grundwerte. Adrenalin, Krits, Henker-Gen und Synergien dürfen weiterhin starke Spitzen erzeugen. Die Feuerrate im HUD ist die Angriffsrate; bei Mehrfachschüssen ist sie nicht die Gesamtzahl aller Projektile.

Die Werte stehen gesammelt in `recalculate_stats()`, die Schussverteilung in `fire()`, die Treffermechaniken in `add_shot()`, `on_hit()` und `update_hazards()`.

## 4. Zehn Bosse und Endless

Dein ursprünglicher Katalog hatte schon zehn Bossarten, aber ein Run nahm pro Biom nur einen von zwei Bossen. Neue Bossgrafiken waren deshalb gar nicht nötig.

Beim Runstart wird für jedes Biom ein erster Boss aus dem Paar bestimmt. Beim zweiten Besuch kommt der andere. Die ersten fünf Gebiete enthalten jedes Biom einmal, der zweite Zyklus wiederholt deine gewählte Route. Damit sind die ersten zehn Bosse alle verschieden. In Endless wechseln die beiden Bossarten eines Bioms bei jedem Besuch weiter.

Nach Boss 5 wird der Sieg beim Evakuieren oder Weitergehen einmalig gutgeschrieben. Nach jedem weiteren Boss kannst du evakuieren; Weitergehen zählt nicht wiederholt als neuer Sieg. Inventar, Münzen, Bomben und Opferkosten bleiben erhalten. Der optionale Risikoweg gilt für das ausgewählte Gebiet; normale Folgeportale setzen ihn wieder zurück.

Boss-LP steigen mit der Tiefe statt ausschließlich mit der zufälligen Bossart:

`115 + 55 × Gebiet + 8 × Gebiet^1.5`

Das sind rund 178 LP in Gebiet 1, 479 in Gebiet 5 und 918 in Gebiet 10, vor Härtetest-/Risikoboni. Normale Gegner erhalten +14% Grund-LP pro Gebiet bis Gebiet 10, danach +12% pro weiterem Gebiet. Kampfräume enthalten höchstens zehn reguläre Gegner; Herausforderungen höchstens zwölf. Die Räume bleiben damit lesbar und die Schwierigkeit kommt nicht nur aus unendlich vielen Gegnern.

Boss-Anstürme, Rammböcke und Nadelaugen sperren ihr Ziel beim Warnsignal. Ein nachträgliches Ausweichen funktioniert deshalb zuverlässig. Bosswut erhöht die Angriffshäufigkeit weniger stark als zuvor.

Umsetzung: `begin_run`, `generate_floor`, `populate_route_choices`, `interact`, `claim_milestone`, `make_enemy`, `populate_room`, `update_boss`. Die Bossreihenfolge, Route und Siegmarkierung werden im Run gespeichert.

## 5. Vier neue Gegner

| Gegner | Besonderheit | Gegenstrategie | Verwendete Grafik |
|---|---|---|---|
| Nährer | Heilt alle 2.4 s einen verletzten normalen Verbündeten in 240 Pixeln um 3 LP; sichtbare Verbindung | Zuerst den Heiler töten | Sporenträger |
| Mörserdrüse | Markiert deine Position; nach Vorbereitung und weiterer Warnung entsteht eine kurze Schadenszone | Aus dem markierten Kreis laufen | Ringdrüse |
| Kreisläufer | Bewegt sich seitlich um dich und feuert zwei langsame Geschosse | Bewegung vorhalten und kreuzende Wege meiden | Larve |
| Berstling | Warnt 0.9 s vor einem festgelegten Ansturm, danach Explosion am Endpunkt | Früh töten oder seitlich ausweichen | Rammbock |

Ab Gebiet 2 wird ein Gegner pro normalem Kampfraum durch eine dieser Varianten ersetzt. Die Auswahl hängt von Gebiet und Raumlayout ab. Alle behalten eigene Namen und Farbringe; die vorhandenen Sprite-Dateien werden nicht geändert. Verhalten: `update_enemies()` für Typ 13–16. Daten: `Catalog.ENEMIES`. Grafische Zuordnung: `art_id` und `enemy_art_key()`.

## 6. Texte und Musik

Die alte Mutationserklärung wurde nur gezeichnet, wenn kein Dialog aktiv war. Gleichzeitig erzeugte das Aufnehmen einen Dialog. Damit konnten sich beide Systeme gegenseitig verdecken.

Jetzt bleibt die Erklärung sieben Sekunden sichtbar, unabhängig vom Dialog. Der Dialog sitzt in einer eigenen Leiste unter dem Spielfeld. Vor dem Aufnehmen zeigt die Nähe-Vorschau den Effekt und gegebenenfalls einen Konflikt. Rechts steht der letzte Fund; I öffnet die aktive Mutationsliste mit Beschreibungen und pausiert den Kampf. Die Sammlungshistorie wird zusätzlich im Run gespeichert.

Umsetzung: `take_item`, `draw_game`, `draw_dialogue`, `draw_sidebar`, `genome_menu`, `draw_genome`.

Musik: eigenes `music_enabled` im Profil und in `sound.gd`; der Schalter pausiert ausschließlich den Musikplayer. Der normale Lautstärkeregler steuert weiterhin die Gesamtlautstärke. Musik bleibt auch nach Biomwechseln ausgeschaltet, bis du sie wieder einschaltest.

## 7. Böden und Übernahme einzelner Ideen

Fünf deterministisch gezeichnete Arenaoberflächen ersetzen ausschließlich die fünf Bodenbilder. Ihre Größe entspricht der Arena: 920 × 584. `draw_texture_rect(..., false)` zeichnet jede Oberfläche einmal. Der kleine Tile-Schleifenhintergrund ist entfernt. Türen, Hindernisse, Raum-Overlays und alle übrigen Grafiken bleiben deine Dateien.

Die originalen Böden liegen unter `extras/original_floors/`. Wenn du nur bestimmte Ideen willst, nutze `BALANCE_CHANGES.diff` zum Vergleichen, nicht blind über dein Hauptprojekt kopieren. Besonders einfach getrennt zu übernehmen sind der Musikschalter, die unabhängige Mutationserklärung und die Konfliktprüfung. Die zehn Boss-Progression benötigt zusammengehörig Route, Bossreihenfolge, Portale und die zusätzlichen Save-Felder.

## 8. Weitere Ideen für deinen nächsten eigenen Ausbau

Diese Vorschläge sind noch nicht implementiert:

- Ein Gen-Reiniger im Shop, der eine ausgewählte Mutation entfernt, damit der Spieler gezielt die elementare Spezialisierung wechseln kann.
- Elite-Gegner mit einem einzigen gut sichtbaren Zusatz, etwa kürzerer Mörserwarnung; nie gleichzeitig mehrere unlesbare Modifikatoren.
- Nach Boss 10 alle fünf Bosse eine Wahl aus drei neuen Risikoregeln: weniger Heilung, zusätzliche Minibosse oder temporäre Sperre eines defensiven Gens.
- Ein Runbericht mit verursachtem Schaden je Mutation. Damit würdest du Balanceprobleme später anhand deiner eigenen Runs erkennen.

Diese Version ist zum Spielen, Vergleichen und Ideenübernehmen gedacht. Die automatischen Tests zeigen Funktionsfähigkeit, keine endgültige perfekte Balance.
