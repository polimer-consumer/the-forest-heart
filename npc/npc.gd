extends CharacterBody2D

signal player_near_npc(body)

func _on_area_2d_body_entered(body):
	player_near_npc.emit(body)
