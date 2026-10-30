extends RefCounted
# Effects stack. Stats use additive changes; mechanics are evaluated by the combat loop.
const ITEMS = [
 {
  "id": "muscle",
  "name": "Muskelspule",
  "desc": "+1.4 Schaden. Jeder Treffer hat mehr Wucht.",
  "rarity": 0,
  "stat": {
   "damage": 1.4
  }
 },
 {
  "id": "quick",
  "name": "Synapsenbrand",
  "desc": "+0.8 Schüsse pro Sekunde.",
  "rarity": 0,
  "stat": {
   "rate": 0.8
  }
 },
 {
  "id": "legs",
  "name": "Sehnenmotor",
  "desc": "+35 Bewegungstempo.",
  "rarity": 0,
  "stat": {
   "speed": 35.0
  }
 },
 {
  "id": "heart",
  "name": "Zweites Herz",
  "desc": "+2 maximale LP, heilt 2 LP.",
  "rarity": 0,
  "stat": {
   "max_hp": 2.0
  }
 },
 {
  "id": "range",
  "name": "Fernlinse",
  "desc": "+140 Reichweite, +80 Projektiltempo.",
  "rarity": 0,
  "stat": {
   "range": 140.0,
   "shot_speed": 80.0
  }
 },
 {
  "id": "crit",
  "name": "Präzisionsauge",
  "desc": "+18% Chance auf doppelten Schaden.",
  "rarity": 0,
  "stat": {
   "crit": 0.18
  }
 },
 {
  "id": "armor",
  "name": "Chitinpanzer",
  "desc": "20% Abwehrchance. Gesamte Abwehr ist auf 45% begrenzt.",
  "rarity": 1,
  "stat": {
   "armor": 0.2
  }
 },
 {
  "id": "vampire",
  "name": "Blutvertrag",
  "desc": "Jeder 8. besiegte Gegner heilt 1 LP.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "poison",
  "name": "Giftblase",
  "desc": "2 Giftschaden/s für 3 s. Gift, Glut und Kälte schließen sich aus.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "burn",
  "name": "Glutorgan",
  "desc": "3 Brandschaden/s für 2 s. Gift, Glut und Kälte schließen sich aus.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "ice",
  "name": "Kältenerv",
  "desc": "Treffer verlangsamen 2 s um 45%. Gift, Glut und Kälte schließen sich aus.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "pierce",
  "name": "Knochennadel",
  "desc": "Durchdringt Gegner; -0.25 Feuerrate.",
  "rarity": 1,
  "stat": {
   "rate": -0.25
  }
 },
 {
  "id": "bounce",
  "name": "Gummizelle",
  "desc": "Projektile prallen zweimal von Wänden ab.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "homing",
  "name": "Suchinstinkt",
  "desc": "Projektile suchen Gegner; -60 Projektiltempo.",
  "rarity": 2,
  "stat": {
   "shot_speed": -60.0
  }
 },
 {
  "id": "twin",
  "name": "Zwillingsdrüse",
  "desc": "Zwei Schüsse pro Angriff, je 65% Schaden. Ersetzt keine Dreifachiris; beide schließen sich aus.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "triple",
  "name": "Dreifachiris",
  "desc": "Drei Richtungen, je 50% Schaden. Nicht mit Zwillingsdrüse kombinierbar.",
  "rarity": 2,
  "stat": {}
 },
 {
  "id": "rear",
  "name": "Rückenauge",
  "desc": "Feuert einen zusätzlichen Schuss rückwärts.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "side",
  "name": "Quernerven",
  "desc": "Zusätzliche Schüsse zur linken und rechten Seite.",
  "rarity": 2,
  "stat": {}
 },
 {
  "id": "burst",
  "name": "Salvenlunge",
  "desc": "Jeder vierte Angriff ist ein dreifacher Salve.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "giant",
  "name": "Titanenzelle",
  "desc": "+2 Schaden, größere Schüsse; -0.4 Feuerrate.",
  "rarity": 1,
  "stat": {
   "damage": 2.0,
   "rate": -0.4
  }
 },
 {
  "id": "explode",
  "name": "Drucksack",
  "desc": "Treffer explodieren mit 45% Schaden. Nicht mit Splittermark kombinierbar.",
  "rarity": 2,
  "stat": {}
 },
 {
  "id": "chain",
  "name": "Sturmleiter",
  "desc": "Treffer leiten 55% Schaden zu einem nahen Gegner.",
  "rarity": 2,
  "stat": {}
 },
 {
  "id": "split",
  "name": "Splittermark",
  "desc": "Beim Treffer entstehen drei kleine Projektile.",
  "rarity": 2,
  "stat": {}
 },
 {
  "id": "orbit",
  "name": "Satellitenkern",
  "desc": "Zwei umkreisende Kugeln schaden nahen Gegnern.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "drone",
  "name": "Larvendrohne",
  "desc": "Ein Begleiter feuert selbstständig auf Gegner.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "shield",
  "name": "Spiegelhaut",
  "desc": "Ein Satellit fängt nahe feindliche Schüsse ab.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "thorns",
  "name": "Dornenrinde",
  "desc": "Nach erlittenem Schaden: 8 Flächenschaden.",
  "rarity": 0,
  "stat": {}
 },
 {
  "id": "dash",
  "name": "Phasenmuskel",
  "desc": "Sprint lädt 40% schneller; Sprint verursacht Schaden.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "bomb",
  "name": "Sprengbauch",
  "desc": "+3 Bomben. Bomben haben 60% mehr Radius.",
  "rarity": 0,
  "stat": {}
 },
 {
  "id": "magnet",
  "name": "Magnetblut",
  "desc": "Zieht Münzen und Heilung aus größerer Distanz an.",
  "rarity": 0,
  "stat": {}
 },
 {
  "id": "gold",
  "name": "Goldfieber",
  "desc": "Besiegte Gegner können zusätzliche Münzen fallen lassen.",
  "rarity": 0,
  "stat": {}
 },
 {
  "id": "discount",
  "name": "Händlerzunge",
  "desc": "Shop-Preise sinken um 35%.",
  "rarity": 0,
  "stat": {}
 },
 {
  "id": "heal",
  "name": "Wundwurzel",
  "desc": "Jeder dritte geklärte Kampfraum heilt 1 LP.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "rage",
  "name": "Adrenalin",
  "desc": "Unter halben LP: +50% Schaden.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "luck",
  "name": "Glückschromosom",
  "desc": "Mehr Raum-Drops und +10% kritische Treffer.",
  "rarity": 0,
  "stat": {
   "crit": 0.1
  }
 },
 {
  "id": "glass",
  "name": "Glasgenom",
  "desc": "+3 Schaden, +1 Feuerrate; -2 maximale LP.",
  "rarity": 2,
  "stat": {
   "damage": 3.0,
   "rate": 1.0,
   "max_hp": -2.0
  }
 },
 {
  "id": "phoenix",
  "name": "Phönixkern",
  "desc": "Einmal pro Run nach dem Tod mit 3 LP aufstehen.",
  "rarity": 2,
  "stat": {},
  "unlock": "first_boss"
 },
 {
  "id": "nova",
  "name": "Null-Nova",
  "desc": "Jeder 6. Angriff feuert zusätzlich einen Kreis.",
  "rarity": 2,
  "stat": {},
  "unlock": "kills_100"
 },
 {
  "id": "void",
  "name": "Leerenherz",
  "desc": "Kritische Treffer erzeugen eine ziehende Zone.",
  "rarity": 2,
  "stat": {},
  "unlock": "win"
 },
 {
  "id": "crown",
  "name": "Mutantenkrone",
  "desc": "+0.2 Schaden je Mutation, maximal +4 Schaden.",
  "rarity": 2,
  "stat": {},
  "unlock": "items_10"
 },
 {
  "id": "heavy",
  "name": "Hammerknorpel",
  "desc": "Schüsse stoßen zurück; -12 Bewegungstempo.",
  "rarity": 1,
  "stat": {
   "speed": -12.0
  }
 },
 {
  "id": "execute",
  "name": "Henker-Gen",
  "desc": "+50% Trefferschaden gegen Gegner unter 25% LP.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "bleed",
  "name": "Rasiermark",
  "desc": "Treffer verursachen 1.5 Blutungsschaden/s für 4 s.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "acid",
  "name": "Säureträne",
  "desc": "Kritische Treffer hinterlassen schädigende Säure für Gegner.",
  "rarity": 2,
  "stat": {}
 },
 {
  "id": "frostnova",
  "name": "Winterreflex",
  "desc": "Ein Sprint verlangsamt alle Gegner in 130 Pixeln.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "blooddash",
  "name": "Blutbahn",
  "desc": "Sprint hinterlässt schädliche Blutspur für Gegner; -1 maximale LP.",
  "rarity": 1,
  "stat": {
   "max_hp": -1.0
  }
 },
 {
  "id": "barrier",
  "name": "Einwegmembran",
  "desc": "Der erste Treffer jedes Raums wird sicher abgewehrt.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "soul",
  "name": "Seelenkultur",
  "desc": "Besiegte normale Gegner fallen lassen mit 8% Chance Heilung.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "scavenger",
  "name": "Schrottmagen",
  "desc": "Zerstörte Felsen fallen lassen garantiert eine Münze.",
  "rarity": 0,
  "stat": {}
 },
 {
  "id": "headhunter",
  "name": "Kopfgeldnerv",
  "desc": "Abgeschossene Köpfe geben zwei Münzen.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "turbo",
  "name": "Ruhepol",
  "desc": "Beim Stillstehen +35% Feuerrate.",
  "rarity": 1,
  "stat": {}
 },
 {
  "id": "boomerang",
  "name": "Rücklaufsehne",
  "desc": "Schüsse kehren nach 0.55 s zurück; -0.3 Feuerrate.",
  "rarity": 2,
  "stat": {
   "rate": -0.3
  }
 },
 {
  "id": "keen",
  "name": "Falkenauge",
  "desc": "+12% kritische Treffer, +60 Reichweite.",
  "rarity": 0,
  "stat": {
   "crit": 0.12,
   "range": 60.0
  }
 },
 {
  "id": "longshot",
  "name": "Teleskoprippe",
  "desc": "+220 Reichweite, +40 Projektiltempo.",
  "rarity": 0,
  "stat": {
   "range": 220.0,
   "shot_speed": 40.0
  }
 },
 {
  "id": "rapid",
  "name": "Zuckermotor",
  "desc": "+1.2 Feuerrate, -0.3 Schaden.",
  "rarity": 1,
  "stat": {
   "rate": 1.2,
   "damage": -0.3
  }
 },
 {
  "id": "brute",
  "name": "Berserkerfaser",
  "desc": "+2.4 Schaden, -15 Tempo.",
  "rarity": 1,
  "stat": {
   "damage": 2.4,
   "speed": -15.0
  }
 },
 {
  "id": "marathon",
  "name": "Federbein",
  "desc": "+25 Tempo, +60 Projektiltempo.",
  "rarity": 0,
  "stat": {
   "speed": 25.0,
   "shot_speed": 60.0
  }
 },
 {
  "id": "shell",
  "name": "Keramikhaut",
  "desc": "+12% Abwehrchance und +1 maximale LP.",
  "rarity": 1,
  "stat": {
   "armor": 0.12,
   "max_hp": 1.0
  }
 },
 {
  "id": "battery",
  "name": "Kraftknoten",
  "desc": "+0.6 Feuerrate und +0.7 Schaden.",
  "rarity": 1,
  "stat": {
   "rate": 0.6,
   "damage": 0.7
  }
 },
 {
  "id": "vital",
  "name": "Lebensknospe",
  "desc": "+3 maximale LP, heilt 3 LP, -10 Tempo.",
  "rarity": 1,
  "stat": {
   "max_hp": 3.0,
   "speed": -10.0
  }
 },
 {
  "id": "needle",
  "name": "Mikrokanal",
  "desc": "+120 Projektiltempo und +0.3 Feuerrate.",
  "rarity": 0,
  "stat": {
   "shot_speed": 120.0,
   "rate": 0.3
  }
 },
 {
  "id": "focus",
  "name": "Drittes Auge",
  "desc": "+20% kritische Treffer, -0.2 Feuerrate.",
  "rarity": 1,
  "stat": {
   "crit": 0.2,
   "rate": -0.2
  }
 },
 {
  "id": "dense",
  "name": "Dichte DNA",
  "desc": "+1.8 Schaden und +80 Reichweite.",
  "rarity": 1,
  "stat": {
   "damage": 1.8,
   "range": 80.0
  }
 },
 {
  "id": "royal",
  "name": "Königszelle",
  "desc": "+1 LP, +15 Tempo, +0.5 Schaden.",
  "rarity": 2,
  "stat": {
   "max_hp": 1.0,
   "speed": 15.0,
   "damage": 0.5
  }
 }
]
const UNLOCKS = [
 {
  "id": "first_boss",
  "name": "Erste Probe",
  "desc": "Besiege einen Boss.",
  "reward": "Phönixkern + Charakter VEKTOR"
 },
 {
  "id": "kills_100",
  "name": "Auslöschung",
  "desc": "Besiege insgesamt 100 Gegner.",
  "reward": "Null-Nova + Charakter ECHO"
 },
 {
  "id": "items_10",
  "name": "Übermutiert",
  "desc": "Sammle 10 Mutationen in einem Run.",
  "reward": "Mutantenkrone + Charakter NAHT"
 },
 {
  "id": "floor_3",
  "name": "Tiefenrausch",
  "desc": "Erreiche Ebene 3.",
  "reward": "Charakter MYZEL"
 },
 {
  "id": "win",
  "name": "Versuchsende",
  "desc": "Besiege den Endboss.",
  "reward": "Leerenherz + Modus Härtetest"
 },
 {
  "id": "no_hit",
  "name": "Sterile Arbeit",
  "desc": "Besiege einen Boss ohne LP-Verlust.",
  "reward": "Goldener Charakter-Ring"
 }
]
const CHARACTERS = [
 {
  "name": "NULL",
  "tag": "Die stabile Probe",
  "desc": "6 LP · ausgewogene Werte · 2 Bomben",
  "hp": 6.0,
  "damage": 3.5,
  "speed": 210.0,
  "rate": 3.4,
  "bombs": 2,
  "unlock": "",
  "id": "null",
  "start_item": ""
 },
 {
  "name": "VEKTOR",
  "tag": "Die schnelle Probe",
  "desc": "4 LP · hohes Tempo · kritische Treffer",
  "hp": 4.0,
  "damage": 3.5,
  "speed": 265.0,
  "rate": 3.8,
  "bombs": 1,
  "unlock": "first_boss",
  "id": "vector",
  "start_item": ""
 },
 {
  "name": "MYZEL",
  "tag": "Die lebende Kolonie",
  "desc": "8 LP · langsam · startet mit Giftblase",
  "hp": 8.0,
  "damage": 3.0,
  "speed": 180.0,
  "rate": 3.2,
  "bombs": 2,
  "unlock": "floor_3",
  "id": "mycel",
  "start_item": "poison"
 },
 {
  "id": "ember",
  "name": "GLUT",
  "tag": "Die glühende Probe",
  "desc": "5 LP · startet mit Glutorgan",
  "hp": 5.0,
  "damage": 3.0,
  "speed": 210.0,
  "rate": 3.3,
  "bombs": 1,
  "unlock": "",
  "start_item": "burn"
 },
 {
  "id": "stitch",
  "name": "NAHT",
  "tag": "Die zusammengesetzte Probe",
  "desc": "7 LP · startet mit Satellitenkern",
  "hp": 7.0,
  "damage": 3.0,
  "speed": 195.0,
  "rate": 3.1,
  "bombs": 2,
  "unlock": "items_10",
  "start_item": "orbit"
 },
 {
  "id": "echo",
  "name": "ECHO",
  "tag": "Die suchende Probe",
  "desc": "4 LP · startet mit Suchinstinkt",
  "hp": 4.0,
  "damage": 2.8,
  "speed": 235.0,
  "rate": 3.5,
  "bombs": 1,
  "unlock": "kills_100",
  "start_item": "homing"
 }
]
const BOSSES = [
 {
  "name": "DER BRÜTER",
  "kind": "brood",
  "subtitle": "Die Kolonie erwacht",
  "hp": 160.0,
  "color": "ed88c5"
 },
 {
  "name": "CHITIN-KÖNIG",
  "kind": "chitin",
  "subtitle": "Unter der Panzerung",
  "hp": 180.0,
  "color": "e6ae62"
 },
 {
  "name": "SYNAPSE",
  "kind": "synapse",
  "subtitle": "Gedanken werden Geschosse",
  "hp": 240.0,
  "color": "94a5ff"
 },
 {
  "name": "DER OFEN",
  "kind": "furnace",
  "subtitle": "Alles wird Asche",
  "hp": 260.0,
  "color": "ff805d"
 },
 {
  "name": "KNOCHENORBIT",
  "kind": "marrow",
  "subtitle": "Der Knochenring schließt sich",
  "hp": 290.0,
  "color": "ead2b4"
 },
 {
  "name": "DIE MODERKÖNIGIN",
  "kind": "bog",
  "subtitle": "Nichts verlässt den Sumpf",
  "hp": 300.0,
  "color": "a4d66b"
 },
 {
  "name": "DER ENTHAUPTER",
  "kind": "executioner",
  "subtitle": "Das Blut bleibt in Bewegung",
  "hp": 340.0,
  "color": "e86585"
 },
 {
  "name": "DER ARCHITEKT",
  "kind": "architect",
  "subtitle": "Der Raum arbeitet gegen dich",
  "hp": 350.0,
  "color": "dab779"
 },
 {
  "name": "SPIEGELPROBE",
  "kind": "mirror",
  "subtitle": "Dein Angriff kommt zurück",
  "hp": 400.0,
  "color": "afa4f0"
 },
 {
  "name": "PROBE OMEGA",
  "kind": "omega",
  "subtitle": "Das Ende des Experiments",
  "hp": 440.0,
  "color": "74f5cc"
 }
]

