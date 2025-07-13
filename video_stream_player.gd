extends VideoStreamPlayer

@onready var bton_skip: Control = $BtonSkip
@onready var transition: Node = $"../../Transition/AnimationPlayer"

func _ready() -> void:
	transition.get_parent().get_node("Control/ColorRect").color.a = 255
	transition.play("transition_out")
	await get_tree().create_timer(0.5).timeout
	GlobalSignals.video_started.emit()
	bton_skip.visible = true
	await get_tree().create_timer(4).timeout
	bton_skip.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		terminar_outro()
		GlobalSignals.video_skiped.emit()

func _on_finished() -> void:
	terminar_outro()
	GlobalSignals.video_ended.emit()

func terminar_outro():
	transition.play("transition")
	await get_tree().create_timer(0.5).timeout
	AudioManager._fade_out_game_player(1.5)
	AudioManager._change_audiobus_scene(AudioManager.AUDIOBUS_SCENE.GAME, 1.5)
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false
	await get_tree().process_frame
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://Scenes/Game/MainMenu.tscn")
