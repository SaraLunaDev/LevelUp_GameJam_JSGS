extends HBoxContainer

const PRUEBA_JUEGO = preload("res://Scenes/Debug/prueba_juego.tscn")
@onready var settings_menu: Control = %SettingsMenu
@onready var transition: Node = $"../Transition/AnimationPlayer"

func _on_play_button_pressed():
	transition.play("transition")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(PRUEBA_JUEGO)

func _on_exit_button_pressed():
	get_tree().quit()

func _on_settings_button_pressed() -> void:
	settings_menu._show()
