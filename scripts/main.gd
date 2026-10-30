extends Node2D
const Catalog = preload("res://scripts/catalog.gd")
const Dungeon = preload("res://scripts/dungeon.gd")
const Profile = preload("res://scripts/profile.gd")
const Sound = preload("res://scripts/sound.gd")
const Art = preload("res://scripts/art.gd")
const Speech = preload("res://scripts/speech.gd")
var speech = Speech.new()
var chatter_rng = RandomNumberGenerator.new()
var chatter_cd = 12.0
var route: Array = [0]
var run_risk = false
var curse_speed = 1.0
var run_hp_cost = 0
var found_synergies: Array = []
var intro_panels: Array = []
var intro_index = 0
var intro_time = 0.0
var intro_for_run = false
const FLOOR_COUNT = 10
var boss_order: Array = []
var milestone_claimed = false
var pickup_history: Array = []
var pool_cd = 0.0
var art = Art.new()
var corpses: Array = []
var barrier_charge = false
var player_facing = "down"
var player_state = "idle"
var player_anim = 0.0
var player_shoot_anim = 0.0
var step_cd = 0.0
var mutation_layers = true
const ARENA = Rect2(60,148,920,584)
const CENTER = Vector2(520,440)
const CYAN = Color("74f5cc")
const PINK = Color("ed88c5")
const GOLD = Color("e8b66c")
const INK = Color("101724")
const WHITE = Color("e3e9f4")
const MUTED = Color("7e8da6")
const DIRS = [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]
var font = ThemeDB.fallback_font
var profile = Profile.new()
var sound
var rng = RandomNumberGenerator.new()
var ui: CanvasLayer
var screen = "menu"
var page = 0
var character = 0
var hard = false
var seed_text = ""
var seed_input: LineEdit
var rooms: Dictionary = {}
var current = Vector2i.ZERO
var floor_number = 1
var player: Dictionary = {}
var inventory: Array = []
var shots: Array = []
var foes: Array = []
var pickups: Array = []
var obstacles: Array = []
var particles: Array = []
var hazards: Array = []
var effects: Array = []
var room: Dictionary = {}
var timer = 0.0
var run_time = 0.0
var shoot_cd = 0.0
var dash_cd = 0.0
var dash_time = 0.0
var dash_vector = Vector2.RIGHT
var invuln = 0.0
var transition_cd = 0.0
var drone_cd = 0.0
var attack_count = 0
var kills_run = 0
var clears = 0
var hit_this_boss = false
var phoenix_used = false
var bomb_cd = 0.0
var seed_value = 0
var shake = 0.0
var toast = ""
var toast_time = 0.0
var unlock_queue: Array = []
var item_banner = ""
var item_detail = ""
var item_time = 0.0
var end_title = ""
var end_reason = ""
var end_won = false
var near_pickup = -1
var orbit_damage_cd = 0.0
var touch_enabled = false
var touch_left = -1
var touch_right = -1
var touch_origin = Vector2.ZERO
var touch_aim_origin = Vector2.ZERO
var touch_move = Vector2.ZERO
var touch_aim = Vector2.ZERO
var mouse_used = false
var test_mode = false
var first_focus = true

func _ready() -> void:
 configure_inputs()
 profile.load_profile()
 speech.enabled = profile.data.get("dialogue_enabled",true)
 var intro_data = JSON.parse_string(FileAccess.get_file_as_string("res://assets/dialogue/intro_de.json"))
 if intro_data is Dictionary: intro_panels = intro_data.get("panels",[])
 chatter_rng.randomize()
 sound = Sound.new()
 sound.testing_silent = "--screenshot" in OS.get_cmdline_user_args()
 add_child(sound)
 sound.volume = float(profile.data.volume)
 sound.music_enabled = profile.data.music_enabled
 ui = CanvasLayer.new()
 add_child(ui)
 touch_enabled = DisplayServer.is_touchscreen_available()
 rng.randomize()
 menu()
 if "--smoke-test" in OS.get_cmdline_user_args():
  test_mode = true
  profile.memory_only = true
  run_smoke_test.call_deferred()
 if "--screenshot" in OS.get_cmdline_user_args():
  test_mode = true
  profile.memory_only = true
  screenshot_scenario.call_deferred()

func configure_inputs() -> void:
 var keys = {"left":[KEY_A],"right":[KEY_D],"up":[KEY_W],"down":[KEY_S],
 "fire_left":[KEY_LEFT],"fire_right":[KEY_RIGHT],"fire_up":[KEY_UP],"fire_down":[KEY_DOWN],
 "dash":[KEY_SPACE],"bomb":[KEY_Q],"interact":[KEY_E],"pause":[KEY_ESCAPE],"map":[KEY_TAB],"genome":[KEY_I]}
 for action in keys:
  InputMap.add_action(action,0.18)
  for key in keys[action]:
   var event = InputEventKey.new()
   event.physical_keycode = key
   InputMap.action_add_event(action,event)
 var buttons = {"dash":JOY_BUTTON_A,"bomb":JOY_BUTTON_X,"interact":JOY_BUTTON_B,"pause":JOY_BUTTON_START,"map":JOY_BUTTON_BACK}
 for action in buttons:
  var event = InputEventJoypadButton.new()
  event.button_index = buttons[action]
  InputMap.action_add_event(action,event)

func clear_ui() -> void:
 first_focus = true
 for node in ui.get_children():
  node.queue_free()
 # Free on next frame; disabled immediately to avoid stale callbacks.
  if node is Control:
   node.hide()
 touch_left = -1
 touch_right = -1
 touch_move = Vector2.ZERO
 touch_aim = Vector2.ZERO

func button(label: String, rect: Rect2, callback: Callable, accent: Color = CYAN) -> Button:
 var b = Button.new()
 b.text = label
 b.position = rect.position
 b.size = rect.size
 b.add_theme_color_override("font_color",WHITE)
 b.add_theme_color_override("font_hover_color",accent)
 b.add_theme_font_size_override("font_size",18)
 for state in ["normal","hover","pressed","focus","disabled"]:
  var box = StyleBoxFlat.new()
  box.bg_color = Color("1a2638") if state == "normal" else Color("26374a")
  box.border_color = accent.darkened(0.65) if state == "normal" else accent
  box.set_border_width_all(1)
  box.set_corner_radius_all(7)
  box.content_margin_left = 14
  box.content_margin_right = 14
  b.add_theme_stylebox_override(state,box)
 b.pressed.connect(callback)
 ui.add_child(b)
 if first_focus and screen != "game":
  b.grab_focus()
  first_focus = false
 return b

func menu() -> void:
 screen = "menu"
 sound.set_music("menu")
 speech.reset()
 clear_ui()
 button("NEUER VERSUCH  →",Rect2(80,440,310,56),start_run)
 if not profile.load_run().is_empty():
  button("VERSUCH FORTSETZEN",Rect2(80,510,310,48),continue_run)
 button("MUTATIONSARCHIV",Rect2(80,574,310,48),func(): archive(0))
 button("VORGESCHICHTE",Rect2(420,574,220,48),func(): start_intro(false),MUTED)
 button("FREIGABEN",Rect2(80,636,148,48),unlock_menu)
 button("OPTIONEN",Rect2(242,636,148,48),options_menu)
 button("◀",Rect2(720,535,54,44),func(): select_character(-1))
 button("▶",Rect2(1040,535,54,44),func(): select_character(1))
 button("HÄRTETEST" if hard else "REGULÄR",Rect2(802,601,212,44),toggle_hard,GOLD)
 seed_input = LineEdit.new()
 seed_input.position = Vector2(720,670)
 seed_input.size = Vector2(374,42)
 seed_input.placeholder_text = "Optionaler Startwert (z.B. LAB42)"
 seed_input.text = seed_text
 seed_input.max_length = 24
 seed_input.add_theme_font_size_override("font_size",17)
 seed_input.text_changed.connect(func(text): seed_text = text)
 ui.add_child(seed_input)

func select_character(delta: int) -> void:
 character = posmod(character + delta,Catalog.CHARACTERS.size())
 menu()
func toggle_hard() -> void:
 if "win" in profile.data.unlocks:
  hard = not hard
  menu()
 else:
  notify("Härtetest: Besiege zuerst fünf Bosse und verlasse die Schleuse.")
func options_menu() -> void:
 screen = "options"
 clear_ui()
 button("LAUTSTÄRKE −",Rect2(380,300,220,52),func(): change_volume(-0.15))
 button("LAUTSTÄRKE +",Rect2(620,300,220,52),func(): change_volume(0.15))
 button("BILDSCHIRMWACKELN",Rect2(380,380,460,52),func(): profile.data.shake = not profile.data.shake; profile.save_profile())
 button("BERÜHRUNGSSTEUERUNG",Rect2(380,460,460,52),func(): touch_enabled = not touch_enabled)
 button("MUTATIONSOPTIK",Rect2(380,523,220,42),func(): mutation_layers = not mutation_layers)
 button("SPRÜCHE: "+("AN" if speech.enabled else "AUS"),Rect2(620,523,220,42),toggle_dialogue)
 button("MUSIK: "+("AN" if profile.data.music_enabled else "AUS"),Rect2(380,575,460,40),toggle_music)
 button("ZURÜCK",Rect2(380,640,460,52),menu)
func change_volume(amount: float) -> void:
 profile.data.volume = clampf(float(profile.data.volume)+amount,0,1)
 sound.volume = profile.data.volume
 profile.save_profile()
func archive(new_page: int) -> void:
 screen = "archive"
 page = clampi(new_page,0,int(ceil(Catalog.ITEMS.size()/8.0))-1)
 clear_ui()
 button("◀",Rect2(80,718,90,45),func(): archive(page-1))
 button("▶",Rect2(184,718,90,45),func(): archive(page+1))
 button("ZURÜCK",Rect2(1040,718,160,45),menu)
func unlock_menu() -> void:
 screen = "unlocks"
 clear_ui()
 button("ZURÜCK",Rect2(1040,718,160,45),menu)

func begin_run() -> void:
 var c = Catalog.CHARACTERS[character]
 if c.unlock != "" and not c.unlock in profile.data.unlocks:
  notify("Diese Probe ist noch gesperrt. Sieh unter Freigaben nach.")
  return
 clear_ui()
 screen = "game"
 seed_value = hash(seed_text) if not seed_text.strip_edges().is_empty() else int(Time.get_unix_time_from_system()*1000) ^ randi()
 rng.seed = seed_value
 inventory.clear()
 speech.reset()
 chatter_rng.seed = seed_value ^ 7281
 chatter_cd = 12.0
 route = [0]
 boss_order = []
 for biome in Catalog.BIOMES: boss_order.append(rng.randi_range(0,1))
 milestone_claimed = false
 pickup_history.clear()
 pool_cd = 0
 item_time = 0
 room = {}
 run_risk = false
 curse_speed = 1.0
 run_hp_cost = 0
 found_synergies.clear()
 player = {"pos":CENTER,"hp":c.hp,"max_hp":c.hp,"damage":c.damage,"speed":c.speed,"rate":c.rate,
 "shot_speed":470.0,"range":620.0,"crit":0.12 if character == 1 else 0.03,"armor":0.0,"coins":0,"bombs":c.bombs}
 floor_number = 1
 run_time = 0
 kills_run = 0
 clears = 0
 attack_count = 0
 phoenix_used = false
 shoot_cd = 0
 dash_cd = 0
 dash_time = 0
 invuln = 0
 bomb_cd = 0
 drone_cd = 0
 profile.data.runs += 1
 profile.save_profile()
 if c.get("start_item","") != "":
  take_item(c.start_item)
 generate_floor()
 notify("WASD bewegen · Pfeile / Maus schießen · Leertaste Sprint · E nehmen")

func generate_floor() -> void:
 rooms = Dungeon.generate(rng,floor_number,route[floor_number-1])
 var biome_index = int(route[floor_number-1])
 var visit = 0
 for i in range(floor_number):
  if route[i] == biome_index: visit += 1
 for coords in rooms:
  if rooms[coords].type == "boss":
   rooms[coords].boss_index = biome_index*2+((int(boss_order[biome_index])+visit-1)%2)
 current = Vector2i.ZERO
 profile.data.best_floor = maxi(profile.data.best_floor,floor_number)
 if floor_number == 3:
  unlock("floor_3")
 enter_room(Vector2i.ZERO,CENTER)

func enter_room(coords: Vector2i, spawn: Vector2) -> void:
 if not room.is_empty():
  room.enemies = foes.duplicate(true)
  room.pickups = pickups.duplicate(true)
 current = coords
 room = rooms[current]
 room.visited = true
 player.pos = spawn
 shots.clear()
 hazards.clear()
 particles.clear()
 effects.clear()
 corpses.clear()
 barrier_charge = has_item("barrier")
 transition_cd = 0.5
 dash_time = 0
 invuln = maxf(invuln,0.45)
 hit_this_boss = room.get("boss_hit",false)
 var newly_spawned = not room.spawned
 if not room.spawned:
  populate_room()
  room.spawned = true
 foes = room.enemies.duplicate(true)
 if newly_spawned and room.type == "boss": speak_boss(room.boss_index,true)
 if newly_spawned and room.type == "transition": speak_player(speech.choice(speech.data.get("route",[]),chatter_rng),"neutral")
 if newly_spawned:
  for e in foes: effects.append({"type":"sprite","key":"spawn","pos":e.pos,"ttl":0.66,"age":0.0,"size":64.0})
 pickups = room.pickups.duplicate(true)
 obstacles = room.obstacles.duplicate(true)
 save_checkpoint()
 game_ui()
 sound.set_music(current_biome().id)
 sound.play("door")

func populate_room() -> void:
 var rr = RandomNumberGenerator.new()
 rr.seed = room.seed
 room.enemies = []
 room.pickups = []
 room.obstacles = []
 if room.type == "combat":
  var layouts = [[],[Vector2(310,320),Vector2(730,560)],[Vector2(310,560),Vector2(730,320)],
   [Vector2(340,330),Vector2(700,330),Vector2(340,550),Vector2(700,550)],[Vector2(360,440),Vector2(680,440)]]
  for pos in layouts[room.layout]:
   room.obstacles.append({"pos":pos,"radius":26.0,"hp":16.0})
  for i in range(mini(10,rr.randi_range(3,5)+int((floor_number-1)/2))):
    var p = Vector2(rr.randf_range(220,820),rr.randf_range(265,620))
    var tries = 0    
    while not clear_spawn(p,room.obstacles) and tries < 30:
        p = Vector2(rr.randf_range(220,820),rr.randf_range(265,620))
        tries += 1 
    var kinds = current_biome().enemies
    var kind = kinds[rr.randi_range(0,kinds.size()-1)]
    if floor_number>=2 and i == 0: kind = 13+posmod(floor_number+room.layout,4)
    room.enemies.append(make_enemy(kind,p))
 elif room.type == "boss":
  var index = room.boss_index
  var info = Catalog.BOSSES[index]
  var boss = make_enemy(5,Vector2(520,350))
  boss.boss = index
  boss.hp = (115.0+floor_number*55.0+pow(float(floor_number),1.5)*8.0)*(1.2 if hard else 1.0)*(1.2 if run_risk else 1.0)
  boss.max_hp = boss.hp
  boss.radius = 42.0
  boss.cd = 2.2
  boss.phase = 0
  room.enemies.append(boss)
  item_banner = info.name
  item_detail = info.subtitle
  item_time = 3.0
  sound.play("boss_roar")
 elif room.type == "treasure":
  room.choice = true
  room.pickups.append(make_pickup("item",Vector2(425,435),roll_item()))
  room.pickups.append(make_pickup("item",Vector2(615,435),roll_item([room.pickups[0].id])))
 elif room.type == "shop":
  var offered: Array = []
  for i in range(3):
   var p = make_pickup("item",Vector2(320+i*200,420),roll_item(offered))
   offered.append(p.id)
   p.price = 3 if p.type == "heal" else 8 + Catalog.item(p.id).rarity * 4
   room.pickups.append(p)
  var heal = make_pickup("heal",Vector2(420,585))
  heal.price = 3
  room.pickups.append(heal)
  var bomb = make_pickup("bomb",Vector2(620,585))
  bomb.price = 3
  room.pickups.append(bomb)
 elif room.type == "transition":
  populate_route_choices()
  room.cleared = true
 elif room.type in ["lab","sacrifice","challenge","unstable"]:
  room.cleared = true
  room.pickups.append(make_pickup("event",CENTER,room.type))
 elif room.type == "rest":
  room.pickups.append(make_pickup("heal",Vector2(480,430)))
  room.pickups.append(make_pickup("heal",Vector2(560,430)))
 else:
  room.pickups.append(make_pickup("bomb",Vector2(520,535)))

