extends TextureRect

# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦
# 
# ✦•················•⋅ ∙ ∘ ☽ ☆ ☾ ∘ ⋅ ⋅•················•✦

func _process(_delta: float) -> void:
	if not is_visible():
		return
	var offset = Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1))
	var new_uv = position + offset
	if new_uv.x < 0 or new_uv.y < 0 or new_uv.x > size.x or new_uv.y > size.y:
		new_uv = Vector2(0, 0)
	position = new_uv
