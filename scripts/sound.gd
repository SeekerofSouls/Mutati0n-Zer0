extends Node
# Replace WAV/OGG files or edit audio_config.json. No combat code changes needed.
var voices: Array = []
var clips: Dictionary = {}
var config: Dictionary = {}
var volume = 0.65
var music: AudioStreamPlayer
var music_key = ""
var music_enabled = true
var testing_silent = false
func _ready() -> void:
 var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/audio_config.json"))
 if parsed is Dictionary: config = parsed
 for i in range(20):
  var voice = AudioStreamPlayer.new()
  add_child(voice)
  voices.append(voice)
 for id in config.get("effects",{}):
  var path = config.effects[id].path
  if ResourceLoader.exists(path): clips[id] = load(path)
 music = AudioStreamPlayer.new()
 add_child(music)
 music.finished.connect(func(): music.play())
 set_music("menu")
func set_music(key: String) -> void:
 if key == music_key: return
 music_key = key
 music.stop()
 if testing_silent: return
 var info = config.get("music",{}).get(key,{})
 if info.is_empty() or not ResourceLoader.exists(info.path): return
 music.stream = load(info.path)
 music.play()
func play(id: String) -> void:
 if testing_silent or volume<=0 or not clips.has(id): return
 var settings = config.get("effects",{}).get(id,{})
 for voice in voices:
  if not voice.playing:
   voice.stream = clips[id]
   voice.volume_db = linear_to_db(maxf(0.001,volume*settings.get("volume",0.65)))
   var jitter = float(config.get("pitch_randomness",0.04))
   voice.pitch_scale = randf_range(1-jitter,1+jitter)
   voice.play()
   return
func _process(_dt: float) -> void:
 if music:
  var settings = config.get("music",{}).get(music_key,{})
  music.volume_db = linear_to_db(maxf(0.001,volume*float(config.get("music_volume",0.35))*float(settings.get("volume",1.0))))
  music.stream_paused = volume<=0 or not music_enabled

func stop_all() -> void:
 if music:
  music.stop()
  music.stream = null
 for voice in voices:
  voice.stop()
  voice.stream = null
 clips.clear()

func _exit_tree() -> void:
 stop_all()