func clear_spawn(p: Vector2, blocks: Array) -> bool:
 for b in blocks:
  if p.distance_to(b.pos) < 80:
   return false
 return true
func make_enemy(kind: int, pos: Vector2) -> Dictionary:
 var spec = Catalog.enemy(kind)
 var hp = spec.hp*(1.0+minf(floor_number-1,9)*0.14+maxf(0,floor_number-10)*0.12)*(1.2 if hard else 1.0)*(1.2 if run_risk else 1.0)
 return {"kind":kind,"pos":pos,"hp":hp,"max_hp":hp,"radius":spec.radius,
 "cd":rng.randf_range(0.6,1.9),"flash":0.0,"poison":0.0,"burn":0.0,"bleed":0.0,"slow":0.0,"touch_cd":0.0,
 "vel":Vector2.ZERO,"charge":0.0,"telegraph":0.0,"boss":-1,"phase":0,"dead":false,
 "reflect_cd":0.0,"headless":false,"head_hp":7.0,"blood_cd":0.3,"panic":5.0,"facing":"down","anim":rng.randf(),"state":"idle","shot_anim":0.0,"target":Vector2.ZERO}

func make_pickup(kind: String,pos: Vector2,id: String="") -> Dictionary:
 return {"type":"heal" if kind == "item" and id == "" else kind,"pos":pos,"id":id,"price":0}
func roll_item(exclude: Array = [],minimum_rarity: int=0) -> String:
 var pool = eligible_items(exclude,minimum_rarity)
 if pool.is_empty(): pool = eligible_items(exclude,0)
 if pool.is_empty(): return ""
 var weighted: Array = []
 for entry in pool:
  var weight = 5-entry.rarity*2+(1 if run_risk and entry.rarity == 2 else 0)
  for i in range(weight): weighted.append(entry.id)
 return str(weighted[rng.randi_range(0,weighted.size()-1)])

func eligible_items(exclude: Array = [],minimum_rarity: int=0) -> Array:
 return Catalog.pool(profile.data.unlocks).filter(func(i): return not i.id in exclude and i.rarity>=minimum_rarity and mutation_block_reason(i.id) == "")

func mutation_block_reason(id: String) -> String:
 if id == "": return "Keine weitere passende Mutation verfügbar."
 if id in inventory: return "Bereits im Genom: jede Mutation ist einmalig."
 for group in [["twin","triple"],["poison","burn","ice"],["explode","split"]]:
  if id in group:
   for owned in group:
    if owned in inventory: return "Unvereinbar mit "+Catalog.item(owned).name+". Tausche diese zuerst im Labor."
 if id in ["glass","blooddash"] and player.max_hp+float(Catalog.item(id).stat.get("max_hp",0))<2:
  return "Du brauchst mindestens 2 maximale LP nach der Mutation."
 return ""

func save_checkpoint() -> void:
 if test_mode:
  return
 room.enemies = foes.duplicate(true)
 room.pickups = pickups.duplicate(true)
 room.obstacles = obstacles.duplicate(true)
 profile.save_run({"version":4,"boss_order":boss_order,"milestone_claimed":milestone_claimed,"history":pickup_history,"seed":seed_value,"rng":rng.state,"rooms":rooms,"current":current,
 "floor":floor_number,"player":player,"inventory":inventory,"character":character,"hard":hard,
 "route":route,"risk":run_risk,"curse_speed":curse_speed,"hp_cost":run_hp_cost,"synergies":found_synergies,
 "run_time":run_time,"kills":kills_run,"clears":clears,"phoenix":phoenix_used,"attack_count":attack_count})
func continue_run() -> void:
 var state = profile.load_run()
 if state.is_empty():
  notify("Kein gültiger Versuch gespeichert.")
  return
 screen = "game"
 clear_ui()
 seed_value = state.seed
 rng.seed = seed_value
 rng.state = state.rng
 rooms = state.rooms
 current = state.current
 floor_number = state.floor
 boss_order = state.boss_order
 milestone_claimed = state.milestone_claimed
 pickup_history = state.get("history",[])
 item_time = 0
 pool_cd = 0
 route = state.route
 run_risk = state.risk
 curse_speed = state.curse_speed
 run_hp_cost = state.hp_cost
 found_synergies = state.synergies
 speech.reset()
 chatter_rng.seed = state.seed ^ 7281
 player = state.player
 inventory = state.inventory
 character = state.character
 hard = state.hard
 run_time = state.run_time
 kills_run = state.kills
 clears = state.clears
 phoenix_used = state.phoenix
 attack_count = state.attack_count
 shoot_cd = 0
 dash_cd = 0
 dash_time = 0
 invuln = 0
 bomb_cd = 0
 drone_cd = 0
 room = {} # Do not overwrite loaded room with a prior session.
 enter_room(current,player.pos)
 notify("Versuch fortgesetzt. Der letzte gespeicherte Raumzustand wurde geladen.")

func game_ui() -> void:
 clear_ui()
 button("II",Rect2(1190,22,58,38),pause_game,MUTED)
 if touch_enabled:
  button("SPRINT",Rect2(810,635,90,65),begin_dash)
  button("Q",Rect2(710,655,75,55),use_bomb,GOLD)
  button("E",Rect2(902,635,70,65),interact,PINK)
func pause_game() -> void:
 if screen != "game":
  return
 screen = "pause"
 save_checkpoint()
 clear_ui()
 button("WEITERSPIELEN",Rect2(450,340,380,56),resume_game)
 button("SPEICHERN & MENÜ",Rect2(450,415,380,52),menu)
 button("GENOM & FUNDPROTOKOLL",Rect2(450,490,380,52),func(): genome_menu(0),GOLD)
 button("VERSUCH AUFGEBEN",Rect2(450,555,380,52),func(): finish_run(false,"Der Versuch wurde abgebrochen."),PINK)
func resume_game() -> void:
 screen = "game"
 game_ui()

func _unhandled_input(event: InputEvent) -> void:
 if event.is_action_pressed("genome") and screen in ["game","genome"]:
  if screen == "game": genome_menu(0)
  else: resume_game()
  return
 if event.is_action_pressed("pause"):
  if screen == "intro":
   skip_intro()
   return
  if screen == "game": pause_game()
  elif screen in ["pause","genome"]: resume_game()
  elif screen != "menu": menu()
 if screen == "intro":
  if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"): intro_next()
  return
 if screen != "game":
  return
 if event is InputEventMouseMotion and event.relative.length() > 1:
  mouse_used = true
 if event is InputEventKey and event.pressed and event.physical_keycode in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]:
  mouse_used = false
 if event.is_action_pressed("dash"): begin_dash()
 if event.is_action_pressed("bomb"): use_bomb()
 if event.is_action_pressed("interact"): interact()
 if event is InputEventScreenTouch:
  touch_enabled = true
  if event.pressed:
   if event.position.x < 520 and touch_left == -1:
    touch_left = event.index
    touch_origin = event.position
   elif event.position.x < 990 and touch_right == -1:
    touch_right = event.index
    touch_aim_origin = event.position
  else:
   if event.index == touch_left:
    touch_left = -1
    touch_move = Vector2.ZERO
   if event.index == touch_right:
    touch_right = -1
    touch_aim = Vector2.ZERO
 if event is InputEventScreenDrag:
  if event.index == touch_left:
   touch_move = ((event.position-touch_origin)/58.0).limit_length(1)
  if event.index == touch_right:
   touch_aim = ((event.position-touch_aim_origin)/58.0).limit_length(1)

func move_input() -> Vector2:
 var vec = Input.get_vector("left","right","up","down")
 if not Input.get_connected_joypads().is_empty():
  var joy = Input.get_connected_joypads()[0]
  var stick = Vector2(Input.get_joy_axis(joy,JOY_AXIS_LEFT_X),Input.get_joy_axis(joy,JOY_AXIS_LEFT_Y))
  if stick.length() > 0.2: vec = stick.limit_length(1)
 if touch_move.length() > 0.1: vec = touch_move
 return vec
func aim_input() -> Vector2:
 var vec = Input.get_vector("fire_left","fire_right","fire_up","fire_down")
 if not Input.get_connected_joypads().is_empty():
  var joy = Input.get_connected_joypads()[0]
  var stick = Vector2(Input.get_joy_axis(joy,JOY_AXIS_RIGHT_X),Input.get_joy_axis(joy,JOY_AXIS_RIGHT_Y))
  if stick.length() > 0.25: vec = stick.normalized()
 if touch_aim.length() > 0.2: vec = touch_aim.normalized()
 if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and touch_left == -1 and touch_right == -1:
  vec = (get_global_mouse_position()-player.pos).normalized()
 return vec

func _process(delta: float) -> void:
 timer += delta
 toast_time = maxf(0,toast_time-delta)
 if screen == "game": item_time = maxf(0,item_time-delta)
 if not unlock_queue.is_empty() and toast_time <= 0:
  notify(unlock_queue.pop_front())
 if screen in ["game","intro"]: speech.step(delta)
 if screen == "intro":
  intro_time += delta
  if intro_index<intro_panels.size() and intro_time>=intro_panels[intro_index].duration: intro_next()
 elif screen == "game":
  if not speech.blocks_combat(): step(minf(delta,0.033))
 elif screen == "end":
  player_anim += delta
 queue_redraw()
func step(dt: float) -> void:
 run_time += dt
 chatter_cd -= dt
 if chatter_cd<=0:
  ambient_chatter()
  chatter_cd = chatter_rng.randf_range(18,28)
 shoot_cd -= dt
 dash_cd = maxf(0,dash_cd-dt)
 dash_time = maxf(0,dash_time-dt)
 invuln = maxf(0,invuln-dt)
 bomb_cd = maxf(0,bomb_cd-dt)
 transition_cd = maxf(0,transition_cd-dt)
 drone_cd -= dt
 orbit_damage_cd -= dt
 pool_cd = maxf(0,pool_cd-dt)
 shake = maxf(0,shake-dt*22)
 var movement = move_input()
 var slow_factor = 1.0
 for h in hazards:
  if h.type == "spore" and h.pos.distance_to(player.pos)<h.radius: slow_factor = 0.65
 var velocity = movement * player.speed * slow_factor
 if dash_time > 0:
  velocity = dash_vector * 710.0
 var old_pos = player.pos
 player.pos = move_body(player.pos,velocity*dt,14.0)
 update_player_animation(dt,player.pos-old_pos)
 if has_item("blooddash") and dash_time>0 and pool_cd<=0:
  hazards.append({"type":"friendly_pool","pos":player.pos,"timer":0.65,"radius":24.0,"age":0.0,"source":"blooddash"})
  pool_cd = 0.1
 var aim = aim_input()
 if aim.length() > 0.1 and shoot_cd <= 0:
  fire(aim.normalized())
  shoot_cd = 1.0/effective_rate()
 update_enemies(dt)
 update_shots(dt)
 update_hazards(dt)
 update_pickups(dt)
 if has_item("drone") and drone_cd <= 0 and not foes.is_empty():
  var target = nearest_enemy(player.pos)
  if target >= 0:
   add_shot(player.pos+Vector2(-28,-28), (foes[target].pos-player.pos).normalized(),true,player.damage*0.7,true)
  drone_cd = 0.7
 if has_item("orbit") and orbit_damage_cd <= 0:
  for i in range(2):
   var pos = player.pos+Vector2.from_angle(timer*3.0+i*PI)*55
   for enemy in foes:
    if not enemy.dead and enemy.pos.distance_to(pos)<enemy.radius+9:
     damage_enemy(enemy,player.damage*0.75)
     if has_synergy("storm_orbit"):
      var other = nearest_enemy(enemy.pos,enemy)
      if other>=0 and foes[other].pos.distance_to(enemy.pos)<180:
       damage_enemy(foes[other],player.damage*.45)
       effects.append({"type":"line","from":enemy.pos,"to":foes[other].pos,"ttl":.16,"color":CYAN})
  orbit_damage_cd = 0.23
 if has_item("dash") and dash_time > 0:
  for enemy in foes:
   if enemy.pos.distance_to(player.pos)<enemy.radius+20 and enemy.touch_cd<=0:
    damage_enemy(enemy,player.damage*2)
    enemy.touch_cd = 0.4
 clean_dead()
 if screen != "game": return
 if not room.cleared and foes.is_empty() and room.type in ["combat","boss","challenge"]:
  clear_room()
 update_particles(dt)
 if room.cleared or room.type not in ["combat","boss","challenge"]:
  check_doors()

func move_body(pos: Vector2,delta: Vector2,radius: float) -> Vector2:
 var next = pos + delta
 next.x = clampf(next.x,ARENA.position.x+radius,ARENA.end.x-radius)
 next.y = clampf(next.y,ARENA.position.y+radius,ARENA.end.y-radius)
 for block in obstacles:
  var diff = next-block.pos
  if diff.length()<radius+block.radius:
   if diff.length()<0.001: diff = Vector2.RIGHT
   next = block.pos+diff.normalized()*(radius+block.radius)
 return next
func begin_dash() -> void:
 if screen != "game" or dash_cd > 0 or speech.blocks_combat(): return
 dash_vector = move_input()
 if dash_vector.length()<0.1:
  dash_vector = aim_input()
 if dash_vector.length()<0.1: dash_vector = Vector2.RIGHT
 dash_vector = dash_vector.normalized()
 dash_time = 0.18
 dash_cd = 1.1 if has_item("dash") else 1.85
 invuln = maxf(invuln,0.22)
 burst_particles(player.pos,CYAN,12)
 if has_item("frostnova"):
  for e in foes:
   if e.pos.distance_to(player.pos)<130: e.slow = 3.0
 sound.play("dash")
func use_bomb() -> void:
 if screen != "game" or player.bombs<=0 or bomb_cd>0 or speech.blocks_combat(): return
 player.bombs -= 1
 bomb_cd = 0.5
 hazards.append({"type":"bomb","pos":player.pos,"timer":1.0,"radius":145.0 if has_item("bomb") else 90.0,"friendly":true,"age":0.0})
 sound.play("pickup")
func has_item(id: String) -> bool:
 return id in inventory
func fire(direction: Vector2) -> void:
 player_shoot_anim = 0.25
 effects.append({"type":"sprite","key":"muzzle","pos":player.pos+direction*24,"ttl":0.2,"age":0.0,"size":24.0})
 attack_count += 1
 var damage = shot_damage()*(0.65 if has_item("twin") else 0.50 if has_item("triple") else 1.0)
 var dirs: Array = [direction]
 if has_item("triple"):
  dirs = [direction.rotated(-0.24),direction,direction.rotated(0.24)]
 if has_item("rear"): dirs.append(-direction)
 if has_item("side"):
  dirs.append(direction.rotated(PI/2))
  dirs.append(direction.rotated(-PI/2))
 if has_item("nova") and attack_count % 6 == 0:
  var ring_size = 16 if has_synergy("needle_nova") else 8
  for n in range(ring_size): dirs.append(Vector2.from_angle(n*TAU/ring_size))
 var count = 2 if has_item("twin") else 1
 for dir in dirs:
  for i in range(count):
   var origin = player.pos + dir.orthogonal()*(float(i)*12-6 if count == 2 else 0)
   add_shot(origin,dir,true,damage)
 if has_item("burst") and attack_count % 4 == 0:
  for delay in [0.08,0.16]:
   hazards.append({"type":"burst","pos":player.pos,"dir":direction,"timer":delay,"damage":damage,"age":0.0})
 sound.play("shoot")
