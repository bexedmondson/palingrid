extends TextureButton

@export var min_size_vertical_layout : Vector2
@export var min_size_horizontal_layout : Vector2

func _on_ready():
	#get_tree().root.ready.connect(resize)
	resize()

func resize():
	var screen_size = get_tree().get_root().size
	var is_vertical = screen_size.x * 1.1 < screen_size.y
	update_min_size_for_layout(is_vertical, screen_size)

func _on_pressed():
	OS.shell_open("https://ko-fi.com/L4L3FFAX")

func update_min_size_for_layout(is_vertical_layout : bool, screen_size: Vector2i) -> void:
	self.custom_minimum_size = min_size_vertical_layout if is_vertical_layout else min_size_horizontal_layout
