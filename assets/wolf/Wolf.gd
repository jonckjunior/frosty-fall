extends AnimatedSprite2D

const move_speed = 100.0
var target

func _ready():
	if GameManager.main_game != null:
		target = GameManager.main_game.player

func _physics_process(delta):
	if target != null:
		var dir = (target.global_position - global_position)
		if dir.length() > 10:
			global_position += dir.normalized() * delta * move_speed
		else:
			play("scare")
			if GameManager.main_game != null and target != null and (target as Player).is_dying == false:
				GameManager.main_game.on_player_killer(target)