func shot_damage() -> float:
 var d = maxf(0.8,player.damage)
 if has_item("crown"): d += minf(4,inventory.size()*0.2)
 if has_item("rage") and player.hp <= player.max_hp*0.5: d *= 1.5
 return d
func add_shot(pos: Vector2,dir: Vector2,friendly: bool,damage: float,child: bool=false,speed: float=0) -> Dictionary:
 if friendly and shots.size()>=256: return {}
 if shots.size()>=384: return {}
 var critical = friendly and not child and rng.randf()<player.crit
 var enemy_speed = (240.0 if speed == 0 else speed)*curse_speed*(1.1 if run_risk else 1.0)*minf(1.4,1.0+maxf(0,floor_number-10)*0.025)
 var bullet = {"pos":pos,"vel":dir*(player.shot_speed if friendly else enemy_speed),
 "friendly":friendly,"damage":damage*(2.0 if critical else 1.0),"radius":(7.0 if has_item("giant") else 5.0) if friendly else 6.0,
 "ttl":player.range/maxf(100,player.shot_speed) if friendly else 5.0,"bounce":2 if friendly and has_item("bounce") else 0,
 "hit":[],"child":child,"crit":critical,"dead":false,"age":0.0,"art":"player_shot" if friendly else "enemy_shot","returning":false}
 shots.append(bullet)
 return bullet

func update_shots(dt: float) -> void:
 # Snapshot: on-hit splitter children are appended without mutating iteration.
 for bullet in shots.duplicate():
  if bullet.dead: continue
  bullet.age = bullet.get("age",0.0)+dt
  bullet.ttl -= dt
  if bullet.friendly and has_item("boomerang") and bullet.age>0.55:
   if not bullet.returning:
    bullet.returning = true
    bullet.ttl = maxf(bullet.ttl,0.85)
    bullet.hit.clear()
   bullet.vel = bullet.vel.lerp((player.pos-bullet.pos).normalized()*player.shot_speed,minf(1,dt*7))
   if bullet.pos.distance_to(player.pos)<15:
    bullet.dead = true
    continue
  if bullet.ttl <= 0:
   bullet.dead = true
   continue
  if bullet.friendly and has_item("homing") and not bullet.returning:
   var index = nearest_enemy(bullet.pos)
   if index>=0 and bullet.pos.distance_to(foes[index].pos)<300:
    var desired = (foes[index].pos-bullet.pos).normalized()*bullet.vel.length()
    bullet.vel = bullet.vel.lerp(desired,minf(1,dt*4)).normalized()*player.shot_speed
  bullet.pos += bullet.vel*dt
  if not ARENA.has_point(bullet.pos):
   if bullet.bounce>0:
    if bullet.pos.x<ARENA.position.x or bullet.pos.x>ARENA.end.x: bullet.vel.x *= -1
    if bullet.pos.y<ARENA.position.y or bullet.pos.y>ARENA.end.y: bullet.vel.y *= -1
    bullet.pos.x = clampf(bullet.pos.x,ARENA.position.x,ARENA.end.x)
    bullet.pos.y = clampf(bullet.pos.y,ARENA.position.y,ARENA.end.y)
    bullet.bounce -= 1
   else: bullet.dead = true
  for block in obstacles:
   if bullet.pos.distance_to(block.pos)<block.radius+bullet.radius:
    if bullet.friendly: block.hp -= bullet.damage
    bullet.dead = true
    burst_particles(bullet.pos,MUTED,4)
    break
  if bullet.dead: continue
  if bullet.friendly:
   for enemy in foes:
    if enemy.dead or enemy in bullet.hit: continue
    if bullet.pos.distance_to(enemy.pos)<enemy.radius+bullet.radius:
     bullet.hit.append(enemy)
     effects.append({"type":"sprite","key":"impact","pos":bullet.pos,"ttl":0.3,"age":0.0,"size":24.0})
     var impact_damage = bullet.damage
     if enemy.kind == 9 and enemy.vel.dot(bullet.vel)<0: impact_damage *= 0.25
     if has_item("execute") and enemy.hp<enemy.max_hp*0.25: impact_damage *= 1.5
     damage_enemy(enemy,impact_damage)
     if enemy.kind == 6 and not enemy.headless and bullet.pos.distance_to(enemy.pos+Vector2(0,-14))<15:
      enemy.head_hp -= bullet.damage
      if enemy.head_hp<=0 and not enemy.dead: decapitate(enemy)
     if has_item("heavy") and enemy.boss<0: enemy.pos = move_body(enemy.pos,bullet.vel.normalized()*20,enemy.radius)
     if has_item("bleed"): enemy.bleed = 4.0
     if has_item("poison"): enemy.poison = 3.0
     if has_item("burn"): enemy.burn = 2.0
     if has_item("ice"): enemy.slow = 2.0
     if not bullet.child:
      on_hit(bullet,enemy)
     if enemy.boss>=0 and Catalog.BOSSES[enemy.boss].kind == "mirror" and enemy.phase%2 == 0 and enemy.reflect_cd<=0:
      add_shot(enemy.pos,(player.pos-enemy.pos).normalized(),false,1,false,210)
      enemy.reflect_cd = 0.45
     if not has_item("pierce") and not (bullet.returning and has_synergy("return_hunt")):
      bullet.dead = true
      break
  else:
   if has_item("shield") and bullet.pos.distance_to(player.pos+Vector2.from_angle(timer*2)*42)<20:
    bullet.dead = true
    burst_particles(bullet.pos,CYAN,5)
   elif bullet.pos.distance_to(player.pos)<14+bullet.radius:
    hurt(1)
    bullet.dead = true
 shots = shots.filter(func(b): return not b.dead)
 var broken = obstacles.filter(func(b): return b.hp<=0)
 for block in broken:
  burst_particles(block.pos,MUTED,14)
  effects.append({"type":"prop","key":"rock_debris","pos":block.pos,"vel":Vector2(30,-25),"ttl":0.4,"age":0.0})
  if has_item("scavenger") or rng.randf()<0.25: pickups.append(make_pickup("coin",block.pos))
 obstacles = obstacles.filter(func(b): return b.hp>0)

func on_hit(bullet: Dictionary,enemy: Dictionary) -> void:
 if has_item("explode"):
  explosion(bullet.pos,65,bullet.damage*0.45,false)
  if has_synergy("toxic_boom"):
   hazards.append({"type":"toxic_pool","pos":bullet.pos,"timer":2.5,"radius":65.0,"age":0.0})
 if has_synergy("shatter") and enemy.slow>0:
  explosion(enemy.pos,58,bullet.damage*0.65,false)
 if has_item("chain"):
  var index = nearest_enemy(enemy.pos,enemy)
  if index>=0 and enemy.pos.distance_to(foes[index].pos)<180:
   effects.append({"type":"line","from":enemy.pos,"to":foes[index].pos,"ttl":0.16,"color":CYAN})
   damage_enemy(foes[index],bullet.damage*0.55)
 if has_item("split"):
  for a in [-0.8,0.0,0.8]:
   add_shot(bullet.pos+bullet.vel.normalized()*20,bullet.vel.normalized().rotated(a),true,bullet.damage*0.4,true)
 if has_item("acid") and bullet.crit:
  hazards.append({"type":"friendly_pool","pos":bullet.pos,"timer":2.0,"radius":40.0,"age":0.0})
 if has_item("void") and bullet.crit:
  hazards.append({"type":"void","pos":bullet.pos,"timer":1.5,"radius":95.0,"age":0.0})
func nearest_enemy(pos: Vector2,exclude: Dictionary={}) -> int:
 var best = -1
 var distance = INF
 for i in range(foes.size()):
  if foes[i].dead or (not exclude.is_empty() and foes[i] == exclude): continue
  var d = foes[i].pos.distance_squared_to(pos)
  if d<distance:
   best = i
   distance = d
 return best
func damage_enemy(enemy: Dictionary,damage: float) -> void:
 if enemy.dead: return
 enemy.hp -= damage
 enemy.flash = 0.09
 burst_particles(enemy.pos,PINK if enemy.boss>=0 else CYAN,3)
 if enemy.hp<=0: enemy.dead = true
func hurt(amount: float) -> void:
 if invuln>0 or screen != "game": return
 if barrier_charge:
  barrier_charge = false
  invuln = 0.4
  burst_particles(player.pos,CYAN,14)
  return
 if rng.randf()<player.armor:
  invuln = 0.4
  burst_particles(player.pos,GOLD,12)
  return
 player.hp -= amount
 hit_this_boss = true
 if room.type == "boss": room.boss_hit = true
 invuln = 1.0
 shake = 8
 sound.play("hurt")
 speak_player(speech.choice(speech.data.get("low_hp" if player.hp<=2 else "hurt",[]),chatter_rng),"hurt")
 if has_item("thorns"): explosion(player.pos,120,8,false)
 if player.hp<=0:
  if has_item("phoenix") and not phoenix_used:
   phoenix_used = true
   player.hp = minf(3,player.max_hp)
   invuln = 3.0
   explosion(player.pos,250,40,false)
   notify("PHÖNIXKERN · Eine zweite Chance.")
  else:
   finish_run(false,"Die Probe ist instabil geworden.")

func update_enemies(dt: float) -> void:
 for enemy in foes.duplicate():
  if enemy.dead: continue
  var before = enemy.pos
  enemy.anim += dt
  enemy.shot_anim = maxf(0,enemy.shot_anim-dt)
  enemy.cd -= dt
  enemy.reflect_cd = maxf(0,enemy.reflect_cd-dt)
  enemy.flash = maxf(0,enemy.flash-dt)
  enemy.touch_cd = maxf(0,enemy.touch_cd-dt)
  for status in ["poison","burn","slow","bleed"]:
   enemy[status] = maxf(0,enemy[status]-dt)
  if enemy.poison>0: damage_enemy(enemy,2*dt)
  if enemy.burn>0: damage_enemy(enemy,3*dt)
  if enemy.bleed>0: damage_enemy(enemy,1.5*dt)
  if enemy.dead: continue
  var dir = (player.pos-enemy.pos).normalized()
  var speed = (0.55 if enemy.slow>0 else 1.0) * (1.15 if hard else 1.0)
  if enemy.boss>=0:
   update_boss(enemy,dt,dir,speed)
  else:
   match enemy.kind:
    0: enemy.pos = move_body(enemy.pos,dir*80*speed*dt,enemy.radius)
    1:
     var dist = enemy.pos.distance_to(player.pos)
     enemy.pos = move_body(enemy.pos,dir*(55 if dist>260 else -35 if dist<170 else 0)*speed*dt,enemy.radius)
     if enemy.cd<=0:
      add_shot(enemy.pos,dir,false,1)
      enemy.cd = 1.8
    2:
     if enemy.charge>0:
      enemy.charge -= dt
      enemy.pos = move_body(enemy.pos,enemy.vel*speed*dt,enemy.radius)
     elif enemy.telegraph>0:
      enemy.telegraph -= dt
      if enemy.telegraph<=0:
       enemy.charge = 0.7
       enemy.vel = (enemy.target-enemy.pos).normalized()*310
     elif enemy.cd<=0:
      enemy.target = player.pos
      enemy.telegraph = 0.65
      enemy.cd = 2.6
     else:
      enemy.pos = move_body(enemy.pos,dir*32*speed*dt,enemy.radius)
    3:
     if enemy.cd<=0:
      for i in range(8): add_shot(enemy.pos,Vector2.from_angle(i*TAU/8+timer*0.2),false,1,false,190)
      enemy.cd = 2.8
     enemy.pos = move_body(enemy.pos,dir*20*speed*dt,enemy.radius)
    4:
     enemy.pos = move_body(enemy.pos,dir*135*speed*dt,enemy.radius)
    6:
     if enemy.headless:
      enemy.panic -= dt
      enemy.blood_cd -= dt
      if enemy.cd<=0:
       enemy.vel = Vector2.from_angle(rng.randf()*TAU)*190
       enemy.cd = 0.5
      enemy.pos = move_body(enemy.pos,enemy.vel*speed*dt,enemy.radius)
      if enemy.blood_cd<=0:
       blood_spray(enemy)
       enemy.blood_cd = 0.32
      if enemy.panic<=0: damage_enemy(enemy,999)
     else:
      enemy.pos = move_body(enemy.pos,dir*55*speed*dt,enemy.radius)
      if enemy.cd<=0:
       fan_attack(enemy,dir,3,0.15,200)
       enemy.cd = 2.2
    7:
     enemy.pos = move_body(enemy.pos,dir*45*speed*dt,enemy.radius)
    8:
     if enemy.telegraph>0:
      enemy.telegraph -= dt
      if enemy.telegraph<=0:
       effects.append({"type":"sprite","key":"teleport","pos":enemy.pos,"ttl":0.6,"age":0.0,"size":64.0})
       enemy.pos = enemy.target
       fan_attack(enemy,dir,3,0.22,220)
       sound.play("teleport")
     elif enemy.cd<=0:
      enemy.target = move_body(player.pos+Vector2.from_angle(rng.randf()*TAU)*180,Vector2.ZERO,enemy.radius)
      enemy.telegraph = 0.7
      enemy.cd = 3.0
    9:
     enemy.vel = dir
     enemy.pos = move_body(enemy.pos,dir*50*speed*dt,enemy.radius)
     if enemy.cd<=0:
      add_shot(enemy.pos,dir,false,1)
      enemy.cd = 2.8
    10:
     enemy.pos = move_body(enemy.pos,dir*115*speed*dt,enemy.radius)
    11:
     enemy.pos = move_body(enemy.pos,dir*30*speed*dt,enemy.radius)
     if enemy.cd<=0:
      hazards.append({"type":"spore","pos":enemy.pos,"timer":4.0,"radius":42.0,"age":0.0})
      enemy.cd = 2.5
    12:
     if enemy.telegraph>0:
      enemy.telegraph -= dt
      if enemy.telegraph<=0:
       add_shot(enemy.pos,(enemy.target-enemy.pos).normalized(),false,1,false,400)
       enemy.shot_anim = 0.25
     elif enemy.cd<=0:
      enemy.target = player.pos
      enemy.telegraph = 0.85
      enemy.cd = 2.8
    13:
     # Medic: visible tether, limited healing that cannot revive or heal bosses.
     enemy.pos = move_body(enemy.pos,-dir*28*speed*dt,enemy.radius)
     if enemy.cd<=0:
      var target = -1
      var distance = 240.0
      for n in range(foes.size()):
       var ally = foes[n]
       if ally != enemy and not ally.dead and ally.boss<0 and ally.hp<ally.max_hp and enemy.pos.distance_to(ally.pos)<distance:
        target = n
        distance = enemy.pos.distance_to(ally.pos)
      if target>=0:
       foes[target].hp = minf(foes[target].max_hp,foes[target].hp+3)
       effects.append({"type":"line","from":enemy.pos,"to":foes[target].pos,"ttl":0.35,"color":CYAN})
      enemy.cd = 2.4
    14:
     # Telegraph a fixed target, allowing the player to leave the landing zone.
     if enemy.telegraph>0:
      enemy.telegraph -= dt
      if enemy.telegraph<=0:
       hazards.append({"type":"warning","pos":enemy.target,"timer":0.9,"radius":42.0,"age":0.0})
     elif enemy.cd<=0:
      enemy.target = player.pos
      enemy.telegraph = 0.7
      enemy.cd = 3.4
    15:
     # Flanker circles the player instead of tracking directly.
     enemy.pos = move_body(enemy.pos,(dir*35+dir.orthogonal()*95)*speed*dt,enemy.radius)
     if enemy.cd<=0:
      fan_attack(enemy,dir,2,0.35,180)
      enemy.cd = 2.2
    16:
     # Exploder locks its charge direction during the warning.
     if enemy.charge>0:
      enemy.charge -= dt
      enemy.pos = move_body(enemy.pos,enemy.vel*speed*dt,enemy.radius)
      if enemy.charge<=0:
       hazards.append({"type":"warning","pos":enemy.pos,"timer":0.7,"radius":60.0,"age":0.0})
       enemy.dead = true
     elif enemy.telegraph>0:
      enemy.telegraph -= dt
      if enemy.telegraph<=0: enemy.charge = 0.65
     elif enemy.cd<=0:
      enemy.vel = dir*260
      enemy.target = player.pos
      enemy.telegraph = 0.9
      enemy.cd = 4.0
     else: enemy.pos = move_body(enemy.pos,dir*45*speed*dt,enemy.radius)
  var moved = enemy.pos-before
  if moved.length()>0.1: enemy.facing = Art.facing(moved)
  var prior_state = enemy.state
  enemy.state = "hurt" if enemy.flash>0 else "dash" if enemy.charge>0 else "shoot" if enemy.shot_anim>0 or enemy.telegraph>0 else "walk" if moved.length()>0.1 else "idle"
  if prior_state != enemy.state: enemy.anim = 0
  if enemy.pos.distance_to(player.pos)<enemy.radius+13:
   var vulnerable = invuln<=0
   hurt(1)
   if enemy.kind == 10 and vulnerable: player.coins = maxi(0,player.coins-1)
 # Separate enemies gently, preserving readable silhouettes.
 for i in range(foes.size()):
  for j in range(i+1,foes.size()):
   var diff = foes[i].pos-foes[j].pos
   var minimum = foes[i].radius+foes[j].radius
   if diff.length()>0.1 and diff.length()<minimum:
    var offset = diff.normalized()*dt*35
    foes[i].pos = move_body(foes[i].pos,offset,foes[i].radius)
    foes[j].pos = move_body(foes[j].pos,-offset,foes[j].radius)

