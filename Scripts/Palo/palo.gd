extends Node3D

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

# Exportadas
@export_group("Bola Blanca")
@export var bola_blanca: PackedScene
@export var bola_blanca_spawn: Node3D
@export var cooldown_bola_blanca: float = 2

@export_group("Palo")
@export var punta_palo: Node3D
@export var rotacion_palo: Vector3 = Vector3(0, 90, -75)
@export var cooldown_palo: float = 0.5
@export var lerp_palo: float = 0.05

@export_group("Lanzamiento")
@export var velocidad_lanzamiento: float = 1
@export var tiempo_retorno_palo = 0.1

# Internas
var bola_blanca_instance: RigidBody3D
var palo_posicionado: bool = false
var lanzando: bool = false
var reseteando_potencia: bool = false
var moviendo_bola: bool = false
var potencia: float = 0.0
var potencia_maxima: float = 1.0
var posicion_mouse
var trayectoria_mesh: MeshInstance3D = null

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _ready() -> void:
	palo_posicionado = false

func _process(delta: float) -> void:
	if palo_posicionado and not lanzando:
		# Rotar el palo basado en la entrada del mouse
		rotar_palo(delta)
	# Actualizar la posición del mouse
	posicion_mouse = get_viewport().get_mouse_position()

	if lanzando and not reseteando_potencia:
		aplicar_potencia(delta)

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Spawn y Posicionamiento
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func instanciar_bola_blanca() -> void:
	# Eliminar bolas blancas existentes
	for bola in get_tree().get_nodes_in_group("bola_blanca"):
		bola.eliminar_bola()

	# Instanciar nueva bola blanca
	bola_blanca_instance = bola_blanca.instantiate()
	get_tree().current_scene.add_child(bola_blanca_instance)
	bola_blanca_instance.global_position = bola_blanca_spawn.global_position

func posicionar_palo() -> void:
	if palo_posicionado:
		return
		
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	instanciar_bola_blanca()
	rotation_degrees = Vector3.ZERO
	global_position = Vector3.ZERO
	rotation_degrees = rotacion_palo

	actualizar_posicion_palo()
	palo_posicionado = true

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Movimiento del Palo
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func rotar_palo(_delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	var ray_origin = camera.project_ray_origin(posicion_mouse)
	var ray_dir = camera.project_ray_normal(posicion_mouse)
	var ground_plane = Plane(Vector3.UP, bola_blanca_spawn.global_position.y)
	var hit = ground_plane.intersects_ray(ray_origin, ray_dir)
	if hit:
		var dir = (hit - bola_blanca_spawn.global_position).normalized()
		var target_angle = atan2(dir.x, dir.z) + deg_to_rad(90)
		var current_angle = deg_to_rad(rotation_degrees.y)
		# Guardar la posicion de la punta
		var punta_pos_antes = punta_palo.global_position
		# Interpolacion to wapa
		var smooth_angle = lerp_angle(current_angle, target_angle, lerp_palo)
		rotation_degrees.y = rad_to_deg(smooth_angle)
		# Mantener la punta en el mismo sitio
		var punta_pos_despues = punta_palo.global_position
		global_position += punta_pos_antes - punta_pos_despues

func aplicar_potencia(_delta: float) -> void:
	if not palo_posicionado:
		return

	potencia = min(potencia + velocidad_lanzamiento * _delta, potencia_maxima)
	print("😤 Cargando potencia... ", potencia)
	actualizar_posicion_palo()

func resetear_potencia() -> void:
	if not palo_posicionado:
		return

	print("\n😀 Potencia enviada: ", potencia, "\n")
	reseteando_potencia = true

	var potencia_inicial = potencia
	var punta_palo_inicial = punta_palo.global_position
	var tiempo := 0.0

	while tiempo < tiempo_retorno_palo:
		var t: float = (tiempo / tiempo_retorno_palo)
		# Ease In
		potencia = potencia_inicial * (1.0 - t * t)
		actualizar_posicion_palo()
		await get_tree().process_frame
		tiempo += get_process_delta_time()

	# Calcular la direccion desde la punta del palo hacia el spawn de la bola blanca
	var bola = get_bola_blanca()
	if bola:
		var direccion = (bola.global_position - punta_palo_inicial).normalized()
		direccion.y = 0
		bola.mover_bola(direccion, potencia_inicial)

	# Resetear bola blanca cuando pasen x segundos
	await get_tree().create_timer(cooldown_bola_blanca).timeout
	await resetear_bola_blanca()

	lanzando = false
	reseteando_potencia = false

func actualizar_posicion_palo() -> void:
	# Ajusta la distancia del palo respecto al spawn de la bola blanca segun la potencia
	var offset = punta_palo.global_position - global_position
	global_position = bola_blanca_spawn.global_position - offset * (1 + (potencia / 2.0) / potencia_maxima)

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Estados de la Bola Blanca
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func resetear_bola_blanca() -> void:
	var bola = get_bola_blanca()
	if bola:
		bola.freeze = true
		var start_pos = bola.global_position
		var end_pos = bola_blanca_spawn.global_position
		var t := 0.0
		var duration := 0.3
		while t < 1.0:
			bola.global_position = start_pos.lerp(end_pos, t)
			await get_tree().process_frame
			t += get_process_delta_time() / duration
		bola.global_position = end_pos
		potencia = 0.0
		bola.freeze = false
		if palo_posicionado:
			actualizar_posicion_palo()
	else:
		potencia = 0.0

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Getters y Setters
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func get_palo():
	return self

func get_bola_blanca():
	var bolas = get_tree().get_nodes_in_group("bola_blanca")
	return bolas[0] if bolas.size() > 0 else null

func set_bola_blanca():
	instanciar_bola_blanca()

func get_spawn_bola_blanca():
	return bola_blanca_spawn

func set_spawn_bola_blanca(posicion: Vector3):
	bola_blanca_spawn.global_position = posicion

func get_punta_palo():
	return punta_palo

func get_cooldown_palo():
	return cooldown_palo

func set_cooldown_palo(cooldown: float):
	cooldown_palo = cooldown

func get_potencia():
	return potencia

func set_potencia(value: float):
	potencia = value

func get_potencia_maxima():
	return potencia_maxima

func set_potencia_maxima(value: float):
	potencia_maxima = value

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Inputs y Debug
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _input(event: InputEvent) -> void:
	# Posicionar Palo con tecla S
	if event is InputEventKey and event.pressed and event.keycode == KEY_S:
		posicionar_palo()
	
	# Manejo del mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not palo_posicionado:
			return
		if event.pressed:
			# Comenzar a cargar potencia
			lanzando = true
		else:
			# Obtener carga de potencia
			if lanzando:
				await resetear_potencia()
