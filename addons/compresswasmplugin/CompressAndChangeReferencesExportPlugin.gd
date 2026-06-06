@tool
class_name CompressAndChangeReferencesExportPlugin extends EditorExportPlugin

func _get_name() -> String:
	return "CompressAndChangeReferencesExportPlugin"

func _export_end() -> void:
	print("CompressAndChangeReferencesExportPlugin begin")
	if (get_export_platform() is not EditorExportPlatformWeb):
		return
	
	print("CompressAndChangeReferencesExportPlugin compress start")
	DirAccess.remove_absolute("res://docs/index.wasm.br")
	var output = []
	var exit_code = OS.execute("/usr/bin/brotli", ["-v", "docs/index.wasm"], output)
	print(exit_code)
	for o in output:
		print("\t\t" + o)
	print("CompressAndChangeReferencesExportPlugin compress end")
	
	print("CompressAndChangeReferencesExportPlugin cleanup start")
	DirAccess.remove_absolute("res://docs/index.wasm")
	print("CompressAndChangeReferencesExportPlugin cleanup end")
	
	print("CompressAndChangeReferencesExportPlugin reference change start")
	var contents = FileAccess.get_file_as_string("res://docs/index.html")
	contents.replace("\"index.wasm\"", "\"index.wasm.br\"")
	
	var f = FileAccess.open("res://docs/index.html", FileAccess.WRITE)
	f.store_string(contents)
	f.close()
	print("CompressAndChangeReferencesExportPlugin reference change end")
	
	print("CompressAndChangeReferencesExportPlugin end")
