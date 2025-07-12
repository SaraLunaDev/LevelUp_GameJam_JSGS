extends Node

@export_group("Referencias de Escena")
@export var game_manager: Node = null
@export var palo: Node3D = null
@export var poscion_objetos: Array[Node3D] = []
enum ModoTexto {
	INCREMENTO,
	VECES_USADO
}
@export var modo_texto: ModoTexto = ModoTexto.INCREMENTO
@export_subgroup("Labels")
@export var velocidad_lanzamiento_label: Label = null
@export var retorno_bola_label: Label = null
@export var potencia_bola_label: Label = null
var bola_blanca: Node3D = null
var bolas: Array[RigidBody3D] = []
var objetos: Array[RigidBody3D] = []
var pasiva_escogida: bool = false
var puede_escoger_pasiva: bool = false

@export_group("Posicion de Pasivas a Elegir")
@export var poscion_pasivas_elegir: Array[Node3D] = []

@export_group("Configuración de Pasivas")

@export_subgroup("Velocidad de Lanzamiento")
@export var velocidad_lanzamiento: float = 0.0
@export var velocidad_lanzamiento_incremento: float = 0.2
@export var velocidad_lanzamiento_maxima: float = 14.0
@export var velocidad_lanzamiento_objeto: PackedScene = null
@export var velocidad_lanzamiento_veces_usado: int = 0

@export_subgroup("Retorno de Bola")
@export var retorno_bola: float = 0.0
@export var retorno_bola_decremento: float = 0.0025
@export var retorno_bola_minimo: float = 0.3
@export var retorno_bola_objeto: PackedScene = null
@export var retorno_bola_veces_usado: int = 0

@export_subgroup("Potencia de Bola")
@export var potencia_bola: float = 0.0
@export var potencia_bola_incremento: float = 0.25
@export var potencia_bola_maxima: float = 5.0
@export var potencia_bola_objeto: PackedScene = null
@export var potencia_bola_veces_usado: int = 0

@export_subgroup("Rebotes Guiados")
@export var numero_rebotes_guiados: int = 0
@export var numero_rebotes_incremento: int = 1
@export var numero_rebotes_guiados_maximo: int = 100
@export var numero_rebotes_guiados_objeto: PackedScene = null
@export var numero_rebotes_guiados_veces_usado: int = 0

@export_subgroup("Spawn de Objetos")
@export var numero_objetos: int = 0
@export var numero_objetos_incremento: int = 1
@export var numero_objetos_maximo: int = 10
@export var numero_objetos_objeto: PackedScene = null
@export var numero_objetos_veces_usado: int = 0

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
	
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Mostrar Pasivas
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func elegir_pasivas_random():
	if puede_escoger_pasiva or poscion_pasivas_elegir.size() < 2:
		return
		
	pasiva_escogida = false
	puede_escoger_pasiva = true

	for pos in poscion_pasivas_elegir:
		for child in pos.get_children():
			child.queue_free()

	var pasivas = []
	if velocidad_lanzamiento_objeto:
		pasivas.append({"scene": velocidad_lanzamiento_objeto, "nombre": "Velocidad Lanzamiento"})
	if retorno_bola_objeto:
		pasivas.append({"scene": retorno_bola_objeto, "nombre": "Retorno Bola"})
	if potencia_bola_objeto:
		pasivas.append({"scene": potencia_bola_objeto, "nombre": "Potencia Bola"})
	if numero_rebotes_guiados_objeto:
		pasivas.append({"scene": numero_rebotes_guiados_objeto, "nombre": "Rebotes Guiados"})
	if numero_objetos_objeto:
		pasivas.append({"scene": numero_objetos_objeto, "nombre": "Spawn Objetos"})

	if pasivas.size() < 2:
		return

	for pos in poscion_pasivas_elegir:
		for child in pos.get_children():
			child.queue_free()

	var indices = []
	while indices.size() < 2:
		var idx = randi() % pasivas.size()
		if idx not in indices:
			indices.append(idx)

	for i in range(2):
		var pasiva_data = pasivas[indices[i]]
		var pasiva_instance = pasiva_data["scene"].instantiate()
		pasiva_instance.name = pasiva_data["nombre"]
		poscion_pasivas_elegir[i].add_child(pasiva_instance)
		pasiva_instance.global_position = poscion_pasivas_elegir[i].global_position

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Pasivas 
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _actualizar_objeto_y_label(objeto_escena, veces_usado, cantidad, maximo, label, texto_label, modo_texto_param, pos_array, _obj_label_ref, nombre_label_func: String = ""):
	var valor = min(cantidad, maximo)
	var objeto_ya_colocado := false
	var obj_label = null
	for pos in pos_array:
		if pos.get_child_count() > 0:
			for child in pos.get_children():
				if objeto_escena and child.scene_file_path == objeto_escena.resource_path:
					objeto_ya_colocado = true
					obj_label = child
					break
		if objeto_ya_colocado:
			break
	if not objeto_ya_colocado:
		for pos in pos_array:
			if pos.get_child_count() == 0 and objeto_escena:
				var obj = objeto_escena.instantiate()
				pos.add_child(obj)
				obj_label = obj
				break
	var texto = ""
	match modo_texto_param:
		ModoTexto.INCREMENTO:
			texto = str("+", valor)
		ModoTexto.VECES_USADO:
			texto = str("x", veces_usado)
	if label:
		label.text = texto_label if texto_label != null else texto
	if obj_label:
		var label_node = obj_label.get_node_or_null("Label")
		if label_node and label_node is MeshInstance3D and label_node.mesh is TextMesh:
			label_node.mesh.text = texto
	if game_manager and nombre_label_func != "" and game_manager.has_method(nombre_label_func):
		game_manager.call(nombre_label_func, texto)
	return valor

