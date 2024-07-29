extends Node2D

@onready var audio_sprite: Sprite2D = $AudioSprite
@onready var audio_on: Texture = load("res://assets/ui/audioOn.png")
@onready var audio_off: Texture = load("res://assets/ui/audioOff.png")

var is_muted: bool = false

func _ready():
	start_tween()


func _physics_process(_delta):
	if Input.is_action_just_pressed("click") and is_inside_area():
		is_muted = !is_muted
		var bus_idx = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(bus_idx, is_muted)
		if is_muted:
			audio_sprite.texture = audio_off
		else:
			audio_sprite.texture = audio_on
func is_inside_area():
	var texture_size = audio_sprite.texture.get_size() * audio_sprite.scale
	return Rect2(audio_sprite.global_position, texture_size).has_point(get_global_mouse_position())

func start_tween():
	await create_tween().tween_property(self, "scale", Vector2(1.1, 1.2), 0.2).finished
	await create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).finished
	start_tween()
	
