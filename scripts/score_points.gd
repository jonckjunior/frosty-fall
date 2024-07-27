extends RichTextLabel

var time_elapsed: float = 0.0
var time_to_update: float = 0.1

func _ready():
	start_tween()

func _physics_process(delta):
	time_elapsed += delta
	if time_elapsed > time_to_update:
		var player_score = snapped(GameManager.player_score, 0.1)
		text = "[center]" + str(player_score)
		time_elapsed = 0


func start_tween():
	await create_tween().tween_property(self, "scale", Vector2(1.1, 1.2), 0.2).finished
	await create_tween().tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).finished
	start_tween()
	