func aumentar_velocidad_lanzamiento(cantidad: float) -> void:
	velocidad_lanzamiento_veces_usado += 1
	velocidad_lanzamiento = _actualizar_objeto_y_label(
		velocidad_lanzamiento_objeto,
		velocidad_lanzamiento_veces_usado,
		velocidad_lanzamiento + cantidad,
		velocidad_lanzamiento_maxima,
		velocidad_lanzamiento_label,
		null,
		modo_texto,
		poscion_objetos,
		null
	)

func aumentar_retorno_bola(cantidad: float) -> void:
	retorno_bola_veces_usado += 1
	retorno_bola = _actualizar_objeto_y_label(
		retorno_bola_objeto,
		retorno_bola_veces_usado,
		retorno_bola + cantidad,
		retorno_bola_minimo,
		retorno_bola_label,
		null,
		modo_texto,
		poscion_objetos,
		null
	)

func aumentar_potencia_bola(cantidad: float) -> void:
	potencia_bola_veces_usado += 1
	potencia_bola = _actualizar_objeto_y_label(
		potencia_bola_objeto,
		potencia_bola_veces_usado,
		potencia_bola + cantidad,
		potencia_bola_maxima,
		potencia_bola_label,
		null,
		modo_texto,
		poscion_objetos,
		null
	)

func aumentar_rebotes_guiados(cantidad: int) -> void:
	numero_rebotes_guiados_veces_usado += 1
	numero_rebotes_guiados = _actualizar_objeto_y_label(
		numero_rebotes_guiados_objeto,
		numero_rebotes_guiados_veces_usado,
		numero_rebotes_guiados + cantidad,
		numero_rebotes_guiados_maximo,
		null,
		null,
		modo_texto,
		poscion_objetos,
		null,
		"set_rebotes_guiados_label"
	)

func aumentar_numero_objetos(cantidad: int) -> void:
	numero_objetos_veces_usado += 1
	numero_objetos = _actualizar_objeto_y_label(
		numero_objetos_objeto,
		numero_objetos_veces_usado,
		numero_objetos + cantidad,
		numero_objetos_maximo,
		null,
		null,
		modo_texto,
		poscion_objetos,
		null,
		"set_numero_objetos_label"
	)

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Getters y Setters
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func get_velocidad_lanzamiento() -> float:
	return velocidad_lanzamiento

func set_velocidad_lanzamiento(value: float) -> void:
	velocidad_lanzamiento = clamp(value, 0.0, velocidad_lanzamiento_maxima)

func get_velocidad_lanzamiento_incremento() -> float:
	return velocidad_lanzamiento_incremento

