extends RigidBody3D

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

var objeto_activo: bool = true

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
	# TODO: Aplicar efectos visuales o sonoros al recibir daño
	vida -= daño
	if vida <= 0:
		eliminar_objeto()

func eliminar_objeto() -> void:
	objeto_activo = false
	match tipo_objeto:
		TipoObjeto.VASO:
			var game_manager = get_tree().get_nodes_in_group("game_manager")
			if game_manager.size() > 0:
				var game_manager_obj = game_manager[0]
				if game_manager_obj.has_method("sumar_vida"):
					game_manager_obj.sumar_vida(1)
		TipoObjeto.BIRRA:
			var game_manager = get_tree().get_nodes_in_group("game_manager")
			if game_manager.size() > 0:
				var game_manager_obj = game_manager[0]
				if game_manager_obj.has_method("sumar_MAX_VIDA"):
					game_manager_obj.sumar_MAX_VIDA(1)
		TipoObjeto.WHISKY:
			var game_manager = get_tree().get_nodes_in_group("game_manager")
			if game_manager.size() > 0:
				var game_manager_obj = game_manager[0]
				if game_manager_obj.has_method("get_MAX_VIDA"):
					var vida_maxima = game_manager_obj.get_MAX_VIDA()
					if game_manager_obj.has_method("sumar_vida"):
						game_manager_obj.sumar_vida(vida_maxima)
			pass

	call_deferred("queue_free")

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Setters y Getters
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func is_activa() -> bool:
	return objeto_activo

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Señales
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("bola_blanca"):
		recibir_golpe(body.get_daño())
