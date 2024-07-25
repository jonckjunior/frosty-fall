class_name Player extends CharacterBody2D

@onready var direction: RayCast2D = $Direction
@onready var animation: AnimatedSprite2D = $Animation
@onready var timer: Timer = $Timer
var movement_speed: float = 0.0

var is_initialized: bool = false

signal create_trail

func _ready():
	timer.connect("timeout", on_timer_timout)
	animation.play("grab_me")

func _physics_process(_delta):
	if not is_initialized:
		return
	
	animation.rotation = direction.rotation - PI / 2
	var dir = Vector2(cos(direction.rotation), sin(direction.rotation))
	velocity = dir * movement_speed - velocity
	move_and_slide()

func on_timer_timout():
	create_trail.emit()

func initialize_player():
	is_initialized = true
	animation.play("default")
	create_tween().tween_property(self, "movement_speed", 200.0, 4.0)
