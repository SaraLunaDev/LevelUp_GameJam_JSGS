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
@export var numero_rebotes_guiados_maximo: int = 0
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
	
func _ready() -> void:
	aumentar_velocidad_lanzamiento(velocidad_lanzamiento)
	aumentar_retorno_bola(retorno_bola)
	aumentar_potencia_bola(potencia_bola)
	aumentar_rebotes_guiados(numero_rebotes_guiados)
	aumentar_numero_objetos(numero_objetos)

@export_subgroup("Rebotes Guiados")
@export var numero_rebotes_guiados: int = 0
@export var numero_rebotes_incremento: int = 1
@export var numero_rebotes_guiados_maximo: int = 0
@export var numero_rebotes_guiados_objeto: PackedScene = null
@export var numero_rebotes_guiados_veces_usado: int = 0

@export_subgroup("Spawn de Objetos")
@export var numero_objetos: int = 0
@export var numero_objetos_incremento: int = 1
@export var numero_objetos_maximo: int = 10
@export var numero_objetos_objeto: PackedScene = null
	
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Pasivas 
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func aumentar_velocidad_lanzamiento(cantidad: float) -> void:
	velocidad_lanzamiento = min(velocidad_lanzamiento + cantidad, velocidad_lanzamiento_maxima)

	if velocidad_lanzamiento == 0.0:
		return

	velocidad_lanzamiento_veces_usado += 1
	var objeto_ya_colocado := false
	var obj_label = null
	for pos in poscion_objetos:
		if pos.get_child_count() > 0:
			for child in pos.get_children():
				if velocidad_lanzamiento_objeto and child.scene_file_path == velocidad_lanzamiento_objeto.resource_path:
					objeto_ya_colocado = true
					obj_label = child
					break
		if objeto_ya_colocado:
			break
	if not objeto_ya_colocado:
		for pos in poscion_objetos:
			if pos.get_child_count() == 0 and velocidad_lanzamiento_objeto:
				var obj = velocidad_lanzamiento_objeto.instantiate()
				pos.add_child(obj)
				obj_label = obj
				break
	var texto = ""
	match modo_texto:
		ModoTexto.INCREMENTO:
			texto = str("+", velocidad_lanzamiento)
		ModoTexto.VECES_USADO:
			texto = str("x", velocidad_lanzamiento_veces_usado)
	if velocidad_lanzamiento_label:
		velocidad_lanzamiento_label.text = texto
	if obj_label:
		var label_node = obj_label.get_node_or_null("Label")
		if label_node and label_node is MeshInstance3D and label_node.mesh is TextMesh:
			label_node.mesh.text = texto

func aumentar_retorno_bola(cantidad: float) -> void:
	retorno_bola = min(retorno_bola + cantidad, retorno_bola_minimo)

	if retorno_bola == 0.0:
		return

	retorno_bola_veces_usado += 1
	var objeto_ya_colocado := false
	var obj_label = null
	for pos in poscion_objetos:
		if pos.get_child_count() > 0:
			for child in pos.get_children():
				if retorno_bola_objeto and child.scene_file_path == retorno_bola_objeto.resource_path:
					objeto_ya_colocado = true
					obj_label = child
					break
		if objeto_ya_colocado:
			break
	if not objeto_ya_colocado:
		for pos in poscion_objetos:
			if pos.get_child_count() == 0 and retorno_bola_objeto:
				var obj = retorno_bola_objeto.instantiate()
				pos.add_child(obj)
				obj_label = obj
				break
	var texto = ""
	match modo_texto:
		ModoTexto.INCREMENTO:
			texto = str("+", retorno_bola)
		ModoTexto.VECES_USADO:
			texto = str("x", retorno_bola_veces_usado)
	if retorno_bola_label:
		retorno_bola_label.text = texto
	if obj_label:
		var label_node = obj_label.get_node_or_null("Label")
		if label_node and label_node is MeshInstance3D and label_node.mesh is TextMesh:
			label_node.mesh.text = texto

