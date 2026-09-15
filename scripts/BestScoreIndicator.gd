class_name BestScoreIndicator
extends Node

signal new_best_reached

@export var gridAnimationPlayer : GridRippleAnimator 
@export var dailyGenerator : DailyLetterSetGenerator
@export var grid : Grid
@export var summaryPopup : SummaryPopup
@export var saveFileHandler : SaveFileHandler
@export var lightDarkMode : LightDarkMode

var allScores : Dictionary = {}
var best : int = 0
var session_done_anim : bool = false
var has_filled_board_today : bool = false
var had_best_score_at_start_of_session : bool = false
var font_color_flash_tween : Tween

func _ready() -> void:
	CheddaBoards.score_submitted.connect(_on_score_submitted)
	CheddaBoards.login_success.connect(_on_logged_in)
	CheddaBoards.logout_success.connect(_on_logged_out)
	CheddaBoards.session_expired.connect(_on_logged_out)
	
func _on_score_submitted(score: int, _streak: int):
	if score < best:
		ScoreSubmitter.submit_score(best)

func update(current: int) -> void:
	# if we're filling the board for the first time that day then we should show the celebration
	if not has_filled_board_today and grid.filled_slot_count() >= grid.letter_count():
		saveFileHandler.update_int_and_save_all_flags(SaveFileHandler.SaveType.GRIDFILL, dailyGenerator.daySeed)
		has_filled_board_today = true
		if best < current:
			new_best_reached.emit()
			best = current
			save(current)
		show_summary(current)
		return
	
	if best >= current:
		return
	
	best = current
	save(current)

	new_best_reached.emit()
	ScoreSubmitter.submit_score(best)
	
	# in these specific circumstances, even though this is your best score we DON'T want to trigger the big celebration
	# - basically when you're filling in the grid for the first time, we don't want to celebrate every move
	if grid.filled_slot_count() == grid.letter_count() or has_filled_board_today:
		gridAnimationPlayer.do()
		session_done_anim = true
		
	if has_filled_board_today or grid.filled_slot_count() < grid.letter_count():
		return	
	
	has_filled_board_today = true

func show_summary(score: int):
	if !CheddaBoards.is_authenticated():
		print("[BestScoreIndicator] waiting for leaderboard load")
		CheddaBoards.leaderboard_loaded.connect(submit)
	else:	
		print("[BestScoreIndicator] submitting score as already authenticated")
		ScoreSubmitter.submit_score(score)

	gridAnimationPlayer.do()
	gridAnimationPlayer.tween.finished.connect(show_summary_popup)

func show_summary_popup():
	gridAnimationPlayer.tween.finished.disconnect(show_summary_popup)
	summaryPopup.do_show()

func submit(_entries):
	if CheddaBoards.leaderboard_loaded.is_connected(submit):
		CheddaBoards.leaderboard_loaded.disconnect(submit)
	
	print("[BestScoreIndicator] Submitting score after leaderboard load: " + str(best))
	ScoreSubmitter.submit_score(best)

func save(score : int):
	print("[BestScoreIndicator] Submitting score: " + str(score))
	ScoreSubmitter.submit_score(score)
	
	allScores[dailyGenerator.daySeed] = score
	
	var f = FileAccess.open(saveFileHandler.get_save_path_for(SaveFileHandler.SaveType.SCORE), FileAccess.WRITE_READ)
	f.get_path_absolute()
	f.store_var(allScores)
	f.close()
	saveFileHandler.update_save_data(SaveFileHandler.SaveType.SCORE, allScores)

func load():
	var resultBoard = saveFileHandler.request_load(SaveFileHandler.SaveType.GRIDFILL)
	if resultBoard[0]:
		has_filled_board_today = dailyGenerator.daySeed == resultBoard[1]
	
	var resultScore = saveFileHandler.request_load(SaveFileHandler.SaveType.SCORE)
	if not resultScore[0]:
		return
	
	allScores = resultScore[1]
	
	if allScores.has(dailyGenerator.daySeed):
		best = allScores[dailyGenerator.daySeed]
		if best > 5:
			had_best_score_at_start_of_session = true
			
func _on_logged_in(nickname: String):
	pass #TODO somehow retrieve best score from today even if on another device? hmm

func _on_logged_out():
	best = 0
	has_filled_board_today = false
	had_best_score_at_start_of_session = false
	grid.update()
	
