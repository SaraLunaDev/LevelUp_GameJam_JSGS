extends RigidBody3D

var active = false
@export var bola_mesh: MeshInstance3D

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	active = true

func _physics_process(_delta: float) -> void:
	var fuerza = Vector3(-1, 0, 0) * 2 * mass

	if linear_velocity.x > 10:
		linear_velocity.x = 10
	else:
		apply_central_force(fuerza)

func eliminar_bola() -> void:
	self.queue_free()

func set_tipo_bola(tipo) -> void:
	if bola_mesh:
		var texture_path = "res://Textures/Bola" + str(tipo + 1) + ".png"
		var texture = load(texture_path)
		if texture:
			var new_material = StandardMaterial3D.new()
			new_material.albedo_texture = texture
			bola_mesh.material_override = new_material
			print("Textura de la bola cambiada a:", texture_path)
		else:
			print("No se pudo cargar la textura:", texture_path)
	else:
		print("No se encontró la malla de la bola.")
