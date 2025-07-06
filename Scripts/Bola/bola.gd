extends RigidBody3D

var bola_activa: bool = false
var aceleracion: float = 0.1
var VELOCIDAD_MAXIMA: float = 2
var destino: Vector3 = Vector3.ZERO
var game_manager: GameManager

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _physics_process(_delta: float) -> void:
	if not bola_activa:
		return

	var direccion = (destino - global_transform.origin)
	direccion.y = 0
	var fuerza = direccion.normalized() * aceleracion * mass

	# Limitar la velocidad maxima
	if linear_velocity.length() > VELOCIDAD_MAXIMA:
		linear_velocity = linear_velocity.normalized() * VELOCIDAD_MAXIMA
	else:
		apply_central_force(fuerza)

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Estados de la Bola
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func eliminar_bola() -> void:
	# Eliminar la bola del juego
	queue_free()
	bola_activa = false

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Setters y Getters
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func set_direccion(direccion: Vector3) -> void:
	destino = global_transform.origin + direccion

func set_bola_activa(value: bool) -> void:
	bola_activa = value

func is_bola_activa() -> bool:
	return bola_activa

func set_aceleracion(value: float) -> void:
	aceleracion = value

func get_aceleracion() -> float:
	return aceleracion

func set_velocidad_maxima(value: float) -> void:
	VELOCIDAD_MAXIMA = value

func get_velocidad_maxima() -> float:
	return VELOCIDAD_MAXIMA

func set_destino(value: Vector3) -> void:
	destino = value

func get_destino() -> Vector3:
	return destino

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Señales
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("bola_blanca"):
		body.resetear_bola()
		body.freeze = true
		eliminar_bola()
