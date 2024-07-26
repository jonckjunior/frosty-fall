class_name Player extends CharacterBody2D

@onready var direction: RayCast2D = $Direction
@onready var animation: AnimatedSprite2D = $Animation
@onready var timer: Timer = $Timer
@onready var lane_detecter: Area2D = $LaneDetecter
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var explosion_sound: AudioStreamPlayer2D = $ExplosionSound
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@export var shadow: Sprite2D

var movement_speed: float = 0.0
var max_movement_speed: float = 500.0
var is_initialized: bool = false
var boost: float = 0

signal create_trail
signal landed
signal game_over

func _ready():
	timer.connect("timeout", on_timer_timout)
	animation.play("grab_me")
	shadow.visible = false
	animation.frame_changed.connect(play_rowing_sound)

func play_rowing_sound():
	if animation.animation == "default" and animation.frame == 1:
		$RowingSound.play()
		landed.emit()
		movement_speed += 10
	if animation.animation == "shatter" and animation.frame == 40:
		explosion_sound.play()
	if animation.animation == "shatter" and animation.frame == 80:
		game_over.emit()

func _physics_process(delta):
	if not is_initialized:
		return
	handle_gravity(delta)
	handle_animation()
	handle_movement(delta)
	handle_shadow()
	handle_lane_check()
	squish_and_squash()
	move_and_slide()

func handle_gravity(delta):
	if boost > 0:
		boost += delta * 4
	else:
		boost += delta * 7

func handle_movement(delta):
	var dir = Vector2(cos(direction.rotation), sin(direction.rotation))
	velocity = dir * movement_speed - velocity
	movement_speed = min(movement_speed, max_movement_speed)

func handle_animation():
	if animation.position.y + boost >= 0 and animation.position.y < 0:
		landed.emit()
		animation.play()
	
	animation.speed_scale = 1 + movement_speed / max_movement_speed
	animation.position.y = min(0, animation.position.y + boost)
	animation.rotation = direction.rotation - PI / 2
	
	if is_in_the_air():
		animation.pause()
	

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
		jump_sound.play()

func is_in_the_air() -> bool:
	return animation.position.y < 0

func handle_shadow():
	shadow.visible = is_in_the_air()
	shadow.scale = Vector2(0.5, 0.5) * (1 + abs(animation.position.y)/50.0)

func handle_lane_check():
	if lane_detecter.get_overlapping_areas().is_empty():
		velocity = Vector2.ZERO

func play_hurt_sound():
	hurt_sound.play()

func play_explosion_sound():
	explosion_sound.play()

func die_to_obstacle():
	play_hurt_sound()
	is_initialized = false
	velocity = Vector2.ZERO
	animation.play("shatter")

func squish_and_squash() -> void:
	var maxX = max_movement_speed
	var maxY = max_movement_speed
	
	var newScaleY = 1 - min(abs(velocity.x), maxX) / maxX * 0.5
	var newScaleX = 1 - min(abs(velocity.y), maxY) / maxY * 0.5
	
	var sum = newScaleX + newScaleY
	if sum < 2:
		if newScaleX >= newScaleY:
			newScaleX += 2 - sum
		else:
			newScaleY += 2 - sum

	animation.scale.x = snapped(lerp(animation.scale.x, newScaleX, 0.2), 0.04)
	animation.scale.y = snapped(lerp(animation.scale.y, newScaleY, 0.2), 0.04)
