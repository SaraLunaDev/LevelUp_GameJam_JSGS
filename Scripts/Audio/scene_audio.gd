extends Node

@export var scene_song: SONG
@export var video:VideoStreamPlayer
@export var holes_area:Area3D

enum SONG {MENU, GAME}

var is_intro_video_skiped:bool = false

func _ready() -> void:
	match scene_song:
		SONG.MENU:
			AudioManager._play_menu_music()
		SONG.GAME:
			_connect_signals()
			if video:
				video.finished.connect(_on_video_finished)
				await get_tree().create_timer(24.2).timeout
				if !is_intro_video_skiped:
					AudioManager._fade_out_menu_player()
					AudioManager._change_audiobus_scene(AudioManager.AUDIOBUS_SCENE.GAME, 3.0)

func _connect_signals():
	GlobalSignals.choosing_passive.connect(_on_choosing_passive)
	GlobalSignals.passive_choosed.connect(_on_passive_choosed)
	GlobalSignals.video_skiped.connect(_on_video_skiped)
	holes_area.body_entered.connect(_on_holes_area_body_entered)

func _on_video_skiped():
	is_intro_video_skiped = true
	AudioManager._fade_out_menu_player()
	AudioManager._change_audiobus_scene(AudioManager.AUDIOBUS_SCENE.GAME, 3.0)
	_on_video_finished()

func _on_video_finished():
	AudioManager._fade_in_game_player()
	AudioManager._fade_in_ambient_player()

func _on_choosing_passive():
	AudioManager._play_choose_passive_sound()
	AudioManager._change_audiobus_scene(AudioManager.AUDIOBUS_SCENE.PAUSE, 0.5)
	
func _on_passive_choosed():
	AudioManager._change_audiobus_scene(AudioManager.AUDIOBUS_SCENE.GAME, 0.5)
	AudioManager._play_passive_choosed_sound()

func _on_holes_area_body_entered(body:RigidBody3D):
	if body.is_in_group("bola"):
		AudioManager._play_ball_missed_sound()
