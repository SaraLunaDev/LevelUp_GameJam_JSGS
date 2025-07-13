extends VideoStreamPlayer

@export var game_manager: Node
@onready var bton_skip: Control = $BtonSkip

func _ready() -> void:
	GlobalSignals.video_started.emit()
	bton_skip.visible = true
	await get_tree().create_timer(4).timeout
	bton_skip.visible = false

func _on_finished() -> void:
	terminar_intro()
	GlobalSignals.video_ended.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		terminar_intro()
		GlobalSignals.video_skiped.emit()

func terminar_intro():
	if game_manager.has_method("comenzar_partida"):
		game_manager.comenzar_partida()
		if get_tree().has_group("camera_manager"):
			var camera_managers = get_tree().get_nodes_in_group("camera_manager")
			if camera_managers.size() > 0:
				var camera_manager = camera_managers[0]
				if camera_manager.has_method("set_camera_base"):
					camera_manager.set_camera_base()
	queue_free()
