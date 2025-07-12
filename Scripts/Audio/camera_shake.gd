extends Node

@export var camera:Camera3D

@export var max_strenght:float = 0.2

var rand:RandomNumberGenerator = RandomNumberGenerator.new()
var shake_strenght:float = 0.0

func _ready() -> void:
	GlobalSignals.shake.connect(_shake)

func _shake(intensity:float, duration:float = 0.1) -> void:
	
	shake_strenght = remap(intensity, 0.3, 1.0, 0.0, max_strenght)
	print("Shake strenght: ", shake_strenght, " with Shake duration: ", duration)
	var tween = create_tween()
	tween.tween_method(_move_camera_offset, shake_strenght, 0.0, duration)

func _move_camera_offset(strenght:float) -> void:
	var random_offset = _get_random_offset_from_strenght(strenght)
	camera.h_offset = random_offset.x
	camera.v_offset = random_offset.y
	Engine.time_scale = 1.0 - strenght/10.0
	
func _get_random_offset_from_strenght(strenght:float) -> Vector2:
	return Vector2(rand.randf_range(-strenght, strenght), rand.randf_range(-strenght, strenght))
