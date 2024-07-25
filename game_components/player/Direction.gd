extends RayCast2D

@onready var player: Player = get_parent()
const ROTATION_ADJUSTMENT: float = 2

func _physics_process(delta):
	var horizontal_move = Input.get_axis("left", "right")
	if not player.is_in_the_air():
		rotation += delta * ROTATION_ADJUSTMENT * horizontal_move
