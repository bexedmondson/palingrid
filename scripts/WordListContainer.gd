class_name WordListContainer
extends Control

func on_words_updated():
	await get_tree().process_frame
	_do_resize.call_deferred()
	
func _do_resize():
	custom_minimum_size.y = min(get_child(0).size.y, 800)
