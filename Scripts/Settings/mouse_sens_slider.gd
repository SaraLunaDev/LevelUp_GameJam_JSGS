extends HSlider

func _init() -> void:
	mouse_entered.connect(_on_mouse_entered)
	visibility_changed.connect(_on_visibility_changed)
	value_changed.connect(_on_value_changed)

func _on_value_changed(new_value:float):
	GlobalSignals._set_mouse_sens_factor(new_value)

func _on_visibility_changed() -> void:
	if (self.is_visible_in_tree()):
		value = GlobalSignals._get_mouse_sens_factor()

func _on_mouse_entered() -> void:
	AudioManager._play_ui_hover_sound()
