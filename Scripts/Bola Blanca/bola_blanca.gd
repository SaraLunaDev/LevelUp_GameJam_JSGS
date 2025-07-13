extends RigidBody3D

var bola_activa: bool = false
signal bola_blanca_reposicionada

var daño: int = 1
@onready var bola_mesh: MeshInstance3D = $Bola
var numero_rebotes_guiados: int = 0
var activado_rebote_guiado: bool = false
var buffs_manager: Node = null

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _ready() -> void:
	var buffs_managers = get_tree().get_nodes_in_group("buffs_manager")
	if buffs_managers.size() > 0:
		buffs_manager = buffs_managers[0]
		
func _process(_delta: float) -> void:
	if linear_velocity.length() > 0.1:
		bola_activa = true

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Movimiento de la Bola Blanca
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func mover_bola(direccion: Vector3, potencia_inicial: float) -> void:
	freeze = false
	direccion.y = 0
	var fuerza = direccion * potencia_inicial
	apply_impulse(fuerza)

var ultimo_objetivo_cercano: RigidBody3D = null
var rebote_queue: Array = []

func _physics_process(_delta: float) -> void:
	var activos := []
	var objetivos := []
	objetivos += get_tree().get_nodes_in_group("bola")
	objetivos += get_tree().get_nodes_in_group("objeto")
	for obj in objetivos:
		if obj != self and obj.has_method("is_activa") and obj.is_activa():
			activos.append(obj)

func mover_hacia_objetivo_cercano() -> void:
	if not activado_rebote_guiado:
		activado_rebote_guiado = true
	if numero_rebotes_guiados >= buffs_manager.get_numero_rebotes_guiados():
		var camera_manager_reset = get_tree().get_first_node_in_group("camera_manager")
		camera_manager_reset.fov_zoom_reset()
		return

	var camera_manager = get_tree().get_first_node_in_group("camera_manager")
	camera_manager.fov_zoom(numero_rebotes_guiados * 0.1, 0.2)

	var objetivos := []
	objetivos += get_tree().get_nodes_in_group("bola")
	objetivos += get_tree().get_nodes_in_group("objeto")
	if objetivos.is_empty():
		return

	var distancias := []
	for obj in objetivos:
		if obj != self and obj.has_method("is_activa") and obj.is_activa():
			distancias.append({"obj": obj, "dist": global_transform.origin.distance_to(obj.global_transform.origin)})

	if distancias.size() < 2:
		return

	distancias.sort_custom(func(a, b): return a["dist"] < b["dist"])

	var objetivo_cercano: RigidBody3D = null
	for i in range(1, distancias.size()):
		var candidato = distancias[i]["obj"]
		if candidato != ultimo_objetivo_cercano:
			objetivo_cercano = candidato
			break

	if objetivo_cercano == null:
		return

	rebote_queue.append(objetivo_cercano)
	_process_rebote_queue()

func _process_rebote_queue() -> void:
	if rebote_queue.is_empty():
		return
	if numero_rebotes_guiados >= buffs_manager.get_numero_rebotes_guiados():
		rebote_queue.clear()
		return

	var objetivo_cercano = rebote_queue.pop_front()
	ultimo_objetivo_cercano = objetivo_cercano

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	if objetivo_cercano:
		objetivo_cercano.linear_velocity = Vector3.ZERO
		objetivo_cercano.angular_velocity = Vector3.ZERO
		var direccion: Vector3 = (objetivo_cercano.global_transform.origin - global_transform.origin).normalized()
		direccion.y = 0
		var palos := get_tree().get_nodes_in_group("palo")
		if palos.size() > 0 and palos[0].has_method("get_potencia_maxima"):
			var potencia_inicial: float = palos[0].get_potencia_maxima()
			mover_bola(direccion, potencia_inicial / 2)
			numero_rebotes_guiados += 1
			var game_manager = get_tree().get_nodes_in_group("game_manager")
			if game_manager.size() > 0 and game_manager[0].has_method("set_rebotes_guiados_label"):
				game_manager[0].set_rebotes_guiados_label(str(numero_rebotes_guiados))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("bola") or body.is_in_group("objeto"):
		if body.has_method("recibir_golpe"):
			var camera_manager = get_tree().get_first_node_in_group("camera_manager")
			camera_manager.shake_camera(0.01, 0.1)
			body.recibir_golpe(daño)
		mover_hacia_objetivo_cercano()

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

func set_activado_rebote_guiado(value: bool) -> void:
	activado_rebote_guiado = value

func is_activado_rebote_guiado() -> bool:
	return activado_rebote_guiado
