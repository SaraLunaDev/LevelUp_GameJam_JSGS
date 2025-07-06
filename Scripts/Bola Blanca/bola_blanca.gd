extends RigidBody3D

var bola_activa: bool = false

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _process(_delta: float) -> void:
	# Obtener actividad de la bola si ha sido golpeada
	if linear_velocity.length() > 0.1:
		bola_activa = true

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Movimiento de la Bola Blanca
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func mover_bola(direccion: Vector3, potencia_inicial: float) -> void:
	direccion.y = 0
	var fuerza = direccion * potencia_inicial
	apply_impulse(fuerza)

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Estados de la Bola Blanca
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func resetear_bola(nueva_posicion: Vector3) -> void:
	# Resetear la posicion de la bola blanca
	global_position = nueva_posicion
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	bola_activa = false

func eliminar_bola() -> void:
	# Eliminar la bola blanca del juego
	queue_free()
	bola_activa = false

# Si la bola pasa por un area3d con grupo "boquete", desactiva el rebote
func _on_boquetes_body_entered(body: Node3D) -> void:
	if body.is_in_group("bola_blanca"):
		desactivar_rebote()

# Si la bola sale del area3d con grupo "boquete", activa el rebote
func _on_boquetes_body_exited(body: Node3D) -> void:
	if body.is_in_group("bola_blanca"):
		activar_rebote()

func activar_rebote() -> void:
	# Activa la propiedad de rebote de la bola
	physics_material_override.bounce = 1

func desactivar_rebote() -> void:
	# Desactiva la propiedad de rebote de la bola
	physics_material_override.bounce = 0

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Getters y Setters
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func is_bola_activa() -> bool:
	return bola_activa
