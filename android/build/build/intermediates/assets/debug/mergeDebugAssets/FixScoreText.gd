extends Node2D

func _ready():
	while true:
		await create_tween().tween_property(self, "scale", Vector2(1.5, 1.5), 0.2).finished
		await create_tween().tween_property(self, "scale", Vector2(1, 1), 0.2).finished