func update_boss(enemy: Dictionary,dt: float,dir: Vector2,speed: float) -> void:
 var kind = Catalog.BOSSES[enemy.boss].kind
 var enraged = enemy.hp<enemy.max_hp*0.5
 var multiplier = 0.82 if enraged else 1.0
 if enemy.charge>0:
  enemy.charge -= dt
  enemy.pos = move_body(enemy.pos,enemy.vel*dt,enemy.radius)
 elif enemy.telegraph>0:
  enemy.telegraph -= dt
  if enemy.telegraph<=0:
   enemy.vel = (enemy.target-enemy.pos).normalized()*390
   enemy.charge = 0.6
 else:
  enemy.pos = move_body(enemy.pos,dir*(42 if kind != "synapse" else 22)*speed*dt,enemy.radius)
 if enemy.cd>0: return
 enemy.target = player.pos
 enemy.phase += 1
 match kind:
  "brood":
   if enemy.phase%2 == 0 and foes.size()<10:
    for i in range(2): foes.append(make_enemy(4,enemy.pos+Vector2(60 if i == 0 else -60,30)))
   else: ring_attack(enemy,10 if enraged else 8,210)
   enemy.cd = 2.1*multiplier
  "chitin":
   if enemy.phase%2 == 1: enemy.telegraph = 0.85
   else: fan_attack(enemy,dir,5,0.24,240)
   enemy.cd = 2.2*multiplier
  "synapse":
   for i in range(3):
    hazards.append({"type":"warning","pos":player.pos+Vector2.from_angle(i*TAU/3)*80,
    "timer":1.0,"radius":38.0,"age":0.0})
   ring_attack(enemy,12,190)
   enemy.cd = 2.3*multiplier
  "furnace":
   fan_attack(enemy,dir,7,0.18,230)
   hazards.append({"type":"fire","pos":enemy.pos,"timer":3.5,"radius":38.0,"age":0.0})
   if enraged: enemy.telegraph = 0.8
   enemy.cd = 1.9*multiplier
  "marrow":
   ring_attack(enemy,14,200)
   if enemy.phase%2 == 0: fan_attack(enemy,dir,3,0.3,300)
   enemy.cd = 2.2*multiplier
  "bog":
   for i in range(3):
    hazards.append({"type":"warning","pos":player.pos+Vector2.from_angle(i*TAU/3)*100,"timer":1.2,"radius":45.0,"age":0.0})
   if foes.size()<9: foes.append(make_enemy(11,enemy.pos+Vector2(70,0)))
   enemy.cd = 2.6*multiplier
  "executioner":
   for i in range(8):
    var blood = add_shot(enemy.pos,Vector2.from_angle(i*TAU/8+enemy.phase*.3),false,1,false,220)
    if not blood.is_empty(): blood.art = "blood_shot"
   if enemy.phase%3 == 0 and foes.size()<8:
    var runner = make_enemy(6,enemy.pos+Vector2(60,0))
    foes.append(runner)
    decapitate(runner,false)
   enemy.cd = 2.0*multiplier
  "architect":
   if enemy.phase%2 == 0 and obstacles.size()<8:
    for offset in [Vector2(-120,100),Vector2(120,100)]:
     var pos = enemy.pos+offset
     if ARENA.grow(-65).has_point(pos) and pos.distance_to(player.pos)>75:
      obstacles.append({"pos":pos,"radius":26.0,"hp":14.0})
   fan_attack(enemy,dir,5,0.17,290)
   if enemy.phase%3 == 0 and foes.size()<8: foes.append(make_enemy(12,enemy.pos+Vector2(-70,0)))
   enemy.cd = 2.5*multiplier
  "mirror":
   for i in range(12): add_shot(enemy.pos,Vector2.from_angle(i*TAU/12+enemy.phase*.7),false,1,false,230)
   if enemy.phase%3 == 0 and foes.size()<9: foes.append(make_enemy(8,enemy.pos+Vector2(75,0)))
   enemy.cd = 1.7*multiplier
  "omega":
   match enemy.phase%3:
    0:
     ring_attack(enemy,16,220)
     if enraged and foes.size()<8: foes.append(make_enemy(1,enemy.pos+Vector2(80,0)))
    1:
     enemy.telegraph = 0.8
     for i in range(3):
      hazards.append({"type":"warning","pos":player.pos+Vector2(i*85-85,0),"timer":1.1,"radius":34.0,"age":0.0})
    2:
     fan_attack(enemy,dir,7,0.20,270)
     ring_attack(enemy,8,170)
   enemy.cd = 2.0*multiplier
func ring_attack(enemy: Dictionary,count: int,speed: float) -> void:
 enemy.shot_anim = 0.25
 sound.play("enemy_shoot")
 for i in range(count):
  add_shot(enemy.pos,Vector2.from_angle(i*TAU/count+enemy.phase*0.25),false,1,false,speed)
func fan_attack(enemy: Dictionary,dir: Vector2,count: int,spread: float,speed: float) -> void:
 enemy.shot_anim = 0.25
 sound.play("enemy_shoot")
 for i in range(count):
  add_shot(enemy.pos,dir.rotated((i-(count-1)/2.0)*spread),false,1,false,speed)

func clean_dead() -> void:
 var hatchlings: Array = []
 var boss_died = foes.any(func(e): return e.dead and e.boss>=0)
 for enemy in foes:
  if not enemy.dead: continue
  corpses.append({"key":enemy_art_key(enemy),"pos":enemy.pos,"facing":enemy.facing,"age":0.0,"ttl":0.6,"size":96.0 if enemy.boss>=0 else 48.0})
  if enemy.kind == 7 and not boss_died:
   for side in [-1,1]: hatchlings.append(make_enemy(4,enemy.pos+Vector2(side*24,0)))
  kills_run += 1
  profile.data.kills += 1
  if profile.data.kills>=100: unlock("kills_100")
  burst_particles(enemy.pos,PINK if enemy.boss>=0 else CYAN,20)
  sound.play("hit")
  if has_item("vampire") and kills_run%8 == 0: player.hp = minf(player.max_hp,player.hp+1)
  if enemy.boss>=0:
   speak_boss(enemy.boss,false)
   sound.play("boss_defeat")
   profile.data.bosses += 1
   unlock("first_boss")
   if not hit_this_boss: unlock("no_hit")
   shots = shots.filter(func(s): return s.friendly)
   hazards.clear()
   # Boss minions die with their source, so a finished boss always opens exits.
   for other in foes:
    if other.boss<0: other.dead = true
  else:
   if has_synergy("blood_pact"):
    for pool in hazards:
     if pool.get("source","") == "blooddash" and pool.pos.distance_to(enemy.pos)<pool.radius+enemy.radius:
      if rng.randf()<.2: player.hp = minf(player.max_hp,player.hp+1)
      break
   if has_item("soul") and rng.randf()<0.08: pickups.append(make_pickup("heal",enemy.pos))
   if rng.randf()<0.28+(0.25 if has_item("gold") else 0): pickups.append(make_pickup("coin",enemy.pos))
 foes = foes.filter(func(e): return not e.dead)
 foes.append_array(hatchlings)
func clear_room() -> void:
 room.cleared = true
 clears += 1
 if has_item("heal") and clears%3 == 0: player.hp = minf(player.max_hp,player.hp+1)
 if room.type == "boss":
  pickups.append(make_pickup("item",Vector2(520,440),roll_item()))
  notify("Boss besiegt. Nimm die Mutation und gehe durch die Tür zur Übergangskammer.")
 elif room.type == "challenge":
  pickups.append(make_pickup("item",CENTER,roll_item([],1)))
  notify("Probe geklärt. Deine Belohnung wartet.")
 else:
  pickups.append(make_pickup("coin",CENTER))
  if run_risk: pickups.append(make_pickup("coin",CENTER+Vector2(-30,25)))
  if rng.randf()<0.35+(0.15 if has_item("luck") else 0)+(0.15 if current_biome().id == "marsh" else 0):
   var heal_chance = 0.5 if current_biome().id == "reactor" else 0.8 if current_biome().id == "marsh" else 0.7
   pickups.append(make_pickup("heal" if rng.randf()<heal_chance else "bomb",CENTER+Vector2(40,0)))
  if rng.randf()<0.10+(0.07 if has_item("luck") else 0):
   pickups.append(make_pickup("item",CENTER-Vector2(60,0),roll_item()))
 profile.save_profile()
 save_checkpoint()
 sound.play("unlock")

func update_hazards(dt: float) -> void:
 var additions: Array = []
 for h in hazards:
  h.timer -= dt
  h.age += dt
  match h.type:
   "bomb":
    if h.timer<=0:
     explosion(h.pos,h.radius,40,true)
   "warning":
    if h.timer<=0:
     additions.append({"type":"fire","pos":h.pos,"timer":0.7,"radius":h.radius,"age":0.0})
     burst_particles(h.pos,PINK,16)
   "fire", "spore":
    if h.pos.distance_to(player.pos)<h.radius+10: hurt(1)
   "toxic_pool":
    pass
   "friendly_pool":
    pass
   "bloodtrail":
    pass
   "burst":
    if h.timer<=0: add_shot(h.pos,h.dir,true,h.damage)
   "void":
    pass
 # Overlapping blood/acid pools deal damage once per enemy, not once per pool.
 for e in foes:
  if hazards.any(func(h): return h.type == "friendly_pool" and h.timer>0 and e.pos.distance_to(h.pos)<h.radius+e.radius): damage_enemy(e,5*dt)
  if hazards.any(func(h): return h.type == "toxic_pool" and h.timer>0 and e.pos.distance_to(h.pos)<h.radius+e.radius):
   e.poison = maxf(e.poison,2)
   damage_enemy(e,3*dt)
  var void_zones = hazards.filter(func(h): return h.type == "void" and h.timer>0 and e.pos.distance_to(h.pos)<h.radius)
  if not void_zones.is_empty():
   e.pos = move_body(e.pos,(void_zones[0].pos-e.pos).normalized()*dt*85,e.radius)
   damage_enemy(e,4*dt)
 hazards = hazards.filter(func(h): return h.timer>0)
 hazards.append_array(additions)
func explosion(pos: Vector2,radius: float,damage: float,break_rocks: bool) -> void:
 effects.append({"type":"ring","pos":pos,"radius":radius,"ttl":0.25,"color":GOLD})
 effects.append({"type":"sprite","key":"explosion","pos":pos,"ttl":0.66,"age":0.0,"size":radius*2})
 for e in foes:
  if e.pos.distance_to(pos)<radius+e.radius: damage_enemy(e,damage)
 if break_rocks:
  for b in obstacles:
   if b.pos.distance_to(pos)<radius+b.radius: b.hp = 0
  shots = shots.filter(func(s): return s.friendly or s.pos.distance_to(pos)>radius)
  shake = 6
  sound.play("boom")
 burst_particles(pos,GOLD,15)

func update_pickups(dt: float) -> void:
 near_pickup = -1
 var best = 80.0
 var remove: Array = []
 for i in range(pickups.size()):
  var pickup = pickups[i]
  var dist = pickup.pos.distance_to(player.pos)
  if pickup.price == 0 and pickup.type in ["coin","heal","bomb"]:
   if has_item("magnet") and dist<200:
    pickup.pos = pickup.pos.move_toward(player.pos,dt*220)
   if dist<24:
    if pickup.type == "heal" and player.hp>=player.max_hp: continue
    consume_pickup(pickup)
    remove.append(pickup)
  elif dist<best:
   best = dist
   near_pickup = i
 for pickup in remove: pickups.erase(pickup)
func interact() -> void:
 if screen != "game": return
 if speech.blocks_combat():
  speech.advance()
  return
 # Compute proximity now: touch/click may happen before the next frame.
 var target = -1
 var best = 80.0
 for i in range(pickups.size()):
  var dist = pickups[i].pos.distance_to(player.pos)
  if dist<best:
   best = dist
   target = i
 if target<0: return
 var pickup = pickups[target]
 if pickup.type == "event":
  interact_event(pickup)
  return
 if pickup.type == "finish":
  claim_milestone()
  finish_run(true,"%d Bosse besiegt. Die Probe wurde sicher evakuiert." % floor_number)
  return
 if pickup.type == "portal":
  if floor_number>=5: claim_milestone()
  route.append(pickup.destination)
  run_risk = pickup.get("risk",false)
  floor_number += 1
  room = {}
  player.hp = minf(player.max_hp,player.hp+1)
  generate_floor()
  return
 if pickup.type == "item":
  var blocked = mutation_block_reason(pickup.id)
  if blocked != "":
   notify(blocked)
   return
 var cost = price_of(pickup)
 if player.coins<cost:
  notify("Nicht genug Münzen: Du brauchst %d." % cost)
  return
 if pickup.type == "heal" and player.hp>=player.max_hp:
  notify("Deine LP sind bereits voll.")
  return
 player.coins -= cost
 consume_pickup(pickup)
 pickups.erase(pickup)
 if room.choice:
  pickups = pickups.filter(func(p): return p.type != "item")
  room.choice = false
 save_checkpoint()
func price_of(pickup: Dictionary) -> int:
 return maxi(1,int(ceil(pickup.price*0.65))) if pickup.price>0 and has_item("discount") else pickup.price
func consume_pickup(pickup: Dictionary) -> void:
 match pickup.type:
  "coin":
   player.coins += 1
   sound.play("coin")
  "heal": player.hp = minf(player.max_hp,player.hp+1)
  "bomb": player.bombs += 1
  "item": take_item(pickup.id)
 burst_particles(pickup.pos,GOLD,12)
 sound.play("pickup")
func take_item(id: String) -> void:
 var blocked = mutation_block_reason(id)
 if blocked != "":
  notify(blocked)
  return
 var item = Catalog.item(id)
 inventory.append(id)
 var old_hp = player.hp
 recalculate_stats()
 var healing = maxf(0,float(item.stat.get("max_hp",0)))
 player.hp = clampf(old_hp+healing,0,player.max_hp)
 if id == "bomb": player.bombs += 3
 if not id in profile.data.seen: profile.data.seen.append(id)
 if inventory.size()>=10: unlock("items_10")
 profile.save_profile()
 item_banner = item.name.to_upper()
 item_detail = item.desc
 item_time = 7.0
 pickup_history.push_front({"id":id,"name":item.name,"desc":item.desc})
 if pickup_history.size()>64: pickup_history.resize(64)
 var lines = speech.data.get("item_lines",{}).get(id,speech.data.get("generic_item",[]))
 speak_player(speech.choice(lines,chatter_rng).replace("{item}",item.name),"happy",true)
 check_synergies()
 sound.play("pickup")
