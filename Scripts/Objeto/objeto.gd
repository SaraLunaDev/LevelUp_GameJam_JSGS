extends RigidBody3D

var MAX_HEALTH: float = 1
var health

enum tipo_objeto {
	CERVEZA
}
var tipo: tipo_objeto = tipo_objeto.CERVEZA

func _ready() -> void:
	health = MAX_HEALTH
	contact_monitor = true

func _physics_process(_delta: float) -> void:
	var bodies = get_colliding_bodies()
	for body in bodies:
		if body.is_in_group("bola_blanca"):
			recibir_golpe(1)

func recibir_golpe(damage: float) -> void:
	health -= damage
	if health <= 0:
		destruir_objeto()

func destruir_objeto():
	queue_free()
