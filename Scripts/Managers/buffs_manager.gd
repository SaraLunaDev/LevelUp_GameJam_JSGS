extends Node

@export_group("Referencias de Escena")
@export var game_manager: Node = null
@export var palo: Node3D = null
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

@export_subgroup("Retorno de Bola")
@export var retorno_bola: float = 0.0
@export var retorno_bola_decremento: float = 0.0025
@export var retorno_bola_minimo: float = 0.3

@export_subgroup("Potencia de Bola")
@export var potencia_bola: float = 0.0
@export var potencia_bola_incremento: float = 0.25
@export var potencia_bola_maxima: float = 5.0

@export_group("Rebotes Guiados")
@export var numero_rebotes_guiados: int = 0
@export var numero_rebotes_incremento: int = 1
@export var numero_rebotes_guiados_maximo: int = 0

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Pasivas 
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func aumentar_velocidad_lanzamiento(cantidad: float) -> void:
	velocidad_lanzamiento = min(velocidad_lanzamiento + cantidad, velocidad_lanzamiento_maxima)
	if velocidad_lanzamiento_label:
		velocidad_lanzamiento_label.text = str("+", velocidad_lanzamiento)

func aumentar_retorno_bola(cantidad: float) -> void:
	retorno_bola = min(retorno_bola + cantidad, retorno_bola_minimo)
	if retorno_bola_label:
		retorno_bola_label.text = str("-", retorno_bola)

func aumentar_potencia_bola(cantidad: float) -> void:
	potencia_bola = min(potencia_bola + cantidad, potencia_bola_maxima)
	if potencia_bola_label:
		potencia_bola_label.text = str("+", potencia_bola)

func aumentar_rebotes_guiados(cantidad: int) -> void:
	numero_rebotes_guiados = min(numero_rebotes_guiados + cantidad, numero_rebotes_guiados_maximo)
	if game_manager and game_manager.has_method("set_rebotes_guiados_label"):
		game_manager.set_rebotes_guiados_label(str(numero_rebotes_guiados))

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