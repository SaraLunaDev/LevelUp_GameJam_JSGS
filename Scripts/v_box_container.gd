extends VBoxContainer

const PRUEBA_JUEGO = preload("res://Scenes/Debug/prueba_juego.tscn")
@onready var transition = $"../Transition/AnimationPlayer"

func _on_play_button_pressed():
	transition.play("transition")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_packed(PRUEBA_JUEGO)

func _on_exit_button_pressed():
	get_tree().quit()
