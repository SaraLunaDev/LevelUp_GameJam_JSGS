extends RigidBody3D

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

var objeto_activo: bool = true
@export var choque: PackedScene

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
			VIDA_MAXIMA = 1
			object_mass = 2
		TipoObjeto.VASO:
			VIDA_MAXIMA = 1
			object_mass = 0.5
		TipoObjeto.BIRRA:
			VIDA_MAXIMA = 1
			object_mass = 1
		_:
			VIDA_MAXIMA = 1
			object_mass = 1
	
	vida = VIDA_MAXIMA

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Estados del Objeto
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func recibir_golpe(daño: int) -> void:
	if choque:
		var choque_instance = choque.instantiate()
		get_tree().current_scene.add_child(choque_instance)
		if is_inside_tree():
			choque_instance.global_transform.origin = global_transform.origin
	vida -= daño
	if vida <= 0:
		eliminar_objeto()

func eliminar_objeto() -> void:
	objeto_activo = false
	match tipo_objeto:
		TipoObjeto.VASO:
			pass
		TipoObjeto.BIRRA:
			pass
		TipoObjeto.WHISKY:
			pass
	
	call_deferred("queue_free")

func eliminar_sin_puntuacion() -> void:
	objeto_activo = false
	
	call_deferred("queue_free")

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Setters y Getters
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func is_activa() -> bool:
	return objeto_activo
