extends StaticBody2D

signal player_near_trash()
signal player_exited_trash()
signal trash_collected()
@onready var trash_sprite = $AnimatedSprite2D
var player_is_near = false
var trash_state
var player
@export var bucket_item: InventoryItem
@export var seed_item: InventoryItem

enum State {
	DEFAULT,
	COLLECTED_1,
	COLLECTED_2,
	CLEAN
}

func _ready():
	trash_state = State.DEFAULT
	trash_sprite.play("first")

func _process(delta):
	if Input.is_action_just_pressed("take_trash") and player_is_near:
		update_trash()

func update_trash():
	match trash_state:
		State.DEFAULT:
			trash_state = State.COLLECTED_1
			trash_sprite.play("second")
			trash_sprite.offset.y = -30
			trash_sprite.scale = Vector2(0.08, 0.08) 
		State.COLLECTED_1:
			trash_state = State.COLLECTED_2
			trash_sprite.offset.y = 10
			trash_sprite.play("third")
		State.COLLECTED_2:
			trash_state = State.CLEAN
			if player:
				player.collect_item(bucket_item)
				player.collect_item(seed_item)
			trash_collected.emit()
	

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_is_near = true
		player = body
		player_near_trash.emit()


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false
		player = null
		player_exited_trash.emit()
