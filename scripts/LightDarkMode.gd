class_name LightDarkMode
extends TextureButton

@export var light : Theme
@export var dark : Theme

@export var nodesToToggleTheme : Array[Control]

@export var saveFileHandler : SaveFileHandler

signal on_theme_changed

func _enter_tree() -> void:
	var result = saveFileHandler.request_load(SaveFileHandler.SaveType.LIGHTDARK)
	set_pressed_no_signal(result[0] && result[1]) #setting with no signal so we don't immediately try and save after loading
	for node in nodesToToggleTheme:
		node.theme = light if is_pressed() else dark

func _on_toggled(toggled_on: bool) -> void:
	for node in nodesToToggleTheme:
		node.theme = light if toggled_on else dark
	saveFileHandler.update_flag_and_save_all_flags(SaveFileHandler.SaveType.LIGHTDARK, toggled_on)
	on_theme_changed.emit(toggled_on)
