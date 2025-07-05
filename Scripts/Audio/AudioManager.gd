extends Node

enum AUDIOBUS {MASTER, MUSIC_M, SFX_M, AMBIENCE_M, MUSIC, UI_SFX, GAME_SFX, AMBIENCE}

enum AUDIOBUS_SCENE {GAME, DIALOGUE, PAUSE}

@export_group("Bus")
@export var audiobus_scenes:Array[AudioBusSceneData]
var music_low_pass_filter_FX:AudioEffectLowPassFilter

@export_group("UI sounds")
@export var ui_accept_sound:AudioStream
@export var ui_hover_sound:AudioStream
@export var ui_close_sound:AudioStream

@export_group("Ball sounds")
@export var roll_sound:AudioStream
#@export var decelerate_loop_sound:AudioStream
#@export var accelerate_loop_sound:AudioStream
#@export var player_hit:AudioStream

@export_group("Ambients")
@export var bar_background_ambient:AudioStream
@export var ambient_one_shots:Array[AudioStream]

@export_group("Interactions")
@export var stick_hit_sound:AudioStream
@export var pool_side_hit_sound:AudioStream
@export var evil_ball_hit_sound:AudioStream
@export var evil_ball_missed_sound:AudioStream
@export var obstacle_hit_sound:AudioStream
@export var obstacle_destroyed_sound:AudioStream

@onready var menu_song_player: AudioStreamPlayer = %MenuSongPlayer
@onready var game_song_player: AudioStreamPlayer = %GameSongPlayer
@onready var ambience_player:AudioStreamPlayer = %AmbiencePlayer
@onready var priority_sfx_audio_player: AudioStreamPlayer = %PrioritySFXAudioPlayer
@onready var roll_sound_player: AudioStreamPlayer = %RollSoundPlayer


const MAX_SIMULTANEOUS_SFX := 6
var sfx_actives := 0
var current_audiobus_scene:AUDIOBUS_SCENE
var previous_audiobus_scene:AUDIOBUS_SCENE

func _ready() -> void:
	music_low_pass_filter_FX = AudioServer.get_bus_effect(AUDIOBUS.MUSIC, 0)

func _play_menu_music():
	menu_song_player.play()

func _play_ambience():
	ambience_player.play()

func _play_game_sfx_1D(sound:AudioStream, volume_db:float = -6.0, random_scale:float = 1.0, is_priority:bool = false, audio_player:AudioStreamPlayer = priority_sfx_audio_player):
	var player:AudioStreamPlayer
	if is_priority:
		player = audio_player
	elif sfx_actives >= MAX_SIMULTANEOUS_SFX:
		return
	else:
		sfx_actives += 1
		player = AudioStreamPlayer.new()
		add_child(player)
		player.set_bus("Game_Sfx")
	player.stream = sound
	if random_scale == 0.0:
		player.pitch_scale = 1.0
	else:
		player.pitch_scale = randf_range(0.85, 1.15) * random_scale
	player.volume_db = volume_db
	player.play()
	if !is_priority:
		await player.finished
		sfx_actives -= 1
		player.queue_free()

func _play_ui_sfx(sound:AudioStream, volume_db:float = -6.0) -> void:
	var player:AudioStreamPlayer
	player = AudioStreamPlayer.new()
	add_child(player)
	player.set_bus("UI_Sfx")
	player.stream = sound
	player.volume_db = volume_db
	player.play()
	await player.finished
	player.queue_free()

func _play_ambience_one_shot(sound:AudioStream):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = sound
	player.set_bus("Ambience")
	player.play()
	await player.finished
	player.queue_free()

func _fade_out_menu_player():
	var pre_tween_volume = menu_song_player.get_volume_db()
	var fade_out_tween = get_tree().create_tween()
	fade_out_tween.tween_property(menu_song_player, "volume_db", -48.0, 3.0)
	await fade_out_tween.finished
	menu_song_player.stop()
	menu_song_player.set_volume_db(pre_tween_volume)
	
func _fade_out_game_player(duration:float = 3.0):
	var pre_tween_volume = game_song_player.get_volume_db()
	var fade_out_tween = get_tree().create_tween()
	fade_out_tween.tween_property(game_song_player, "volume_db", -48.0, duration)
	await fade_out_tween.finished
	game_song_player.stop()
	game_song_player.set_volume_db(pre_tween_volume)

func _fade_in_game_player():
	var pre_tween_volume = game_song_player.get_volume_db()
	game_song_player.volume_db = -60.0
	var fade_in_tween = get_tree().create_tween()
	game_song_player.play()
	fade_in_tween.tween_property(game_song_player, "volume_db", pre_tween_volume, 5.0)
	await fade_in_tween.finished

func _fade_in_menu_player():
	var pre_tween_volume = menu_song_player.get_volume_db()
	menu_song_player.volume_db = -60.0
	var fade_in_tween = get_tree().create_tween()
	menu_song_player.play()
	fade_in_tween.tween_property(menu_song_player, "volume_db", pre_tween_volume, 5.0)
	await fade_in_tween.finished

