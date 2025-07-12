extends Button

@export var button_type:BUTTON_TYPE

enum BUTTON_TYPE {IN, OUT, START}

func _init() -> void:
	mouse_entered.connect(_on_mouse_entered)
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	match button_type:
		BUTTON_TYPE.IN:
			AudioManager._play_ui_accept_sound()
		BUTTON_TYPE.OUT:
			AudioManager._play_ui_close_sound()
		BUTTON_TYPE.START:
			AudioManager._play_ui_accept_sound()
			AudioManager._play_ui_start_sound()
			AudioManager._change_audiobus_scene(AudioManager.AUDIOBUS_SCENE.VIDEO, 2.0)
			AudioManager._fade_in_ambient_player(2.0)
			
func _on_mouse_entered() -> void:
	AudioManager._play_ui_hover_sound()
