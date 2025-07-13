extends Node3D

@export var is_white_ball:bool = false
## Rigidbody afectado por el componente de audio y su area 3D
@export var rb:RigidBody3D
@export var area_3d:Area3D

## Sonido afectado por el RigidBody
@export var rb_sound:AudioStream

## Para controlar la modificación de pitch y volumen hace falta tener una referencia de 
## la velocidad máxima aproximada del Rigidbody afectado.
@export var max_velocity_magnitude:float

## Variación de pitch por encima y por debajo del pitch 1.0 por defecto (valores de 0.0 a 0.5)
@export_range(0.0, 0.5, 0.1) var pitch_variation_factor:float

# Con reproductor integrado!
var audio_player:AudioStreamPlayer3D

# Control de estados y velocidad
var is_playing:bool = false
var exited:bool = false
var is_first_shot:bool = false
var initial_velocity_magnitude:float = 0.0
var current_velocity_magnitude:float = 0.0

# Variables de cálculo para pitch, distancia y atenuación
var current_pitch:float = 1.0
var current_distance:float = 0.0
var current_volume_attenuation:float = 0.0

# La posición desde la que se escuchan los sonidos localizados en 3D
var current_listener_position:Vector3

# Asignamos la posición de la cámara como listener para los cálculos y 
# conectamos señales del Rigidbody
func _ready() -> void:
	audio_player = _initialize_audio_player(rb_sound)
	current_listener_position = get_viewport().get_camera_3d().global_position
	_connect_signals()
	
# Con la velocidad y la posición del Rigidbody asignado calculamos los cambios de pitch y volumen
func _physics_process(_delta: float) -> void:
	
	# Si empieza a moverse encendemos el sonido y testeamos velocidad
	if (!is_playing and !exited and rb.linear_velocity.length() > 0.2):
		initial_velocity_magnitude = rb.linear_velocity.length()
		#print("Initial velocity: ", initial_velocity_magnitude)
		_play()
		if is_first_shot and is_white_ball:
			AudioManager._play_stick_ball_sound(global_position, -6.0 + remap(log(current_velocity_magnitude +1.0), 0.1, log(max_velocity_magnitude), 0.0, 6.0))
			GlobalSignals.shake.emit(initial_velocity_magnitude / max_velocity_magnitude)
			is_first_shot = false
	
	# Si está en movimiento calculamos los valores de pitch y atenuación
	elif (is_playing and rb.linear_velocity.length() > 0.1):
		current_velocity_magnitude = abs(rb.linear_velocity.length())
		current_pitch = remap(log(current_velocity_magnitude + 1.0), log(max_velocity_magnitude), 0.1, 1.0 + pitch_variation_factor, 1.0 - pitch_variation_factor)
		audio_player.pitch_scale = current_pitch
		current_distance = (global_position - current_listener_position).length()
		current_volume_attenuation = current_distance / 2.0 + remap(log(current_velocity_magnitude +1.0), log(max_velocity_magnitude), 0.1, 0.0, 36.0)
		audio_player.volume_db = 0.0 - current_volume_attenuation
		#print("Attenuation: ", current_volume_attenuation)
		#print("Current velocity: ", current_velocity_magnitude)
		#print("Current Log result: ", log(current_velocity_magnitude))
		#print("Current Log result + 1: ", log(current_velocity_magnitude + 1.0))
		#print("Current pitch: ", current_pitch)
	
	# Paramos el sonido si la velocidad es demasiado baja
	elif (is_playing and abs(rb.linear_velocity.length()) <= 0.1):
		_stop()

func _connect_signals() -> void:
	GlobalSignals.stick_hit.connect(_on_stick_hit)
	rb.body_entered.connect(_on_body_entered)
	rb.body_exited.connect(_on_body_exited)
	area_3d.area_entered.connect(_on_area_entered)

func _initialize_audio_player(_rb_sound:AudioStream) -> AudioStreamPlayer3D:
	var player = AudioStreamPlayer3D.new()
	add_child(player)
	player.stream = rb_sound
	return player
	 

func _play() -> void:
	is_playing = true
	audio_player.play()

func _stop() -> void:
	is_playing = false
	audio_player.stop()
	
func _on_body_entered(body:Node) -> void:
	#print("Body entered: ", body)
	if body.is_in_group("billar") and exited:
		exited = false
		_play()
		if current_velocity_magnitude >= 0.1:
			AudioManager._play_ball_table_sound(global_position, -24.0 + remap(log(current_velocity_magnitude +1.0), 0.1, log(max_velocity_magnitude), 0.0, 24.0))
	elif body.is_in_group("bola"):
		#print("Global pos: ", global_position, " Velocity: ", current_velocity_magnitude)
		AudioManager._play_ball_ball_sound(global_position, -6.0 + remap(log(current_velocity_magnitude +1.0), 0.1, log(max_velocity_magnitude), 0.0, 6.0))
		GlobalSignals.shake.emit(current_velocity_magnitude / max_velocity_magnitude)
		await get_tree().create_timer(0.1).timeout
		AudioManager._play_ball_point_sound()
	
func _on_body_exited(body:Node) -> void:
	#print("Body exited: ", body)
	if body.is_in_group("billar") and !exited:
		exited = true
		_stop()

func _on_area_entered(area:Area3D):
	#print("Area entered: ", area)
	if area.is_in_group("banda"):
		AudioManager._play_ball_side_sound(global_position, -24.0 + remap(log(current_velocity_magnitude +1.0), 0.1, log(max_velocity_magnitude), 0.0, 24.0))

func _on_stick_hit():
	is_first_shot = true
