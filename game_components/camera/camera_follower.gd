class_name CameraFollower extends Camera2D
@export var target: Node2D

func _physics_process(delta):
	if target != null:
		global_position = lerp(global_position, target.global_position + Vector2(0, 80), delta * 5)
