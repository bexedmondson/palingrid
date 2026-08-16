class_name BestScoreIndicator
extends Node

@export var gridAnimationPlayer : GridRippleAnimator 
@export var dailyGenerator : DailyLetterSetGenerator
@export var grid : Grid
@export var scoreboard : Scoreboard
@export var saveFileHandler : SaveFileHandler
@export var lightDarkMode : LightDarkMode

var allScores : Dictionary = {}
var best : int = 0
var session_done_anim : bool = false
var has_filled_board_this_session : bool = false
var had_best_score_at_start_of_session : bool = false
var font_color_flash_tween : Tween

func _ready() -> void:
	CheddaBoards.score_submitted.connect(_on_score_submitted)
	CheddaBoards.logout_success.connect(_on_logged_out)
	
func _on_score_submitted(score: int, streak: int):
	if score < best:
		ScoreSubmitter.submit_score(best)

func update(current: int) -> void:
	if best > current:
		return
		
	if best == current:
		if not had_best_score_at_start_of_session and not has_filled_board_this_session and grid.filled_slot_count() >= grid.letter_count():
			has_filled_board_this_session = true
			show_scoreboard(current)
		return
	
	best = current
	save(current)
	
	# in these specific circumstances, even though this is your best score we DON'T want to trigger the big celebration
	# - basically when you're filling in the grid for the first time, we don't want to celebrate every move
	if grid.filled_slot_count() == grid.letter_count() or has_filled_board_this_session:
		gridAnimationPlayer.do()
		session_done_anim = true
		
	if has_filled_board_this_session or grid.filled_slot_count() < grid.letter_count():
		return	
	
	has_filled_board_this_session = true

func show_scoreboard(score: int):
	if !CheddaBoards.is_authenticated():
		print("[BestScoreIndicator] waiting for leaderboard load")
		CheddaBoards.leaderboard_loaded.connect(submit)
	else:	
		print("[BestScoreIndicator] submitting score as already authenticated")
		ScoreSubmitter.submit_score(score)
	
	scoreboard.show()

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
	var result = saveFileHandler.request_load(SaveFileHandler.SaveType.SCORE)
	if not result[0]:
		return
	
	allScores = result[1]
	
	if allScores.has(dailyGenerator.daySeed):
		best = allScores[dailyGenerator.daySeed]
		if best > 5:
			had_best_score_at_start_of_session = true

func _on_logged_out():
	best = 0
	grid.update(null)
	