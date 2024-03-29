extends Control

@onready var inventory = preload("res://inventory/player_inventory.tres")
@onready var slots = $NinePatchRect/GridContainer.get_children()
var is_open = false

func _ready():
	update()
	close()

func _process(_delta):
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close()
		else:
			open()

func update():
	for i in range(min(inventory.items.size(), slots.size())):
		slots[i].update(inventory.items[i])

func close():
	print("inventory close")
	is_open = false
	visible = false

func open():
	print("inventory open")
	is_open = true
	visible = true
