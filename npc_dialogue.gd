extends Area2D


# Called when the node enters the scene tree for the first time.
func _input(event):
	if player_near_frog:
		use_dialogue()
func use_dialogue():
	var dialogue = get_parent().get_node("Dialogue")
	if dialogue:
		dialogue.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
