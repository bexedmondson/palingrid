extends Control

@export var letter_label: Label

func set_letter(letter: String):
	letter_label.text = letter.to_upper()

func get_letter():
	return letter_label.text