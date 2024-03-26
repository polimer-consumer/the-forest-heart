extends StaticBody2D

signal player_near_trash()
signal player_exited_trash()
signal trash_collected()
@onready var sprite = $Sprite2D
var player_is_near = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("take_trash") and player_is_near:
		sprite.texture = ResourceLoader.load("res://tiles/Trees (2).png")
		trash_collected.emit()
		

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_is_near = true
		player_near_trash.emit()


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_is_near = false
		player_exited_trash.emit()
