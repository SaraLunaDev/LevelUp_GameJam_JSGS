extends Node3D

@onready var chispas = $Chispas
## @onready var sonido = [añadir el objeto del audio]

func explode():
	chispas.emitting = true
## sonido.play()
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _ready() -> void:
	explode()
