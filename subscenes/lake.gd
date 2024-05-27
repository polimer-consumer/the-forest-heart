extends Area2D

func create_water_sound(position: Vector2):
	var audio_stream_player = $LakeSound.duplicate()
	audio_stream_player.position = position
	add_child(audio_stream_player)
	audio_stream_player.play()
