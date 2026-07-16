extends TextureButton

@export var light : Theme
@export var dark : Theme

@export var rootNode : Control


func _on_toggled(toggled_on: bool) -> void:
	rootNode.theme = light if toggled_on else dark
