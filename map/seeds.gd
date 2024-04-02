extends Node2D
@onready var timer = $Timer
@onready var seeds = $Sprite
var stage = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.start()
	seeds.frame = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match stage:
		1:
			seeds.frame = 1
		2:
			seeds.frame = 2
		3:
			seeds.frame = 3
		4:
			seeds.frame = 4
		5:
			seeds.frame = 5
			
		


func _on_timer_timeout():
	if stage <= 4:
		stage +=1 
