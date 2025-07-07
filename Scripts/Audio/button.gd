extends Button


func _init() -> void:
	mouse_entered.connect(_on_mouse_entered)
	#focus_entered.connect(_on_focus_entered)

func _on_pressed() -> void:
	AudioManager._play_ui_accept_sound()

func _on_mouse_entered() -> void:
	AudioManager._play_ui_hover_sound()
	
func _on_focus_entered() -> void:
	AudioManager._play_ui_hover_sound()

func _on_cancel_pressed() -> void:
	AudioManager._play_ui_close_sound()

#func _on_visibility_changed() -> void:
	#if is_visible_in_tree() and GlobalSignals._is_gamepad_main_input():
		#grab_focus()
