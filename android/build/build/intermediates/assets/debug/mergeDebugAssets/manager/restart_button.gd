extends AnimatedSprite2D

func _ready():
	start_tween()

func _physics_process(_delta):
	if is_inside_area() and Input.is_action_just_pressed("click") and is_visible_in_tree():
		GameManager.restart()
		
func is_inside_area():
	var texture_size = Vector2(84, 14) * 1.2
	return Rect2(global_position, texture_size).has_point(get_global_mouse_position())

func start_tween():
	await create_tween().tween_property(self, "scale", Vector2(1.2, 1.2), 0.2).finished
	await create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).finished
	start_tween()
	
