extends Node
class_name CameraManager

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Variables 
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

@export var camera: Camera3D
@export var camera_lerp_speed: int = 5

@export_group("Camera Settings")

@export_subgroup("Base Position")
var go_to_base: bool = false
@export var camera_base_rotation := Vector3(-27, 180, 0)
@export var camera_base_position := Vector3(0, 4, -5.04)
@export var camera_base_fov: float = 46.2

@export_subgroup("Camarero Position")
var go_to_camarero: bool = false
@export var camera_camarero_rotation := Vector3(-12.2, -131.5, 0)
@export var camera_camarero_position := Vector3(0, 4, -5.04)
@export var camera_camarero_fov: float = 17.4

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _process(delta: float) -> void:
	if go_to_base:
		lerp_camera_to(camera_base_position, camera_base_rotation, camera_base_fov, delta)
		if camera.global_transform.origin.distance_to(camera_base_position) < 0.1 and \
		   camera.global_transform.basis.get_euler().distance_to(camera_base_rotation) < 0.1 and \
		   abs(camera.fov - camera_base_fov) < 0.1:
			go_to_base = false
	if go_to_camarero:
		lerp_camera_to(camera_camarero_position, camera_camarero_rotation, camera_camarero_fov, delta)
		if camera.global_transform.origin.distance_to(camera_camarero_position) < 0.1 and \
		   camera.global_transform.basis.get_euler().distance_to(camera_camarero_rotation) < 0.1 and \
		   abs(camera.fov - camera_camarero_fov) < 0.1:
			go_to_camarero = false

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Cambiar Posiciones
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func lerp_camera_to(target_position: Vector3, target_rotation: Vector3, target_fov: float, delta: float) -> void:
	camera.global_transform.origin = camera.global_transform.origin.lerp(target_position, camera_lerp_speed * delta)
	var start_quat = Quaternion(camera.global_transform.basis)
	var end_quat = Quaternion(
		Basis()
			.rotated(Vector3(1, 0, 0), deg_to_rad(target_rotation.x))
			.rotated(Vector3(0, 1, 0), deg_to_rad(target_rotation.y))
			.rotated(Vector3(0, 0, 1), deg_to_rad(target_rotation.z))
	)
	camera.global_transform.basis = Basis(start_quat.slerp(end_quat, camera_lerp_speed * delta))
	camera.fov = lerp(camera.fov, target_fov, camera_lerp_speed * delta)

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Setters y Getters
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func set_camera_base() -> void:
	go_to_base = true

func set_camera_camarero() -> void:
	go_to_camarero = true

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Efectos de la Camara 
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func shake_camera(intensity: float, duration: float) -> void:
	var shake_amount = intensity
	var timer = duration
	while timer > 0:
		var offset = Vector3(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		camera.global_position += offset
		timer -= get_process_delta_time()
		await get_tree().create_timer(0.01).timeout
	camera.global_position = camera_base_position
