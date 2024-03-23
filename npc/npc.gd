extends CharacterBody2D

@onready var audio = $AudioStreamPlayer2D

signal player_near_npc(body)

func _ready():
	audio.play()
	audio.autoplay = true

func _on_area_2d_body_entered(body):
	player_near_npc.emit(body)
