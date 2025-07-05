extends Node3D

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

# Exportadas
@export_group("Bola Blanca")
@export var bola_blanca: PackedScene
@export var bola_blanca_spawn: Node3D
@export var cooldown_bola_blanca: float = 2.5

@export_group("Palo")
@export var punta_en_bola_blanca: Node3D
@export var punta_palo: Node3D
@export var rotacion_palo: Vector3 = Vector3(0, 90, -75)
@export var cooldown_palo: float = 0.5
@export var lerp_palo: float = 0.05

@export_group("Trayectoria")
@export var distancia_entre_bolas: float = 0.2
@export var tamaño_bolas_trayectoria: float = 0.05
@export var color_bolas: Color = Color.WHITE
@export var transparencia_bolas: float = .02
@export var numero_rebotes: int = 1

@export_group("Lanzamiento")
@export var velocidad_lanzamiento: float = 2
@export var tiempo_retorno_palo = 0.1
@export var potencia_maxima: float = 3.0

# Internas
var bola_blanca_instance: RigidBody3D
var palo_posicionado: bool = false
var lanzando: bool = false
var reseteando_potencia: bool = false
var moviendo_bola: bool = false
var trayectoria_eliminada: bool = false
var potencia: float = 0.0
var posicion_mouse
var trayectoria_mesh: MeshInstance3D = null

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _ready() -> void:
	palo_posicionado = false

func _process(delta: float) -> void:
	if palo_posicionado and not lanzando:
		trayectoria_eliminada = false
		# Rotar el palo basado en la entrada del mouse
		rotar_palo(delta)
		# Mostrar la trayectoria del palo
		mostrar_trayectoria()
	elif lanzando and not trayectoria_eliminada:
		trayectoria_eliminada = true
		eliminar_trayectoria()
	# Actualizar la posicion del mouse
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
		var punta_pos_antes = punta_en_bola_blanca.global_position
		# Interpolacion to wapa
		var smooth_angle = lerp_angle(current_angle, target_angle, lerp_palo)
		rotation_degrees.y = rad_to_deg(smooth_angle)
		# Mantener la punta en el mismo sitio
		var punta_pos_despues = punta_en_bola_blanca.global_position
		global_position += punta_pos_antes - punta_pos_despues

func mostrar_trayectoria() -> void:
	var bola = get_bola_blanca()
	if not bola:
		return

	var radio_bola = 0.093
	var direction = (bola.global_position - punta_palo.global_position).normalized()
	direction.y = 0

	var puntos = []
	var origen = bola_blanca_spawn.global_position
	var dir = direction
	var distancia_restante = 50.0

	var rebotes = 0
	while rebotes <= numero_rebotes and distancia_restante > 0.1:
		var ray_params = PhysicsRayQueryParameters3D.new()
		# Ajustar el origen para que el raycast empiece desde el borde de la bola
		ray_params.from = origen + dir * radio_bola
		ray_params.to = origen + dir * (distancia_restante - radio_bola)
		ray_params.exclude = [bola]
		ray_params.collision_mask = 1
		var result = get_world_3d().direct_space_state.intersect_ray(ray_params)
		if result:
			# Ajustar el punto de colision para simular donde rebotaria la bola 
			var col_pos = result.position + result.normal * radio_bola
			puntos.append(col_pos)
			distancia_restante -= origen.distance_to(col_pos)
			dir = dir.bounce(result.normal).normalized()
			origen = col_pos + dir * 0.01
			rebotes += 1
		else:
			puntos.append(origen + dir * (distancia_restante - radio_bola))
			break

	var total_dist = bola_blanca_spawn.global_position.distance_to(puntos[0])
	for i in range(1, puntos.size()):
		total_dist += puntos[i - 1].distance_to(puntos[i])
	var num_esferas = int(total_dist / distancia_entre_bolas)
	# Crear esferas a lo largo de la trayectoria
	var esferas := []
	for child in bola_blanca_spawn.get_children():
		if child.name.begins_with("TrayectoriaEsfera"):
			esferas.append(child)
	while esferas.size() < num_esferas:
		var esfera = MeshInstance3D.new()
		esfera.name = "TrayectoriaEsfera_%d" % (esferas.size() + 1)
		esfera.mesh = SphereMesh.new()
		esfera.scale = Vector3.ONE * tamaño_bolas_trayectoria
		esfera.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var material = StandardMaterial3D.new()
		var color = color_bolas
		color.a = transparencia_bolas
		material.albedo_color = color
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.flags_transparent = true
		esfera.set_surface_override_material(0, material)
		bola_blanca_spawn.add_child(esfera)
		esferas.append(esfera)

	var pos_actual = bola_blanca_spawn.global_position
	var esfera_idx = 0
	for seg_idx in range(puntos.size()):
		var seg_inicio = pos_actual
		var seg_fin = puntos[seg_idx]
		var seg_dir = (seg_fin - seg_inicio).normalized()
		var seg_dist = seg_inicio.distance_to(seg_fin)
		var t = 0.0
		while t < seg_dist and esfera_idx < esferas.size():
			esferas[esfera_idx].visible = true
			esferas[esfera_idx].position = bola_blanca_spawn.to_local(seg_inicio + seg_dir * t)
			esfera_idx += 1
			t += distancia_entre_bolas
		pos_actual = seg_fin
	for i in range(esfera_idx, esferas.size()):
		esferas[i].visible = false

func eliminar_trayectoria() -> void:
	# Eliminar las esferas de trayectoria
	for child in bola_blanca_spawn.get_children():
		if child.name.begins_with("TrayectoriaEsfera"):
			child.queue_free()

func aplicar_potencia(_delta: float) -> void:
	if not palo_posicionado:
		return
	potencia = min(potencia + velocidad_lanzamiento * _delta, potencia_maxima)
	actualizar_posicion_palo()

func resetear_potencia() -> void:
	if not palo_posicionado:
		return
	reseteando_potencia = true

	var potencia_inicial = potencia
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
		var direccion = (bola.global_position - punta_palo.global_position).normalized()
		direccion.y = 0
		bola.mover_bola(direccion, potencia_inicial)

	# Resetear bola blanca cuando pasen x segundos
	await get_tree().create_timer(cooldown_bola_blanca).timeout
	await resetear_bola_blanca()

	lanzando = false
	reseteando_potencia = false

func actualizar_posicion_palo() -> void:
	# Ajusta la distancia del palo respecto al spawn de la bola blanca segun la potencia
	var offset = punta_en_bola_blanca.global_position - global_position
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

func get_punta_en_bola_blanca():
	return punta_en_bola_blanca

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
