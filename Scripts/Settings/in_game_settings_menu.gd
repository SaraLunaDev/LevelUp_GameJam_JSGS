extends Control

const MAIN_MENU = "res://Scenes/Game/MainMenu.tscn"

@onready var settings_panel: Panel = %SettingsPanel

var is_video_playing:bool = true
var is_open:bool = false

func _ready() -> void:
	GlobalSignals.video_started.connect(_on_video_started)
	GlobalSignals.video_skiped.connect(_on_video_ended)
	GlobalSignals.video_ended.connect(_on_video_ended)

func _unhandled_input(event: InputEvent) -> void:
	if is_video_playing:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		if !is_open:
			_show()
			is_open = true
		else:
			_on_close_button_pressed()
			is_open = false

func _show():
	AudioManager._change_audiobus_scene(AudioManager.AUDIOBUS_SCENE.PAUSE, 0.5)
	settings_panel.show()
	get_tree().paused = true
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)

func _on_close_button_pressed() -> void:
	AudioManager._change_audiobus_scene(AudioManager.AUDIOBUS_SCENE.GAME, 0.5)
	settings_panel.hide()
	get_tree().paused = false
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CONFINED_HIDDEN)

func _on_exit_to_menu_buton_pressed() -> void:
	AudioManager._fade_out_game_player(1.5)
	AudioManager._change_audiobus_scene(AudioManager.AUDIOBUS_SCENE.GAME, 1.5)
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false
	await get_tree().process_frame
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(MAIN_MENU)

func _on_video_ended():
	is_video_playing = false

func _on_video_started():
	is_video_playing = true
