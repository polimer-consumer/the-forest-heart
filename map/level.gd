extends Node2D

@onready var ambient_sound = $AudioStreamPlayer
@onready var npc = $NPC

func _ready():
	ambient_sound.play()

func _on_npc_player_near_npc(body):
	if body.is_in_group("player"):
		print("player entered")

