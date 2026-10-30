#!/usr/bin/env python3
"""Offline structural checks. Does not compile GDScript or run the game."""
from pathlib import Path
import json
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / 'scripts'
CATALOG = (SCRIPTS / 'catalog.gd').read_text()
MAIN = (SCRIPTS / 'main.gd').read_text()


def catalog_array(name):
    match = re.search(r'const ' + name + r' = (\[.*?\n\])', CATALOG, re.S)
    assert match, name
    return json.loads(match.group(1))


class ProjectChecks(unittest.TestCase):
    def test_scene_and_preloads_resolve(self):
        for path in list(SCRIPTS.glob('*.gd')) + list((ROOT / 'scenes').glob('*.tscn')) + [ROOT / 'project.godot']:
            for target in re.findall(r'"res://([^"\n]+)"', path.read_text()):
                self.assertTrue((ROOT / target).is_file(), (path.name, target))

    def test_64_unique_mutations_have_implemented_effects(self):
        items = catalog_array('ITEMS')
        self.assertEqual(len(items), 64)
        self.assertEqual(len({i['id'] for i in items}), 64)
        # Stat-only items need no bespoke hook; mechanics must actually be read.
        mechanics = set(re.findall(r'has_item\("(\w+)"\)', MAIN))
        special = set(re.findall(r'if id == "(\w+)"', MAIN))
        known_stats = {'damage', 'speed', 'max_hp', 'rate', 'crit', 'range', 'shot_speed', 'armor'}
        for item in items:
            self.assertIn(item['rarity'], (0, 1, 2))
            self.assertTrue(item['name'] and item['desc'])
            self.assertTrue(set(item['stat']).issubset(known_stats), item['id'])
            self.assertTrue(item['stat'] or item['id'] in mechanics | special, item['id'])
        self.assertTrue(mechanics.issubset({i['id'] for i in items}))

    def test_unlock_rewards_and_character_gates_resolve(self):
        unlocks = catalog_array('UNLOCKS')
        ids = {i['id'] for i in unlocks}
        self.assertEqual(len(ids), 6)
        triggers = set(re.findall(r'unlock\("(\w+)"\)', MAIN))
        self.assertEqual(ids, triggers)
        for item in catalog_array('ITEMS'):
            self.assertTrue(not item.get('unlock') or item['unlock'] in ids)
        chars = catalog_array('CHARACTERS')
        self.assertEqual(len(chars), 6)
        for c in chars:
            self.assertTrue(not c['unlock'] or c['unlock'] in ids)

    def test_ten_bosses_have_patterns(self):
        bosses = catalog_array('BOSSES')
        self.assertEqual(len(bosses), 10)
        for boss in bosses:
            self.assertRegex(MAIN, r'"' + boss['kind'] + r'":\s*\n')
            self.assertGreater(boss['hp'], 0)
        dungeon = (SCRIPTS / 'dungeon.gd').read_text()
        self.assertIn('biome_index*2', dungeon)
        self.assertIn('make_room("transition",rng)', dungeon)
        self.assertIn('rooms[b].gate == a', dungeon)

    def test_scripts_have_balanced_tokens_and_unique_functions(self):
        for path in SCRIPTS.glob('*.gd'):
            source = path.read_text()
            functions = re.findall(r'^(?:static )?func (\w+)\(', source, re.M)
            self.assertEqual(len(functions), len(set(functions)), path.name)
            stack = []
            pairs = {')': '(', ']': '[', '}': '{'}
            quote = None
            escaped = False
            comment = False
            for char in source:
                if comment:
                    if char == '\n': comment = False
                    continue
                if quote:
                    if escaped: escaped = False
                    elif char == '\\': escaped = True
                    elif char == quote: quote = None
                    continue
                if char == '#': comment = True
                elif char in ('"', "'"): quote = char
                elif char in '([{': stack.append(char)
                elif char in ')]}':
                    self.assertTrue(stack, (path.name, char))
                    self.assertEqual(stack.pop(), pairs[char], path.name)
            self.assertIsNone(quote, path.name)
            self.assertFalse(stack, path.name)

    def test_test_mode_never_saves_profile(self):
        profile = (SCRIPTS / 'profile.gd').read_text()
        for method in ('save_profile', 'save_run', 'clear_run'):
            self.assertRegex(profile, r'func ' + method + r'\([^\n]*\n if memory_only: return')
        self.assertIn('profile.memory_only = true', MAIN)
        self.assertNotIn('get_var(true)', profile)

    def test_split_children_do_not_recurse(self):
        self.assertIn('if not bullet.child:\n      on_hit(bullet,enemy)', MAIN)
        self.assertRegex(MAIN, r'bullet.damage\*0.4,true\)')
        self.assertIn('shots.size()>=384', MAIN)

    def test_room_rewards_and_save_points_exist(self):
        self.assertIn('room.choice = false', MAIN)
        self.assertIn('pickups = pickups.filter(func(p): return p.type != "item")', MAIN)
        self.assertIn('player.coins -= cost', MAIN)
        self.assertIn('room.cleared = true', MAIN)
        self.assertIn('profile.clear_run()', MAIN)
        self.assertGreaterEqual(MAIN.count('save_checkpoint()'), 5)

    def test_every_asset_exists_with_exact_dimensions(self):
        from PIL import Image
        manifest = json.loads((ROOT / 'assets/asset_manifest.json').read_text())
        self.assertGreaterEqual(len(manifest), 237)
        for key, entry in manifest.items():
            with Image.open(ROOT / entry['path'][6:]) as image:
                self.assertEqual(image.size, (entry['width'], entry['height']), key)
                self.assertEqual(image.mode, 'RGBA', key)
            if 'states' in entry:
                self.assertEqual(entry['width'], entry['cell'] * 6, key)
                self.assertEqual(entry['height'], entry['cell'] * 24, key)
                self.assertEqual(entry['states'], ['idle', 'walk', 'shoot', 'hurt', 'dash', 'death'])
        for item in catalog_array('ITEMS'):
            self.assertIn('item/' + item['id'], manifest)
            self.assertIn('mutation/' + item['id'], manifest)
        for character in catalog_array('CHARACTERS'):
            self.assertIn('character/' + character['id'], manifest)
        for enemy in catalog_array('ENEMIES'):
            self.assertIn('enemy/' + enemy.get('art_id',enemy['id']), manifest)
        for boss in catalog_array('BOSSES'):
            self.assertIn('boss/' + boss['kind'], manifest)
        for biome in catalog_array('BIOMES'):
            for role in ['floor', 'background', 'rock', 'transition']:
                self.assertIn('biome/' + biome['id'] + '/' + role, manifest)

    def test_custom_audio_files_and_settings(self):
        import wave
        config = json.loads((ROOT / 'assets/audio/audio_config.json').read_text())
        self.assertEqual(len(config['effects']), 18)
        self.assertEqual(len(config['music']), 6)
        for settings in list(config['effects'].values()) + list(config['music'].values()):
            with wave.open(str(ROOT / settings['path'][6:])) as wav:
                self.assertEqual(wav.getsampwidth(), 2)
                self.assertGreater(wav.getnframes(), 0)
            self.assertGreaterEqual(settings['volume'], 0)

    def test_enemy_behaviors_and_direct_blood_damage(self):
        enemies = catalog_array('ENEMIES')
        self.assertEqual(len(enemies), 16)
        for enemy in enemies:
            self.assertRegex(MAIN, r'    ' + str(enemy['kind']) + r':\n')
        self.assertIn('enemy.head_hp -= bullet.damage', MAIN)
        self.assertIn('blood.art = "blood_shot"', MAIN)
        self.assertIn('enemy.headless = true', MAIN)
        self.assertIn('"bloodtrail":\n    pass', MAIN)

    def test_rendering_never_spawns_gameplay_objects(self):
        draw_section = MAIN[MAIN.index('func _draw()'):MAIN.index('func take_screenshot()')]
        self.assertNotIn('room.pickups.append', draw_section)
        self.assertNotIn('foes.append', draw_section)

    def test_portraits_and_cutscene_resolve(self):
        manifest = json.loads((ROOT / 'assets/asset_manifest.json').read_text())
        intro = json.loads((ROOT / 'assets/dialogue/intro_de.json').read_text())['panels']
        self.assertEqual(len(intro), 6)
        self.assertGreaterEqual(sum(p['duration'] for p in intro), 30)
        self.assertLessEqual(sum(p['duration'] for p in intro), 40)
        people = ['character/' + c['id'] for c in catalog_array('CHARACTERS')]
        people += ['enemy/' + e.get('art_id',e['id']) for e in catalog_array('ENEMIES')]
        people += ['boss/' + b['kind'] for b in catalog_array('BOSSES')] + ['ai']
        for person in people:
            for emotion in ['neutral', 'happy', 'angry', 'hurt']:
                entry = manifest['portrait/' + person + '/' + emotion]
                self.assertEqual((entry['width'], entry['height']), (96, 96))
        for p in intro:
            self.assertIn('cutscene/' + p['id'], manifest)
            self.assertTrue(p['text'])
        self.assertIn('ui/dialogue_box', manifest)
        self.assertIn('ui/portrait_frame', manifest)

    def test_dialogue_is_silent_and_all_speakers_have_text(self):
        speech = (SCRIPTS / 'speech.gd').read_text()
        self.assertNotIn('AudioStream', speech)
        self.assertNotIn('sound.play', speech)
        data = json.loads((ROOT / 'assets/dialogue/dialogue_de.json').read_text())
        self.assertIn('drei von den Viechern', data['item_lines']['triple'][0])
        self.assertGreaterEqual(data['ambient_cooldown'], 15)
        for e in catalog_array('ENEMIES'):
            self.assertTrue(data['enemies'][e['id']])
        for b in catalog_array('BOSSES'):
            self.assertTrue(data['bosses'][b['kind']]['intro'])
            self.assertTrue(data['bosses'][b['kind']]['defeat'])
        self.assertNotIn('Isaac', json.dumps(data))

    def test_synergies_and_optional_room_assets(self):
        manifest = json.loads((ROOT / 'assets/asset_manifest.json').read_text())
        ids = {i['id'] for i in catalog_array('ITEMS')}
        combos = catalog_array('SYNERGIES')
        self.assertEqual(len(combos), 6)
        for combo in combos:
            self.assertTrue(set(combo['requires']).issubset(ids))
            self.assertIn('has_synergy("' + combo['id'] + '")', MAIN)
        self.assertEqual(len(catalog_array('EVENTS')), 4)
        for biome in catalog_array('BIOMES'):
            for e in catalog_array('EVENTS'):
                self.assertIn('biome/' + biome['id'] + '/' + e['id'], manifest)
        self.assertIn('run_hp_cost += 2', MAIN)
        self.assertIn('curse_speed = minf(1.75,curse_speed*1.25)', MAIN)
        self.assertIn('room.cleared = false', MAIN)
        self.assertIn('not id in route', MAIN)

    def test_branch_save_and_export_json(self):
        self.assertIn('"route":route', MAIN)
        self.assertIn('"hp_cost":run_hp_cost', MAIN)
        self.assertIn('route = state.route', MAIN)
        self.assertIn('curse_speed = state.curse_speed', MAIN)
        self.assertIn('room.boss_hit = true', MAIN)
        exports = (ROOT / 'export_presets.cfg').read_text()
        self.assertEqual(exports.count('include_filter="*.json"'), 2)

if __name__ == '__main__':
    unittest.main(verbosity=2)
