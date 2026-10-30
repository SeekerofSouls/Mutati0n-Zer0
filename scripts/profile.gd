extends RefCounted
const PATH = "user://balanced_profile.json"
const RUN_PATH = "user://balanced_run.dat"
var memory_only = false
var memory_run: Dictionary = {}
var data = {"version":1,"unlocks":[],"kills":0,"wins":0,"runs":0,"bosses":0,"seen":[],"volume":0.65,"shake":true,"best_floor":1,"dialogue_enabled":true,"music_enabled":true}
func load_profile() -> void:
 if not FileAccess.file_exists(PATH):
  return
 var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH))
 if parsed is Dictionary and parsed.get("version",0) == 1:
  for key in data:
   if parsed.has(key) and typeof(parsed[key]) == typeof(data[key]):
	data[key] = parsed[key]
  # JSON numbers are floats; counters are explicitly normalized below.
  for key in ["kills","wins","runs","bosses","best_floor"]:
   data[key] = int(parsed.get(key,data[key]))
func save_profile() -> void:
 if memory_only: return
 var file = FileAccess.open(PATH,FileAccess.WRITE)
 if file:
  file.store_string(JSON.stringify(data,"\t"))
func unlock(id: String) -> bool:
 if id in data.unlocks:
  return false
 data.unlocks.append(id)
 save_profile()
 return true
func save_run(state: Dictionary) -> void:
 if memory_only: return
 var file = FileAccess.open(RUN_PATH,FileAccess.WRITE)
 if file:
  file.store_var(state)
func load_run() -> Dictionary:
 if memory_only: return memory_run.duplicate(true)
 if not FileAccess.file_exists(RUN_PATH):
  return {}
 var file = FileAccess.open(RUN_PATH,FileAccess.READ)
 if not file:
  return {}
 var value = file.get_var(false)
 if value is Dictionary and value.get("version",0) == 4:
  return value
 return {}
func clear_run() -> void:
 if memory_only: return
 if FileAccess.file_exists(RUN_PATH):
  DirAccess.remove_absolute(RUN_PATH)
