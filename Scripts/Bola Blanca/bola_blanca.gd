extends RigidBody3D

var bola_activa: bool = false
signal bola_blanca_reposicionada

var daño: int = 1
@onready var bola_mesh: MeshInstance3D = $Bola
var numero_rebotes_guiados: int = 0
var numero_rebotes_guiados_maximo: int = 0
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

var ultimo_objetivo_cercano: RigidBody3D = null

func mover_hacia_objetivo_cercano() -> void:
	if not activado_rebote_guiado:
		activado_rebote_guiado = true
	print("Intentando mover hacia el objetivo cercano")
	if numero_rebotes_guiados >= numero_rebotes_guiados_maximo:
		return
	# me voy
	var objetivos := get_tree().get_nodes_in_group("bola") + get_tree().get_nodes_in_group("objeto")
	if objetivos.is_empty():
		return
	# a pegar
	var distancias := []
	for obj in objetivos:
		if obj != self and obj.has_method("is_activa") and obj.is_activa():
			var distancia := global_transform.origin.distance_to(obj.global_transform.origin)
			distancias.append({"obj": obj, "dist": distancia})
	# un tiro
	if distancias.size() < 2:
		return
	distancias.sort_custom(func(a, b): return a["dist"] < b["dist"])
	# entre ceja y ceja
	var objetivo_cercano: RigidBody3D = null
	for i in range(1, distancias.size()):
		var candidato = distancias[i]["obj"]
		if candidato != ultimo_objetivo_cercano:
			objetivo_cercano = candidato
			break
	# y todos
	if objetivo_cercano == null:
		return
	# sereis culpables
	ultimo_objetivo_cercano = objetivo_cercano
	# os jodeis
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	if objetivo_cercano != null:
		objetivo_cercano.linear_velocity = Vector3.ZERO
		objetivo_cercano.angular_velocity = Vector3.ZERO
		var direccion := objetivo_cercano.global_transform.origin - global_transform.origin
		direccion = direccion.normalized()
		direccion.y = 0
		var palos := get_tree().get_nodes_in_group("palo")
		if palos.size() > 0 and palos[0].has_method("get_potencia_maxima"):
			var potencia_inicial: float = palos[0].get_potencia_maxima()
			mover_bola(direccion, potencia_inicial / 2)
			numero_rebotes_guiados += 1
			var game_manager = get_tree().get_nodes_in_group("game_manager")
			if game_manager.size() > 0:
				var game_manager_obj = game_manager[0]
				if game_manager_obj.has_method("set_rebotes_guiados_label"):
					game_manager_obj.set_rebotes_guiados_label(str(numero_rebotes_guiados))
	
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("bola") or body.is_in_group("objeto"):
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

func set_numero_rebotes_guiados_maximo(value: int) -> void:
	numero_rebotes_guiados_maximo = value

func get_numero_rebotes_guiados_maximo() -> int:
	return numero_rebotes_guiados_maximo

func set_activado_rebote_guiado(value: bool) -> void:
	activado_rebote_guiado = value

func is_activado_rebote_guiado() -> bool:
	return activado_rebote_guiado
