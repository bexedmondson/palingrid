extends Control

@export var saveFileHandler : SaveFileHandler

var show_hide_tween : Tween

func _enter_tree() -> void:
	hide()

func _ready() -> void:
	var result = saveFileHandler.request_load(SaveFileHandler.SaveType.HOWTOPLAY)
	if result[0] && result[1]:
		hide()
	else:
		do_show()
		save()

func save():
	saveFileHandler.update_flag_and_save_all_flags(SaveFileHandler.SaveType.HOWTOPLAY, true)

func do_show():
	super.show()
	pivot_offset = size * 0.5
	show_hide_tween = TweenLibrary.popup_in(show_hide_tween, self)
	pivot_offset = size * 0.5
	show_hide_tween.play()
	
func do_hide():
	pivot_offset = size * 0.5
	show_hide_tween = TweenLibrary.popup_out(show_hide_tween, self)
	pivot_offset = size * 0.5
	show_hide_tween.play()
	
	await show_hide_tween.finished
	self.visible = false
