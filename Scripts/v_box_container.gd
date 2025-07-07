extends VBoxContainer

const PRUEBA_JUEGO = preload("res://Scenes/Debug/prueba_juego.tscn")

func _on_play_button_pressed():
	get_tree().change_scene_to_packed(PRUEBA_JUEGO) ##cambiar esto a escena final del gameplay


func _on_exit_button_pressed():
	get_tree().quit()
