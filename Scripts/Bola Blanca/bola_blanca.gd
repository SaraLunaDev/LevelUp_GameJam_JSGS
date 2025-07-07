extends RigidBody3D

var bola_activa: bool = false
signal bola_blanca_reposicionada

var daño: int = 1

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

func resetear_bola() -> void:
	#obtener el palo por grupo palo
	var palo = get_tree().get_nodes_in_group("palo")
	if palo.size() > 0:
		var palo_obj = palo[0]
		if not palo_obj.reseteando_bola_blanca:
			emit_signal("bola_blanca_reposicionada")

func eliminar_bola() -> void:
	# Eliminar la bola blanca del juego
	queue_free()
	bola_activa = false

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

func set_daño(value: int) -> void:
	daño = value

func get_daño() -> int:
	return daño
