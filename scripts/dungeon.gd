extends RefCounted
const DIRECTIONS = [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]
static func generate(rng: RandomNumberGenerator, floor_number: int, biome_index: int = -1) -> Dictionary:
 if biome_index<0: biome_index = posmod(floor_number-1,5)
 var rooms = {Vector2i.ZERO: make_room("start",rng)}
 var frontier = [Vector2i.ZERO]
 var target = 11 + mini(floor_number,3) * 2
 while rooms.size() < target:
  var origin = frontier[rng.randi_range(0,frontier.size()-1)]
  var pos = origin + DIRECTIONS[rng.randi_range(0,3)]
  if rooms.has(pos):
   continue
  var adjacent = 0
  for dir in DIRECTIONS:
   if rooms.has(pos + dir):
    adjacent += 1
  if adjacent > 1 and rng.randf() < 0.85:
   continue
  rooms[pos] = make_room("combat",rng)
  frontier.append(pos)
 # BFS distance ensures the boss is actually far from the starting room.
 var distance = {Vector2i.ZERO:0}
 var queue = [Vector2i.ZERO]
 while not queue.is_empty():
  var p = queue.pop_front()
  for dir in DIRECTIONS:
   var next = p + dir
   if rooms.has(next) and not distance.has(next):
    distance[next] = distance[p] + 1
    queue.append(next)
 var candidates = rooms.keys().filter(func(p): return p != Vector2i.ZERO)
 candidates.sort_custom(func(a,b): return distance[a] > distance[b])
 var boss_pos = candidates[0]
 for candidate in candidates:
  var free_neighbor = false
  for dir in DIRECTIONS:
   if not rooms.has(candidate+dir): free_neighbor = true
  if free_neighbor:
   boss_pos = candidate
   break
 rooms[boss_pos].type = "boss"
 rooms[boss_pos].boss_index = biome_index*2+rng.randi_range(0,1)
 candidates.erase(boss_pos)
 for dir in DIRECTIONS:
  var exit_pos = boss_pos+dir
  if not rooms.has(exit_pos):
   rooms[exit_pos] = make_room("transition",rng)
   rooms[exit_pos].gate = boss_pos
   break
 for special in ["treasure","shop","treasure","rest"]:
  var idx = rng.randi_range(0,candidates.size()-1)
  rooms[candidates[idx]].type = special
  candidates.remove_at(idx)
 var event_types = ["lab","sacrifice","challenge","unstable"]
 for i in range(2):
  var event_index = rng.randi_range(0,event_types.size()-1)
  var pos_index = rng.randi_range(0,candidates.size()-1)
  rooms[candidates[pos_index]].type = event_types[event_index]
  event_types.remove_at(event_index)
  candidates.remove_at(pos_index)
 return rooms
static func make_room(kind: String, rng: RandomNumberGenerator) -> Dictionary:
 return {"type":kind,"visited":false,"cleared":kind == "start","spawned":false,
 "layout":rng.randi_range(0,4),"seed":rng.randi(),"enemies":[],"pickups":[],"obstacles":[],"choice":false,"event_used":false,"boss_hit":false}

static func connected(rooms: Dictionary, a: Vector2i, b: Vector2i) -> bool:
 if not rooms.has(a) or not rooms.has(b): return false
 if absi(a.x-b.x)+absi(a.y-b.y) != 1: return false
 if rooms[a].type == "transition": return rooms[a].gate == b
 if rooms[b].type == "transition": return rooms[b].gate == a
 return true
