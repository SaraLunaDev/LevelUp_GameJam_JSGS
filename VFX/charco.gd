extends MeshInstance3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("bola") and body.has_method("limitar_velocidad"):
		body.limitar_velocidad()

func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()
