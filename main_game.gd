extends Node2D
class_name MainGame

@export var player: Player
@export var cameraFollower: CameraFollower
@export var click_on_me: AnimatedSprite2D
@export var click_on_me_shake: RichTextLabel
@export var shadowy: ColorRect
@export var score: Node2D

@onready var snowman_raw: Resource = load("res://game_components/snowman.tscn")
@onready var landed_effect_raw: Resource = load("res://assets/player/falling_particle.tscn")
@onready var wolf_raw: Resource = load("res://assets/wolf/Wolf.tscn")
@onready var tutorial: RichTextLabel = $Tutorial

@onready var stop_player_area: Area2D = $Holders/KillerHolder/StopPlayer
@onready var map_holder: Node2D = $Holders/MapHolder
@onready var lanes_holder: Node2D = $Holders/LanesHolder
@onready var killer_holder: Node2D = $Holders/KillerHolder
@onready var background_holder: Node2D = $Holders/BackgroundHolder
@onready var effect_holder: Node2D = $Holders/EffectHolder
@onready var detail_holder: Node2D = $Holders/DetailHolder
@onready var shadow_holder: Node2D = $Holders/ShadowHolder
@onready var bumper_holder: Node2D = $Holders/BumperHolder
@onready var snowman_holder: Node2D = $Holders/SnowmanHolder
@onready var wolf_holder: Node2D = $Holders/WolfHolder

@onready var possible_maps: Array = [
	preload("res://game_components/map_pieces/map_0/map_000.tscn"),
	preload("res://game_components/map_pieces/map_1/map_111.tscn"),
	preload("res://game_components/map_pieces/map_2/map_222.tscn"),
	preload("res://game_components/map_pieces/map_3/map_333.tscn"),
	preload("res://game_components/map_pieces/map_4/map_444.tscn"),
]

var loaded_maps: Array[Pair] = []
var is_active: bool = false
var time_elapsed: float = 0.0

signal game_over 

func _ready():
	add_new_map(0)
	player.create_trail.connect(create_trail_for_player)
	player.landed.connect(on_player_landed)
	stop_player_area.connect("body_entered", on_player_killer)
	
	GameManager.main_game = self

func _physics_process(delta):
	if tutorial.visible == false:
		time_elapsed += delta
	if player.global_position.y > loaded_maps.back().first.y:
		add_new_map(randi_range(0, possible_maps.size() - 1))
	
	free_nodes()
	if player.movement_speed < 100 and time_elapsed > 10.0 and wolf_holder.get_child_count() == 0:
		var wolf = wolf_raw.instantiate()
		wolf.global_position = player.global_position - Vector2(200, 0)
		wolf_holder.add_child(wolf)

func add_new_map(map_index: int):
	var new_map = possible_maps[map_index].instantiate()
	map_holder.add_child(new_map)
	configure_new_map(new_map)

	var starter_tile = new_map.get_node("Starter").get_used_cells(0).front()
	var ender_tile = new_map.get_node("Ender").get_used_cells(0).front()
	
	if not loaded_maps.is_empty():
		var previous_ender_position = loaded_maps.back().second
		new_map.global_position = previous_ender_position - Vector2(starter_tile.x, 0) * 16 + Vector2(0, 16)
	
	var ender_position = new_map.global_position + ender_tile * 16.0
	var starter_position = new_map.global_position + starter_tile * 16.0
	
	loaded_maps.append(Pair.new(starter_position, ender_position))
	new_map.get_node("Background").reparent(background_holder)
	new_map.get_node("Lane").reparent(lanes_holder)
	new_map.get_node("Shadow").reparent(shadow_holder)
	new_map.get_node("Killer").reparent(killer_holder)
	new_map.get_node("Detail").reparent(detail_holder)
	new_map.get_node("Bumper").reparent(bumper_holder)
	new_map.get_node("Snowman").reparent(snowman_holder)

func configure_new_map(new_map):
	configure_killer(new_map)
	configure_lanes(new_map)
	configure_bumper(new_map)
	configure_snowman(new_map)

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

func configure_snowman(new_map):
	var tilemap: TileMap = new_map.get_node("Snowman")
	var used_cells = tilemap.get_used_cells(0)
	for cell in used_cells:
		tilemap.set_cell(0, cell, -1)
		var snowman = snowman_raw.instantiate()
		snowman.global_position = cell * 16.0 + Vector2(8, 8)
		tilemap.add_child(snowman)

func on_player_killer(_body):
	if not player.is_in_the_air():
		player.is_initialized = false
		cameraFollower.apply_shake(1.0)
		player.die_to_obstacle()
		await player.game_over
		game_over.emit()

func on_hit_bumper(_body):
	player.hit_bumper()

func create_trail_for_player():
	var trail = load("res://game_components/player/Trail.tscn").instantiate()
	trail.global_position = player.global_position
	trail.rotation = player.animation.rotation
	effect_holder.add_child(trail)

func _input(event):
	if event is InputEvent and (event as InputEvent).is_action_pressed("click") and not player.is_dying and player.is_initialized == false and is_active:
		player.initialize_player()
		cameraFollower.apply_shake(0.2)
		
		shadowy.visible = false
		score.visible = true
		create_tween().tween_property(click_on_me_shake, "global_position", click_on_me_shake.global_position + Vector2(-200, 0), 0.5).set_trans(Tween.TRANS_SPRING)
		await create_tween().tween_property(tutorial, "global_position", tutorial.global_position + Vector2(-200, 0), 0.5).set_trans(Tween.TRANS_SPRING).finished
		tutorial.visible = false
		
	if event is InputEvent and (event as InputEvent).is_action_pressed("reload"):
		get_tree().reload_current_scene()

func on_player_landed():
	var landed_effect = landed_effect_raw.instantiate()
	landed_effect.global_position = player.global_position
	landed_effect.rotation = player.animation.rotation - PI/2
	effect_holder.add_child(landed_effect)



func free_nodes():
	free_children_in(map_holder)
	free_children_in(background_holder)
	free_children_in(lanes_holder)
	free_children_in(shadow_holder)
	free_children_in(effect_holder)
	free_children_in(bumper_holder)
	free_children_in(killer_holder)
	free_children_in(detail_holder)
	free_children_in(snowman_holder)

func free_children_in(node):
	for child in node.get_children():
		if player.global_position.y - child.global_position.y > 2000:
			child.queue_free()
