extends Node

var main_game: MainGame
var player_score: float

func get_player_speed():
	return main_game.player.velocity.length()

func _physics_process(delta):
	player_score += get_player_speed() * delta
