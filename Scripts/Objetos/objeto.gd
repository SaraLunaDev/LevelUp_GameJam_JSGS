extends RigidBody3D

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

var objeto_activa: bool = false

enum TipoObjeto {
	WHISKY,
	VASO,
	BIRRA
}

@export var tipo_objeto: TipoObjeto

var VIDA_MAXIMA: int
var vida: int

var object_mass: float = 1

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _ready():
	match tipo_objeto:
		TipoObjeto.WHISKY:
			VIDA_MAXIMA = 3
			object_mass = 2
		TipoObjeto.VASO:
			VIDA_MAXIMA = 1
			object_mass = 0.5
		TipoObjeto.BIRRA:
			VIDA_MAXIMA = 2
			object_mass = 1
		_:
			VIDA_MAXIMA = 1
			object_mass = 1
	
	vida = VIDA_MAXIMA

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Estados del Objeto
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func recibir_golpe(daño: int) -> void:
	# Reducir la vida del objeto al recibir daño
	# TODO: Aplicar efectos visuales o sonoros al recibir daño
	vida -= daño
	if vida <= 0:
		eliminar_objeto()

func eliminar_objeto() -> void:
	# Eliminar el objeto del juego
	# TODO: Aplicar efectos visuales o sonoros al recibir morir
	queue_free()
	objeto_activa = false

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Señales
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("bola_blanca"):
		body.resetear_bola()
		recibir_golpe(body.get_daño())
