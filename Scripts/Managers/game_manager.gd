extends Node
class_name GameManager

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables 
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

# Variables Exportadas

@export_group("Referencias de Escena")
@export var palo: Node3D
@export var camara: Camera3D
@export var spawn_area: Area3D
@export var area_boquetes: Area3D
@export var spawn_bola_blanca: Node3D

@export_group("Boquetes y Bolas")
@export var boquetes: Array[Node3D] = []
@export var bolas: Array[PackedScene] = []
@export var bolas_objetos_activos: Array = []

@export_group("Configuración de Spawn de Bolas")
@export var radio_proteccion_spawn: float = 1.0
@export var cooldown_bola_spawn: float = 5.0
@export var limite_bolas: int = 10

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
	if not spawn_area:
		push_error("No se ha encontrado el SpawnArea")
		return

	area_boquetes.body_entered.connect(_on_area_boquetes_body_entered)
	area_boquetes.body_exited.connect(_on_area_boquetes_body_exited)

func _process(_delta: float) -> void:
	if not palo or not camara or not spawn_area or not palo.palo_posicionado:
		return
	# Spawnear bolas enemigas
	await spawn_bola()
	
	if bolas_objetos_activos.size() > 0:
		# Actualizar las posiciones de las bolas activas
		actualizar_bolas_activos()

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Gestion de Partida
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func comenzar_partida() -> void:
	# Iniciar el Palo
	palo.posicionar_palo()

func terminar_partida() -> void:
	# TODO: Implementar logica de finalizacion de partida
	pass

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Gestion de Spawns
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

var puede_spawnear := true

func spawn_bola() -> void:
	if not puede_spawnear or bolas.is_empty():
		return

	# No spawnear si se supera el límite de bolas activas
	if bolas_objetos_activos.size() >= limite_bolas:
		return

	puede_spawnear = false

	var area_shape = spawn_area.get_node_or_null("CollisionShape3D")
	var extents: Vector3
	if area_shape and area_shape.shape is BoxShape3D:
		extents = area_shape.shape.extents
	else:
		extents = spawn_area.scale * 0.5

	var altura_fija = spawn_area.global_position.y

	for _i in range(20):
		var pos = Vector3(
			spawn_area.global_position.x + randf_range(-extents.x, extents.x),
			altura_fija,
			spawn_area.global_position.z + randf_range(-extents.z, extents.z)
		)
		var hay_cerca := false
		for b in bolas_objetos_activos:
			if b.distance_to(pos) < radio_proteccion_spawn:
				hay_cerca = true
				break
		if not hay_cerca:
			var bola = bolas.pick_random().instantiate()
			add_child(bola)
			bola.global_position = pos
			bolas_objetos_activos.append(pos)
			# Establecer velocidad y dirección
			if bola.has_method("set_destino") and boquetes.size() > 0:
				var boquete_obj = boquetes.pick_random()
				bola.set_destino(boquete_obj.global_position)
			if bola.has_method("set_aceleracion"):
				bola.set_aceleracion(randf_range(0.2, 0.5))
			if bola.has_method("set_velocidad_maxima"):
				bola.set_velocidad_maxima(randf_range(2.0, 1.0))
			if bola.has_method("set_bola_activa"):
				bola.set_bola_activa(true)
			break

	await get_tree().create_timer(cooldown_bola_spawn).timeout
	puede_spawnear = true

func actualizar_bolas_activos() -> void:
	# Actualizar la posicion actual de las bolas activas
	bolas_objetos_activos.clear()
	for bola in get_children():
		if bola is RigidBody3D and bola.is_in_group("bola"):
			bolas_objetos_activos.append(bola.global_position)

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Gestion de Boquetes
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _on_area_boquetes_body_entered(_body: Node) -> void:
	# Si el cuerpo tiene grupo "bola" ejecutar su metodo eliminar_bola
	if _body.is_in_group("bola"):
		if _body.has_method("eliminar_bola"):
			_body.eliminar_bola()
			# Eliminar la bola de la lista de bolas activas
			if bolas_objetos_activos.has(_body.global_position):
				bolas_objetos_activos.erase(_body.global_position)
	# Si el cuerpo tiene grupo "bola_blanca", reiniciar la bola blanca
	elif _body.is_in_group("bola_blanca"):
		if _body.has_method("resetear_bola"):
			_body.resetear_bola()

func _on_area_boquetes_body_exited(_body: Node) -> void:
	# TODO: Lógica cuando un cuerpo sale de area_boquetes
	pass

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Input y Debug
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _input(event: InputEvent) -> void:
	# Posicionar Palo con tecla S
	if event is InputEventKey and event.pressed and event.keycode == KEY_S:
		comenzar_partida()
	
	# Manejo del mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not palo.palo_posicionado:
			return
		if event.pressed:
			# Comenzar a cargar potencia
			palo.lanzando = true
		else:
			# Obtener carga de potencia
			if palo.lanzando:
				await palo.resetear_potencia()
