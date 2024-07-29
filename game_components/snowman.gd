extends Node2D

@onready var area: Area2D = $Area2D
@onready var animation: AnimatedSprite2D = $SnowmanAnimatedSprite

var activated: bool = false


func _ready():
	area.connect("body_entered", on_player_entered)
	animation.animation_finished.connect(queue_free)

func on_player_entered(body):
	if not (body as Player).is_in_the_air() and not activated:
		activated = true
		body.movement_speed *= 0.6
		animation.play("explode")
