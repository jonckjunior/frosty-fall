extends Node2D
class_name MainGame

@export var player: Player
@export var cameraFollower: CameraFollower
@export var click_on_me: RichTextLabel
@export var transition_rect: ColorRect
@export var end_game: Node2D

@onready var landed_effect_raw: Resource = load("res://assets/player/falling_particle.tscn")

@onready var map_holder: Node2D = $Holders/MapHolder
@onready var lanes_holder: Node2D = $Holders/LanesHolder
@onready var killer_holder: Node2D = $Holders/KillerHolder
@onready var background_holder: Node2D = $Holders/BackgroundHolder
@onready var effect_holder: Node2D = $Holders/EffectHolder
@onready var detail_holder: Node2D = $Holders/DetailHolder
@onready var shadow_holder: Node2D = $Holders/ShadowHolder
@onready var bumper_holder: Node2D = $Holders/BumperHolder
@onready var game_over_sound: AudioStreamPlayer2D = $Audio/GameOverSound
@onready var possible_maps: Array = [
	preload("res://game_components/map_pieces/map_0/map_0.tmx"),
	preload("res://game_components/map_pieces/map_1/map_1.tmx"),
	preload("res://game_components/map_pieces/map_2/map_2.tmx"),
	preload("res://game_components/map_pieces/map_3/mapzera_3.tmx"),
	preload("res://game_components/map_pieces/map_4/map_4.tmx"),
]

var loaded_maps: Array[Pair] = []

 
func _ready():
	add_new_map(0)
	player.create_trail.connect(create_trail_for_player)
	player.landed.connect(on_player_landed)
	
	GameManager.main_game = self

func _physics_process(_delta):
	if player.global_position.y > loaded_maps.back().first.y:
		add_new_map(randi_range(0, possible_maps.size() - 1))
	
	free_nodes()

func add_new_map(map_index: int):
	var new_map = possible_maps[map_index].instantiate()
	map_holder.add_child(new_map)
	configure_new_map(new_map)

	var starter_tile = new_map.get_node("Starter").get_used_cells(0).front()
	var ender_tile = new_map.get_node("Ender").get_used_cells(0).front()
	
	if not loaded_maps.is_empty():
		var ender_position = loaded_maps.back().second
		new_map.global_position = ender_position - Vector2(starter_tile.x, 0) * 16 + Vector2(0, 16)
	
	var ender_position = new_map.global_position + ender_tile * 16.0
	var starter_position = new_map.global_position + starter_tile * 16.0
	
	loaded_maps.append(Pair.new(starter_position, ender_position))
	new_map.get_node("Background").reparent(background_holder)
	new_map.get_node("Lane").reparent(lanes_holder)
	new_map.get_node("Shadow").reparent(shadow_holder)
	new_map.get_node("Killer").reparent(killer_holder)
	new_map.get_node("Detail").reparent(detail_holder)
	new_map.get_node("Bumper").reparent(bumper_holder)

func configure_new_map(new_map):
	configure_killer(new_map)
	configure_lanes(new_map)
	configure_bumper(new_map)

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
		await player.game_over
		game_over()

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
		click_on_me.visible = false
	if event is InputEvent and (event as InputEvent).is_action_pressed("reload"):
		get_tree().reload_current_scene()

func on_player_landed():
	var landed_effect = landed_effect_raw.instantiate()
	landed_effect.global_position = player.global_position
	landed_effect.rotation = player.animation.rotation - PI/2
	effect_holder.add_child(landed_effect)

func game_over():
	game_over_sound.play()
	var tween = get_tree().create_tween()
	await tween.tween_method(set_shader_value, 0.0, 1.0, 1.0).finished
	end_game.visible = true

func set_shader_value(value: float):
	(transition_rect.material as ShaderMaterial).set_shader_parameter("progress", value);

func free_nodes():
	free_children_in(map_holder)
	free_children_in(background_holder)
	free_children_in(lanes_holder)
	free_children_in(shadow_holder)
	free_children_in(effect_holder)
	free_children_in(bumper_holder)
	free_children_in(killer_holder)
	free_children_in(detail_holder)

func free_children_in(node):
	for child in node.get_children():
		if player.global_position.y - child.global_position.y > 2000:
			child.queue_free()
			print("freeing ", child)