func check_doors() -> void:
 if transition_cd>0: return
 var p = player.pos
 var direction = Vector2i.ZERO
 var spawn = CENTER
 if p.x<80 and absf(p.y-CENTER.y)<52:
  direction = Vector2i.LEFT; spawn = Vector2(940,CENTER.y)
 elif p.x>960 and absf(p.y-CENTER.y)<52:
  direction = Vector2i.RIGHT; spawn = Vector2(100,CENTER.y)
 elif p.y<168 and absf(p.x-CENTER.x)<52:
  direction = Vector2i.UP; spawn = Vector2(CENTER.x,690)
 elif p.y>712 and absf(p.x-CENTER.x)<52:
  direction = Vector2i.DOWN; spawn = Vector2(CENTER.x,190)
 if direction != Vector2i.ZERO and Dungeon.connected(rooms,current,current+direction):
  enter_room(current+direction,spawn)

func unlock(id: String) -> void:
 if profile.unlock(id):
  for entry in Catalog.UNLOCKS:
   if entry.id == id: unlock_queue.append("FREIGESCHALTET · %s · %s" % [entry.name,entry.reward])
  sound.play("unlock")
func notify(message: String) -> void:
 toast = message
 toast_time = 5.0
func finish_run(won: bool,reason: String) -> void:
 sound.play("win" if won else "death")
 screen = "end"
 end_won = won
 player_anim = 0
 end_title = "VERSUCH ABGESCHLOSSEN" if won else "PROBE VERLOREN"
 end_reason = reason
 profile.clear_run()
 profile.save_profile()
 clear_ui()
 button("NEUER VERSUCH",Rect2(360,570,270,55),start_run)
 button("ZUM MENÜ",Rect2(650,570,270,55),menu)

func burst_particles(pos: Vector2,color: Color,count: int) -> void:
 for i in range(count):
  if particles.size()>450: break
  particles.append({"pos":pos,"vel":Vector2.from_angle(rng.randf()*TAU)*rng.randf_range(35,170),"ttl":rng.randf_range(0.2,0.6),"color":color})
func update_particles(dt: float) -> void:
 for p in particles:
  p.pos += p.vel*dt
  p.vel *= 1-dt*3
  p.ttl -= dt
 particles = particles.filter(func(p): return p.ttl>0)
 for e in effects:
  e.ttl -= dt
  if e.has("age"): e.age += dt
  if e.has("vel"): e.pos += e.vel*dt
 for c in corpses:
  c.ttl -= dt
  c.age += dt
 corpses = corpses.filter(func(c): return c.ttl>0)
 effects = effects.filter(func(e): return e.ttl>0)

# All artwork is drawn at runtime: an original laboratory aesthetic, fully scalable.
func _draw() -> void:
 draw_rect(Rect2(0,0,1280,800),INK)
 for x in range(0,1280,40): draw_line(Vector2(x,0),Vector2(x,800),Color(0.16,0.21,0.3,0.20))
 for y in range(0,800,40): draw_line(Vector2(0,y),Vector2(1280,y),Color(0.16,0.21,0.3,0.20))
 if screen in ["game","pause","genome","end"] and not player.is_empty():
  draw_game()
 else:
  match screen:
   "menu": draw_menu()
   "archive": draw_archive()
   "unlocks": draw_unlocks()
   "options": draw_options()
   "intro": draw_intro()
 if screen == "pause":
  draw_rect(Rect2(0,0,1280,800),Color(0.025,0.04,0.07,0.88))
  text_at("VERSUCH PAUSIERT",Vector2(448,255),32,WHITE)
  text_at("Der aktuelle Raum wurde gespeichert.",Vector2(450,292),17,MUTED)
 if screen == "end": draw_end()
 if screen == "genome": draw_genome()
 if screen == "game": draw_dialogue(Rect2(60,748,932,50))
 if toast_time>0 and screen != "genome" and (screen != "game" or speech.active.is_empty()):
  draw_rect(Rect2(60,752,1160,35),Color("243345"))
  text_at(toast,Vector2(78,776),16,GOLD)

