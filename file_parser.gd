@tool
extends Node

@export_tool_button("parse") var parseAction = parse 
func parse() -> void:
	var file = FileAccess.open("res://wordlist-20210729.txt", FileAccess.READ)
	var lines = 0
	var small = 0
	var count =0
	while (file.get_position() <file.get_length()):
		count += 1
		var line = file.get_line()
		lines +=1
		if (line.length() > 4 && line.length() <8):
			small+=1
			print(line)
		if (count % 10000 == 0):
			print("10000: small: ", small)
	print("lines ", lines, ", small ", small)
	file.close()
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
