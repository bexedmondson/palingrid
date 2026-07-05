@tool
extends EditorScript

func _run() -> void:
	var small = {}
	
	var files = ["res://british-english", "res://american-english"]
	
	for path in files:
		var file = FileAccess.open(path, FileAccess.READ)
		while (file.get_position() < file.get_length()):
			var line = file.get_line()
			if (line.length() > 2 && line.length() < 6 && !line.contains("'")):
				small[line] = null
				#print(line)
		file.close()
	
	var smallFile = FileAccess.open("res://small.txt", FileAccess.WRITE)
	for s in small:
		smallFile.store_line(s)
		
	smallFile.close()
