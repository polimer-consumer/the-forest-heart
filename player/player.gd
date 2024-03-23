extends CharacterBody2D

@export var speed: int = 150
@onready var animation_player = $AnimationPlayer
@onready var audio_listener = $AudioListener2D

func  _ready():
	add_to_group("player")
	audio_listener.make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("right") || Input.is_action_pressed("left") || Input.is_action_pressed("forward") || Input.is_action_pressed("backward"):
		animation_player.play("walk")
	else:
		animation_player.play("idle")
	var direction = Input.get_vector("left", "right", "forward", "backward").normalized()
	velocity = direction * speed
	move_and_slide()
