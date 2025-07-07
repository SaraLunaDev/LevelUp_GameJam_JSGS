extends Node3D

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

# Exportadas
@export_group("Bola Blanca")
@export var bola_blanca: PackedScene
@export var bola_blanca_spawn: Node3D
@export var cooldown_bola_blanca: float = 2.5
var tiempo_bola_moviendose := 0.0

@export_group("Palo")
@export var punta_en_bola_blanca: Node3D
@export var punta_palo: Node3D
@export var rotacion_palo: Vector3 = Vector3(0, -90, -75)
@export var cooldown_palo: float = 0.5
@export var cooldown_palo_minimo: float = 0.1
@export var lerp_palo: float = 0.1

@export_group("Trayectoria")
@export var distancia_entre_bolas: float = 0.2
@export var tamaño_bolas_trayectoria: float = 0.05
@export var color_bolas: Color = Color.WHITE
@export var transparencia_bolas: float = .5
@export var numero_rebotes: int = 1

@export_group("Lanzamiento")
@export var velocidad_lanzamiento: float = 2
@export var tiempo_retorno_palo = 0.1
@export var potencia_maxima: float = 2.0

# Internas
var bola_blanca_instance: RigidBody3D
var palo_posicionado: bool = false
var lanzando: bool = false
var reseteando_bola_blanca: bool = false
var reseteando_potencia: bool = false
var moviendo_bola: bool = false
var potencia: float = 0.0
var posicion_mouse
var trayectoria_mesh: MeshInstance3D = null
@onready var mesh_palo: MeshInstance3D = $PaloBillar
var posicion_mesh_palo: Vector3
var bola_moviendose: bool = false

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _ready() -> void:
	palo_posicionado = false
	lanzando = false
	posicion_mesh_palo = mesh_palo.position

func _process(delta: float) -> void:
	if palo_posicionado:
		# Rotar el palo basado en la entrada del mouse
		rotar_palo(delta)
		# Mostrar la trayectoria del palo
		mostrar_trayectoria()
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

	# Conectar las señales de las areas de los boquetes pa modificar el rebote de la bola cuando entre o salga
	for boquete in get_tree().get_nodes_in_group("boquete"):
		if boquete.has_signal("body_entered"):
			boquete.connect("body_entered", Callable(bola_blanca_instance, "_on_boquetes_body_entered"))
		if boquete.has_signal("body_exited"):
			boquete.connect("body_exited", Callable(bola_blanca_instance, "_on_boquetes_body_exited"))
	
	bola_blanca_instance.connect("bola_blanca_reposicionada", Callable(self, "resetear_bola_blanca"))

func posicionar_palo() -> void:
	if palo_posicionado:
		return
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	instanciar_bola_blanca()
	rotation_degrees = Vector3.ZERO
	global_position = Vector3.ZERO
	rotation_degrees = rotacion_palo

	actualizar_posicion_palo()
	palo_posicionado = true

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Movimiento del Palo
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func rotar_palo(delta: float) -> void:
	var mouse_vel = Input.get_last_mouse_velocity().x
	if mouse_vel != 0:
		# Suaviza la rotación usando lerp
		var target_rot = rotation_degrees.y - mouse_vel * delta * 0.75
		rotation_degrees.y = lerp(rotation_degrees.y, target_rot, lerp_palo)
	actualizar_posicion_palo()

