extends Node
@onready var transition_rect: ColorRect = $CanvasLayer/TransitionRect
@onready var main_game_raw = preload("res://main_game.tscn")
@onready var game_over_sound: AudioStreamPlayer2D = $CanvasLayer/GameOverSound
@onready var end_game: Node2D = $CanvasLayer/Textures/EndGame
@onready var score_point: RichTextLabel = $CanvasLayer/Textures/EndGame/ScorePoint
@onready var soundtrack: AudioStreamPlayer2D = $CanvasLayer/Soundtrack
@onready var highest_score: RichTextLabel = $CanvasLayer/Textures/EndGame/HighestScore

var main_game: MainGame
var player_score: float
var max_score: float = 0

func _ready():
	start_game()
	load_save_file()
	await get_tree().create_timer(0.5).timeout
	main_game.is_active = true

func load_save_file():
	if not FileAccess.file_exists("user://savegame.save"):
		return
	
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json_string = save_game.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return

	var node_data = json.get_data()
	max_score = node_data["max_score"]

func save_file():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(
		{ "max_score": max_score }
	)
	save_game.store_line(json_string)

func _physics_process(delta):
	if main_game != null:
		game_over_sound.global_position = main_game.player.global_position
		soundtrack.global_position = main_game.player.global_position
		player_score += get_player_speed() * delta
	else:
		game_over_sound.global_position = Vector2.ZERO
		soundtrack.global_position = Vector2.ZERO

func start_game():
	main_game = main_game_raw.instantiate()
	add_child(main_game)
	main_game.game_over.connect(on_game_over)

func get_player_speed():
	return main_game.player.velocity.length()

func on_game_over():
	game_over_sound.play()
	await create_tween().tween_method(set_shader_value, 0.0, 1.0, 1.0).finished
	max_score = max(max_score, player_score)
	
	if max_score == player_score:
		score_point.text = "[shake] [center]" + str(snapped(player_score, 0.01))
	else:
		score_point.text = "[wave] [center]" + str(snapped(player_score, 0.01))
	
	save_file()
	
	player_score = 0
	main_game.queue_free()
	
	highest_score.update()
	end_game.visible = true

func restart():
	start_game()
	end_game.visible = false
	await create_tween().tween_method(set_shader_value, 1.0, 0.0, 1.0).finished
	main_game.is_active = true

func set_shader_value(value: float):
	(transition_rect.material as ShaderMaterial).set_shader_parameter("progress", value);
