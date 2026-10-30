extends RefCounted
# Silent text system. Portrait paths, dialogue lines and timing are data-driven.
var data: Dictionary = {}
var active: Dictionary = {}
var queue: Array = []
var quiet = 0.0
var enabled = true
func _init() -> void:
 var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://assets/dialogue/dialogue_de.json"))
 if parsed is Dictionary: data = parsed
func reset() -> void:
 active = {}
 queue.clear()
 quiet = 0
func say(speaker: String,name: String,text: String,emotion: String="neutral",important: bool=false,modal: bool=false,duration: float=0) -> bool:
 if not enabled and not modal: return false
 if not important and (quiet>0 or not active.is_empty()): return false
 var seconds = duration if duration>0 else clampf(text.length()/float(data.get("letters_per_second",42))+2.2,3.2,7.5)
 var line = {"speaker":speaker,"name":name,"text":text,"emotion":emotion,"modal":modal,"time":0.0,"duration":seconds}
 if modal:
  active = line
 elif important and not active.is_empty():
  if queue.size()<3: queue.append(line)
 else:
  active = line
 quiet = float(data.get("ambient_cooldown",18.0))
 return true
func step(dt: float) -> void:
 quiet = maxf(0,quiet-dt)
 if active.is_empty(): return
 active.time += dt
 if active.time>=active.duration: advance()
func advance() -> void:
 active = queue.pop_front() if not queue.is_empty() else {}
func blocks_combat() -> bool:
 return not active.is_empty() and active.modal
func visible_text() -> String:
 if active.is_empty(): return ""
 var letters = int(active.time*float(data.get("letters_per_second",42)))
 return active.text.substr(0,letters)
func choice(lines: Array,rng: RandomNumberGenerator) -> String:
 return "" if lines.is_empty() else str(lines[rng.randi_range(0,lines.size()-1)])
