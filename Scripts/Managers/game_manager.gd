extends Node
class_name GameManager

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables 
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

@export_group("Referencias de Escena")
@export var buffs_manager: Node = null
@export var palo: Node3D
@export var camara: Camera3D
@export var spawn_bolas: Area3D
@export var spawn_objetos: Area3D
@export var area_boquetes: Area3D
@export var spawn_bola_blanca: Node3D
@export var spawn_vida: Node3D
@export var bola_vida: PackedScene = null

@export_group("Labels")
@export var vida_label: Label = null
@export var puntuacion_label: Label = null
@export var puntuacion_mesh_label: MeshInstance3D = null
@export var vida_maxima_label: Label = null
@export var global_timer_label: Label = null
@export var rebotes_guiados_label: Label = null
@export var numero_objetos_label: Label = null

@export_group("Gestion de Partida")
@export var vida: int
@export var MAX_VIDA: int = 10
@export var puntuacion: int = 0
@export var pasives: Array = []

@export_group("Boquetes")
@export var boquetes: Array[Node3D] = []

@export_group("Configuración de Spawn de Bolas")
@export var bolas: Array[PackedScene] = []
@export var radio_proteccion_spawn_bola: float = 0.5
@export var cooldown_bola_spawn: float = 5.0
@export var decremento_de_cooldown_bola_spawn: float = 0.05
@export var cooldown_bola_spawn_minimo: float = 1
@export var limite_bolas: int = 5
var puede_spawnear_bola := true
var bolas_activas: Array[Node3D] = []

@export_group("Configuración de Spawn de Objetos")
@export var objetos: Array[PackedScene] = []
@export var radio_proteccion_spawn_objetos: float = 1.0
@export var cooldown_objeto_spawn: float = 5.0
@export var limite_objetos: int = 2
var puede_spawnear_objeto := true
var objetos_activos: Array[Node3D] = []
var partida_iniciada: bool = false
var global_timer_seconds: float = 0.0

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _ready() -> void:
	if not palo:
		push_error("No se ha encontrado el Palo")
		return
	if not camara:
		push_error("No se ha encontrado la Camara")
		return
	if not spawn_bolas:
		push_error("No se ha encontrado el SpawnArea de Bolas")
		return
	if not spawn_objetos:
		push_error("No se ha encontrado el SpawnArea de Objetos")

	area_boquetes.body_entered.connect(_on_area_boquetes_body_entered)

	vida = MAX_VIDA

func _process(_delta: float) -> void:
	if not partida_iniciada:
		return
	if not palo or not camara or not spawn_bolas or not spawn_objetos or not palo.palo_posicionado:
		return
	
	limpiar_listas_activas()

	await spawn_bola()
	await spawn_objeto()
	
	if cooldown_bola_spawn > 0:
		cooldown_bola_spawn -= decremento_de_cooldown_bola_spawn * _delta
		if cooldown_bola_spawn < cooldown_bola_spawn_minimo:
			cooldown_bola_spawn = cooldown_bola_spawn_minimo
	
	if global_timer_seconds >= 0:
		global_timer_seconds += _delta
		var minutes = int(floor(global_timer_seconds / 60.0))
		var seconds = int(global_timer_seconds) % 60
		global_timer_label.text = "%02d:%02d" % [minutes, seconds]
	
func _physics_process(_delta: float) -> void:
	if partida_iniciada:
		if Input.is_action_pressed("left_click"):
			palo.lanzando = true
		if Input.is_action_just_pressed("right_click"):
			palo.resetear_bola_blanca()

	if palo.bola_moviendose:
		if palo.tiempo_bola_moviendose < palo.cooldown_bola_blanca:
			palo.tiempo_bola_moviendose += _delta
		else:
			palo.bola_moviendose = false
			palo.tiempo_bola_moviendose = 0
			palo.resetear_bola_blanca()

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Gestion de Partida
# ✦•················••⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func comenzar_partida() -> void:
	partida_iniciada = true
	palo.posicionar_palo()

