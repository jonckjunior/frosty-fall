extends Node2D
var numbers = []
@export var text: String

func _ready():
	for i in range(84, 93 + 1):
		numbers.append(
			load("res://assets/fonts/tile_00" + str(i) + ".png")
		)
	var offset: float = 0
	for c in text:
		var letter = numbers[c.unicode_at(0) - 48]
		var sprite = Sprite2D.new()
		sprite.texture = letter
		add_child(sprite)
		sprite.position.x += offset
		offset += 10
