extends HSlider

# Script para slider de audio en los menús

@export var bus:AudioManager.AUDIOBUS

func _init() -> void:
	focus_entered.connect(_on_focus_entered)
	mouse_entered.connect(_on_mouse_entered)
	drag_started.connect(_on_drag_started)

func _on_value_changed(value: float) -> void:
	AudioManager._set_bus_volume(bus, linear_to_db(value))

func _on_visibility_changed() -> void:
	if (self.is_visible_in_tree()):
		value = AudioServer.get_bus_volume_linear(bus)

func _on_focus_entered() -> void:
	AudioManager._play_ui_hover_sound()

func _on_mouse_entered() -> void:
	AudioManager._play_ui_hover_sound()

func _on_drag_started() -> void:
	if bus == AudioManager.AUDIOBUS.SFX_M:
		AudioManager._play_test_audio()