func terminar_partida() -> void:
	if vida <= 0:
		print("Partida terminada.")
		partida_iniciada = false
		await get_tree().create_timer(2.0).timeout
		get_tree().call_deferred("reload_current_scene")
		
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Gestion de Spawns
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func spawn_bola() -> void:
	if not partida_iniciada:
		return
	if not puede_spawnear_bola or bolas.is_empty():
		return
	if bolas_activas.size() >= limite_bolas:
		return

	puede_spawnear_bola = false

	var area_shape = spawn_bolas.get_node_or_null("CollisionShape3D")
	var extents: Vector3
	if area_shape and area_shape.shape is BoxShape3D:
		extents = area_shape.shape.extents
	else:
		extents = spawn_bolas.scale * 0.5

	var altura_fija = spawn_bolas.global_position.y

	for _i in range(20):
		var pos = Vector3(
			spawn_bolas.global_position.x + randf_range(-extents.x, extents.x),
			altura_fija,
			spawn_bolas.global_position.z + randf_range(-extents.z, extents.z)
		)
		var hay_cerca := false
		for b in bolas_activas:
			if b.global_position.distance_to(pos) < radio_proteccion_spawn_bola:
				hay_cerca = true
				break
		for bola_blanca in get_tree().get_nodes_in_group("bola_blanca"):
			if bola_blanca.global_position.distance_to(pos) < radio_proteccion_spawn_bola:
				hay_cerca = true
				break
		for objeto in objetos_activos:
			if objeto.global_position.distance_to(pos) < radio_proteccion_spawn_objetos:
				hay_cerca = true
				break
		if hay_cerca:
			continue
		if boquetes.size() == 0:
			break

		var boquetes_ordenados = boquetes.duplicate()
		boquetes_ordenados.sort_custom(func(a, b): return a.global_position.distance_to(pos) > b.global_position.distance_to(pos))

		var candidatos = boquetes_ordenados.slice(0, min(2, boquetes_ordenados.size()))
		var boquete_obj = candidatos.pick_random()
		var destino = boquete_obj.global_position

		var hay_objeto_en_trayectoria := false
		for objeto_ref in objetos_activos:
			var to_objeto = objeto_ref.global_position - pos
			var to_destino = destino - pos
			var proy = to_objeto.project(to_destino.normalized())
			var distancia_al_segmento = (to_objeto - proy).length()
			var dentro_segmento = proy.length() < to_destino.length() and proy.dot(to_destino) > 0
			if distancia_al_segmento < radio_proteccion_spawn_bola and dentro_segmento:
				hay_objeto_en_trayectoria = true
				break
		if hay_objeto_en_trayectoria:
			continue

		var bola = bolas.pick_random().instantiate()
		add_child(bola)
		bola.global_position = pos
		bolas_activas.append(bola)
		if bola.has_method("set_destino"):
			bola.set_destino(destino)
		if bola.has_method("set_bola_activa"):
			bola.set_bola_activa(true)
		break

	await get_tree().create_timer(cooldown_bola_spawn).timeout
	puede_spawnear_bola = true