func text_at(text: String,pos: Vector2,size: int=18,color: Color=WHITE) -> void:
 draw_string(font,pos,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func centered(text: String,pos: Vector2,size: int,color: Color) -> void:
 text_at(text,pos-Vector2(font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x/2,0),size,color)
func panel(rect: Rect2,color: Color=Color("172132")) -> void:
 draw_style_box(panel_style(color),rect)
func panel_style(color: Color) -> StyleBoxFlat:
 var style = StyleBoxFlat.new()
 style.bg_color = color
 style.border_color = Color("2d3c52")
 style.set_border_width_all(1)
 style.set_corner_radius_all(10)
 return style
func wrapped(text: String,pos: Vector2,width: float,size: int,color: Color,line_height: float=24) -> void:
 var line = ""
 var y = pos.y
 for word in text.split(" "):
  var candidate = word if line == "" else line+" "+word
  if font.get_string_size(candidate,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>width and line != "":
   text_at(line,Vector2(pos.x,y),size,color)
   y += line_height
   line = word
  else: line = candidate
 if line != "": text_at(line,Vector2(pos.x,y),size,color)

func draw_menu() -> void:
 text_at("LABOR 07  /  VERSUCHSREIHE",Vector2(80,100),18,CYAN)
 text_at("MUTATION",Vector2(72,220),86,WHITE)
 text_at("/ NULL",Vector2(74,316),86,CYAN)
 text_at("Ein Raum. Eine Entscheidung. Ein neues Genom.",Vector2(80,370),20,MUTED)
 text_at("5 GEBIETE   /   64 MUTATIONEN   /   10 BOSSE",Vector2(80,405),15,GOLD)
 panel(Rect2(690,110,436,615))
 text_at("WÄHLE DEINE PROBE",Vector2(720,152),18,MUTED)
 var c = Catalog.CHARACTERS[character]
 var locked = c.unlock != "" and not c.unlock in profile.data.unlocks
 var pos = Vector2(910,320)
 draw_circle(pos,110,Color(0.45,0.95,0.8,0.035))
 draw_arc(pos,114,0,TAU,64,CYAN.darkened(0.7),1,true)
 draw_arc(pos,128,timer*0.1,timer*0.1+PI*1.3,64,CYAN.darkened(0.5),2,true)
 draw_sprite("character/"+c.id,pos,Vector2(150,150),"walk","down",timer)
 centered(c.name,Vector2(908,451),38,WHITE)
 centered("GESPERRT" if locked else c.tag,Vector2(908,485),19,PINK if locked else CYAN)
 centered(c.desc,Vector2(908,514),15,MUTED)
 centered("%d / %d" % [character+1,Catalog.CHARACTERS.size()],Vector2(908,564),18,MUTED)
 text_at("Gesamt: %d Versuche · %d Siege · %d Kills" % [profile.data.runs,profile.data.wins,profile.data.kills],Vector2(80,725),16,MUTED)
 text_at("WASD + Pfeile / Maus · Controller · Berührung",Vector2(80,761),15,MUTED)

func draw_options() -> void:
 text_at("OPTIONEN",Vector2(380,170),44,WHITE)
 text_at("Audio: %d%%" % int(float(profile.data.volume)*100),Vector2(380,255),20,CYAN)
 text_at("Bildschirmwackeln: "+("AN" if profile.data.shake else "AUS"),Vector2(380,370),16,MUTED)
 text_at("Berührungssteuerung: "+("AN" if touch_enabled else "AUS"),Vector2(380,450),16,MUTED)
 text_at("Musik separat schaltbar; Soundeffekte bleiben hörbar.",Vector2(380,625),14,MUTED)

func draw_archive() -> void:
 text_at("MUTATIONSARCHIV",Vector2(80,90),40,WHITE)
 text_at("64 Gene. Alle Effekte kombinieren sich. Schatzkammern bieten eine Wahl.",Vector2(80,127),18,MUTED)
 for n in range(8):
  var index = page*8+n
  if index>=Catalog.ITEMS.size(): break
  var item = Catalog.ITEMS[index]
  var col = n%2
  var row = n/2
  var origin = Vector2(80+col*580,164+int(row)*130)
  panel(Rect2(origin,Vector2(550,112)))
  var color = [CYAN,PINK,GOLD][item.rarity]
  draw_item_icon(item.id,origin+Vector2(42,46),22,color)
  text_at(item.name,origin+Vector2(80,33),20,color)
  wrapped(item.desc,origin+Vector2(80,61),440,16,WHITE,22)
  var locked = item.get("unlock","") != "" and not item.get("unlock","") in profile.data.unlocks
  text_at("GESPERRT" if locked else ("ENTDECKT" if item.id in profile.data.seen else "NOCH NICHT GEFUNDEN"),origin+Vector2(80,99),12,MUTED)
 text_at("SEITE %d / 8 · %d / 64 entdeckt" % [page+1,profile.data.seen.size()],Vector2(330,747),17,CYAN)

func draw_unlocks() -> void:
 text_at("DAUERHAFTE FREIGABEN",Vector2(80,90),40,WHITE)
 text_at("Fortschritt bleibt zwischen Versuche erhalten.",Vector2(80,128),18,MUTED)
 for i in range(Catalog.UNLOCKS.size()):
  var entry = Catalog.UNLOCKS[i]
  var origin = Vector2(80+(i%2)*580,176+int(i/2)*164)
  var done = entry.id in profile.data.unlocks
  panel(Rect2(origin,Vector2(550,143)))
  draw_circle(origin+Vector2(35,38),12,CYAN if done else Color("354259"))
  text_at(entry.name,origin+Vector2(63,43),23,CYAN if done else WHITE)
  text_at(entry.desc,origin+Vector2(25,81),17,MUTED)
  wrapped("Freigabe: "+entry.reward,origin+Vector2(25,113),498,16,GOLD,23)
 text_at("Gegner: %d / 100 · Bosse: %d · Siege: %d" % [profile.data.kills,profile.data.bosses,profile.data.wins],Vector2(80,729),18,MUTED)

func draw_game() -> void:
 text_at("MUTATION / NULL",Vector2(60,44),23,WHITE)
 text_at(("ENDLESS %d" % (floor_number-10) if floor_number>10 else "BOSS %d / 10" % floor_number)+"   ·   "+current_biome().name,Vector2(60,74),16,CYAN)
 var seconds = int(run_time)
 text_at("%02d:%02d" % [seconds/60,seconds%60],Vector2(880,46),20,MUTED)
 for i in range(mini(12,int(ceil(player.max_hp)))):
  var x = 62+i*21
  var color = PINK if player.hp>i else Color("2c3244")
  draw_circle(Vector2(x+8,110),8,color)
  if player.hp>i and player.hp<i+1: draw_circle(Vector2(x+8,110),4,INK)
 text_at("LP %.0f / %.0f" % [player.hp,player.max_hp],Vector2(60,133),12,MUTED)
 text_at("%d MÜNZEN" % player.coins,Vector2(370,116),18,GOLD)
 text_at("%d BOMBEN" % player.bombs,Vector2(520,116),18,MUTED)
 text_at("SPRINT",Vector2(705,116),14,CYAN if dash_cd<=0 else MUTED)
 draw_rect(Rect2(756,104,130,8),Color("243345"))
 draw_rect(Rect2(756,104,130*(1-dash_cd/(1.1 if has_item("dash") else 1.85)),8),CYAN)
 var offset = Vector2.ZERO
 if shake>0 and profile.data.shake:
  offset = Vector2(sin(timer*97),cos(timer*83))*shake
 draw_set_transform(offset)
 draw_room()
 for c in corpses: draw_sprite(c.key,c.pos,Vector2.ONE*c.size,"death",c.facing,c.age)
 for pickup in pickups: draw_pickup(pickup)
 for h in hazards: draw_hazard(h)
 for bullet in shots:
  var color = (GOLD if bullet.crit else CYAN) if bullet.friendly else PINK
  draw_line(bullet.pos-bullet.vel.normalized()*12,bullet.pos,color.darkened(0.4),bullet.radius*1.2,true)
  draw_circle(bullet.pos,bullet.radius+3,Color(color,0.14))
  if not draw_prop(bullet.get("art","player_shot" if bullet.friendly else "enemy_shot"),bullet.pos,Vector2.ONE*(bullet.radius*3)):
   draw_circle(bullet.pos,bullet.radius,color)
 for enemy in foes: draw_enemy(enemy)
 if has_item("drone"):
  var pos = player.pos+Vector2(-28,-28+sin(timer*4)*4)
  draw_prop("drone",pos,Vector2(32,32))
 if has_item("orbit"):
  for i in range(2):
   var pos = player.pos+Vector2.from_angle(timer*3+i*PI)*55
   draw_prop("orbiter",pos,Vector2(24,24))
 if has_item("shield"):
  var pos = player.pos+Vector2.from_angle(timer*2)*42
  draw_prop("shield",pos,Vector2(32,32))
 if invuln<=0 or int(timer*16)%2 == 0:
  draw_sprite("character/"+Catalog.CHARACTERS[character].id,player.pos,Vector2(48,48),player_state,player_facing,player_anim)
  if mutation_layers:
   for id in inventory: draw_sprite("mutation/"+id,player.pos,Vector2(48,48),player_state,player_facing,player_anim)
  if "no_hit" in profile.data.unlocks: draw_arc(player.pos,23,0,TAU,24,GOLD,1,true)
  if has_item("rage") and player.hp<=player.max_hp*0.5: draw_arc(player.pos,27,0,TAU,24,PINK,2,true)
 for p in particles: draw_circle(p.pos,2.5,Color(p.color,minf(1,p.ttl*3)))
 for e in effects:
  if e.type == "line": draw_line(e.from,e.to,e.color,3,true)
  elif e.type == "sprite": draw_fx(e.key,e.pos,e.size,e.age)
  elif e.type == "prop": draw_prop(e.key,e.pos,Vector2(28,28))
  else: draw_arc(e.pos,e.radius*(1-e.ttl/0.3),0,TAU,40,Color(e.color,e.ttl/0.25),3,true)
 draw_set_transform(Vector2.ZERO)
 draw_sidebar()
 if item_time>0:
  var a = minf(1,item_time)
  draw_rect(Rect2(188,163,664,82),Color(0.05,0.08,0.13,0.93*a))
  centered(item_banner,Vector2(520,197),25,Color(WHITE,a))
  wrapped(item_detail,Vector2(210,222),620,16,Color(CYAN,a),20)
 if near_pickup>=0 and near_pickup<pickups.size():
  var pickup = pickups[near_pickup]
  var caption = pickup_caption(pickup)
  if pickup.price>0: caption += " · %d Münzen" % price_of(pickup)
  if pickup.type == "item":
   panel(Rect2(110,637,820,89),Color("142235"))
   var desc = Catalog.item(pickup.id).desc
   var blocked = mutation_block_reason(pickup.id)
   wrapped(desc+(" · "+blocked if blocked != "" else ""),Vector2(128,688),782,14,WHITE,18)
   text_at(caption,Vector2(128,665),16,GOLD)
  elif pickup.type in ["event","portal"]: wrapped(caption,Vector2(110,685),820,15,GOLD,20)
  else: centered(caption,Vector2(520,704),16,GOLD)
 if touch_enabled:
  for info in [[touch_left,touch_origin,touch_move],[touch_right,touch_aim_origin,touch_aim]]:
   if info[0]>=0:
    draw_circle(info[1],58,Color(0.5,0.9,0.85,0.08))
    draw_arc(info[1],58,0,TAU,32,Color(CYAN,0.35),2,true)
    draw_circle(info[1]+info[2]*45,18,Color(CYAN,0.5))

func draw_room() -> void:
 panel(Rect2(48,136,944,608),Color("263144"))
 draw_rect(ARENA,Color("182232"))
 var biome_id = current_biome().id
 var tile = art.texture("biome/"+biome_id+"/floor")
 if tile:
  draw_texture_rect(tile,ARENA,false)
 var background = art.texture("biome/"+biome_id+"/background")
 if background: draw_texture_rect(background,ARENA,false)
 var overlay = art.texture("biome/"+biome_id+"/"+room.type)
 if overlay: draw_texture_rect(overlay,ARENA,false)
 var accent = Color(current_biome().color)
 for p in [Vector2(78,166),Vector2(962,166),Vector2(78,714),Vector2(962,714)]:
  draw_circle(p,4,accent)
 # Exit positions only exist where the graph contains a neighboring room.
 var open = room.cleared or room.type not in ["combat","boss","challenge"]
 for dir in DIRS:
  if not Dungeon.connected(rooms,current,current+dir): continue
  var p = CENTER + Vector2(dir)*Vector2(460,292)
  var rect = Rect2(p-Vector2(10,48),Vector2(20,96)) if dir.x != 0 else Rect2(p-Vector2(48,10),Vector2(96,20))
  var dest = rooms[current+dir]
  var color = PINK if dest.type == "boss" else GOLD if dest.type in ["treasure","shop"] else accent
  draw_rect(rect,Color("0c1220"))
  draw_rect(rect.grow(-4),color.darkened(0.45) if open else Color("47304b"))
  var door = art.texture("biome/"+biome_id+"/door_"+("open" if open else "closed")+("_horizontal" if dir.y != 0 else ""))
  if door:
   draw_texture_rect(door,rect.grow(4),false)
  if not open:
   draw_line(rect.position,rect.end,PINK,3,true)
   draw_line(Vector2(rect.end.x,rect.position.y),Vector2(rect.position.x,rect.end.y),PINK,3,true)
 for block in obstacles:
  var p = block.pos
  var rock = art.texture("biome/"+biome_id+"/rock")
  if rock:
   draw_texture_rect(rock,Rect2(p-Vector2(32,32),Vector2(64,64)),false)
   continue
  var verts = PackedVector2Array()
  for i in range(6): verts.append(p+Vector2.from_angle(i*TAU/6)*block.radius)
  draw_colored_polygon(verts,Color("35475c"))
  verts.append(verts[0])
  draw_polyline(verts,Color("59697e"),2,true)
  draw_line(p+Vector2(-10,-7),p+Vector2(4,3),MUTED,2,true)
 if room.type == "start":
  draw_arc(CENTER,64,0,TAU,48,accent.darkened(0.7),2,true)
  centered("AUSGANGSPROBE",Vector2(520,325),16,MUTED)
 elif room.type == "treasure": centered("GENBANK · WÄHLE EINE MUTATION",Vector2(520,290),19,GOLD)
 elif room.type == "shop": centered("BIOHANDEL · E ZUM KAUFEN",Vector2(520,265),19,GOLD)
 elif room.type == "rest": centered("REGENERATION",Vector2(520,290),19,CYAN)
 elif room.type == "transition":
  centered("ÜBERGANGSKAMMER · "+current_biome().name,Vector2(520,325),19,CYAN)
  centered("Evakuieren oder weitermachen? Dein Genom bleibt beim Weitergehen erhalten." if floor_number>=5 else "Wähle deinen nächsten Weg. Die Portale zeigen Gefahr und Belohnung.",Vector2(520,360),15,MUTED)
 elif room.type in ["lab","sacrifice","challenge","unstable"]:
  for event in Catalog.EVENTS:
   if event.id == room.type:
    centered(event.name,Vector2(520,330),22,GOLD)
    wrapped(event.desc,Vector2(220,370),620,17,MUTED,24)

func draw_enemy(enemy: Dictionary) -> void:
 var color = Color(Catalog.enemy(enemy.kind).color)
 if enemy.boss>=0: color = Color(Catalog.BOSSES[enemy.boss].color)
 if enemy.flash>0: color = WHITE
 if enemy.poison>0: color = Color("a3d768")
 if enemy.burn>0: color = Color("ff865a")
 if enemy.slow>0: draw_arc(enemy.pos,enemy.radius+5,0,TAU,20,Color("7bc2ff"),2,true)
 if enemy.telegraph>0:
  var direction = ((enemy.target if enemy.kind in [2,5,12,16] else player.pos)-enemy.pos).normalized()
  draw_line(enemy.pos,enemy.pos+direction*230,Color(PINK,0.4),5,true)
  draw_arc(enemy.pos,enemy.radius+8,0,TAU,24,PINK,3,true)
 if enemy.kind>=13:
  draw_arc(enemy.pos,enemy.radius+7,0,TAU,24,color,2,true)
  text_at(Catalog.enemy(enemy.kind).name,enemy.pos+Vector2(-32,-32),10,color)
  if enemy.kind == 14 and enemy.telegraph>0: draw_arc(enemy.target,42,0,TAU,32,PINK,2,true)
 var key = enemy_art_key(enemy)
 if not draw_sprite(key,enemy.pos,Vector2.ONE*(96 if enemy.boss>=0 else 48),enemy.state,enemy.facing,enemy.anim):
  draw_creature(enemy.pos,enemy.radius,color,enemy.kind,(player.pos-enemy.pos).normalized())
 if enemy.kind == 6 and not enemy.headless:
  draw_arc(enemy.pos+Vector2(0,-14),10,0,TAU,16,Color(PINK,.45),1,true)
 if enemy.kind == 8 and enemy.telegraph>0:
  draw_arc(enemy.target,24,0,TAU,24,CYAN,2,true)
 if enemy.kind == 9:
  var angle = (player.pos-enemy.pos).angle()
  draw_arc(enemy.pos,enemy.radius+4,angle-.8,angle+.8,16,GOLD,4,true)
 if enemy.boss>=0:
  var bar = Rect2(255,255,530,8)
  draw_rect(bar,Color("49304a"))
  draw_rect(Rect2(bar.position,Vector2(bar.size.x*maxf(0,enemy.hp/enemy.max_hp),bar.size.y)),color)
  centered(Catalog.BOSSES[enemy.boss].name,Vector2(520,284),14,MUTED)
 elif enemy.hp<enemy.max_hp:
  draw_rect(Rect2(enemy.pos+Vector2(-16,-enemy.radius-10),Vector2(32,4)),Color("49304a"))
  draw_rect(Rect2(enemy.pos+Vector2(-16,-enemy.radius-10),Vector2(32*maxf(0,enemy.hp/enemy.max_hp),4)),color)

func draw_creature(pos: Vector2,radius: float,color: Color,kind: int,direction: Vector2) -> void:
 draw_circle(pos+Vector2(0,radius*0.65),radius*0.88,Color(0.02,0.03,0.05,0.45))
 if kind in [2,5]:
  for i in range(6):
   var angle = i*TAU/6
   var base = pos+Vector2.from_angle(angle)*radius*0.75
   var tip = pos+Vector2.from_angle(angle)*(radius*1.25+sin(timer*3+i)*radius*0.08)
   draw_line(base,tip,color.darkened(0.35),radius*0.18,true)
 draw_circle(pos,radius+1,color.darkened(0.55))
 draw_circle(pos-Vector2(0,radius*0.06),radius*0.9,color)
 draw_arc(pos-Vector2(0,radius*0.08),radius*0.72,PI*1.08,PI*1.68,16,color.lightened(0.3),maxf(1,radius*0.06),true)
 var eyes = pos+direction*radius*0.21
 for side in [-1,1]:
  var p = eyes+Vector2(side*radius*0.3,-radius*0.18)
  draw_circle(p,radius*0.20,INK)
  draw_circle(p+direction*radius*0.06,radius*0.08,WHITE)
 draw_line(pos+Vector2(-radius*0.18,radius*0.3),pos+Vector2(radius*0.18,radius*0.3),INK,maxf(1,radius*0.08),true)

func draw_item_icon(id: String,pos: Vector2,radius: float,color: Color) -> void:
 var tex = art.texture("item/"+id)
 if tex:
  draw_texture_rect(tex,Rect2(pos-Vector2.ONE*radius,Vector2.ONE*radius*2),false)
  return
 var code = absi(hash(id))
 draw_circle(pos,radius+7,Color(color,0.07))
 var vertices = PackedVector2Array()
 var sides = 3+code%4
 for i in range(sides): vertices.append(pos+Vector2.from_angle(i*TAU/sides-PI/2)*radius)
 draw_colored_polygon(vertices,color.darkened(0.5))
 vertices.append(vertices[0])
 draw_polyline(vertices,color,2,true)
 if code%3 == 0:
  draw_circle(pos,radius*0.4,color)
  draw_circle(pos,radius*0.16,INK)
 elif code%3 == 1:
  draw_line(pos+Vector2(-radius*0.5,0),pos+Vector2(radius*0.5,0),color,3,true)
  draw_line(pos+Vector2(0,-radius*0.5),pos+Vector2(0,radius*0.5),color,3,true)
 else:
  draw_arc(pos,radius*0.5,-PI*0.7,PI*0.7,16,color,3,true)
func draw_pickup(pickup: Dictionary) -> void:
 var pos = pickup.pos+Vector2(0,sin(timer*2.5+pickup.pos.x)*3)
 match pickup.type:
  "item":
   draw_rect(Rect2(pickup.pos+Vector2(-28,18),Vector2(56,10)),Color("334259"))
   var item = Catalog.item(pickup.id)
   draw_item_icon(pickup.id,pos,18,[CYAN,PINK,GOLD][item.rarity])
  "coin":
   draw_circle(pos,9,GOLD.darkened(0.45))
   draw_circle(pos-Vector2(0,1),7,GOLD)
   draw_line(pos-Vector2(0,4),pos+Vector2(0,4),INK,2,true)
  "heal":
   draw_circle(pos,12,PINK.darkened(0.7))
   draw_line(pos+Vector2(-7,0),pos+Vector2(7,0),PINK,5,true)
   draw_line(pos+Vector2(0,-7),pos+Vector2(0,7),PINK,5,true)
  "bomb":
   draw_circle(pos,10,MUTED)
   draw_line(pos+Vector2(3,-7),pos+Vector2(6,-15),GOLD,3,true)
  "event":
   draw_prop("event_"+pickup.id,pos,Vector2(56,56))
  "portal", "finish":
   draw_prop("portal",pos,Vector2(64,64))
   draw_arc(pos,32,0,TAU,40,CYAN,3,true)
   draw_arc(pos,22,timer,timer+PI*1.5,32,CYAN.darkened(0.5),4,true)
   centered("↓",pos+Vector2(0,11),28,CYAN)
   if pickup.type == "finish": centered("EVAKUIEREN",pickup.pos+Vector2(0,58),15,GOLD)
   if pickup.type == "portal":
    centered(Catalog.BIOMES[pickup.destination].name,pickup.pos+Vector2(0,58),14,GOLD if pickup.get("risk",false) else CYAN)
    centered(("ENDLESS" if floor_number>=10 else "ZWEITER ZYKLUS") if floor_number>=5 else "INSTABIL · MEHR BEUTE" if pickup.get("risk",false) else "REGULÄR",pickup.pos+Vector2(0,78),12,MUTED)
    centered(Catalog.BIOMES[pickup.destination].reward,pickup.pos+Vector2(0,97),12,MUTED)
 if pickup.type in ["coin","heal","bomb"]: draw_prop(pickup.type,pos,Vector2(28,28))
 if pickup.price>0: centered("%d ¤" % price_of(pickup),pickup.pos+Vector2(0,51),17,GOLD)

func draw_hazard(h: Dictionary) -> void:
 match h.type:
  "bomb":
   draw_circle(h.pos,13,GOLD)
   draw_prop("bomb",h.pos,Vector2(32,32))
   draw_arc(h.pos,h.radius,0,TAU,40,Color(GOLD,0.18+0.2*sin(timer*16)),2,true)
  "warning":
   draw_circle(h.pos,h.radius,Color(PINK,0.09))
   draw_arc(h.pos,h.radius*(0.3+h.age*0.7),0,TAU,32,PINK,2,true)
   draw_line(h.pos-Vector2(8,8),h.pos+Vector2(8,8),PINK,2,true)
   draw_line(h.pos+Vector2(-8,8),h.pos+Vector2(8,-8),PINK,2,true)
  "spore":
   draw_fx("acid_pool",h.pos,h.radius*2,h.age)
  "toxic_pool":
   draw_fx("acid_pool",h.pos,h.radius*2,h.age)
  "friendly_pool":
   draw_fx("acid_pool",h.pos,h.radius*2,h.age)
  "bloodtrail":
   draw_fx("blood_puddle",h.pos,h.radius*2,h.age)
  "fire":
   draw_circle(h.pos,h.radius,Color(0.95,0.25,0.17,0.25))
   draw_arc(h.pos,h.radius,0,TAU,32,Color("ff805d"),2,true)
  "void":
   draw_circle(h.pos,h.radius,Color(0.3,0.2,0.7,0.12))
   for i in range(3): draw_arc(h.pos,18+i*15,timer*3+i,timer*3+i+PI,24,Color("aca3ef"),2,true)

func draw_sidebar() -> void:
 panel(Rect2(1010,90,238,646))
 text_at("RAUMPLAN",Vector2(1032,124),15,CYAN)
 draw_minimap(Rect2(1029,145,200,158),Input.is_action_pressed("map"))
 text_at("%s%s" % [room_label(room.type)," · FREI" if room.cleared else ""],Vector2(1032,324),14,MUTED)
 draw_line(Vector2(1030,343),Vector2(1228,343),Color("2d3c52"),1)
 text_at("GENOM / %02d" % inventory.size(),Vector2(1032,376),18,WHITE)
 text_at("SCHADEN    %.1f" % shot_damage(),Vector2(1032,409),15,MUTED)
 text_at("FEUERRATE  %.1f/s" % effective_rate(),Vector2(1032,435),15,MUTED)
 text_at("TEMPO      %d" % player.speed,Vector2(1032,461),15,MUTED)
 for i in range(mini(18,inventory.size())):
  var item = Catalog.item(inventory[i])
  var pos = Vector2(1050+(i%6)*33,493+int(i/6)*34)
  draw_item_icon(item.id,pos,10,[CYAN,PINK,GOLD][item.rarity])
 if not pickup_history.is_empty():
  text_at("ZULETZT AUFGENOMMEN",Vector2(1032,587),12,CYAN)
  wrapped(pickup_history[0].name,Vector2(1032,608),195,14,GOLD,18)
 text_at("WASD   Bewegen",Vector2(1032,642),12,MUTED)
 text_at("Pfeile / Maus   Feuer",Vector2(1032,680),12,MUTED)
 text_at("Leertaste   Sprint   ·   Q   Bombe",Vector2(1032,699),11,MUTED)
 text_at("E Nehmen · Tab Karte · I Genom",Vector2(1032,718),10,MUTED)
 text_at("Startwert: %d" % seed_value,Vector2(1032,734),10,MUTED)
func draw_minimap(rect: Rect2,reveal: bool) -> void:
 var visible: Array = []
 for p in rooms:
  if rooms[p].visited or reveal or adjacent_visited(p): visible.append(p)
 if visible.is_empty(): return
 var low = Vector2i(100,100)
 var high = Vector2i(-100,-100)
 for p in rooms:
  low.x = mini(low.x,p.x); low.y = mini(low.y,p.y)
  high.x = maxi(high.x,p.x); high.y = maxi(high.y,p.y)
 var span = high-low+Vector2i.ONE
 var cell = minf(27,minf(rect.size.x/span.x,rect.size.y/span.y))
 var origin = rect.position+(rect.size-Vector2(span)*cell)/2
 for p in visible:
  var r = rooms[p]
  var pos = origin+Vector2(p-low)*cell
  var color = Color("34415a")
  if r.visited: color = Color("647690")
  if r.type == "boss": color = PINK
  if r.type in ["treasure","shop"]: color = GOLD
  if r.type == "rest": color = CYAN.darkened(0.4)
  draw_rect(Rect2(pos+Vector2(3,3),Vector2(cell-6,cell-6)),color.darkened(0.45) if not r.visited else color)
  if r.cleared: draw_circle(pos+Vector2.ONE*cell/2,2,INK)
  if p == current: draw_rect(Rect2(pos+Vector2(1,1),Vector2(cell-2,cell-2)),CYAN,false,2)
 if reveal:
  panel(Rect2(205,305,630,330),Color("101724"))
  # Draw a larger revealed map once, with recursion disabled.
  var big_cell = minf(52,minf(570.0/span.x,270.0/span.y))
  var big_origin = Vector2(235,335)+(Vector2(570,270)-Vector2(span)*big_cell)/2
  for p in rooms:
   var pos = big_origin+Vector2(p-low)*big_cell
   var color = CYAN if p == current else PINK if rooms[p].type == "boss" else GOLD if rooms[p].type in ["treasure","shop"] else MUTED
   for dir in [Vector2i.RIGHT,Vector2i.DOWN]:
    if Dungeon.connected(rooms,p,p+dir): draw_line(pos+Vector2.ONE*big_cell/2,pos+Vector2(dir)*big_cell+Vector2.ONE*big_cell/2,Color("314259"),4)
   draw_rect(Rect2(pos+Vector2(5,5),Vector2.ONE*(big_cell-10)),color)
  centered("TAB LOSLASSEN · KARTE SCHLIESSEN",Vector2(520,619),14,MUTED)
func adjacent_visited(p: Vector2i) -> bool:
 for dir in DIRS:
  if Dungeon.connected(rooms,p,p+dir) and rooms[p+dir].visited: return true
 return false
func draw_end() -> void:
 draw_rect(Rect2(0,0,1280,800),Color(0.025,0.04,0.07,0.94))
 draw_sprite("character/"+Catalog.CHARACTERS[character].id,Vector2(640,140),Vector2(104,104),"idle" if end_won else "death",player_facing,player_anim)
 centered("LABORBERICHT",Vector2(640,210),17,CYAN)
 centered(end_title,Vector2(640,280),42,WHITE)
 centered(end_reason,Vector2(640,322),18,MUTED)
 var seconds = int(run_time)
 for i in range(4):
  var pos = Vector2(330+i*165,400)
  var labels = ["EBENE","MUTATIONEN","GEGNER","ZEIT"]
  var values = [str(floor_number),str(inventory.size()),str(kills_run),"%02d:%02d" % [seconds/60,seconds%60]]
  centered(values[i],pos,36,CYAN)
  centered(labels[i],pos+Vector2(0,35),13,MUTED)
 centered("Freigaben und entdeckte Mutationen bleiben erhalten.",Vector2(640,503),17,GOLD)

func take_screenshot() -> void:
 await get_tree().process_frame
 await RenderingServer.frame_post_draw
 var image = get_viewport().get_texture().get_image()
 image.save_png("user://screenshot.png")
 screen = "testing"
 sound.stop_all()
 await get_tree().create_timer(0.06).timeout
 get_tree().quit()

# Integration checks run inside the engine, without changing the real player's save.
func run_smoke_test() -> void:
 var real_profile = profile
 profile = Profile.new()
 profile.memory_only = true
 test_mode = true
 var failures: Array = []
 if Catalog.ITEMS.size() != 64: failures.append("Catalog must contain 64 items")
 var ids: Array = []
 for item in Catalog.ITEMS:
  if item.id in ids: failures.append("Duplicate item id: "+item.id)
  ids.append(item.id)
 var gen_rng = RandomNumberGenerator.new()
 for s in range(100):
  gen_rng.seed = s
  for f in range(1,FLOOR_COUNT+1):
   var graph = Dungeon.generate(gen_rng,f)
   var visited = [Vector2i.ZERO]
   var queue = [Vector2i.ZERO]
   var bosses = 0
   var treasures = 0
   for p in graph:
    if graph[p].type == "transition":
     var links = 0
     for dir in DIRS:
      if Dungeon.connected(graph,p,p+dir): links += 1
     if links != 1 or graph[graph[p].gate].type != "boss": failures.append("Exit chamber must connect only to boss")
    if graph[p].type == "boss": bosses += 1
    if graph[p].type == "treasure": treasures += 1
   while not queue.is_empty():
    var p = queue.pop_front()
    for dir in DIRS:
     if Dungeon.connected(graph,p,p+dir) and not (p+dir) in visited:
      visited.append(p+dir); queue.append(p+dir)
   if visited.size()!=graph.size() or bosses != 1 or treasures != 2:
    failures.append("Invalid graph seed %d floor %d" % [s,f])
 character = 0
 start_run()
 # All item effects must be callable together, including child-shot recursion protection.
 profile.data.unlocks = ["first_boss","kills_100","items_10","floor_3","win","no_hit"]
 for item in Catalog.ITEMS: take_item(item.id)
 room = {"type":"combat","cleared":false,"choice":false}
 foes = [make_enemy(0,CENTER+Vector2(90,0)),make_enemy(1,CENTER+Vector2(160,0))]
 obstacles = []
 pickups = []
 for i in range(120):
  fire(Vector2.RIGHT)
  update_enemies(1.0/60)
  update_shots(1.0/60)
  update_hazards(1.0/60)
  clean_dead()
 # Each boss must generate hazards and be killable.
 for b in range(Catalog.BOSSES.size()):
  shots.clear()
  hazards.clear()
  foes = [make_enemy(5,CENTER+Vector2(150,0))]
  foes[0].boss = b
  for i in range(4):
   foes[0].cd = 0
   update_enemies(0.016)
  damage_enemy(foes[0],100000)
  clean_dead()
  if not foes.is_empty(): failures.append("Boss cleanup failed: %d" % b)
 # All normal kinds must enter their AI path without invalid indices or missing state.
 for spec in Catalog.ENEMIES:
  foes = [make_enemy(spec.kind,CENTER+Vector2(180,0))]
  shots.clear()
  hazards.clear()
  player.hp = 1000
  for n in range(180): update_enemies(1.0/60)
 # Decapitation keeps the enemy alive and emits hostile blood, not damaging floor pools.
 var runner = make_enemy(6,CENTER+Vector2(100,0))
 foes = [runner]
 decapitate(runner)
 shots.clear()
 blood_spray(runner)
 if not runner.headless or runner.dead or shots.size()!=3:
  failures.append("Decapitation and blood projectile emission")
 var blood = shots[0]
 if blood.friendly or blood.art != "blood_shot": failures.append("Blood must be hostile")
 shots = [blood]
 blood.pos = player.pos
 blood.vel = Vector2.ZERO
 invuln = 0
 barrier_charge = false
 player.armor = 0
 player.hp = 6
 update_shots(0.016)
 if player.hp != 5: failures.append("Direct blood hit must damage player")
 inventory.clear()
 recalculate_stats()
 # Shops must deduct coins exactly once; treasure choices consume both pedestals.
 screen = "game"
 room = {"type":"shop","cleared":true,"choice":false}
 pickups = [make_pickup("item",player.pos,"muscle")]
 pickups[0].price = 10
 player.coins = 20
 var price = price_of(pickups[0])
 interact()
 if player.coins != 20-price or not pickups.is_empty(): failures.append("Shop transaction")
 room.choice = true
 pickups = [make_pickup("item",player.pos,"quick"),make_pickup("item",player.pos+Vector2(10,0),"legs")]
 interact()
 if not pickups.is_empty(): failures.append("Treasure choice must be exclusive")
 # Silent dialogue must queue and block only explicitly modal lines.
 var text_system = Speech.new()
 text_system.say("ai","KI","Hallo.","neutral",true,true,0.05)
 if not text_system.blocks_combat(): failures.append("Modal dialogue")
 text_system.step(0.1)
 if not text_system.active.is_empty(): failures.append("Dialogue expiry")
 # Branches visit all five biomes once; single remaining destinations offer risk variants.
 floor_number = 1
 route = [0]
 room = {"type":"transition","pickups":[]}
 populate_route_choices()
 if room.pickups.size()!=3 or room.pickups[1].destination == room.pickups[2].destination:
  failures.append("Initial biome branch")
 route = [0,2,3]
 floor_number = 3
 room = {"type":"transition","pickups":[]}
 populate_route_choices()
 if room.pickups[1].destination != 1 or not room.pickups[2].risk: failures.append("Remaining biome risk branch")
 floor_number = 1
 route = [0]
 inventory.clear()
 run_hp_cost = 0
 player.hp = 6
 recalculate_stats()
 room = {"type":"sacrifice","event_used":false,"cleared":true}
 var offer = make_pickup("event",player.pos,"sacrifice")
 pickups = [offer]
 interact_event(offer)
 if run_hp_cost!=2 or inventory.size()!=1 or not room.event_used: failures.append("Sacrifice transaction")
 room = {"type":"unstable","event_used":false,"cleared":true}
 offer = make_pickup("event",player.pos,"unstable")
 pickups = [offer]
 var before = inventory.size()
 var old_curse = curse_speed
 interact_event(offer)
 interact_event(offer)
 if inventory.size()!=before+2 or not is_equal_approx(curse_speed,old_curse*1.25): failures.append("Unstable offer must be consumed once")
 # Duplicate and incompatible pickups cannot spend coins or consume choices.
 inventory.clear()
 recalculate_stats()
 take_item("twin")
 var unique_count = inventory.size()
 take_item("twin")
 take_item("triple")
 if inventory.size()!=unique_count: failures.append("Duplicate / multishot exclusion")
 take_item("poison")
 take_item("burn")
 take_item("ice")
 if has_item("burn") or has_item("ice"): failures.append("Element exclusion")
 take_item("explode")
 take_item("split")
 if has_item("split"): failures.append("Payload exclusion")
 room = {"type":"shop","cleared":true,"choice":false}
 pickups = [make_pickup("item",player.pos,"triple")]
 pickups[0].price = 12
 player.coins = 30
 speech.reset()
 interact()
 if player.coins!=30 or pickups.size()!=1: failures.append("Blocked shop must be atomic")
 # Exhausted pool must return supplies instead of prohibited duplicates.
 inventory = Catalog.ITEMS.map(func(i): return i.id)
 if roll_item()!= "" or make_pickup("item",CENTER,roll_item()).type != "heal": failures.append("Exhausted pool fallback")
 recalculate_stats()
 if player.damage>18 or player.rate>8 or player.max_hp>16 or player.armor>0.45 or player.crit>0.60: failures.append("Stat caps")
 # Overlapping pools cannot multiply damage.
 inventory.clear()
 recalculate_stats()
 var pool_target = make_enemy(0,CENTER)
 foes = [pool_target]
 hazards.clear()
 for n in range(15): hazards.append({"type":"friendly_pool","pos":CENTER,"timer":2.0,"radius":40.0,"age":0.0})
 var pool_hp = pool_target.hp
 update_hazards(0.1)
 if not is_equal_approx(pool_hp-pool_target.hp,0.5): failures.append("Pool overlap limit")
 # Play all transitions: every boss once in ten floors; Endless remains valid.
 character = 0
 begin_run()
 var encountered: Array = []
 for f in range(1,16):
  floor_number = f
  generate_floor()
  for coord in rooms:
   if rooms[coord].type == "boss": encountered.append(rooms[coord].boss_index)
  room = {"type":"transition","cleared":true,"choice":false,"pickups":[],"enemies":[],"obstacles":[]}
  populate_route_choices()
  var portal = room.pickups.filter(func(p): return p.type == "portal")[0]
  pickups = room.pickups
  if f>=5 and not pickups.any(func(p): return p.type == "finish"): failures.append("Missing evacuation")
  speech.reset()
  player.pos = portal.pos
  interact()
  if floor_number != f+1: failures.append("Continuation failed at floor %d" % f)
 var first_ten = encountered.slice(0,10)
 for index in range(10):
  if first_ten.count(index)!=1: failures.append("Ten-boss variety")
 if profile.data.wins!=1: failures.append("Milestone counted more than once")
 # Save payload must retain route, boss sequence, history, and risk after serialization.
 var saved = {"version":4,"floor":floor_number,"route":route,"boss_order":boss_order,"history":pickup_history,"rooms":rooms,"player":player}
 var restored = bytes_to_var(var_to_bytes(saved))
 if restored.route!=route or restored.boss_order!=boss_order or restored.floor!=floor_number: failures.append("Run serialization")
 # Resume through the real load path, using an in-memory test profile.
 var resume_state = {"version":4,"seed":seed_value,"rng":rng.state,"rooms":rooms,"current":current,"floor":floor_number,"player":player,"inventory":inventory,"character":character,"hard":hard,"route":route,"risk":run_risk,"curse_speed":curse_speed,"hp_cost":run_hp_cost,"synergies":found_synergies,"run_time":run_time,"kills":kills_run,"clears":clears,"phoenix":phoenix_used,"attack_count":attack_count,"boss_order":boss_order,"milestone_claimed":milestone_claimed,"history":pickup_history}
 profile.memory_run = bytes_to_var(var_to_bytes(resume_state))
 var resume_floor = floor_number
 var resume_route = route.duplicate()
 floor_number = 1
 route = [0]
 continue_run()
 if floor_number!=resume_floor or route!=resume_route or current!=resume_state.current: failures.append("Actual checkpoint resume")
 # Music pause is independent of sound-effect volume.
 var old_volume = sound.volume
 sound.music_enabled = false
 sound._process(0.01)
 if not sound.music.stream_paused or sound.volume!=old_volume: failures.append("Independent music switch")
 sound.music_enabled = true
 sound._process(0.01)
 if sound.music.stream_paused and sound.volume>0: failures.append("Music restore")
 profile = real_profile
 screen = "testing"
 sound.stop_all()
 await get_tree().create_timer(0.06).timeout
 if failures.is_empty():
  print("SMOKE TEST PASSED: 1000 floor graphs, 64 mutation acquisition checks, 16 enemy AI paths, 10 boss patterns, 15-floor progression, shops, exclusions, caps, pool overlap, serialization, independent music toggle.")
  get_tree().quit(0)
 else:
  for failure in failures: push_error(failure)
  get_tree().quit(1)

func effective_rate() -> float:
 return minf(10,maxf(1.2,player.rate)*(1.35 if has_item("turbo") and move_input().length()<0.1 else 1.0))
func update_player_animation(dt: float,moved: Vector2) -> void:
 player_shoot_anim = maxf(0,player_shoot_anim-dt)
 step_cd -= dt
 var aim = aim_input()
 if aim.length()>0.1: player_facing = Art.facing(aim)
 elif moved.length()>0.1: player_facing = Art.facing(moved)
 var state = "hurt" if invuln>0.6 else "dash" if dash_time>0 else "walk" if moved.length()>0.1 else "shoot" if player_shoot_anim>0 else "idle"
 if moved.length()>0.1 and step_cd<=0:
  sound.play("step")
  step_cd = 0.35
 if state != player_state:
  player_anim = 0
  player_state = state
 player_anim += dt
func enemy_art_key(enemy: Dictionary) -> String:
 if enemy.boss>=0: return "boss/"+Catalog.BOSSES[enemy.boss].kind
 if enemy.kind == 6 and enemy.headless: return "enemy/decapitator_headless"
 return "enemy/"+Catalog.enemy(enemy.kind).get("art_id",Catalog.enemy(enemy.kind).id)
func decapitate(enemy: Dictionary,reward: bool=true) -> void:
 if enemy.headless or enemy.dead: return
 enemy.headless = true
 enemy.cd = 0
 enemy.panic = 5.0
 enemy.anim = 0
 sound.play("head_pop")
 effects.append({"type":"sprite","key":"blood_splash","pos":enemy.pos+Vector2(0,-14),"ttl":0.66,"age":0.0,"size":64.0})
 effects.append({"type":"prop","key":"detached_head","pos":enemy.pos+Vector2(0,-14),"vel":Vector2(60,-80),"ttl":0.7,"age":0.0})
 if reward and has_item("headhunter"):
  for i in range(2): pickups.append(make_pickup("coin",enemy.pos+Vector2(i*16-8,18)))
func blood_spray(enemy: Dictionary) -> void:
 var base = rng.randf()*TAU
 for i in range(3):
  var blood = add_shot(enemy.pos+Vector2(0,-12),Vector2.from_angle(base+i*TAU/3),false,1,false,170)
  if not blood.is_empty(): blood.art = "blood_shot"
 hazards.append({"type":"bloodtrail","pos":enemy.pos,"timer":1.8,"radius":19.0,"age":0.0})
 sound.play("blood_spray")
func draw_sprite(key: String,pos: Vector2,size: Vector2,state: String="idle",direction: String="down",time: float=0) -> bool:
 var tex = art.texture(key)
 if not tex: return false
 draw_texture_rect_region(tex,Rect2(pos-size/2,size),art.region(key,state,direction,time))
 return true
func draw_prop(key: String,pos: Vector2,size: Vector2) -> bool:
 var tex = art.texture("prop/"+key)
 if not tex: return false
 draw_texture_rect(tex,Rect2(pos-size/2,size),false)
 return true
func draw_fx(key: String,pos: Vector2,size: float,age: float) -> void:
 var asset_key = "fx/"+key
 var tex = art.texture(asset_key)
 if not tex: return
 var frame = int(age*8)%8 if key in ["acid_pool","blood_puddle"] else mini(7,int(age*12))
 draw_texture_rect_region(tex,Rect2(pos-Vector2.ONE*size/2,Vector2.ONE*size),Rect2(frame*32,0,32,32))

func current_biome() -> Dictionary:
 return Catalog.BIOMES[int(route[floor_number-1])]
func start_run() -> void:
 var c = Catalog.CHARACTERS[character]
 if c.unlock != "" and not c.unlock in profile.data.unlocks:
  notify("Diese Probe ist noch gesperrt. Sieh unter Freigaben nach.")
  return
 if test_mode: begin_run()
 else: start_intro(true)
func start_intro(for_run: bool) -> void:
 intro_for_run = for_run
 intro_index = 0
 intro_time = 0
 screen = "intro"
 speech.reset()
 clear_ui()
 button("ÜBERSPRINGEN",Rect2(1040,22,190,40),skip_intro,MUTED)
 var next_button = button("WEITER  →",Rect2(1040,750,190,36),intro_next)
 next_button.grab_focus()
 if intro_panels.is_empty():
  skip_intro()
  return
 show_intro_line()
func show_intro_line() -> void:
 intro_time = 0
 var panel_data = intro_panels[intro_index]
 var person = "character/"+Catalog.CHARACTERS[character].id if panel_data.speaker == "character" else "ai"
 var name = Catalog.CHARACTERS[character].name if panel_data.speaker == "character" else panel_data.name
 speech.say(person,name,panel_data.text,panel_data.emotion,true,true,panel_data.duration+0.5)
func intro_next() -> void:
 if screen != "intro": return
 intro_index += 1
 if intro_index>=intro_panels.size(): skip_intro()
 else: show_intro_line()
func skip_intro() -> void:
 speech.reset()
 if intro_for_run: begin_run()
 else: menu()
func draw_intro() -> void:
 if intro_index>=intro_panels.size(): return
 var panel_data = intro_panels[intro_index]
 var tex = art.texture("cutscene/"+panel_data.id)
 text_at("VORGESCHICHTE / %d VON %d" % [intro_index+1,intro_panels.size()],Vector2(160,66),17,CYAN)
 if tex: draw_texture_rect(tex,Rect2(160,104,960,480),false)
 draw_dialogue(Rect2(150,608,980,132))
 text_at("E oder Eingabetaste: weiter · Esc: überspringen",Vector2(160,768),15,MUTED)
func toggle_dialogue() -> void:
 speech.enabled = not speech.enabled
 profile.data.dialogue_enabled = speech.enabled
 profile.save_profile()
 notify("Gelegentliche Sprüche: "+("an" if speech.enabled else "aus"))
func speak_player(line: String,emotion: String="neutral",important: bool=false) -> void:
 if line == "": return
 var c = Catalog.CHARACTERS[character]
 speech.say("character/"+c.id,c.name,line,emotion,important)
func speak_boss(index: int,entrance: bool) -> void:
 var boss = Catalog.BOSSES[index]
 var lines = speech.data.get("bosses",{}).get(boss.kind,{}).get("intro" if entrance else "defeat",[])
 var line = speech.choice(lines,chatter_rng)
 if line != "": speech.say("boss/"+boss.kind,boss.name,line,"angry" if entrance else "hurt",true,entrance)
func ambient_chatter() -> void:
 if not speech.enabled or not speech.active.is_empty(): return
 var candidates = foes.filter(func(e): return not e.dead and e.boss<0)
 if not candidates.is_empty() and chatter_rng.randf()<0.65:
  var foe = candidates[chatter_rng.randi_range(0,candidates.size()-1)]
  var spec = Catalog.enemy(foe.kind)
  var line = speech.choice(speech.data.get("enemies",{}).get(spec.id,[]),chatter_rng)
  if line != "": speech.say("enemy/"+spec.get("art_id",spec.id),spec.name,line,"neutral")
 elif chatter_rng.randf()<0.4:
  var line = speech.choice(speech.data.get("ai",[]),chatter_rng)
  if line != "": speech.say("ai","LABOR-KI",line)
func draw_dialogue(rect: Rect2) -> void:
 if speech.active.is_empty(): return
 if screen == "game":
  panel(rect,Color("152237"))
  var portrait = art.texture("portrait/"+speech.active.speaker+"/"+speech.active.emotion)
  if portrait: draw_texture_rect(portrait,Rect2(rect.position+Vector2(5,4),Vector2(36,36)),false)
  text_at(speech.active.name,rect.position+Vector2(49,16),11,CYAN)
  var line = speech.visible_text()+("  [E: weiter]" if speech.blocks_combat() else "")
  wrapped(line,rect.position+Vector2(49,28),rect.size.x-62,13,WHITE,16)
  return
 var tex = art.texture("ui/dialogue_box")
 if tex: draw_texture_rect(tex,rect,false)
 else:
  draw_rect(rect,Color.BLACK)
  draw_rect(rect,WHITE,false,3)
 var head_pos = rect.position+Vector2(64,65)
 var frame = art.texture("ui/portrait_frame")
 if frame: draw_texture_rect(frame,Rect2(head_pos-Vector2(48,48),Vector2(96,96)),false)
 var key = "portrait/"+speech.active.speaker+"/"+speech.active.emotion
 var portrait = art.texture(key)
 if not portrait: portrait = art.texture("portrait/"+speech.active.speaker+"/neutral")
 if portrait: draw_texture_rect(portrait,Rect2(head_pos-Vector2(42,42),Vector2(84,84)),false)
 text_at(speech.active.name,rect.position+Vector2(132,28),16,CYAN)
 wrapped(speech.visible_text(),rect.position+Vector2(132,56),rect.size.x-150,17,WHITE,23)
 if speech.blocks_combat() and screen == "game": text_at("E: WEITER",rect.end-Vector2(115,10),12,MUTED)
func room_label(type: String) -> String:
 var names = {"start":"STARTKAMMER","combat":"KAMPFRAUM","treasure":"GENBANK","shop":"HANDEL","rest":"ERHOLUNG","boss":"BOSSRAUM","transition":"SCHLEUSE","lab":"TAUSCHLABOR","sacrifice":"OPFERKAMMER","challenge":"PROBE","unstable":"INSTABILE GENBANK"}
 return names.get(type,"RAUM")
func pickup_caption(pickup: Dictionary) -> String:
 if pickup.type == "event":
  for event in Catalog.EVENTS:
   if event.id == pickup.id: return "E · "+event.desc
 if pickup.type == "finish": return "E · VERSUCH ABSCHLIESSEN"
 if pickup.type == "portal" and floor_number>=5: return "E · "+("ENDLESS STARTEN" if floor_number == 10 else "WEITER ZU BOSS %d" % (floor_number+1))+" · Genom behalten"
 if pickup.type == "portal": return "E · "+Catalog.BIOMES[pickup.destination].name+" · "+Catalog.BIOMES[pickup.destination].danger+(" · INSTABIL: stärkere Gegner, mehr Beute" if pickup.get("risk",false) else "")
 return "E · "+(Catalog.item(pickup.id).name if pickup.type == "item" else "Heilung" if pickup.type == "heal" else "Bombe")
func populate_route_choices() -> void:
 room.pickups.append(make_pickup("heal",Vector2(520,580)))
 if floor_number>=5:
  room.pickups.append(make_pickup("finish",Vector2(340,455)))
  var portal = make_pickup("portal",Vector2(700,455))
  portal.destination = int(route[(floor_number-5)%5])
  portal.risk = false
  room.pickups.append(portal)
  return
 var options: Array = []
 if floor_number == 4: options = [4]
 else:
  for id in [1,2,3]:
   if not id in route: options.append(id)
  if options.size()>2: options.resize(2)
 for i in range(2):
  var portal = make_pickup("portal",Vector2(395+i*250,460))
  portal.destination = options[mini(i,options.size()-1)]
  portal.risk = options.size() == 1 and i == 1
  room.pickups.append(portal)

func claim_milestone() -> void:
 if milestone_claimed: return
 milestone_claimed = true
 profile.data.wins += 1
 unlock("win")
 profile.save_profile()

func toggle_music() -> void:
 profile.data.music_enabled = not profile.data.music_enabled
 sound.music_enabled = profile.data.music_enabled
 profile.save_profile()
 options_menu()

func has_synergy(id: String) -> bool:
 for combo in Catalog.SYNERGIES:
  if combo.id == id: return combo.requires.all(func(item_id): return has_item(item_id))
 return false
func check_synergies() -> void:
 for combo in Catalog.SYNERGIES:
  if has_synergy(combo.id) and not combo.id in found_synergies:
   found_synergies.append(combo.id)
   notify("KOMBINATION · "+combo.name+" · "+combo.desc)
   speak_player(speech.choice(speech.data.get("synergy",[]),chatter_rng),"happy",true)
func recalculate_stats() -> void:
 var c = Catalog.CHARACTERS[character]
 var stats = {"max_hp":c.hp,"damage":c.damage,"speed":c.speed,"rate":c.rate,"shot_speed":470.0,"range":620.0,"crit":0.12 if character == 1 else 0.03,"armor":0.0}
 for id in inventory:
  for key in Catalog.item(id).stat: stats[key] += Catalog.item(id).stat[key]
 stats.max_hp = maxf(2,clampf(stats.max_hp,2,16)-run_hp_cost)
 stats.speed = clampf(stats.speed,130,340)
 stats.shot_speed = clampf(stats.shot_speed,150,850)
 stats.damage = clampf(stats.damage if stats.damage<=10 else 10+(stats.damage-10)*0.45,0.8,18)
 stats.rate = clampf(stats.rate if stats.rate<=5 else 5+(stats.rate-5)*0.5,1.2,8)
 stats.crit = clampf(stats.crit,0,0.60)
 stats.armor = clampf(stats.armor,0,0.45)
 stats.range = clampf(stats.range,200,1200)
 for key in stats: player[key] = stats[key]
 player.hp = minf(player.hp,player.max_hp)
func remove_item(id: String) -> void:
 var index = inventory.rfind(id)
 if index<0: return
 inventory.remove_at(index)
 recalculate_stats()
func interact_event(pickup: Dictionary) -> void:
 if room.get("event_used",false): return
 match pickup.id:
  "lab":
   if inventory.is_empty():
    notify("Ohne Mutation gibt es nichts zu tauschen.")
    return
   var old_id = str(inventory.back())
   var old_player = player.duplicate(true)
   var old_inventory = inventory.duplicate()
   remove_item(old_id)
   var replacement = roll_item([old_id])
   if replacement == "":
    player = old_player
    inventory = old_inventory
    notify("Keine passende Ersatzmutation verfügbar.")
    return
   take_item(replacement)
  "sacrifice":
   if player.max_hp<=3:
    notify("Dafür brauchst du mindestens 4 maximale LP.")
    return
   var reward = roll_item([],2)
   if reward == "":
    notify("Keine passende Mutation verfügbar. Deine LP bleiben erhalten.")
    return
   run_hp_cost += 2
   recalculate_stats()
   take_item(reward)
  "unstable":
   if eligible_items().size()<2:
    notify("Nicht genug passende Mutationen verfügbar.")
    return
   var first = roll_item()
   var old_player = player.duplicate(true)
   inventory.append(first)
   recalculate_stats()
   var second = roll_item()
   inventory.pop_back()
   player = old_player
   if second == "":
    notify("Diese Genbank enthält keine zwei kompatiblen Mutationen.")
    return
   var previous_speed = curse_speed
   curse_speed = minf(1.75,curse_speed*1.25)
   take_item(first)
   take_item(second)
   notify("INSTABILITÄT · Geschosstempo +%d%%; insgesamt %d%% vom Basiswert." % [int(round((curse_speed/previous_speed-1)*100)),int(round(curse_speed*100))])
  "challenge":
   room.cleared = false
   var count = mini(12,5+int(floor_number/2))
   var kinds = current_biome().enemies
   for n in range(count):
    var pos = CENTER+Vector2.from_angle(n*TAU/count)*190
    var foe = make_enemy(kinds[rng.randi_range(0,kinds.size()-1)],pos)
    foe.hp *= 1.3
    foe.max_hp = foe.hp
    foes.append(foe)
   speak_player("Okay. Tür zu. Dann machen wir das jetzt.","angry",true)
 room.event_used = true
 pickups.erase(pickup)
 save_checkpoint()

func genome_menu(new_page: int) -> void:
 screen = "genome"
 page = clampi(new_page,0,maxi(0,int(ceil(inventory.size()/6.0))-1))
 clear_ui()
 button("◀",Rect2(140,718,80,44),func(): genome_menu(page-1))
 button("▶",Rect2(235,718,80,44),func(): genome_menu(page+1))
 button("WEITERSPIELEN",Rect2(875,718,240,44),resume_game)

func draw_genome() -> void:
 draw_rect(Rect2(0,0,1280,800),Color(0.025,0.04,0.07,0.96))
 text_at("DEIN GENOM / FUNDPROTOKOLL",Vector2(140,76),28,CYAN)
 text_at("Jede Mutation einmal · I oder Esc: schließen · Seite %d" % (page+1),Vector2(140,109),15,MUTED)
 if inventory.is_empty(): text_at("Noch keine Mutation eingesammelt.",Vector2(160,220),20,WHITE)
 for i in range(6):
  var index = page*6+i
  if index>=inventory.size(): break
  var item = Catalog.item(inventory[index])
  var y = 140+i*78
  panel(Rect2(140,y,975,69))
  draw_item_icon(item.id,Vector2(171,y+33),15,[CYAN,PINK,GOLD][item.rarity])
  text_at("%02d  %s" % [index+1,item.name],Vector2(203,y+24),17,GOLD)
  wrapped(item.desc,Vector2(203,y+47),885,14,WHITE,17)
 text_at("Grenzen: 16 LP · 18 Grundschaden · 8/s (10/s mit Ruhepol) · 60% Krit · 45% Abwehr",Vector2(140,650),15,MUTED)
 text_at("Ausschlüsse: Zwilling / Dreifach · Gift / Glut / Kälte · Explosion / Splitter",Vector2(140,681),15,MUTED)

func screenshot_scenario() -> void:
 begin_run()
 var scenario = OS.get_environment("MUTATION_PREVIEW")
 if scenario == "options": options_menu()
 elif scenario == "genome":
  for id in ["triple","poison","heavy","chain","orbit","heart"]: take_item(id)
  genome_menu(0)
 elif scenario == "transition":
  floor_number = 10
  route = [0,1,2,3,4,0,1,2,3,4]
  room = {"type":"transition","cleared":true,"choice":false,"pickups":[],"enemies":[],"obstacles":[]}
  populate_route_choices()
  pickups = room.pickups
  foes.clear()
 elif scenario == "pickup":
  take_item("triple")
  item_time = 7
  speech.active.time = 3
  speech.active.duration = 12
 elif scenario == "enemies":
  foes.clear()
  for kind in range(13,17): foes.append(make_enemy(kind,Vector2(300+(kind-13)*150,370)))
  room.cleared = false
  room.type = "combat"
 toast_time = 0
 await take_screenshot()
