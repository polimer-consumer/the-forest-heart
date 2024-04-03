extends CanvasLayer

@export_file("*.json") var d_file
var dialogue =[]
var cur_dialogue_id = 0
var d_active = false
var dialog_end = 0 
# Called when the node enters the scene tree for the first time.
func _ready():
	$NinePatchRect.visible = false
	
		
func start():
	if d_active == true and dialog_end == 0:
		return
	d_active = true
	$NinePatchRect.visible = true
	dialogue = load_dialogue()
	cur_dialogue_id = -1
	next_script()
	
func load_dialogue():
	if FileAccess.file_exists(d_file):
		var file = FileAccess.open(d_file, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
		
func _input(event):
	if not d_active:
		return
	if event.is_action_pressed("dialog"):
		next_script()

func next_script():
	cur_dialogue_id += 1
	
	if cur_dialogue_id >= 6:
		dialog_end = 1
		print(dialog_end)
		end()
	
	$NinePatchRect/Name.text = dialogue[cur_dialogue_id]['name']
	$NinePatchRect/Chat.text = dialogue[cur_dialogue_id]['text']

func end():
	d_active = false
	$NinePatchRect.visible = false
	return
	
