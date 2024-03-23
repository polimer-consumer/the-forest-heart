extends CharacterBody2D

@export var speed: int = 100
@onready var animation_player = $AnimationPlayer

func  _ready():
	add_to_group("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("right") || Input.is_action_pressed("left") || Input.is_action_pressed("forward") || Input.is_action_pressed("backward"):
		animation_player.play("walk")
	else:
		animation_player.play("idle")
	var direction = Input.get_vector("left", "right", "forward", "backward")
	velocity = direction * speed
	move_and_slide()