func _fade_in_audio_player(audio_player:AudioStreamPlayer, fade_time:float = 3.0):
	var pre_tween_volume = audio_player.get_volume_db()
	audio_player.volume_db = -60.0
	var fade_in_tween = get_tree().create_tween()
	audio_player.play()
	fade_in_tween.tween_property(audio_player, "volume_db", pre_tween_volume, fade_time)

func _fade_out_audio_player(audio_player:AudioStreamPlayer, fade_time:float = 3.0):
	var pre_tween_volume = audio_player.get_volume_db()
	var fade_out_tween = get_tree().create_tween()
	fade_out_tween.tween_property(audio_player, "volume_db", -48.0, fade_time)
	await fade_out_tween.finished
	audio_player.stop()
	audio_player.set_volume_db(pre_tween_volume)

func _play_ui_hover_sound():
	_play_ui_sfx(ui_hover_sound)

func _play_ui_accept_sound():
	_play_ui_sfx(ui_accept_sound)

func _play_ui_close_sound():
	_play_ui_sfx(ui_close_sound)

func _play_roll_sound():
	_play_game_sfx_1D(roll_sound, -3.0, 1.0, true, roll_sound_player)

#func _play_memory_collected_sound():
	#_play_game_sfx_1D(memory_collected, -10.0)
#
#func _play_decelerate() -> void:
	#_play_game_sfx_1D(decelerate_loop_sound, -6.0, 1.0, true, move_shoot_player)

#func _stop_decelerate() -> void:
	#move_shoot_player.stop()

#func _play_accelerate() -> void:
	#_play_game_sfx_1D(accelerate_loop_sound, -9.0, 1.0, true, move_shoot_player)

#func _stop_accelerate() -> void:
	#move_shoot_player.stop()
	
#func _play_flame_gained(volume_dB:float = -6.0) -> void:
	#_play_game_sfx_1D(flame_gained, volume_dB)
#
#func _play_explosion() -> void:
	#_play_game_sfx_1D(enemy_explosion, 0.0)
#
#func _play_player_hit() -> void:
	#_play_game_sfx_1D(player_hit, 1.0)

func _set_bus_volume(bus:AUDIOBUS, new_db_volume:float) -> void:
	AudioServer.set_bus_volume_db(bus, new_db_volume)

func _set_music_volume(new_db_volume:float) -> void:
	_set_bus_volume(AUDIOBUS.MUSIC, new_db_volume)

func _set_ui_sfx_volume(new_db_volume:float) -> void:
	_set_bus_volume(AUDIOBUS.UI_SFX, new_db_volume)

func _set_game_sfx_volume(new_db_volume:float) -> void:
	_set_bus_volume(AUDIOBUS.GAME_SFX, new_db_volume)

func _set_ambience_volume(new_db_volume:float) -> void:
	_set_bus_volume(AUDIOBUS.AMBIENCE, new_db_volume)

func _set_music_low_pass_freq(new_freq:float) -> void:
	music_low_pass_filter_FX.cutoff_hz = new_freq

func _change_audiobus_scene(new_scene:AUDIOBUS_SCENE, duration:float = 0.1) -> void:
	previous_audiobus_scene = current_audiobus_scene
	current_audiobus_scene = new_scene
	var tween = create_tween().set_parallel()
	for bus in audiobus_scenes[new_scene].bus_volumes.keys():
		match bus:
			AUDIOBUS.MUSIC:
				tween.tween_method(_set_music_volume, audiobus_scenes[previous_audiobus_scene].bus_volumes[bus], audiobus_scenes[new_scene].bus_volumes[bus], duration)
			AUDIOBUS.UI_SFX:
				tween.tween_method(_set_ui_sfx_volume, audiobus_scenes[previous_audiobus_scene].bus_volumes[bus], audiobus_scenes[new_scene].bus_volumes[bus], duration)
			AUDIOBUS.GAME_SFX:
				tween.tween_method(_set_game_sfx_volume, audiobus_scenes[previous_audiobus_scene].bus_volumes[bus], audiobus_scenes[new_scene].bus_volumes[bus], duration)
			AUDIOBUS.AMBIENCE:
				tween.tween_method(_set_ambience_volume, audiobus_scenes[previous_audiobus_scene].bus_volumes[bus], audiobus_scenes[new_scene].bus_volumes[bus], duration)
	if audiobus_scenes[new_scene].music_low_pass:
		tween.tween_method(_set_music_low_pass_freq, audiobus_scenes[previous_audiobus_scene].low_pass_freq, audiobus_scenes[new_scene].low_pass_freq, duration)
	else:
		tween.tween_method(_set_music_low_pass_freq, audiobus_scenes[previous_audiobus_scene].low_pass_freq, 20000.0, duration)

func _revert_previous_audiobus_scene() -> void:
	_change_audiobus_scene(previous_audiobus_scene)
