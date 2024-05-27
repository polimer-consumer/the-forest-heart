extends Control

@onready var inventory = preload("res://inventory/player_inventory.tres")
@onready var slots = $NinePatchRect/GridContainer.get_children()
var is_open = false
signal inventory_open()
signal inventory_close()

func _ready():
	inventory.update_slot.connect(update)
	update()
	close()

func _process(_delta):
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			inventory_close.emit()
			close()
		else:
			inventory_open.emit()
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
