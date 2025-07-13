extends Camera3D
@export var max_rotation_deg: float = 3.0
@export var swing_speed: float = 0.2

@export var shake_strength: float = 0.5
@export var shake_speed: float = 0.15

var original_rotation: Basis
var original_position: Vector3
var time_passed: float = 0.0
@onready var transition: Node = $"../Transition/AnimationPlayer"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	original_rotation = global_transform.basis
	original_position = global_transform.origin
	transition.get_parent().get_node("Control/ColorRect").color.a = 255
	transition.play("transition_out")
	await get_tree().create_timer(0.5).timeout

func _process(delta):
	time_passed += delta

	var swing_angle = sin(time_passed * swing_speed) * deg_to_rad(max_rotation_deg)
	var new_basis = original_rotation.rotated(Vector3.UP, swing_angle)
	
	var offset_x = sin(time_passed * shake_speed * 1.3) * shake_strength
	var offset_y = cos(time_passed * shake_speed * 1.7) * shake_strength
	var offset_z = sin(time_passed * shake_speed) * shake_strength * 0.5

	global_transform.basis = new_basis
	global_transform.origin = original_position + Vector3(offset_x, offset_y, offset_z)
