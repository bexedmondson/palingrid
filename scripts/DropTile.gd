class_name DropTile extends Control

signal dragged_away(tile: DropTile)
signal swapped(tileToAdd: DropTile, tileToRemove: DropTile)
signal quick_move_to_dock(tile: DropTile)

@export var letter_label: Label

@export var min_size_horizontal_layout : float
@export var min_size_vertical_layout : float

const DOUBLETAPDELAY = .25
var doubleTapTimeout = 0.0

func _on_ready():
	var screen_size = get_tree().get_root().size
	var is_vertical = screen_size.x * 1.1 < screen_size.y
	update_min_size_for_layout(is_vertical, screen_size)

func _process(delta: float) -> void:
	if doubleTapTimeout > 0:
		doubleTapTimeout -= delta

func get_preview() -> Control:
	var dupe = letter_label.duplicate()
	self.modulate = Color.TRANSPARENT
	return dupe

func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(get_preview())
	return self
	
func set_letter(letter: String):
	letter_label.text = letter.to_upper()

func get_letter():
	return letter_label.text
	
func _notification(notification_type):
	if (notification_type == NOTIFICATION_DRAG_END):
		self.modulate = Color.WHITE

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if doubleTapTimeout > 0:
			quick_move_to_dock.emit(self)
			doubleTapTimeout = 0.0
		else:
			doubleTapTimeout = DOUBLETAPDELAY
	elif event is InputEventMouseButton and event.double_click:
		quick_move_to_dock.emit(self)

func update_min_size_for_layout(is_vertical_layout : bool, screen_size: Vector2i) -> void:
	self.custom_minimum_size = Vector2.ONE * (screen_size.x / 8 - 5)  if is_vertical_layout else Vector2.ONE * min_size_horizontal_layout
	var factor = min_size_horizontal_layout / (screen_size.x / 8 - 5)
	if is_vertical_layout && !letter_label.has_theme_font_size_override("font_size"):
		var current_font_size = letter_label.get_theme_font_size("font_size")
		letter_label.add_theme_font_size_override("font_size", current_font_size / factor)
	elif !is_vertical_layout && letter_label.has_theme_font_size_override("font_size"):
		letter_label.remove_theme_font_size_override("font_size")
