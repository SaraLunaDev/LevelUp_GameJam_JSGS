extends Node

@warning_ignore("unused_signal")
signal shake
@warning_ignore("unused_signal")
signal choosing_passive
@warning_ignore("unused_signal")
signal passive_choosed
@warning_ignore("unused_signal")
signal stick_hit
@warning_ignore("unused_signal")
signal video_skiped
@warning_ignore("unused_signal")
signal video_ended
@warning_ignore("unused_signal")
signal video_started

var mouse_sens_factor:float = 1.0
var inverse_rotation_setting:bool = false

func _get_mouse_sens_factor() -> float:
	return mouse_sens_factor

func _get_inverse_rotation_setting() -> bool:
	return inverse_rotation_setting

func _set_mouse_sens_factor(new_value:float):
	mouse_sens_factor = new_value

func _set_inverse_rotation_setting(is_active:bool):
	inverse_rotation_setting = is_active
