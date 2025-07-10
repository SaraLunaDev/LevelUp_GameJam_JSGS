extends RigidBody3D

var active = false

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _ready() -> void:
	# timer de 1 segundo
	await get_tree().create_timer(1.0).timeout
	active = true

func _physics_process(_delta: float) -> void:
	var fuerza = Vector3(1, 0, 0) * 2 * mass

	if linear_velocity.x > 10:
		linear_velocity.x = 10
	else:
		apply_central_force(fuerza)

func eliminar_bola() -> void:
	self.queue_free()
