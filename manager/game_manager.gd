extends Node
@onready var transition_rect: ColorRect = $CanvasLayer/TransitionRect
@onready var main_game_raw = preload("res://main_game.tscn")
@onready var game_over_sound: AudioStreamPlayer2D = $CanvasLayer/GameOverSound
@onready var end_game: Node2D = $CanvasLayer/Textures/EndGame
@onready var score_point: RichTextLabel = $CanvasLayer/Textures/EndGame/ScorePoint

var main_game: MainGame
var player_score: float

func _ready():
	start_game()

func start_game():
	main_game = main_game_raw.instantiate()
	add_child(main_game)
	main_game.game_over.connect(on_game_over)

func get_player_speed():
	return main_game.player.velocity.length()

func _physics_process(delta):
	if main_game != null:
		player_score += get_player_speed() * delta

func on_game_over():
	game_over_sound.play()
	await create_tween().tween_method(set_shader_value, 0.0, 1.0, 1.0).finished
	score_point.text = "[wave] [center]" + str(snapped(player_score, 0.01))
	player_score = 0
	main_game.queue_free()
	end_game.visible = true
	await get_tree().create_timer(2.0).timeout
	start_game()
	
	end_game.visible = false
	await create_tween().tween_method(set_shader_value, 1.0, 0.0, 1.0).finished

func set_shader_value(value: float):
	(transition_rect.material as ShaderMaterial).set_shader_parameter("progress", value);
