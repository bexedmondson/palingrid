class_name LightDarkMode
extends TextureButton

@export var light : Theme
@export var dark : Theme

@export var rootNode : Control

@export var saveFileHandler : SaveFileHandler

func _enter_tree() -> void:
	var result = saveFileHandler.request_load(SaveFileHandler.SaveType.LIGHTDARK)
	set_pressed_no_signal(result[0] && result[1]) #setting with no signal so we don't immediately try and save after loading
	rootNode.theme = light if is_pressed() else dark

func _on_toggled(toggled_on: bool) -> void:
	rootNode.theme = light if toggled_on else dark
	saveFileHandler.update_flag_and_save_all_flags(SaveFileHandler.SaveType.LIGHTDARK, toggled_on)

func get_active_theme():
	return dark if self.pressed else light
