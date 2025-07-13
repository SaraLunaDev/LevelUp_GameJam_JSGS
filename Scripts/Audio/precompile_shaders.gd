extends Node

@export var want_precompile:bool = true
@export var vfx_node_scenes:Array[PackedScene]

func _ready() -> void:
	for vfx_scene in vfx_node_scenes:
		var vfx_node = vfx_scene.instantiate()
		add_child(vfx_node)
		if !vfx_node.has_method("_ready"):
			vfx_node.explode()
	
	await get_tree().create_timer(3.0).timeout
	call_deferred("queue_free")
