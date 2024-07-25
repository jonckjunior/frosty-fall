class_name CameraFollower extends Camera2D
@export var target: Node2D
@export var randomStrength: float = 2
@export var shakeFade: float = 20

var rng = RandomNumberGenerator.new()
var shakeStrength: float = 0.0

func _physics_process(delta):
	if target != null:
		global_position = lerp(global_position, target.global_position + Vector2(0, 80), delta * 5)
	
	if shakeStrength > 0.0:
		shakeStrength = lerp(shakeStrength, 0.0, shakeFade * delta)
		offset = randomOffset()

func apply_shake(strength):
	shakeStrength = strength
	shakeFade = 1.0

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
