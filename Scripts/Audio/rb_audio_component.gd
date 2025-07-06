extends Node3D

@export var rb:RigidBody3D
@export var max_velocity_magnitude:float

@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

var is_playing:bool = false
var initial_velocity_magnitude:float = 0.0
var current_velocity_magnitude:float = 0.0
var current_pitch:float = 1.0

func _physics_process(delta: float) -> void:
	if (!is_playing and abs(rb.linear_velocity.length()) > 0.2):
		initial_velocity_magnitude = abs(rb.linear_velocity.length())
		print("Initial velocity: ", initial_velocity_magnitude)
		_play()
	elif (is_playing and abs(rb.linear_velocity.length()) > 0.1):
		current_velocity_magnitude = abs(rb.linear_velocity.length())
		current_pitch = remap(log(current_velocity_magnitude + 1.0), log(max_velocity_magnitude), 0.1, 2.0, 0.8)
		audio_player.pitch_scale = current_pitch
		print("Current velocity: ", current_velocity_magnitude)
		print("Current Log result: ", log(current_velocity_magnitude))
		print("Current Log result + 1: ", log(current_velocity_magnitude + 1.0))
		print("Current pitch: ", current_pitch)
	elif (is_playing and abs(rb.linear_velocity.length()) <= 0.1):
		_stop()
		print("Stop")

func _play() -> void:
	is_playing = true
	audio_player.play()

func _stop() -> void:
	is_playing = false
	audio_player.stop()
	
