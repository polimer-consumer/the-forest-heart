extends Node2D

func _ready():
	var npc = $NPC
	npc.connect("player_near_npc", Callable(self, "_on_npc_player_near_npc"))

func _on_npc_player_near_npc(body):
	if body.is_in_group("player"):
		print("player entered")

