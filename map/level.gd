extends Node2D
signal water_collected()
signal player_near_water()
signal player_exited_water()
@onready var ambient_sound = $AudioStreamPlayer
@onready var npc = $NPC
var player_is_near = false
var fire_scene = preload("res://bigfire/big_fire.tscn")

func _ready():
	ambient_sound.play()

func _on_npc_player_near_npc(body):
	if body.is_in_group("player"):
		print("player entered")



func _on_trash_trash_collected():
	print(" У тебя есть ведро")


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
		new_fire.fire_center = Vector2(randf_range(-100, 300), randf_range(-100, 300))
		add_child(new_fire)
	_player_take_water()
			
func _player_take_water():		
	if Input.is_action_just_pressed("take_water") and player_is_near:
		print( "you have water now")
		water_collected.emit()
	
	
