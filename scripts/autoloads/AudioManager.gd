extends Node
class_name AudioManager

const MUSIC_TRACKS := {
	"town_day": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Gentle Breeze.ogg",
	"town_night": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Evening Harmony.ogg",
	"beach": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Floating Dream.ogg",
	"ocean_z1": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Whispering Woods.ogg",
	"ocean_z2": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Forgotten Biomes.ogg",
	"ocean_z3": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Strange Worlds.ogg",
	"ocean_z4": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Polar Lights.ogg",
	"leviathan": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Wanderers Tale.ogg",
	"shop": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Golden Gleam.ogg",
	"win": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Cuddle Clouds.ogg",
	"game_over": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Drifting Memories.ogg",
	"tutorial": "res://Assets/CozyTunes(Pro)/Audio/ogg/Tracks/Sunlight Through Leaves.ogg"
}

const SFX_TRACKS := {
	"finn_blip": "res://Assets/CozyTunes(Pro)/Audio/ogg/Sound Effects/alien remarks 3.ogg",
	"fisherman_blip": "res://Assets/CozyTunes(Pro)/Audio/ogg/Sound Effects/alien remarks 2.ogg",
	"townsfolk_blip": "res://Assets/CozyTunes(Pro)/Audio/ogg/Sound Effects/alien remarks.ogg",
	"phantom": "res://Assets/CozyTunes(Pro)/Audio/ogg/Sound Effects/phantom.ogg",
	"presencebehind": "res://Assets/CozyTunes(Pro)/Audio/ogg/Sound Effects/presence behind.ogg",
	"shadow": "res://Assets/CozyTunes(Pro)/Audio/ogg/Sound Effects/shadow.ogg",
	"stalker": "res://Assets/CozyTunes(Pro)/Audio/ogg/Sound Effects/stalker.ogg",
	"underwaterworld": "res://Assets/CozyTunes(Pro)/Audio/ogg/Sound Effects/underwater world.ogg",
	"ui_click": "res://Assets/JDSherbert-UltimateUISFXPack/Free/Mono/ogg/JDSherbert - Ultimate UI SFX Pack - Select - 1.ogg",
	"ui_hover": "res://Assets/JDSherbert-UltimateUISFXPack/Free/Mono/ogg/JDSherbert - Ultimate UI SFX Pack - Cursor - 1.ogg",
	"ui_open": "res://Assets/JDSherbert-UltimateUISFXPack/Free/Mono/ogg/JDSherbert - Ultimate UI SFX Pack - Popup Open - 1.ogg",
	"ui_close": "res://Assets/JDSherbert-UltimateUISFXPack/Free/Mono/ogg/JDSherbert - Ultimate UI SFX Pack - Popup Close - 1.ogg",
	"ui_error": "res://Assets/JDSherbert-UltimateUISFXPack/Free/Mono/ogg/JDSherbert - Ultimate UI SFX Pack - Error - 1.ogg",
	"ui_cancel": "res://Assets/JDSherbert-UltimateUISFXPack/Free/Mono/ogg/JDSherbert - Ultimate UI SFX Pack - Cancel - 1.ogg"
}

var _music_primary := AudioStreamPlayer.new()
var _music_secondary := AudioStreamPlayer.new()
var _sfx_player := AudioStreamPlayer.new()
var _music_volume := 0.7
var _sfx_volume := 0.85
var _active_primary := true
var _current_track_name := ""

func _ready() -> void:
	_music_primary.name = "MusicPrimary"
	_music_secondary.name = "MusicSecondary"
	_sfx_player.name = "SfxPlayer"
	_music_primary.bus = _resolve_bus("Music")
	_music_secondary.bus = _resolve_bus("Music")
	_sfx_player.bus = _resolve_bus("SFX")
	add_child(_music_primary)
	add_child(_music_secondary)
	add_child(_sfx_player)
	set_music_volume(_music_volume)
	set_sfx_volume(_sfx_volume)

func _resolve_bus(name: String) -> String:
	return name if AudioServer.get_bus_index(name) != -1 else "Master"

func play_music(track_name: String) -> void:
	if _current_track_name == track_name:
		return
	var path := MUSIC_TRACKS.get(track_name, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	_current_track_name = track_name
	var incoming := _music_secondary if _active_primary else _music_primary
	var outgoing := _music_primary if _active_primary else _music_secondary
	incoming.stream = load(path)
	incoming.volume_db = linear_to_db(0.001)
	incoming.play()
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(incoming, "volume_db", _linear_to_db(_music_volume), 1.5)
	tween.tween_property(outgoing, "volume_db", linear_to_db(0.001), 1.5)
	await tween.finished
	outgoing.stop()
	_active_primary = not _active_primary

func play_sfx(sfx_name: String) -> void:
	var path := SFX_TRACKS.get(sfx_name, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	_sfx_player.stream = load(path)
	_sfx_player.play()

func stop_music() -> void:
	_music_primary.stop()
	_music_secondary.stop()
	_current_track_name = ""

func set_music_volume(val: float) -> void:
	_music_volume = clamp(val, 0.0, 1.0)
	var db := _linear_to_db(_music_volume)
	_music_primary.volume_db = db if _music_primary.playing else _music_primary.volume_db
	_music_secondary.volume_db = db if _music_secondary.playing else _music_secondary.volume_db

func set_sfx_volume(val: float) -> void:
	_sfx_volume = clamp(val, 0.0, 1.0)
	_sfx_player.volume_db = _linear_to_db(_sfx_volume)

func _linear_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	return linear_to_db(value)