func aumentar_potencia_bola(cantidad: float) -> void:
	potencia_bola = min(potencia_bola + cantidad, potencia_bola_maxima)

	if potencia_bola == 0.0:
		return

	potencia_bola_veces_usado += 1
	var objeto_ya_colocado := false
	var obj_label = null
	for pos in poscion_objetos:
		if pos.get_child_count() > 0:
			for child in pos.get_children():
				if potencia_bola_objeto and child.scene_file_path == potencia_bola_objeto.resource_path:
					objeto_ya_colocado = true
					obj_label = child
					break
		if objeto_ya_colocado:
			break
	if not objeto_ya_colocado:
		for pos in poscion_objetos:
			if pos.get_child_count() == 0 and potencia_bola_objeto:
				var obj = potencia_bola_objeto.instantiate()
				pos.add_child(obj)
				obj_label = obj
				break
	var texto = ""
	match modo_texto:
		ModoTexto.INCREMENTO:
			texto = str("+", potencia_bola)
		ModoTexto.VECES_USADO:
			texto = str("x", potencia_bola_veces_usado)
	if potencia_bola_label:
		potencia_bola_label.text = texto
	if obj_label:
		var label_node = obj_label.get_node_or_null("Label")
		if label_node and label_node is MeshInstance3D and label_node.mesh is TextMesh:
			label_node.mesh.text = texto

func aumentar_rebotes_guiados(cantidad: int) -> void:
	numero_rebotes_guiados = min(numero_rebotes_guiados + cantidad, numero_rebotes_guiados_maximo)
	if numero_rebotes_guiados == 0:
		return

	numero_rebotes_guiados_veces_usado += 1
	if not bola_blanca:
		bola_blanca = get_tree().get_nodes_in_group("bola_blanca")[0] if get_tree().get_nodes_in_group("bola_blanca") else null
	if bola_blanca and bola_blanca.has_method("set_numero_rebotes_guiados_maximo"):
		bola_blanca.set_numero_rebotes_guiados_maximo(numero_rebotes_guiados)
	var objeto_ya_colocado := false
	var obj_label = null
	for pos in poscion_objetos:
		if pos.get_child_count() > 0:
			for child in pos.get_children():
				if numero_rebotes_guiados_objeto and child.scene_file_path == numero_rebotes_guiados_objeto.resource_path:
					objeto_ya_colocado = true
					obj_label = child
					break
		if objeto_ya_colocado:
			break
	if not objeto_ya_colocado:
		for pos in poscion_objetos:
			if pos.get_child_count() == 0 and numero_rebotes_guiados_objeto:
				var obj = numero_rebotes_guiados_objeto.instantiate()
				pos.add_child(obj)
				obj_label = obj
				break
	var texto = ""
	match modo_texto:
		ModoTexto.INCREMENTO:
			texto = str("+", numero_rebotes_guiados)
		ModoTexto.VECES_USADO:
			texto = str("x", numero_rebotes_guiados_veces_usado)
	if game_manager and game_manager.has_method("set_rebotes_guiados_label"):
		game_manager.set_rebotes_guiados_label(texto)
	if obj_label:
		var label_node = obj_label.get_node_or_null("Label")
		if label_node and label_node is MeshInstance3D and label_node.mesh is TextMesh:
			label_node.mesh.text = texto

func aumentar_numero_objetos(cantidad: int) -> void:
	numero_objetos = min(numero_objetos + cantidad, numero_objetos_maximo)

	if numero_objetos == 0:
		return
	numero_objetos_veces_usado += 1

	var objeto_ya_colocado := false
	var obj_label = null
	for pos in poscion_objetos:
		if pos.get_child_count() > 0:
			for child in pos.get_children():
				if numero_objetos_objeto and child.scene_file_path == numero_objetos_objeto.resource_path:
					objeto_ya_colocado = true
					obj_label = child
					break
		if objeto_ya_colocado:
			break
	if not objeto_ya_colocado:
		for pos in poscion_objetos:
			if pos.get_child_count() == 0 and numero_objetos_objeto:
				var obj = numero_objetos_objeto.instantiate()
				pos.add_child(obj)
				obj_label = obj
				break
	var texto = ""
	match modo_texto:
		ModoTexto.INCREMENTO:
			texto = str("+", numero_objetos)
		ModoTexto.VECES_USADO:

			texto = str("x", numero_objetos_veces_usado)
	if game_manager and game_manager.has_method("set_numero_objetos_label"):
		game_manager.set_numero_objetos_label(numero_objetos)

	if obj_label:
		var label_node = obj_label.get_node_or_null("Label")
		if label_node and label_node is MeshInstance3D and label_node.mesh is TextMesh:
			label_node.mesh.text = texto

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
