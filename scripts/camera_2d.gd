extends Camera2D
var shake_strength := 0.0

func shake(amount: float):
	shake_strength = amount

func _process(delta):
	if shake_strength > 0:
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
		shake_strength = lerp(shake_strength, 0.0, delta * 5)
	else:
		offset = Vector2.ZERO
