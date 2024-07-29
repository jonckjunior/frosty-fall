class_name Wolf extends CharacterBody2D

@onready var animation: AnimatedSprite2D = $Animation

func _physics_process(delta):
	velocity = GameManager.main_game.player.velocity
	animation.rotation = GameManager.main_game.player.animation.rotation
	move_and_slide()
