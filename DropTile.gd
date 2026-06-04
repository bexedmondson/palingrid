class_name DropTile extends Control

signal dragged_away(card: DropTile)

@export var texture_rect: TextureRect
@export var card_face: Panel 
@export var letter_label: Label
@export var sprite_2d: Sprite2D 

func get_preview() -> Control:
	return letter_label.duplicate()

func _get_drag_data(_at_position: Vector2) -> Variant:
	set_drag_preview(get_preview())
	return self
	
func set_letter(letter: String):
	letter_label.text = letter.to_upper()

func letter():
	return letter_label.text
