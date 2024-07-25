class_name Player extends CharacterBody2D

@onready var direction: RayCast2D = $Direction
@onready var animation: AnimatedSprite2D = $Animation
@onready var timer: Timer = $Timer
@onready var lane_detecter: Area2D = $LaneDetecter
@export var shadow: Sprite2D

var movement_speed: float = 0.0
var max_movement_speed: float = 200.0
var is_initialized: bool = false
var boost: float = 0


signal create_trail
signal landed

func _ready():
	timer.connect("timeout", on_timer_timout)
	animation.play("grab_me")
	shadow.visible = false

func _physics_process(delta):
	if not is_initialized:
		return
	handle_gravity(delta)
	handle_animation()
	handle_movement(delta)
	handle_shadow()
	handle_lane_check()
	move_and_slide()

func handle_gravity(delta):
	if boost > 0:
		boost += delta * 4
	else:
		boost += delta * 7

func handle_movement(delta):
	var dir = Vector2(cos(direction.rotation), sin(direction.rotation))
	velocity = dir * movement_speed - velocity
	movement_speed += delta * 20
	movement_speed = min(movement_speed, max_movement_speed)

func handle_animation():
	if animation.position.y + boost >= 0 and animation.position.y < 0:
		landed.emit()
	
	animation.position.y = min(0, animation.position.y + boost)
	animation.rotation = direction.rotation - PI / 2

func on_timer_timout():
	if not is_in_the_air():
		create_trail.emit()

func initialize_player():
	is_initialized = true
	animation.play("default")
	create_tween().tween_property(self, "movement_speed", 200.0, 4.0)

func hit_bumper():
	if not is_in_the_air():
		boost = -2

func is_in_the_air() -> bool:
	return animation.position.y < 0

func handle_shadow():
	shadow.visible = is_in_the_air()
	shadow.scale = Vector2(0.5, 0.5) * (1 + abs(animation.position.y)/50.0)

func handle_lane_check():
	if lane_detecter.get_overlapping_areas().is_empty():
		velocity = Vector2.ZERO
