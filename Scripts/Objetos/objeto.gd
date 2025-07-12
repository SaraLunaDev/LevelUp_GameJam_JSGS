extends RigidBody3D

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

var objeto_activo: bool = true
@export var choque: PackedScene
@export var explosion: PackedScene
@export var charco: PackedScene

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
			var game_manager = get_tree().get_first_node_in_group("game_manager")
			if game_manager and game_manager.has_method("sumar_vida"):
				game_manager.sumar_vida(1)
		TipoObjeto.BIRRA:
			if explosion:
				var explosion_instance = explosion.instantiate()
				get_tree().current_scene.add_child(explosion_instance)
				if is_inside_tree():
					explosion_instance.global_transform.origin = global_transform.origin
			
			var activos := []
			var objetivos := []
			objetivos += get_tree().get_nodes_in_group("bola")
			for obj in objetivos:
				if obj != self and obj.has_method("is_activa") and obj.is_activa():
					activos.append(obj)
		
			for obj in activos:
				var distance = obj.global_transform.origin.distance_to(global_transform.origin)
				if distance < 1:
					if obj.is_in_group("bola") and obj.has_method("eliminar_bola"):
						obj.eliminar_bola()
		TipoObjeto.WHISKY:
			if charco:
				var charco_instance = charco.instantiate()
				get_tree().current_scene.add_child(charco_instance)
				if is_inside_tree():
					charco_instance.global_transform.origin = global_transform.origin
					charco_instance.global_transform.origin.y -= 0.05
					var tween = get_tree().create_tween()
					charco_instance.scale = Vector3(0.01, 0.01, 0.01)
					tween.tween_property(charco_instance, "scale", Vector3(1, 1, 1), 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	call_deferred("queue_free")

func eliminar_sin_puntuacion() -> void:
	objeto_activo = false
	
	call_deferred("queue_free")

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Setters y Getters
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func is_activa() -> bool:
	return objeto_activo

func get_tipo() -> TipoObjeto:
	return tipo_objeto
