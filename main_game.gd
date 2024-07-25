extends Node2D
class_name MainGame

@export var player: Player
@export var cameraFollower: CameraFollower

@onready var landed_effect_raw: Resource = load("res://assets/player/falling_particle.tscn")

@onready var map_holder: Node2D = $Holders/MapHolder
@onready var lanes_holder: Node2D = $Holders/LanesHolder
@onready var killer_holder: Node2D = $Holders/KillerHolder
@onready var background_holder: Node2D = $Holders/BackgroundHolder
@onready var effect_holder: Node2D = $Holders/EffectHolder
@onready var detail_holder: Node2D = $Holders/DetailHolder
@onready var shadow_holder: Node2D = $Holders/ShadowHolder
@onready var bumper_holder: Node2D = $Holders/BumperHolder
@onready var possible_maps: Array = [
	preload("res://game_components/map_pieces/map_0/map.tscn"),
	preload("res://game_components/map_pieces/map_1/map.tscn")
]

var loaded_maps: Array[Triple] = []

 
func _ready():
	#var map = load("res://game_components/map_pieces/map_0.tscn").instantiate()
	#map_holder.add_child(map)
	#var starterEnder = configure_new_map(map)
	#loaded_maps.append(Triple.new(map, starterEnder.first, starterEnder.second))
	
	add_new_map(0)
	add_new_map(1)
	player.create_trail.connect(create_trail_for_player)
	player.landed.connect(on_player_landed)
	
	GameManager.main_game = self
	

func add_new_map(map_index: int = 0):
	var new_map = possible_maps[map_index].instantiate()
	var starterEnder = configure_new_map(new_map)
	
	if not loaded_maps.is_empty():
		var triple = loaded_maps.back()
		var last_map = triple.first
		var ender_position = triple.third
		var offset_starter = starterEnder.first * 16.0
		new_map.global_position = Vector2(ender_position.x, ender_position.y + 1) * 16.0 + last_map.global_position - offset_starter
	
	loaded_maps.append(Triple.new(new_map, starterEnder.first, starterEnder.second))
	new_map.get_node("Background").reparent(background_holder)
	new_map.get_node("Lane").reparent(lanes_holder)
	new_map.get_node("Shadow").reparent(shadow_holder)
	new_map.get_node("Killer").reparent(killer_holder)
	new_map.get_node("Detail").reparent(detail_holder)
	new_map.get_node("Bumper").reparent(bumper_holder)
	

func configure_new_map(new_map) -> Pair:
	configure_killer(new_map)
	configure_lanes(new_map)
	configure_bumper(new_map)
	
	var starter = new_map.get_node("Starter").get_used_cells(0).front()
	var ender = new_map.get_node("Ender").get_used_cells(0).front()

	return Pair.new(starter, ender)

func configure_lanes(new_map):
	var tilemap: TileMap = new_map.get_node("Lane")
	var used_cells = tilemap.get_used_cells(0)
	for cell in used_cells:
		var area = Area2D.new()
		area.collision_layer = 1 << 1
		area.monitoring = false
		area.monitorable = true
		var collision: CollisionShape2D = CollisionShape2D.new()
		var rectangleShape = RectangleShape2D.new()
		rectangleShape.size = Vector2(16, 16)
		
		collision.shape = rectangleShape
		
		area.add_child(collision)
		tilemap.add_child(area)
		area.position = cell * 16.0 + Vector2(8, 8)

func configure_killer(new_map):
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
		area.position = cell * 16.0 + Vector2(8, 8)
		
		area.connect("body_entered", on_player_killer)

func configure_bumper(new_map):
	var tilemap: TileMap = new_map.get_node("Bumper")
	var used_cells = tilemap.get_used_cells(0)
	for cell in used_cells:
		var area = Area2D.new()
		var collision: CollisionShape2D = CollisionShape2D.new()
		var rectangleShape = RectangleShape2D.new()
		rectangleShape.size = Vector2(16, 16)
		
		collision.shape = rectangleShape
		
		area.add_child(collision)
		tilemap.add_child(area)
		area.position = cell * 16.0 + Vector2(8, 8)
		
		area.connect("body_entered", on_hit_bumper)

func on_player_killer(_body):
	if not player.is_in_the_air():
		player.is_initialized = false
		cameraFollower.apply_shake(1.0)
		player.die_to_obstacle()

func on_hit_bumper(_body):
	player.hit_bumper()

func create_trail_for_player():
	var trail = load("res://game_components/player/Trail.tscn").instantiate()
	trail.global_position = player.global_position
	trail.rotation = player.animation.rotation
	effect_holder.add_child(trail)

func _input(event):
	if event is InputEvent and (event as InputEvent).is_action_pressed("click"):
		player.initialize_player()
		cameraFollower.apply_shake(0.2)
	if event is InputEvent and (event as InputEvent).is_action_pressed("reload"):
		get_tree().reload_current_scene()

func on_player_landed():
	var landed_effect = landed_effect_raw.instantiate()
	landed_effect.global_position = player.global_position
	landed_effect.rotation = player.animation.rotation - PI/2
	effect_holder.add_child(landed_effect)
