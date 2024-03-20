extends CharacterBody2D

const SPEED: int = 200  

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Input.get_vector("left", "right", "forward", "backward")
	velocity = direction * SPEED
	move_and_slide()
