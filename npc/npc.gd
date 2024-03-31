extends CharacterBody2D

signal player_near_npc(body)
var player_near_frog = false 

@onready var audio = $AudioStreamPlayer2D
@onready var animation = $AnimatedSprite2D
@onready var timer = $Timer
var current_state = State.IDLE
@export var speed = 50
@export var area_min = Vector2(-50, -50)
@export var area_max = Vector2(50, 50)
var direction = Vector2()

enum State {
	IDLE,
	CHANGE_DIR,
	MOVING
}

func _ready():
	area_max += position
	area_min += position
	audio.play()
	audio.autoplay = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	set_timer()
	update_state(State.IDLE)

func set_timer():
	timer.wait_time = randf_range(0.5, 1.0)
	timer.start()

func _on_timer_timeout():
	var next_state = randi() % State.MOVING
	update_state(next_state)

func update_state(new_state):
	current_state = new_state
	match current_state:
		State.IDLE:
			velocity = Vector2.ZERO
			animation.play("idle")
		State.CHANGE_DIR:
			var attempts = 0
			var potential_direction = Vector2()
			var can_move = false
			while attempts < 10 and not can_move:
				potential_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
				can_move = can_move_to_direction(potential_direction, speed * timer.wait_time)
				attempts += 1
			if can_move:
				direction = potential_direction
				update_state(State.MOVING)
			else:
				set_timer()
		State.MOVING:
			if can_move_to_direction(direction, speed * timer.wait_time):
				velocity = direction * speed
				if direction.x < 0:
					animation.flip_h = false
				else:
					animation.flip_h = true
				animation.play("jump")
			else:
				update_state(State.IDLE)
			set_timer()
			

func can_move_to_direction(direction, speed) -> bool:
	var new_position = position + direction * speed
	return new_position.x >= area_min.x && new_position.x <= area_max.x && new_position.y >= area_min.y && new_position.y <= area_max.y


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		timer.stop()
		update_state(State.IDLE)
		player_near_npc.emit(body)
		use_dialogue()
		
func use_dialogue():
	var dialogue = get_parent().get_node("Dialogue")
	if dialogue:
		dialogue.start()

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		set_timer()

func _physics_process(delta):
	move_and_collide(velocity * delta)
