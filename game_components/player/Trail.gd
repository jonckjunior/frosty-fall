extends Sprite2D

func _ready():
	await create_tween().tween_property(self, "modulate:a", 0.0, 3.0).finished
	queue_free()
