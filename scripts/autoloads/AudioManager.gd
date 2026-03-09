extends Node

# AudioManager.gd - Manages music crossfade, SFX, and volume settings

var music_player: AudioStreamPlayer
var sfx_players: Array = []
var ambient_player: AudioStreamPlayer

var current_music: String = ""
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var master_volume: float = 1.0

const MAX_SFX_PLAYERS = 8

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Ambient"
	add_child(ambient_player)
	
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		sfx_players.append(player)
	
	# Set default bus volumes per GDD Section 18
	_set_bus_volume("Music", 0.70)
	_set_bus_volume("SFX", 0.85)

func _set_bus_volume(bus_name: String, linear_volume: float):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_volume))

func play_music(track_path: String, fade_duration: float = 1.5):
	if current_music == track_path:
		return
	
	var new_stream = load(track_path)
	if new_stream == null:
		return
	
	# Fade out current music
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -40.0, fade_duration)
		await tween.finished
	
	music_player.stream = new_stream
	music_player.volume_db = linear_to_db(music_volume * master_volume)
	music_player.play()
	current_music = track_path

func stop_music(fade_duration: float = 1.5):
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -40.0, fade_duration)
		await tween.finished
		music_player.stop()
		current_music = ""

func play_sfx(sfx_path: String, volume_db: float = 0.0):
	for player in sfx_players:
		if not player.playing:
			player.stream = load(sfx_path)
			player.volume_db = volume_db + linear_to_db(sfx_volume * master_volume)
			player.play()
			return player

func play_ambient(ambient_path: String, loop: bool = true):
	var stream = load(ambient_path)
	if stream:
		ambient_player.stream = stream
		ambient_player.volume_db = linear_to_db(master_volume)
		ambient_player.play()

func stop_ambient():
	ambient_player.stop()

func set_master_volume(value: float):
	master_volume = value
	_update_all_volumes()

func set_music_volume(value: float):
	music_volume = value
	if music_player.playing:
		music_player.volume_db = linear_to_db(music_volume * master_volume)

func set_sfx_volume(value: float):
	sfx_volume = value

func _update_all_volumes():
	if music_player.playing:
		music_player.volume_db = linear_to_db(music_volume * master_volume)