func spawn_objeto() -> void:
	if not partida_iniciada:
		return
	if not puede_spawnear_objeto or objetos.is_empty():
		return
	if objetos_activos.size() >= limite_objetos:
		return

	puede_spawnear_objeto = false

	await get_tree().create_timer(cooldown_objeto_spawn).timeout
	var area_shape = spawn_objetos.get_node_or_null("CollisionShape3D")
	var extents: Vector3
	if area_shape and area_shape.shape is BoxShape3D:
		extents = area_shape.shape.extents
	else:
		extents = spawn_objetos.scale * 0.5

	var altura_fija = spawn_objetos.global_position.y

	for _i in range(20):
		var pos = Vector3(
			spawn_objetos.global_position.x + randf_range(-extents.x, extents.x),
			altura_fija,
			spawn_objetos.global_position.z + randf_range(-extents.z, extents.z)
		)
		var hay_cerca := false
		for b in bolas_activas:
			if is_instance_valid(b) and b.global_position.distance_to(pos) < max(radio_proteccion_spawn_objetos, radio_proteccion_spawn_bola):
				hay_cerca = true
				break
		for o in objetos_activos:
			if is_instance_valid(o) and o.global_position.distance_to(pos) < radio_proteccion_spawn_objetos:
				hay_cerca = true
				break
		for b in bolas_activas:
			if is_instance_valid(b) and b.global_position == pos:
				hay_cerca = true
				break

		if not hay_cerca:
			var objeto = objetos.pick_random().instantiate()
			add_child(objeto)
			objeto.global_position = pos
			objeto.rotation.y = randf_range(0, TAU)
			objetos_activos.append(objeto)
			if objeto.has_method("set_objeto_activo"):
				objeto.set_objeto_activo(true)
			break

	puede_spawnear_objeto = true

func limpiar_listas_activas() -> void:
	bolas_activas = bolas_activas.filter(func(bola): return is_instance_valid(bola))
	objetos_activos = objetos_activos.filter(func(objeto): return is_instance_valid(objeto))

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Gestion de Boquetes
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _on_area_boquetes_body_entered(_body: Node) -> void:
	if _body.is_in_group("bola"):
		if _body.has_method("suicidar_bola"):
			_body.suicidar_bola()
			if bolas_activas.has(_body):
				bolas_activas.erase(_body)

	elif _body.is_in_group("bola_blanca"):
		if _body.has_method("resetear_bola"):
			_body.resetear_bola()

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Getters y Setters
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func get_vida() -> int:
	return vida

func restar_vida(value: int) -> void:
	vida -= value
	vida_label.text = str(vida)
	if spawn_vida and bola_vida and spawn_vida.is_inside_tree():
		var bola_vida_instance = bola_vida.instantiate()
		spawn_vida.add_child(bola_vida_instance)
		bola_vida_instance.global_position = spawn_vida.global_position
		bola_vida_instance.global_rotation = spawn_vida.global_rotation
	if vida <= 0:
		terminar_partida()

func sumar_vida(value: int) -> void:
	vida += value
	if vida > MAX_VIDA:
		vida = MAX_VIDA
	vida_label.text = str(vida)
	if spawn_vida and spawn_vida.get_child_count() > 0:
		var first_child = spawn_vida.get_child(0)
		if is_instance_valid(first_child):
			first_child.queue_free()

func get_MAX_VIDA() -> int:
	return MAX_VIDA

func sumar_MAX_VIDA(value: int) -> void:
	MAX_VIDA += value
	sumar_vida(value)
	vida_maxima_label.text = str(MAX_VIDA)

func get_puntuacion() -> int:
	return puntuacion

func sumar_puntuacion(value: int) -> void:
	puntuacion += value
	puntuacion_label.text = str(puntuacion)
	# cambiar el texto del mesh si existe
	if puntuacion_mesh_label and puntuacion_mesh_label.mesh is TextMesh:
		var text_mesh := puntuacion_mesh_label.mesh as TextMesh
		text_mesh.text = str(puntuacion)
		puntuacion_mesh_label.mesh = text_mesh

func get_pasives() -> Array:
	return pasives

func set_pasives(value: Array) -> void:
	pasives = value

func set_rebotes_guiados_label(text: String) -> void:
	rebotes_guiados_label.text = text

func set_numero_objetos_label(value: int) -> void:
	numero_objetos_label.text = str(value)

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Input y Debug
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_S:
		comenzar_partida()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not palo.palo_posicionado:
			return
		if event.pressed:
			palo.lanzando = true
		else:
			if palo.lanzando and not palo.reseteando_potencia:
				await palo.resetear_potencia()
