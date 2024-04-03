extends Node2D
signal water_collected()
signal player_near_water()
signal player_exited_water()
@onready var tile_map: TileMap = $TileMap
@onready var ambient_sound = $AmbientForestSound
@onready var lake_sound = $TileMap/Area2D/LakeSound
@onready var npc = $NPC
var ground_layer = 2
var player_is_near = false
var fire_scene = preload("res://bigfire/big_fire.tscn")
var final_seeds_level = 5
var env_layer = 3
var num_seed = 0

func _ready():
	ambient_sound.play()
	lake_sound.play()

func _on_npc_player_near_npc(body):
	if body.is_in_group("player"):
		print("player entered")

func _on_trash_trash_collected():
	remove_child($trash)
	num_seed += 1 
	print("У тебя есть ведро")

func _on_player_entered_water(body):
	if body.is_in_group("player"):
		print("наберите воду")
		player_is_near = true
		player_near_water.emit()
		
func _on_player_exited_water(body):
	if body.is_in_group("player"):
		player_is_near = false
		player_exited_water.emit()
		
func _process(delta):
	if Input.is_action_just_pressed("spawn_fire"):
		var new_fire = fire_scene.instantiate()
		new_fire.fire_center = Vector2(-180, 80)
		add_child(new_fire)
	_player_take_water()
			
func _player_take_water():		
	if Input.is_action_just_pressed("take_water") and player_is_near:
		print( "you have water now")
		num_seed +=1
		water_collected.emit()
		
func _input(event):
	if Input.is_action_just_pressed("seeds") and num_seed > 0:
		var mous_pos: Vector2 = get_global_mouse_position()
		var tile_mouse_pos: Vector2i = tile_map.local_to_map(mous_pos)
		var source_id : int = 8
		var atlas_coard : Vector2i = Vector2i(0,1)
		var level = 0
		var final_seed_level = 4
		tile_map.set_cell(ground_layer, tile_mouse_pos, source_id, atlas_coard)
		handle_seed(tile_mouse_pos, level, atlas_coard, final_seed_level)
		num_seed -= 1
				

func handle_seed(tile_map_pos, level, atlas_coard, final_seed_level):
	var source_id : int = 8
	tile_map.set_cell(ground_layer, tile_map_pos, source_id, atlas_coard)
	await get_tree().create_timer(1.5).timeout
	if level >= final_seed_level:
		return
		print("не растет")
	else:
		var new_atlas: Vector2i = Vector2i(atlas_coard.x +4, atlas_coard.y)
		tile_map.set_cell(ground_layer, tile_map_pos, source_id, new_atlas)
		print("растет")
		handle_seed(tile_map_pos, level+1 , new_atlas, final_seed_level)
	
