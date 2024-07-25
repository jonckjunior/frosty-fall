extends Node2D
class_name MainGame

@export var player: Player
@export var cameraFollower: CameraFollower
@onready var effects: Node2D = $Effects
@onready var map_holder: Node2D = $MapHolder

var loaded_maps: Array[Triple] = []

 
func _ready():
	var map = load("res://game_components/map_pieces/map_0.tscn").instantiate()
	map_holder.add_child(map)
	var starterEnder = configure_new_map(map)
	loaded_maps.append(Triple.new(map, starterEnder.first, starterEnder.second))
	player.create_trail.connect(create_trail_for_player)
	

func configure_new_map(new_map) -> Pair:
	var tilemap: TileMap = new_map.get_node("Killer")
	var used_cells = tilemap.get_used_cells(0)
	for cell in used_cells:
		var area = Area2D.new()
		var collision: CollisionShape2D = CollisionShape2D.new()
		var rectangleShape = RectangleShape2D.new()
		rectangleShape.size = Vector2(16, 16)
		
		collision.shape = rectangleShape
		
		area.add_child(collision)
		tilemap.add_child(area)
		area.global_position = cell * 16.0 + Vector2(8, 8)
		
		area.connect("body_entered", kill_player)
	
	var starter = new_map.get_node("Starter").get_used_cells(0).front()
	var ender = new_map.get_node("Ender").get_used_cells(0).front()
	
	return Pair.new(starter, ender)

func kill_player(_body):
	player.hit_bumper()

func create_trail_for_player():
	var trail = load("res://game_components/player/Trail.tscn").instantiate()
	trail.global_position = player.global_position
	trail.rotation = player.animation.rotation
	effects.add_child(trail)

func _input(event):
	if event is InputEvent and (event as InputEvent).is_action_pressed("click"):
		player.initialize_player()
	if event is InputEvent and (event as InputEvent).is_action_pressed("reload"):
		get_tree().reload_current_scene()
