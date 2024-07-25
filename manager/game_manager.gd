extends Node

var main_game: MainGame
var player_score: float

func get_player_speed():
	return main_game.player.velocity.length()

func get_player_score():
	return player_score

func _physics_process(delta):
	player_score += get_player_speed() * delta
