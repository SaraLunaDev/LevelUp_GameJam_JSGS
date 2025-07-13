extends Node3D

@onready var chispas = $Chispas
@onready var humo = $Humo
@onready var fuego = $Fuego
## @onready var sonido = [añadir el objeto del audio]

func explode():
	chispas.emitting = true
	humo.emitting = true
	fuego.emitting = true
## sonido.play()
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _ready() -> void:
	explode()
