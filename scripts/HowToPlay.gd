extends Control

@export var saveFileHandler : SaveFileHandler

func _enter_tree() -> void:
	hide()

func _ready() -> void:
	var result = saveFileHandler.request_load(SaveFileHandler.SaveType.HOWTOPLAY)
	if result[0] && result[1]:
		hide()
	else:
		show()
		save()

func save():
	saveFileHandler.update_flag_and_save_all_flags(SaveFileHandler.SaveType.HOWTOPLAY, true)
