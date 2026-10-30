extends RefCounted
# Asset paths and frame layouts live in the JSON manifest, not in combat code.
const STATES = ["idle","walk","shoot","hurt","dash","death"]
const DIRECTIONS = ["down","left","right","up"]
var manifest: Dictionary = {}
var cache: Dictionary = {}
func _init() -> void:
 var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://assets/asset_manifest.json"))
 if parsed is Dictionary: manifest = parsed
func texture(key: String) -> Texture2D:
 if cache.has(key): return cache[key]
 if not manifest.has(key): return null
 var info = manifest[key]
 if not ResourceLoader.exists(info.path):
  cache[key] = null
  return null
 var tex = load(info.path) as Texture2D
 if tex and (tex.get_width()!=info.width or tex.get_height()!=info.height):
  push_warning("Asset size differs from manifest: "+info.path)
 cache[key] = tex
 return tex
func region(key: String,state: String,direction: String,time: float) -> Rect2:
 var info = manifest[key]
 var cell = int(info.get("cell",info.width))
 if not info.has("states"): return Rect2(0,0,info.width,info.height)
 var state_index = maxi(0,info.states.find(state))
 var direction_index = maxi(0,DIRECTIONS.find(direction))
 var frames = {"idle":2,"walk":6,"shoot":3,"hurt":2,"dash":4,"death":6}
 var fps = {"idle":3.0,"walk":10.0,"shoot":12.0,"hurt":10.0,"dash":20.0,"death":10.0}
 var frame = int(time*fps.get(state,10.0)) % frames.get(state,6)
 if state == "death": frame = mini(5,int(time*10))
 return Rect2(frame*cell,(state_index*4+direction_index)*cell,cell,cell)
static func facing(vector: Vector2) -> String:
 if absf(vector.x)>absf(vector.y): return "right" if vector.x>=0 else "left"
 return "down" if vector.y>=0 else "up"
