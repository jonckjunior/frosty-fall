extends RichTextLabel

var time_elapsed: float = 0.0
var time_to_update: float = 0.1

func _physics_process(delta):
	time_elapsed += delta
	if time_elapsed > time_to_update:
		var player_score = snapped(GameManager.player_score, 0.1)
		text = "[center]" + str(player_score)
		time_elapsed = 0
