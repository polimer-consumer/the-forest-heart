extends CanvasLayer

@export_file("*.json") var d_file
var dialogue =[]
# Called when the node enters the scene tree for the first time.
func _ready():
	start()
func start():
	dialogue = load_dialogue()
	$NinePatchRect/Name.text = dialogue[0]['name']
	$NinePatchRect/Chat.text = dialogue[4]['text']
	
func load_dialogue():
	if FileAccess.file_exists(d_file):
		var file = FileAccess.open(d_file, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
		
	
	
	
