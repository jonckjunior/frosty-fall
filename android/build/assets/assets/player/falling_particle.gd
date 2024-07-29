extends AnimatedSprite2D

func _ready():
	connect("animation_finished", queue_free)
	var final_position = global_position + Vector2(cos(rotation), sin(rotation)) * 100
	create_tween().tween_property(self, "position", final_position, 1)
