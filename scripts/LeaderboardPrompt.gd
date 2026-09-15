class_name LeaderboardPrompt
extends Node

var show_hide_tween : Tween
var move_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.scale = Vector2.ZERO
	self.visible = false
	
	var wait_tween = create_tween()
	wait_tween.tween_interval(2)
	wait_tween.finished.connect(do_show)
	wait_tween.play()
	#do_show()

func do_show():
	if self.visible:
		return
		
	self.visible = true
	if show_hide_tween != null and show_hide_tween.is_valid():
		show_hide_tween.kill()
	show_hide_tween = TweenLibrary.popup_in_scaled(show_hide_tween, self, 2)
	show_hide_tween.play()
	if not show_hide_tween.finished.is_connected(do_float):
		show_hide_tween.finished.connect(do_float)
		
func do_float():
	var start_y = self.position.y
	
	if show_hide_tween != null and show_hide_tween.finished.is_connected(do_float):
		show_hide_tween.finished.disconnect(do_float)
	move_tween = create_tween()
	move_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	move_tween.set_loops()
	move_tween.tween_property(self, "position:y", start_y + 5, 1.5)
	move_tween.tween_property(self, "position:y", start_y - 5, 1.5)
	
func do_hide():
	if !self.visible:
		return
	
	if move_tween != null and move_tween.is_valid():
		move_tween.pause()
	
	if show_hide_tween != null and show_hide_tween.is_valid():
		show_hide_tween.kill()
	show_hide_tween = TweenLibrary.popup_out(show_hide_tween, self)
	show_hide_tween.play()
	await show_hide_tween.finished

	if move_tween != null and move_tween.is_valid():
		move_tween.kill()
	self.visible = false;
