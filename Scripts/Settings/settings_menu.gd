extends Control

@onready var settings_panel: Panel = %SettingsPanel

func _show():
	settings_panel.show()

func _on_close_button_pressed() -> void:
	settings_panel.hide()
