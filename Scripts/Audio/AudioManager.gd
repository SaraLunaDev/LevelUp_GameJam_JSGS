extends Node

# Tipos de buses de audio
enum AUDIOBUS {MASTER, MUSIC_M, SFX_M, AMBIENCE_M, MUSIC, UI_SFX, GAME_SFX, AMBIENCE}

# Tipos de escenas de audio
enum AUDIOBUS_SCENE {GAME, VIDEO, PAUSE}

# Variables de buses
@export_group("Bus")
@export var audiobus_scenes:Array[AudioBusSceneData]
var music_low_pass_filter_FX:AudioEffectLowPassFilter

# Biblioteca de sonidos
@export_group("")
@export var sfx_test_sound:AudioStream

@export_group("UI sounds")
@export var ui_accept_sound:AudioStream
@export var ui_hover_sound:AudioStream
@export var ui_close_sound:AudioStream
@export var ui_start_game:AudioStream

@export_group("Ambients")
@export var bar_background_ambient:AudioStream
@export var ambient_one_shots:Array[AudioStream]

@export_group("Interaction sounds")
@export var stick_ball_sounds:Array[AudioStream]
@export var ball_side_sounds:Array[AudioStream]
@export var ball_ball_sounds:Array[AudioStream]
@export var ball_table_sounds:Array[AudioStream]
@export var ball_missed_sounds:Array[AudioStream]
@export var obstacle_hit_sounds:Array[AudioStream]
@export var obstacle_destroyed_sounds:Array[AudioStream]

@export_group("Game sounds")
@export var choose_passive_sound:AudioStream
@export var passive_choosed_sound:AudioStream
@export var ball_missed_sound:AudioStream
@export var ball_point_sound:AudioStream

# Reproductores de audio cacheados
@onready var menu_song_player: AudioStreamPlayer = %MenuSongPlayer
@onready var game_song_player: AudioStreamPlayer = %GameSongPlayer
@onready var ambience_player:AudioStreamPlayer = %AmbiencePlayer
@onready var priority_sfx_audio_player: AudioStreamPlayer = %PrioritySFXAudioPlayer
@onready var priority_sfx_audio_player_3d: AudioStreamPlayer3D = %PrioritySFXAudioPlayer3D

# Control de sfx simultáneos
const MAX_SIMULTANEOUS_SFX := 6
var sfx_actives := 0

# Control de escenas de audio
var current_audiobus_scene:AUDIOBUS_SCENE = AUDIOBUS_SCENE.GAME
var previous_audiobus_scene:AUDIOBUS_SCENE

var random_generator := RandomNumberGenerator.new()

func _ready() -> void:
	music_low_pass_filter_FX = AudioServer.get_bus_effect(AUDIOBUS.MUSIC, 0)

func _play_menu_music():
	menu_song_player.play()

func _play_game_music():
	game_song_player.play()

func _play_ambience():
	ambience_player.play()

# Reproducir sonido sfx (sonidos no localizados)
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

# Reproducir sonido sfx con localización 3D (cercanía y izq / der)
func _play_game_sfx_3D(sound:AudioStream, sound_position:Vector3, volume_db:float = -6.0, random_scale:float = 1.0, is_priority:bool = false, audio_player_3d:AudioStreamPlayer3D = priority_sfx_audio_player_3d):
	var player_3d:AudioStreamPlayer3D
	if is_priority:
		player_3d = audio_player_3d
	elif sfx_actives >= MAX_SIMULTANEOUS_SFX:
		return
	else:
		sfx_actives += 1
		player_3d = AudioStreamPlayer3D.new()
		add_child(player_3d)
		player_3d.set_bus("Game_Sfx")
	player_3d.stream = sound
	player_3d.position = sound_position
	if random_scale == 0.0:
		player_3d.pitch_scale = 1.0
	else:
		player_3d.pitch_scale = randf_range(0.85, 1.15) * random_scale
	player_3d.volume_db = volume_db
	player_3d.play()
	if !is_priority:
		await player_3d.finished
		sfx_actives -= 1
		player_3d.queue_free()

# Reproducir sonido de UI
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

# Reproducir sonido ambiente puntual (sonidos no localizados)
func _play_ambience_one_shot_1D(sound:AudioStream):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = sound
	player.set_bus("Ambience")
	player.play()
	await player.finished
	player.queue_free()

# Reproducir sonido ambiente puntual con localización 3D (cercanía y izq / der)
func _play_ambience_one_shot_3D(sound:AudioStream, sound_position:Vector3):
	var player_3d = AudioStreamPlayer3D.new()
	add_child(player_3d)
	player_3d.stream = sound
	player_3d.global_position = sound_position
	player_3d.set_bus("Ambience")
	player_3d.play()
	await player_3d.finished
	player_3d.queue_free()

