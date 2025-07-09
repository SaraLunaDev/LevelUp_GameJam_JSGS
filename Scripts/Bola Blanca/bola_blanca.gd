extends RigidBody3D

var bola_activa: bool = false
signal bola_blanca_reposicionada

var daño: int = 1
@onready var bola_mesh: MeshInstance3D = $Bola
var numero_rebotes_guiados: int = 0
var numero_rebotes_guiados_maximo: int = 10
var activado_rebote_guiado: bool = false

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _process(_delta: float) -> void:
	if linear_velocity.length() > 0.1:
		bola_activa = true

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Movimiento de la Bola Blanca
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func mover_bola(direccion: Vector3, potencia_inicial: float) -> void:
	direccion.y = 0
	var fuerza = direccion * potencia_inicial
	apply_impulse(fuerza)

func mover_hacia_bola_cercana() -> void:
	if not activado_rebote_guiado:
		activado_rebote_guiado = true
	if numero_rebotes_guiados >= numero_rebotes_guiados_maximo:
		return

	var objetivos := get_tree().get_nodes_in_group("bola") + get_tree().get_nodes_in_group("objeto")
	if objetivos.is_empty():
		return

	numero_rebotes_guiados += 1
	print("Número de rebotes guiados:", numero_rebotes_guiados)

	var objetivo_cercano: RigidBody3D = null
	var distancia_minima := INF

	for obj in objetivos:
		if obj != self and obj.has_method("is_activa") and obj.is_activa():
			var distancia := global_transform.origin.distance_to(obj.global_transform.origin)
			if distancia < distancia_minima:
				distancia_minima = distancia
				objetivo_cercano = obj

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	if objetivo_cercano != null:
		objetivo_cercano.linear_velocity = Vector3.ZERO
		objetivo_cercano.angular_velocity = Vector3.ZERO

		# Posicionar la bola blanca cerca del objetivo
		var direccion := objetivo_cercano.global_transform.origin - global_transform.origin
		direccion = direccion.normalized()
		var spawn_bola_blanca = get_tree().get_first_node_in_group("spawn_bola_blanca")
		var posicion_cercana: Vector3
		if spawn_bola_blanca:
			var direccion_spawn = (spawn_bola_blanca.global_transform.origin - objetivo_cercano.global_transform.origin).normalized()
			posicion_cercana = objetivo_cercano.global_transform.origin + direccion_spawn * 0.5
		else:
			posicion_cercana = objetivo_cercano.global_transform.origin - direccion * 0.5
		posicion_cercana.y = global_transform.origin.y
		global_transform.origin = posicion_cercana

		# Aplicar el impulso hacia el objetivo
		var palos := get_tree().get_nodes_in_group("palo")
		if palos.size() > 0 and palos[0].has_method("get_potencia_maxima"):
			var potencia_inicial: float = palos[0].get_potencia_maxima()
			apply_central_impulse(direccion * potencia_inicial / 2)

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Estados de la Bola Blanca
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func resetear_bola() -> void:
	var palo = get_tree().get_nodes_in_group("palo")
	if palo.size() > 0:
		var palo_obj = palo[0]
		if not palo_obj.reseteando_bola_blanca:
			emit_signal("bola_blanca_reposicionada")

func eliminar_bola() -> void:
	queue_free()
	bola_activa = false

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Getters y Setters
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func is_bola_activa() -> bool:
	return bola_activa

func set_daño(value: int) -> void:
	daño = value

func get_daño() -> int:
	return daño

func set_transparencia(value: float) -> void:
	var material = bola_mesh.get_active_material(0)
	if material:
		material.albedo_color.a = value
		bola_mesh.set_surface_override_material(0, material)

func set_numero_rebotes_guiados(value: int) -> void:
	numero_rebotes_guiados = value

func get_numero_rebotes_guiados() -> int:
	return numero_rebotes_guiados

func set_numero_rebotes_guiados_maximo(value: int) -> void:
	numero_rebotes_guiados_maximo = value

func get_numero_rebotes_guiados_maximo() -> int:
	return numero_rebotes_guiados_maximo

func set_activado_rebote_guiado(value: bool) -> void:
	activado_rebote_guiado = value

func is_activado_rebote_guiado() -> bool:
	return activado_rebote_guiado
