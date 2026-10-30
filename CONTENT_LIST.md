# Inhalt und Zeichenideen — v3
Die Ideen sind Vorschläge für deine Zeichnungen. Die tatsächlichen Effekte sind fest im Spiel angelegt. Alle exakten Dateigrößen stehen im Asset-Katalog.
## Charaktere
| Datei | Charakter | Werte / Start | Freigabe |
|---|---|---|---|
| `assets/characters/null.png` | NULL | 6 LP · ausgewogene Werte · 2 Bomben | Von Anfang an |
| `assets/characters/vector.png` | VEKTOR | 4 LP · hohes Tempo · kritische Treffer | first_boss |
| `assets/characters/mycel.png` | MYZEL | 8 LP · langsam · startet mit Giftblase | floor_3 |
| `assets/characters/ember.png` | GLUT | 5 LP · startet mit Glutorgan | Von Anfang an |
| `assets/characters/stitch.png` | NAHT | 7 LP · startet mit Satellitenkern | items_10 |
| `assets/characters/echo.png` | ECHO | 4 LP · startet mit Suchinstinkt | kills_100 |

## Gegner
| Datei | Name | Verhalten |
|---|---|---|
| `assets/enemies/crawler.png` | Kriecher | Verfolgt die Probe. |
| `assets/enemies/spitter.png` | Spucker | Hält Abstand und schießt gezielt. |
| `assets/enemies/charger.png` | Rammbock | Warnt mit einem Strahl vor seinem Ansturm. |
| `assets/enemies/turret.png` | Ringdrüse | Feuert Geschossringe. |
| `assets/enemies/larva.png` | Larve | Klein und schnell. |
| `assets/enemies/decapitator.png` | Blutläufer | Kopf mit eigener Trefferzone. Kopflos läuft er panisch und spritzt Blutgeschosse. |
| `assets/enemies/splitter.png` | Teilungssack | Zerfällt nach dem Tod in zwei Larven. |
| `assets/enemies/blinker.png` | Phasengeist | Teleportiert nach einer Warnung und schießt einen Fächer. |
| `assets/enemies/shieldbug.png` | Schildkäfer | Fronttreffer verursachen nur 25% Schaden. Flankiere ihn. |
| `assets/enemies/leech.png` | Münzegel | Schneller Verfolger. Kontakt stiehlt zusätzlich eine Münze. |
| `assets/enemies/spore.png` | Sporenträger | Legt Sporenfelder, die Schaden verursachen und Tempo senken. |
| `assets/enemies/sniper.png` | Nadelauge | Kündigt einen schnellen Präzisionsschuss mit einem Laser an. |

## Bosse
| Gebiet | Datei | Name | Muster |
|---|---|---|---|
| INKUBATOR | `assets/bosses/brood.png` | DER BRÜTER | Larven + Ringe |
| INKUBATOR | `assets/bosses/chitin.png` | CHITIN-KÖNIG | Ansturm + Fächer |
| REAKTOR | `assets/bosses/synapse.png` | SYNAPSE | Bodenwarnungen + Ringe |
| REAKTOR | `assets/bosses/furnace.png` | DER OFEN | Feuerfelder + Fächer |
| MODERSUMPF | `assets/bosses/marrow.png` | KNOCHENORBIT | Viele Knochen-Ringe + schnelle Fächer |
| MODERSUMPF | `assets/bosses/bog.png` | DIE MODERKÖNIGIN | Bodenwarnungen + Sporenträger |
| KNOCHENARCHIV | `assets/bosses/executioner.png` | DER ENTHAUPTER | Blutringe + kopflose Blutläufer |
| KNOCHENARCHIV | `assets/bosses/architect.png` | DER ARCHITEKT | Erzeugt Felsen + Nadelaugen; schießt Fächer |
| NULLKERN | `assets/bosses/mirror.png` | SPIEGELPROBE | Rotierende Ringe + Phasengeister; reflektiert Treffer in jeder zweiten Angriffsphase |
| NULLKERN | `assets/bosses/omega.png` | PROBE OMEGA | Wechselt zwischen Ringen, Ansturm, Bodenwarnung und Fächer |

