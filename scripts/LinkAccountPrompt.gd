class_name LinkAccountPrompt
extends Node

@export var bestScoreHandler : BestScoreIndicator
@export var dailyGenerator : DailyLetterSetGenerator
@export var saveFileHandler : SaveFileHandler

var show_hide_tween : Tween
var move_tween : Tween

var shouldShow : bool = false

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	self.scale = Vector2.ZERO
	self.visible = false

func ready():
	var resultPrevent = saveFileHandler.request_load(SaveFileHandler.SaveType.LINKACCOUNT_PREVENT)
	if resultPrevent[0] && resultPrevent[1]:
		shouldShow = false
		return
	
	var resultPrompt = saveFileHandler.request_load(SaveFileHandler.SaveType.LINKACCOUNT_PROMPT)
	if resultPrompt[0] && resultPrompt[1] == dailyGenerator.daySeed:
		shouldShow = false
		return

	CheddaBoards.profile_loaded.connect(try_show)
	CheddaBoards.score_submitted.connect(try_show)

func try_show():
	if shouldShow and !self.visible and !CheddaBoards.is_logged_in() and bestScoreHandler.best >= 25:
		do_show()

func do_show():
	if self.visible:
		return

	saveFileHandler.update_int_and_save_all_flags(SaveFileHandler.SaveType.LINKACCOUNT_PROMPT, dailyGenerator.daySeed)

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

func on_toggle_hide_forever(hide_forever: bool):
	saveFileHandler.update_int_and_save_all_flags(SaveFileHandler.SaveType.LINKACCOUNT_PREVENT, hide_forever)
