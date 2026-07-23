extends TextureButton

@export var min_size_vertical_layout : Vector2
@export var min_size_horizontal_layout : Vector2

func _on_pressed():
	OS.shell_open("https://ko-fi.com/L4L3FFAX")

func update_min_size_for_layout(is_vertical_layout : bool) -> void:
	self.custom_minimum_size = min_size_vertical_layout if is_vertical_layout else min_size_horizontal_layout
