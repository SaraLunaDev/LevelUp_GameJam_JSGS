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
	var game_manager = get_tree().get_nodes_in_group("game_manager")
	if game_manager.size() == 0:
		var game_manager_obj = game_manager[0]
		if game_manager_obj.has_method("get_partida_iniciada"):
			if not game_manager_obj.get_partida_iniciada():
				# reducir velocidad de la bola
				linear_velocity *= 0.9
				return

	var direccion = (destino - global_transform.origin)
	direccion.y = 0
	var fuerza = direccion.normalized() * aceleracion * mass

	if linear_velocity.length() > VELOCIDAD_MAXIMA:
		linear_velocity = linear_velocity.normalized() * VELOCIDAD_MAXIMA
	else:
		apply_central_force(fuerza)

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Estados de la Bola
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func recibir_golpe(daño: int) -> void:
	# TODO: Aplicar efectos visuales o sonoros al recibir daño
	vida -= daño
	if vida <= 0:
		eliminar_bola()

func eliminar_bola() -> void:
	aplicar_efecto()
	# TODO: Aplicar efectos visuales o sonoros al morir
	
	var game_manager = get_tree().get_nodes_in_group("game_manager")
	if game_manager.size() > 0:
		var game_manager_obj = game_manager[0]
		if game_manager_obj.has_method("sumar_puntuacion"):
			game_manager_obj.sumar_puntuacion(1)

		if game_manager_obj.has_method("get_puntuacion"):
			if game_manager_obj.get_puntuacion() % 10 == 0:
				if game_manager_obj.has_method("sumar_vida"):
					game_manager_obj.sumar_vida(1)
	
	queue_free()
	bola_activa = false

func suicidar_bola() -> void:
	var game_manager = get_tree().get_nodes_in_group("game_manager")
	if game_manager.size() > 0:
		var game_manager_obj = game_manager[0]
		if game_manager_obj.has_method("restar_vida"):
			game_manager_obj.restar_vida(1)
		
	queue_free()
	bola_activa = false

func aplicar_efecto() -> void:
	var buffs_manager = get_tree().get_nodes_in_group("buffs_manager")
	if buffs_manager.size() > 0:
		var buffs_manager_obj = buffs_manager[0]
		match tipo_bola:
			TipoBola.TIPO_1, TipoBola.TIPO_2, TipoBola.TIPO_3, TipoBola.TIPO_4, TipoBola.TIPO_5, TipoBola.TIPO_6, TipoBola.TIPO_7:
				if buffs_manager_obj.has_method("aumentar_velocidad_lanzamiento"):
					buffs_manager_obj.aumentar_velocidad_lanzamiento(buffs_manager_obj.velocidad_lanzamiento_incremento)
			TipoBola.TIPO_9, TipoBola.TIPO_10, TipoBola.TIPO_11, TipoBola.TIPO_12, TipoBola.TIPO_13, TipoBola.TIPO_14, TipoBola.TIPO_15:
				if buffs_manager_obj.has_method("aumentar_retorno_bola"):
					buffs_manager_obj.aumentar_retorno_bola(buffs_manager_obj.retorno_bola_decremento)
			TipoBola.TIPO_8:
				if buffs_manager_obj.has_method("aumentar_potencia_bola"):
					buffs_manager_obj.aumentar_potencia_bola(buffs_manager_obj.potencia_bola_incremento)

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

func get_tipo_bola() -> TipoBola:
	print("Tipo de bola:", tipo_bola)
	return tipo_bola

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Señales
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("bola_blanca"):
		body.resetear_bola()
		recibir_golpe(body.get_daño())
