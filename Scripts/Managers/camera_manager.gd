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
@export var camera_base_quaternion := Vector4(0.0, 0.973, 0.232, 0)
@export var camera_base_position := Vector3(0, 4, -5.04)
@export var camera_base_fov: float = 46.2

@export_subgroup("Camarero Position")
var go_to_camarero: bool = false
@export var camera_camarero_quaternion := Vector4(0.087, 0.875, 0.171, -0.444)
@export var camera_camarero_position := Vector3(0.089, 4.587, -4.318)
@export var camera_camarero_fov: float = 17.5

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Ready y Process
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _process(_delta: float) -> void:
	if go_to_base:
		move_camera_smooth(camera_base_position, camera_base_quaternion, camera_base_fov)
		go_to_base = false
	if go_to_camarero:
		move_camera_smooth(camera_camarero_position, camera_camarero_quaternion, camera_camarero_fov)
		go_to_camarero = false

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# Cambiar Posiciones Smooth
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func move_camera_smooth(target_position: Vector3, target_quaternion: Vector4, target_fov: float, duration: float = 1.0) -> void:
	var tween := create_tween().set_parallel(true)

	tween.tween_property(camera, "global_position", target_position, duration)
	tween.tween_property(camera, "fov", target_fov, duration)

	var target_quat = Quaternion(target_quaternion.x, target_quaternion.y, target_quaternion.z, target_quaternion.w)
	var start_quat = camera.global_transform.basis.get_rotation_quaternion()
	tween.tween_method(
		func(q):
			camera.global_transform = Transform3D(Basis(q), camera.global_position)
			return q,
		start_quat,
		target_quat,
		duration
	)

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
