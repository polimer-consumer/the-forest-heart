extends Node2D

signal fire_extinguished(node)

@onready var fire_sound = $AudioStreamPlayer2D
@onready var fire_extinguish_shape = $FireArea/CollisionShape2D
var fire_scene = preload("..//subscenes/fire.tscn")
var player_in_extinguish_area = false
var player = null
@export var max_fires = 5
@export var area_size = Vector2(70, 70)
@export var min_distance = 20
@export var fire_center = Vector2(-100, -50)

func _ready():
	populate_fires()
	fire_extinguish_shape.shape.size = area_size + Vector2(30, 30)
	fire_extinguish_shape.position = Vector2(area_size.x / 2, area_size.y / 2)
	fire_sound.position = Vector2(area_size.x / 2, area_size.y / 2)
	fire_sound.volume_db = log(max_fires)
	for child in get_children():
		child.position += fire_center
	fire_sound.play()

func _process(_delta):
	if Input.is_action_just_pressed("take_trash") and player_in_extinguish_area and player.has_water_now:
		extunguish_fire()

func extunguish_fire():
	var fires = get_children().filter(func(child): return child.has_method("is_fire"))
	if fires.size() > 0:
		var fire = fires[0]
		fire.queue_free()
		if fires.size() == 1:
			get_children()[0].queue_free()
			player.has_water_now = false
			fire_extinguished.emit(self)

func populate_fires():
	for i in range(max_fires):
		var position_attempts = 0
		var fire_position = Vector2.ZERO
		var can_place = false

		while position_attempts < 100 and not can_place:
			fire_position = Vector2(randf_range(0, area_size.x), randf_range(0, area_size.y))
			can_place = true
			
			for fire in get_children():
				if fire.global_position.distance_to(fire_position) < min_distance:
					can_place = false
					break
			
			position_attempts += 1

		if can_place:
			var fire_instance = fire_scene.instantiate()
			add_child(fire_instance)
			fire_instance.global_position = fire_position


func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player = body
		player_in_extinguish_area = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player = null
		player_in_extinguish_area = false
