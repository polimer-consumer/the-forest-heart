extends CharacterBody2D

@export var speed: int = 100
@export var inventory: Inventory
@export var full_bucket: InventoryItem
@export var empty_bucket: InventoryItem
var has_water_now = false
var had_water_before = false
var audio_playing = false

@onready var animation_player = $AnimationPlayer
@onready var audio_listener = $AudioListener2D
@onready var sprite = $Sprite2D
@onready var trash = $"../trash"
@onready var steps_player = $AudioStreamPlayer

func _ready():
	add_to_group("player")
	audio_listener.make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if has_water_now and !had_water_before:
		delete_item(empty_bucket)
		collect_item(full_bucket)
		had_water_before = true
	if !has_water_now and had_water_before:
		delete_item(full_bucket)
		collect_item(empty_bucket)
		had_water_before = false
	var direction = Input.get_vector("left", "right", "forward", "backward").normalized()
	if direction != Vector2.ZERO:
		if !audio_playing:
			steps_player.play()
			audio_playing = true
		if direction.x > 0:
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true
		animation_player.play("walk")
	else:
		audio_playing = false
		steps_player.stop()
		animation_player.play("idle")
	velocity = direction * speed
	move_and_slide()

func _on_trash_player_near_trash():
	pass # Replace with function body.

func collect_item(item):
	inventory.insert(item)

func delete_item(item):
	inventory.delete(item)