func set_velocidad_lanzamiento_incremento(value: float) -> void:
	velocidad_lanzamiento_incremento = max(0.0, value)

func get_velocidad_lanzamiento_maxima() -> float:
	return velocidad_lanzamiento_maxima

func set_velocidad_lanzamiento_maxima(value: float) -> void:
	velocidad_lanzamiento_maxima = max(0.0, value)
	velocidad_lanzamiento = clamp(velocidad_lanzamiento, 0.0, velocidad_lanzamiento_maxima)

func get_retorno_bola() -> float:
	return retorno_bola

func set_retorno_bola(value: float) -> void:
	retorno_bola = clamp(value, 0.0, retorno_bola_minimo)

func get_retorno_bola_decremento() -> float:
	return retorno_bola_decremento

func set_retorno_bola_decremento(value: float) -> void:
	retorno_bola_decremento = max(0.0, value)

func get_retorno_bola_minimo() -> float:
	return retorno_bola_minimo

func set_retorno_bola_minimo(value: float) -> void:
	retorno_bola_minimo = max(0.0, value)
	retorno_bola = clamp(retorno_bola, 0.0, retorno_bola_minimo)

func get_potencia_bola() -> float:
	return potencia_bola

func set_potencia_bola(value: float) -> void:
	potencia_bola = clamp(value, 0.0, potencia_bola_maxima)

func get_potencia_bola_incremento() -> float:
	return potencia_bola_incremento

func set_potencia_bola_incremento(value: float) -> void:
	potencia_bola_incremento = max(0.0, value)

func get_potencia_bola_maxima() -> float:
	return potencia_bola_maxima

func set_potencia_bola_maxima(value: float) -> void:
	potencia_bola_maxima = max(0.0, value)
	potencia_bola = clamp(potencia_bola, 0.0, potencia_bola_maxima)

func get_numero_rebotes_guiados() -> int:
	return numero_rebotes_guiados

func set_numero_rebotes_guiados(value: int) -> void:
	numero_rebotes_guiados = clamp(value, 0, numero_rebotes_guiados_maximo)

func get_numero_rebotes_incremento() -> int:
	return numero_rebotes_incremento

func set_numero_rebotes_incremento(value: int) -> void:
	numero_rebotes_incremento = max(0, value)

func get_numero_rebotes_guiados_maximo() -> int:
	return numero_rebotes_guiados_maximo

func set_numero_rebotes_guiados_maximo(value: int) -> void:
	numero_rebotes_guiados_maximo = max(0, value)
	numero_rebotes_guiados = clamp(numero_rebotes_guiados, 0, numero_rebotes_guiados_maximo)

func get_numero_objetos() -> int:
	return numero_objetos

func set_numero_objetos(value: int) -> void:
	numero_objetos = clamp(value, 0, numero_objetos_maximo)

func ha_escogido_pasiva() -> bool:
	print("Ha sido escogida?: ", pasiva_escogida)
	return pasiva_escogida

func set_pasiva_escogida(value: bool) -> void:
	pasiva_escogida = value

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Input y Debug
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not pasiva_escogida and puede_escoger_pasiva:
		var idx = -1
		if event.keycode == KEY_1:
			idx = 0
		elif event.keycode == KEY_2:
			idx = 1
			
		if idx >= 0 and poscion_pasivas_elegir.size() > idx and poscion_pasivas_elegir[idx].get_child_count() > 0:
			pasiva_escogida = true
			var pasiva = poscion_pasivas_elegir[idx].get_child(0).name
			match pasiva:
				"Velocidad Lanzamiento":
					aumentar_velocidad_lanzamiento(velocidad_lanzamiento_incremento)
				"Retorno Bola":
					aumentar_retorno_bola(retorno_bola_decremento)
				"Potencia Bola":
					aumentar_potencia_bola(potencia_bola_incremento)
				"Rebotes Guiados":
					aumentar_rebotes_guiados(numero_rebotes_incremento)
				"Spawn Objetos":
					aumentar_numero_objetos(numero_objetos_incremento)
			
			for pos in poscion_pasivas_elegir:
				for child in pos.get_children():
					child.queue_free()
			
			game_manager.reanudar_partida_por_pasiva()
			puede_escoger_pasiva = false