## 64 Mutationen
Icon: `assets/items/<id>.png`, Körper-Layer: `assets/mutations/<id>.png`. Eine Mutation mit reinem Stat-Bonus darf ebenfalls einen frei gemalten kosmetischen Layer haben.
| ID | Name | Effekt | Zeichenidee |
|---|---|---|---|
| `muscle` | Muskelspule | +1.4 Schaden. Jeder Treffer hat mehr Wucht. | Dickere Arme / Faserstränge |
| `quick` | Synapsenbrand | +0.8 Schüsse pro Sekunde. | Leuchtende Nerven |
| `legs` | Sehnenmotor | +35 Bewegungstempo. | Zusätzliche Sehnen |
| `heart` | Zweites Herz | +2 maximale LP, heilt 2 LP. | Zweites Herz auf der Brust |
| `range` | Fernlinse | +140 Reichweite, +80 Projektiltempo. | Teleskopauge |
| `crit` | Präzisionsauge | +18% Chance auf doppelten Schaden. | Fadenkreuz-Auge |
| `armor` | Chitinpanzer | 25% Chance, einen Treffer abzuwehren. | Chitinplatten |
| `vampire` | Blutvertrag | Jeder 8. besiegte Gegner heilt 1 LP. | Fangzähne |
| `poison` | Giftblase | Treffer vergiften Gegner: 2 Schaden/s. | Grüne Giftblase |
| `burn` | Glutorgan | Treffer entzünden: 3 Schaden/s für 2 s. | Glühende Brust |
| `ice` | Kältenerv | Treffer verlangsamen Gegner um 45%. | Eiskristalle |
| `pierce` | Knochennadel | Durchdringt Gegner; -0.25 Feuerrate. | Knochennadel am Arm |
| `bounce` | Gummizelle | Projektile prallen zweimal von Wänden ab. | Elastische Haut |
| `homing` | Suchinstinkt | Projektile suchen Gegner; -60 Projektiltempo. | Suchantenne |
| `twin` | Zwillingsdrüse | Zwei Schüsse gleichzeitig; -0.4 Schaden. | Doppelte Drüse |
| `triple` | Dreifachiris | Drei Schussrichtungen; -0.6 Schaden. | Drei Pupillen |
| `rear` | Rückenauge | Feuert einen zusätzlichen Schuss rückwärts. | Auge am Rücken |
| `side` | Quernerven | Zusätzliche Schüsse zur linken und rechten Seite. | Seitliche Nervenknoten |
| `burst` | Salvenlunge | Jeder vierte Angriff ist ein dreifacher Salve. | Drei Lungenkammern |
| `giant` | Titanenzelle | +2 Schaden, größere Schüsse; -0.4 Feuerrate. | Großer Knochenarm |
| `explode` | Drucksack | Schüsse explodieren beim ersten Treffer. | Aufgeblähter Drucksack |
| `chain` | Sturmleiter | Treffer leiten 55% Schaden zu einem nahen Gegner. | Elektrische Kontakte |
| `split` | Splittermark | Beim Treffer entstehen drei kleine Projektile. | Rissige Knochen |
| `orbit` | Satellitenkern | Zwei umkreisende Kugeln schaden nahen Gegnern. | Ring-Symbol an der Brust |
| `drone` | Larvendrohne | Ein Begleiter feuert selbstständig auf Gegner. | Larvennest |
| `shield` | Spiegelhaut | Ein Satellit fängt nahe feindliche Schüsse ab. | Spiegelplatten |
| `thorns` | Dornenrinde | Nach erlittenem Schaden: 8 Flächenschaden. | Stacheln |
| `dash` | Phasenmuskel | Sprint lädt 40% schneller; Sprint verursacht Schaden. | Phasenspuren |
| `bomb` | Sprengbauch | +3 Bomben. Bomben haben 60% mehr Radius. | Sprengbauch |
| `magnet` | Magnetblut | Zieht Münzen und Heilung aus größerer Distanz an. | Magnetförmige Antenne |
| `gold` | Goldfieber | Besiegte Gegner können zusätzliche Münzen fallen lassen. | Goldene Adern |
| `discount` | Händlerzunge | Shop-Preise sinken um 35%. | Gabelzunge |
| `heal` | Wundwurzel | Jeder dritte geklärte Kampfraum heilt 1 LP. | Wurzeln |
| `rage` | Adrenalin | Unter halben LP: +50% Schaden. | Rote Adern |
| `luck` | Glückschromosom | Mehr Raum-Drops und +10% kritische Treffer. | Klee-Chromosom |
| `glass` | Glasgenom | +3 Schaden, +1 Feuerrate; -2 maximale LP. | Transparente Risse |
| `phoenix` | Phönixkern | Einmal pro Run nach dem Tod mit 3 LP aufstehen. | Kleine Flügel |
| `nova` | Null-Nova | Jeder 6. Angriff feuert zusätzlich einen Kreis. | Stern auf der Brust |
| `void` | Leerenherz | Kritische Treffer erzeugen eine ziehende Zone. | Dunkles Zentrum |
| `crown` | Mutantenkrone | +0.3 Schaden für jede Mutation im Inventar. | Krone |
| `heavy` | Hammerknorpel | Schüsse stoßen zurück; -12 Bewegungstempo. | Hammerhand |
| `execute` | Henker-Gen | +50% Trefferschaden gegen Gegner unter 25% LP. | Sichel-Horn |
| `bleed` | Rasiermark | Treffer verursachen 1.5 Blutungsschaden/s für 4 s. | Rasierklingen |
| `acid` | Säureträne | Kritische Treffer hinterlassen schädigende Säure für Gegner. | Tropfendes Auge |
| `frostnova` | Winterreflex | Ein Sprint verlangsamt alle Gegner in 130 Pixeln. | Frostkranz |
| `blooddash` | Blutbahn | Sprint hinterlässt schädliche Blutspur für Gegner; -1 maximale LP. | Rote Sehnen |
| `barrier` | Einwegmembran | Der erste Treffer jedes Raums wird sicher abgewehrt. | Blasenmembran |
| `soul` | Seelenkultur | Besiegte normale Gegner fallen lassen mit 8% Chance Heilung. | Geisterfunke |
| `scavenger` | Schrottmagen | Zerstörte Felsen fallen lassen garantiert eine Münze. | Schrottteile |
| `headhunter` | Kopfgeldnerv | Abgeschossene Köpfe geben zwei Münzen. | Trophäen-Auge |
| `turbo` | Ruhepol | Beim Stillstehen +35% Feuerrate. | Motor-Spule |
| `boomerang` | Rücklaufsehne | Schüsse kehren nach 0.55 s zurück; -0.3 Feuerrate. | Gebogene Sehne |
| `keen` | Falkenauge | +12% kritische Treffer, +60 Reichweite. | Freie eigene Form passend zum Namen |
| `longshot` | Teleskoprippe | +220 Reichweite, +40 Projektiltempo. | Freie eigene Form passend zum Namen |
| `rapid` | Zuckermotor | +1.2 Feuerrate, -0.3 Schaden. | Freie eigene Form passend zum Namen |
| `brute` | Berserkerfaser | +2.4 Schaden, -15 Tempo. | Freie eigene Form passend zum Namen |
| `marathon` | Federbein | +25 Tempo, +60 Projektiltempo. | Freie eigene Form passend zum Namen |
| `shell` | Keramikhaut | +12% Abwehrchance und +1 maximale LP. | Freie eigene Form passend zum Namen |
| `battery` | Kraftknoten | +0.6 Feuerrate und +0.7 Schaden. | Freie eigene Form passend zum Namen |
| `vital` | Lebensknospe | +3 maximale LP, heilt 3 LP, -10 Tempo. | Freie eigene Form passend zum Namen |
| `needle` | Mikrokanal | +120 Projektiltempo und +0.3 Feuerrate. | Freie eigene Form passend zum Namen |
| `focus` | Drittes Auge | +20% kritische Treffer, -0.2 Feuerrate. | Freie eigene Form passend zum Namen |
| `dense` | Dichte DNA | +1.8 Schaden und +80 Reichweite. | Freie eigene Form passend zum Namen |
| `royal` | Königszelle | +1 LP, +15 Tempo, +0.5 Schaden. | Freie eigene Form passend zum Namen |

