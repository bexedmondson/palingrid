class_name Word extends Node

@export var word : Label
@export var points : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_word(w: String):
	word.text = w
	points.text = str(get_points()) + "pts"

func get_points():
	var w = word.text
	return 3 if w.length() == 5 else 2 if w.length() == 4 else 1
