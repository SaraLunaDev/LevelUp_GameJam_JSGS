extends RigidBody3D

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

var bola_activa: bool = false
var aceleracion: float = 1
var VELOCIDAD_MAXIMA: float = 2
var destino: Vector3 = Vector3.ZERO

var VIDA_MAXIMA: int
var vida: int

enum TipoBola {
	TIPO_1,
	TIPO_2,
	TIPO_3,
	TIPO_4,
	TIPO_5,
	TIPO_6,
	TIPO_7,
	TIPO_8,
	TIPO_9,
	TIPO_10,
	TIPO_11,
	TIPO_12,
	TIPO_13,
	TIPO_14,
	TIPO_15
}

@export var tipo_bola: TipoBola

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _ready() -> void:
	match tipo_bola:
		TipoBola.TIPO_8:
			VIDA_MAXIMA = 2
		_:
			VIDA_MAXIMA = 1
	
	vida = VIDA_MAXIMA

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

func recibir_golpe(daño: int) -> void:
	# Reducir la vida del objeto al recibir daño
	# TODO: Aplicar efectos visuales o sonoros al recibir daño
	vida -= daño
	if vida <= 0:
		eliminar_bola()

func eliminar_bola() -> void:
	# Eliminar la bola del juego
	aplicar_efecto()
	# TODO: Aplicar efectos visuales o sonoros al morir
	# TODO: Sumar al contador de puntos
	queue_free()
	bola_activa = false

func suicidar_bola() -> void:
	queue_free()
	bola_activa = false

# en base al tipo de bola al morir deben dar una ventaja al jugador, por ahora todas van a reducir el cooldown del palo buscando por su grupo "palo"
func aplicar_efecto() -> void:
	var palo = get_tree().get_nodes_in_group("palo")
	if palo.size() > 0:
		var palo_obj = palo[0]
		match tipo_bola:
			_:
				if palo_obj.has_method("reducir_cooldown_palo"):
					palo_obj.reducir_cooldown_palo(0.1)

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
		recibir_golpe(body.get_daño())
