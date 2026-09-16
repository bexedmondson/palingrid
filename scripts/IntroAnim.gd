extends Control

@export var wordAnimation : Node

var wordAnimInstance : WordAnimation

func _ready() -> void:
	wordAnimInstance = wordAnimation.create_instance()
	wordAnimInstance.animate_in_speed("PALINGRID", 0.5)
	wordAnimInstance.tween.finished.connect(do_out)
	
func do_out():
	wordAnimInstance.animate_out()
	wordAnimInstance.tween.finished.connect(fade)

func fade():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.play()
	tween.finished.connect(hide)
