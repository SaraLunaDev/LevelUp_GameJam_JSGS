extends Node

@export var scene_song: SONG

enum SONG {MENU, GAME}

func _ready() -> void:
	match scene_song:
		SONG.MENU:
			AudioManager._play_menu_music()
		SONG.GAME:
			AudioManager._fade_in_game_player()
			AudioManager._fade_in_ambient_player()
