class_name DropTile extends Control

signal dragged_away(card: DropTile)

@export var letter_label: Label

func get_preview() -> Control:
	var dupe = letter_label.duplicate()
	self.modulate = Color.TRANSPARENT
	return dupe

func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(get_preview())
	return self
	
func set_letter(letter: String):
	letter_label.text = letter.to_upper()

func letter():
	return letter_label.text
	
func _notification(notification_type):
	if (notification_type == NOTIFICATION_DRAG_END):
		self.modulate = Color.WHITE