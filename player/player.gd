extends CharacterBody2D

@export var speed: int = 150
@onready var animation_player = $AnimationPlayer
@onready var audio_listener = $AudioListener2D
@onready var sprite = $Sprite2D
@onready var trash = $"../trash"

func  _ready():
	add_to_group("player")
	audio_listener.make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Input.get_vector("left", "right", "forward", "backward").normalized()
	if direction != Vector2.ZERO:
		if direction.x > 0:
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true
		animation_player.play("walk")
	else:
		animation_player.play("idle")
	velocity = direction * speed
	move_and_slide()


func _on_trash_player_near_trash():
	pass # Replace with function body.