func mostrar_trayectoria() -> void:
	var bola = get_bola_blanca()
	if not bola:
		return

	var radio_bola = 0.093
	var direction = (bola_blanca_spawn.global_position - punta_palo.global_position).normalized()
	direction.y = 0

	var puntos = []
	var origen = bola_blanca_spawn.global_position
	var dir = direction
	var distancia_restante = 50.0

	var rebotes = 0
	while rebotes <= numero_rebotes and distancia_restante > 0.1:
		var ray_params = PhysicsRayQueryParameters3D.new()
		ray_params.from = origen + dir * radio_bola
		ray_params.to = origen + dir * (distancia_restante - radio_bola)
		ray_params.exclude = [bola]
		var result = get_world_3d().direct_space_state.intersect_ray(ray_params)
		if result:
			var col_pos = result.position
			if not result.collider.is_in_group("bola"):
				col_pos += result.normal * radio_bola
			puntos.append(col_pos)
			if result.collider.is_in_group("bola"):
				break
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
	var distancia_acumulada = 0.0
	for seg_idx in range(puntos.size()):
		var seg_inicio = pos_actual
		var seg_fin = puntos[seg_idx]
		var seg_dir = (seg_fin - seg_inicio).normalized()
		var seg_dist = seg_inicio.distance_to(seg_fin)
		while distancia_acumulada < seg_dist and esfera_idx < esferas.size():
			var punto = seg_inicio + seg_dir * distancia_acumulada
			esferas[esfera_idx].visible = true
			esferas[esfera_idx].position = bola_blanca_spawn.to_local(punto)
			esfera_idx += 1
			distancia_acumulada += distancia_entre_bolas
		distancia_acumulada -= seg_dist
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
	var bola = get_bola_blanca()
	if not bola:
		return
	# Solo aplicar si la bola está en la posición de bola spawn (con tolerancia)
	var tolerancia = 0.01
	if bola.global_position.distance_to(bola_blanca_spawn.global_position) > tolerancia:
		return
	potencia = min(potencia + velocidad_lanzamiento * _delta, potencia_maxima)
	actualizar_posicion_palo()

func resetear_potencia() -> void:
	if not palo_posicionado:
		return
	reseteando_potencia = true
	var potencia_inicial = potencia
	var tiempo := 0.0

	# Desactivar rotación del palo durante el retorno
	var rotacion_original = palo_posicionado
	palo_posicionado = false

	while tiempo < tiempo_retorno_palo:
		var t: float = (tiempo / tiempo_retorno_palo)
		# Ease In
		potencia = potencia_inicial * (1.0 - t * t)
		actualizar_posicion_palo()
		await get_tree().process_frame
		tiempo += get_process_delta_time()

	# Restaurar la rotación del palo
	palo_posicionado = rotacion_original

	# Calcular la direccion desde la punta del palo hacia el spawn de la bola blanca
	var bola = get_bola_blanca()
	if bola:
		bola_moviendose = true
		var direccion = (bola_blanca_spawn.global_position - punta_palo.global_position).normalized()
		direccion.y = 0
		bola.mover_bola(direccion, potencia_inicial)

	# Esperar cooldown solo si lanzando sigue siendo true
	var tiempo_espera := 0.0
	while lanzando and tiempo_espera < cooldown_bola_blanca:
		await get_tree().process_frame
		tiempo_espera += get_process_delta_time()
	reseteando_potencia = false

func actualizar_posicion_palo() -> void:
	# Ajusta la distancia del palo respecto al spawn de la bola blanca segun la potencia
	var offset = punta_en_bola_blanca.global_position - global_position
	global_position = bola_blanca_spawn.global_position - offset * (1 + (potencia / 4.0) / potencia_maxima)
	
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Estados de la Bola Blanca
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func resetear_bola_blanca() -> void:
	if reseteando_bola_blanca:
		return
	tiempo_bola_moviendose = 0.0
	bola_moviendose = false
	reseteando_bola_blanca = true
	var bola = get_bola_blanca()
	if bola:
		bola.freeze = true
		var start_pos = bola.global_position
		var end_pos = bola_blanca_spawn.global_position
		var t := 0.0
		var duration := 0.2
		while t < 1.0:
			bola.global_position = start_pos.lerp(end_pos, t)
			await get_tree().process_frame
			t += get_process_delta_time() / duration
		bola.global_position = end_pos
		bola.freeze = false
		if palo_posicionado:
			actualizar_posicion_palo()
		
	lanzando = false
	reseteando_potencia = false
	reseteando_bola_blanca = false

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Bufos
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func reducir_cooldown_palo(cantidad_reduccion: float) -> void:
	# Reducir el cooldown del palo
	velocidad_lanzamiento = max(velocidad_lanzamiento + cantidad_reduccion, cooldown_palo_minimo)
	print("Cooldown del palo reducido a: ", velocidad_lanzamiento)

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

func set_velocidad_lanzamiento(value: float):
	velocidad_lanzamiento = value

func get_velocidad_lanzamiento():
	return velocidad_lanzamiento
