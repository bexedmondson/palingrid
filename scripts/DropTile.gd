class_name DropTile extends Control

signal dragged_away(tile: DropTile)
signal swapped(tileToAdd: DropTile, tileToRemove: DropTile)
signal quick_move_to_dock(tile: DropTile)

@export var letter_label: Label

const DOUBLETAPDELAY = .25
var doubleTapTimeout = 0.0

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
