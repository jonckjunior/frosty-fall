extends RayCast2D

@onready var player: Player = get_parent()
const ROTATION_ADJUSTMENT: float = 2

func _physics_process(delta):
	var horizontal_move = Input.get_axis("left", "right")
	var reading = Input.get_gyroscope()
	#if not player.is_in_the_air():
	if reading != Vector3.ZERO:
		rotation -= delta * reading.z * 2
	else:
		rotation += delta * ROTATION_ADJUSTMENT * horizontal_move