## Kombinationen
| Name | Benötigte Mutationen | Wirkung |
|---|---|---|
| Giftknall | poison, explode | Explosive Treffer erzeugen Giftflächen. |
| Eisbrecher | ice, heavy | Treffer auf verlangsamte Gegner lösen einen Splitterstoß aus. |
| Blutkreislauf | blooddash, vampire | Gegner, die auf deiner Blutspur sterben, heilen mit 20% Chance 1 LP. |
| Sturmring | orbit, chain | Satellitentreffer leiten zusätzlichen Schaden zu nahen Gegnern. |
| Splitterstern | nova, split | Jede sechste Salve enthält einen Ring aus 16 statt 8 Schüssen. |
| Rückruf | homing, boomerang | Zurückkehrende Schüsse durchdringen Gegner. |

## Sonderräume
| Raum | Entscheidung |
|---|---|
| TAUSCHLABOR | Die zuletzt erhaltene Mutation gegen eine unbekannte tauschen. |
| OPFERKAMMER | 2 maximale LP für eine seltene Mutation opfern. |
| VERSIEGELTE PROBE | Freiwilligen schweren Kampf für eine seltene Mutation starten. |
| INSTABILE GENBANK | Zwei Mutationen nehmen; feindliche Geschosse sind danach dauerhaft 25% schneller. |
