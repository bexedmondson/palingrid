extends Control

@export var saveFileHandler : SaveFileHandler

func _enter_tree() -> void:
	hide()

func _ready() -> void:
	var result = saveFileHandler.request_load(SaveFileHandler.SaveType.HOWTOPLAY)
	#if result[0] && result[1]:
		#hide()
	#else:
		#show()
		#save()

func save():
	var f = FileAccess.open(saveFileHandler.get_save_path_far(SaveFileHandler.SaveType.HOWTOPLAY), FileAccess.WRITE_READ)
	f.get_path_absolute()
	f.store_8(1)
	f.close()