const BIOMES = [
 {
  "id": "incubator",
  "name": "INKUBATOR",
  "color": "74f5cc",
  "enemies": [
   0,
   1,
   2,
   6,
   7
  ],
  "reward": "Leichter Einstieg",
  "danger": "Nahkämpfer"
 },
 {
  "id": "reactor",
  "name": "REAKTOR",
  "color": "ff805d",
  "enemies": [
   1,
   2,
   3,
   8,
   12
  ],
  "reward": "Mehr Bomben",
  "danger": "Schnelle Geschosse"
 },
 {
  "id": "marsh",
  "name": "MODERSUMPF",
  "color": "a4d66b",
  "enemies": [
   0,
   4,
   7,
   10,
   11
  ],
  "reward": "Mehr Heilung",
  "danger": "Schädliche Sporen"
 },
 {
  "id": "ossuary",
  "name": "KNOCHENARCHIV",
  "color": "e6bc86",
  "enemies": [
   2,
   6,
   9,
   10,
   12
  ],
  "reward": "Mehr besondere Mutationen",
  "danger": "Panzer und Kopfschüsse"
 },
 {
  "id": "void",
  "name": "NULLKERN",
  "color": "afa4f0",
  "enemies": [
   3,
   6,
   8,
   9,
   11,
   12
  ],
  "reward": "Letzter Abschnitt",
  "danger": "Phasenwechsel und Reflexion"
 }
]
const ENEMIES = [
 {
  "id": "crawler",
  "kind": 0,
  "name": "Kriecher",
  "hp": 11.0,
  "radius": 16.0,
  "color": "ed88c5",
  "desc": "Verfolgt die Probe."
 },
 {
  "id": "spitter",
  "kind": 1,
  "name": "Spucker",
  "hp": 16.0,
  "radius": 18.0,
  "color": "aca3ef",
  "desc": "Hält Abstand und schießt gezielt."
 },
 {
  "id": "charger",
  "kind": 2,
  "name": "Rammbock",
  "hp": 22.0,
  "radius": 22.0,
  "color": "e8b66c",
  "desc": "Warnt mit einem Strahl vor seinem Ansturm."
 },
 {
  "id": "turret",
  "kind": 3,
  "name": "Ringdrüse",
  "hp": 18.0,
  "radius": 19.0,
  "color": "ff806f",
  "desc": "Feuert Geschossringe."
 },
 {
  "id": "larva",
  "kind": 4,
  "name": "Larve",
  "hp": 13.0,
  "radius": 15.0,
  "color": "a5db8b",
  "desc": "Klein und schnell."
 },
 {
  "id": "decapitator",
  "kind": 6,
  "name": "Blutläufer",
  "hp": 30.0,
  "radius": 20.0,
  "color": "e86585",
  "desc": "Kopf mit eigener Trefferzone. Kopflos läuft er panisch und spritzt Blutgeschosse."
 },
 {
  "id": "splitter",
  "kind": 7,
  "name": "Teilungssack",
  "hp": 24.0,
  "radius": 22.0,
  "color": "b5d674",
  "desc": "Zerfällt nach dem Tod in zwei Larven."
 },
 {
  "id": "blinker",
  "kind": 8,
  "name": "Phasengeist",
  "hp": 20.0,
  "radius": 18.0,
  "color": "9bb4f1",
  "desc": "Teleportiert nach einer Warnung und schießt einen Fächer."
 },
 {
  "id": "shieldbug",
  "kind": 9,
  "name": "Schildkäfer",
  "hp": 26.0,
  "radius": 23.0,
  "color": "ddb786",
  "desc": "Fronttreffer verursachen nur 25% Schaden. Flankiere ihn."
 },
 {
  "id": "leech",
  "kind": 10,
  "name": "Münzegel",
  "hp": 18.0,
  "radius": 17.0,
  "color": "dd8dac",
  "desc": "Schneller Verfolger. Kontakt stiehlt zusätzlich eine Münze."
 },
 {
  "id": "spore",
  "kind": 11,
  "name": "Sporenträger",
  "hp": 22.0,
  "radius": 20.0,
  "color": "89c985",
  "desc": "Legt Sporenfelder, die Schaden verursachen und Tempo senken."
 },
 {
  "id": "sniper",
  "kind": 12,
  "name": "Nadelauge",
  "hp": 16.0,
  "radius": 17.0,
  "color": "eab99b",
  "desc": "Kündigt einen schnellen Präzisionsschuss mit einem Laser an."
 },
 {
  "id": "medic",
  "art_id": "spore",
  "kind": 13,
  "name": "Nährer",
  "hp": 20.0,
  "radius": 18.0,
  "color": "74f5cc",
  "desc": "Heilt verletzte Verbündete alle 2.4 s um 3 LP. Türkise Verbindung zeigt das Ziel. Heilt keine Bosse."
 },
 {
  "id": "mortar",
  "art_id": "turret",
  "kind": 14,
  "name": "Mörserdrüse",
  "hp": 22.0,
  "radius": 19.0,
  "color": "ffad66",
  "desc": "Markiert deinen Standort und bombardiert ihn nach einer Warnung. Verlasse den Kreis."
 },
 {
  "id": "stalker",
  "art_id": "larva",
  "kind": 15,
  "name": "Kreisläufer",
  "hp": 18.0,
  "radius": 16.0,
  "color": "c39bff",
  "desc": "Umläuft dich seitlich und schießt zwei langsame Geschosse."
 },
 {
  "id": "volatile",
  "art_id": "charger",
  "kind": 16,
  "name": "Berstling",
  "hp": 16.0,
  "radius": 20.0,
  "color": "ff6666",
  "desc": "Kündigt einen geraden Ansturm an und explodiert danach am Endpunkt. Töte ihn vorher."
 }
]
const SYNERGIES = [
 {
  "id": "toxic_boom",
  "name": "Giftknall",
  "requires": [
   "poison",
   "explode"
  ],
  "desc": "Explosive Treffer erzeugen Giftflächen."
 },
 {
  "id": "shatter",
  "name": "Eisbrecher",
  "requires": [
   "ice",
   "heavy"
  ],
  "desc": "Treffer auf verlangsamte Gegner lösen einen Splitterstoß aus."
 },
 {
  "id": "blood_pact",
  "name": "Blutkreislauf",
  "requires": [
   "blooddash",
   "vampire"
  ],
  "desc": "Gegner, die auf deiner Blutspur sterben, heilen mit 20% Chance 1 LP."
 },
 {
  "id": "storm_orbit",
  "name": "Sturmring",
  "requires": [
   "orbit",
   "chain"
  ],
  "desc": "Satellitentreffer leiten zusätzlichen Schaden zu nahen Gegnern."
 },
 {
  "id": "needle_nova",
  "name": "Splitterstern",
  "requires": [
   "nova",
   "split"
  ],
  "desc": "Jede sechste Salve enthält einen Ring aus 16 statt 8 Schüssen."
 },
 {
  "id": "return_hunt",
  "name": "Rückruf",
  "requires": [
   "homing",
   "boomerang"
  ],
  "desc": "Zurückkehrende Schüsse durchdringen Gegner."
 }
]
const EVENTS = [
 {
  "id": "lab",
  "name": "TAUSCHLABOR",
  "desc": "Die zuletzt erhaltene Mutation gegen eine unbekannte tauschen."
 },
 {
  "id": "sacrifice",
  "name": "OPFERKAMMER",
  "desc": "2 maximale LP für eine seltene Mutation opfern."
 },
 {
  "id": "challenge",
  "name": "VERSIEGELTE PROBE",
  "desc": "Freiwilligen schweren Kampf für eine seltene Mutation starten."
 },
 {
  "id": "unstable",
  "name": "INSTABILE GENBANK",
  "desc": "Zwei Mutationen nehmen; feindliche Geschosse sind danach dauerhaft 25% schneller."
 }
]

static func enemy(kind: int) -> Dictionary:
 for entry in ENEMIES:
  if entry.kind == kind: return entry
 return {"id":"boss","kind":5,"hp":160.0,"radius":42.0,"color":"ed88c5"}

static func item(id: String) -> Dictionary:
 for entry in ITEMS:
  if entry.id == id:
   return entry
 return ITEMS[0]
static func pool(unlocked: Array) -> Array:
 return ITEMS.filter(func(entry): return entry.get("unlock", "") == "" or entry.get("unlock", "") in unlocked)
