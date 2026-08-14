@tool
class_name WordAnimation
extends Control

@export var tile_placeholder : InstancePlaceholder

var tween : Tween

var letters : Array[DropTile] = []

func animate_word(word: String):
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	
	for c in word:
		var new_letter = tile_placeholder.create_instance() as DropTile
		letters.append(new_letter)
		new_letter.set_letter(c)
		
	for i in letters.size():
		var letter = letters[i]
		letter.offset_transform_enabled = true
		letter.offset_transform_position = _get_tile_offset(letter)
		tween.tween_property(letter, "offset_transform_position", Vector2.ZERO, 3).set_delay(0.1 * i)
	
	tween.chain().tween_interval(2.0)
	
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)

	for i in letters.size():
		var letter = letters[i]
		tween.tween_property(letter, "offset_transform_position", _get_tile_offset(letter), 0.5).set_delay(0.05 * i)
		
	tween.finished.connect(_cleanup)
	tween.play()

func _get_tile_offset(tile : Control):
	return Vector2(0, -tile.size.y * 1.1)

func _cleanup():
	for l in letters:
		remove_child(l)
	letters.clear()
