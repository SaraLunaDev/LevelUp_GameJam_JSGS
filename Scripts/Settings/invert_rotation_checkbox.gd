extends CheckBox

func _init() -> void:
	toggled.connect(_on_toggled)
	visibility_changed.connect(_on_visibility_changed)

func _on_toggled(toggled_on:bool):
	GlobalSignals._set_inverse_rotation_setting(toggled_on)

func _on_visibility_changed():
	button_pressed = GlobalSignals._get_inverse_rotation_setting()
