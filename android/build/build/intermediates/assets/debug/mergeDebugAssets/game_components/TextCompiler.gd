extends Node2D
var alphabet = []
@export var text: String

func _ready():
	alphabet.append(load("res://assets/fonts/tile_0096.png"))
	alphabet.append(load("res://assets/fonts/tile_0097.png"))
	alphabet.append(load("res://assets/fonts/tile_0098.png"))
	alphabet.append(load("res://assets/fonts/tile_0099.png"))
	for i in range(100, 121 + 1):
		alphabet.append(
			load("res://assets/fonts/tile_0" + str(i) + ".png")
		)
	var offset: float = 0
	for c in text:
		var letter = alphabet[c.unicode_at(0) - 97]
		var sprite = Sprite2D.new()
		sprite.texture = letter
		add_child(sprite)
		sprite.position.x += offset
		offset += 12
