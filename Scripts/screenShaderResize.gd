extends ColorRect

func _process(delta):
	var shader_material = material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("screen_size", get_viewport().size)
		shader_material.set_shader_parameter("viewport_size", get_viewport().size)
