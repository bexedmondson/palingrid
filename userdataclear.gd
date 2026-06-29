@tool
extends EditorScript

func _run():
		print("Hello from the Godot Editor!")
		var fs = DirAccess.get_files_at("user://")
		for f in fs:
			print(f)
			DirAccess.remove_absolute("user://" + f)
