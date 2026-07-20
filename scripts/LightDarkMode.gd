class_name LightDarkMode
extends TextureButton

@export var light : Theme
@export var dark : Theme

@export var rootNode : Control


func _on_toggled(toggled_on: bool) -> void:
	rootNode.theme = light if toggled_on else dark

func get_active_theme():
	return dark if self.pressed else light
