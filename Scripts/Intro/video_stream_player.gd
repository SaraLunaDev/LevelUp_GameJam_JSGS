extends VideoStreamPlayer

@export var game_manager: Node

func _on_finished() -> void:
	if game_manager.has_method("comenzar_partida"):
		game_manager.comenzar_partida()
		if get_tree().has_group("camera_manager"):
			var camera_managers = get_tree().get_nodes_in_group("camera_manager")
			if camera_managers.size() > 0:
				var camera_manager = camera_managers[0]
				if camera_manager.has_method("set_camera_base"):
					camera_manager.set_camera_base()
	queue_free()