# Fundido de un reproductor de audio desde silencio a volumen predeterminado (duración predeterminada 3 segundos)
func _fade_in_audio_player(audio_player:AudioStreamPlayer, fade_time:float = 3.0):
	var pre_tween_volume = audio_player.get_volume_db()
	audio_player.volume_db = -60.0
	var fade_in_tween = get_tree().create_tween()
	audio_player.play()
	fade_in_tween.tween_property(audio_player, "volume_db", pre_tween_volume, fade_time)

# Fundido de un reproductor de audio a silencio (duración predeterminada 3 segundos)
func _fade_out_audio_player(audio_player:AudioStreamPlayer, fade_time:float = 3.0):
	var pre_tween_volume = audio_player.get_volume_db()
	var fade_out_tween = get_tree().create_tween()
	fade_out_tween.tween_property(audio_player, "volume_db", -48.0, fade_time)
	await fade_out_tween.finished
	audio_player.stop()
	audio_player.set_volume_db(pre_tween_volume)

# ---------- PUBLIC PLAY FUNCTIONS

func _play_sfx_test_audio():
	_play_game_sfx_1D(sfx_test_sound)

func _play_ui_hover_sound():
	_play_ui_sfx(ui_hover_sound)

func _play_ui_accept_sound():
	_play_ui_sfx(ui_accept_sound)

func _play_ui_close_sound():
	_play_ui_sfx(ui_close_sound)

func _play_ui_start_sound():
	_play_ui_sfx(ui_start_game)

func _play_stick_ball_sound(sound_position:Vector3, sound_volume_db:float, pitch_variation_scale:float = 1.0):
	var rnd_index = random_generator.randi_range(0 , stick_ball_sounds.size()-1)
	_play_game_sfx_3D(stick_ball_sounds[rnd_index], sound_position, sound_volume_db, pitch_variation_scale)

func _play_ball_ball_sound(sound_position:Vector3, sound_volume_db:float, pitch_variation_scale:float = 1.0):
	var rnd_index = random_generator.randi_range(0 , ball_ball_sounds.size()-1)
	_play_game_sfx_3D(ball_ball_sounds[rnd_index], sound_position, sound_volume_db, pitch_variation_scale)

func _play_ball_table_sound(sound_position:Vector3, sound_volume_db:float, pitch_variation_scale:float = 1.0):
	var rnd_index = random_generator.randi_range(0 , ball_table_sounds.size()-1)
	_play_game_sfx_3D(ball_table_sounds[rnd_index], sound_position, sound_volume_db, pitch_variation_scale)

func _play_ball_side_sound(sound_position:Vector3, sound_volume_db:float, pitch_variation_scale:float = 1.0):
	var rnd_index = random_generator.randi_range(0 , ball_side_sounds.size()-1)
	_play_game_sfx_3D(ball_side_sounds[rnd_index], sound_position, sound_volume_db, pitch_variation_scale)

func _play_ball_point_sound():
	_play_game_sfx_1D(ball_point_sound, -3.0, 0.0, true)

func _play_choose_passive_sound():
	_play_game_sfx_1D(choose_passive_sound, -3.0, 0.0, true)

func _play_passive_choosed_sound():
	_play_game_sfx_1D(passive_choosed_sound, -3.0, 0.0, true)

func _play_ball_missed_sound():
	_play_game_sfx_1D(ball_missed_sound, -6.0, 0.0, true)

## Fundido de la música de menú a silencio (duración predeterminada 3 segundos)
func _fade_out_menu_player(duration:float = 3.0):
	_fade_out_audio_player(menu_song_player, duration)

## Fundido de la música de juego a silencio(duración predeterminada 3 segundos)
func _fade_out_game_player(duration:float = 3.0):
	_fade_out_audio_player(game_song_player, duration)

## Fundido del ambiente general a silencio(duración predeterminada 3 segundos)
func _fade_out_ambient_player(duration:float = 3.0):
	_fade_out_audio_player(ambience_player, duration)

## Fundido de la música de juego desde silencio a volumen predeterminado (duración predeterminada 3 segundos)
func _fade_in_game_player(duration:float = 3.0):
	_fade_in_audio_player(game_song_player, duration)

## Fundido de la música de menú desde silencio a volumen predeterminado (duración predeterminada 3 segundos)
func _fade_in_menu_player(duration:float = 3.0):
	_fade_in_audio_player(menu_song_player, duration)

## Fundido del ambiente general desde silencio a volumen predeterminado (duración predeterminada 3 segundos)
func _fade_in_ambient_player(duration:float = 3.0):
	_fade_in_audio_player(ambience_player, duration)

# ---------------------------------------

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

# Cambiar escena de audio
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
