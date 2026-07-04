class_name Word extends Node

@export var word : Label
@export var points : Label

var grid
var indexes = []

func set_word(w: String, i: Array[int], g):
	grid = g
	indexes = i
	word.text = w.to_upper()
	points.text = str(get_points()) + "pts"

func get_word():
	return word.text.to_lower()

func get_points():
	var w = word.text
	return 3 if w.length() == 5 else 2 if w.length() == 4 else 1

func _on_button_pressed() -> void:
	grid.highlight(indexes)
