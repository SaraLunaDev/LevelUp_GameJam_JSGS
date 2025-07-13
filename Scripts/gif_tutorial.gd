extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_tutorial():
	animation_player.play("new_animation")
	await get_tree().create_timer(6).timeout
	queue_free()
