extends RichTextLabel

func _ready():
	start_tween()

func start_tween():
	await create_tween().tween_property(self, "scale", Vector2(1.1, 1.2), 0.2).finished
	await create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).finished
	start_tween()
	
