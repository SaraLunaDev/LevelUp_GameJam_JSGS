extends Resource

class_name AudioBusSceneData

@export var bus_volumes:Dictionary[AudioManager.AUDIOBUS, float]
@export var music_low_pass:bool = false
@export_range(40.0, 20000.0, 1.0, "exp") var low_pass_freq:float = 20000.0
