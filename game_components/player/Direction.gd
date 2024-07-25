extends RayCast2D

const ROTATION_ADJUSTMENT: float = 2

func _physics_process(delta):
	var horizontal_move = Input.get_axis("left", "right")
	rotation += delta * ROTATION_ADJUSTMENT * horizontal_move
