class_name BestScoreIndicator
extends Label

@export var gridAnimationPlayer : GridRippleAnimator 
@export var dailyGenerator : DailyLetterSetGenerator
@export var bestLabel : Label
@export var bestContainer : Control
@export var grid : Grid
@export var scoreboard : Scoreboard

const saveFile : String = "user://score.dat"

var allScores : Dictionary = {}
var best : int = 0
var session_done_anim : bool = false
var has_filled_board_this_session : bool = false
var had_best_score_at_start_of_session : bool = false

func update(current: int) -> void:
	if best > current:
		return
		
	if best == current:
		if not had_best_score_at_start_of_session and not has_filled_board_this_session and grid.filled_slot_count() >= grid.letter_count():
			has_filled_board_this_session = true
			show_scoreboard(current)
		return
	
	best = current
	self.text = str(best)
	
	save(current)
	
	# in these specific circumstances, even though this is your best score we DON'T want to trigger the big celebration
	# - basically when you're filling in the grid for the first time, we don't want to celebrate every move
	if  grid.filled_slot_count() < grid.letter_count() and not had_best_score_at_start_of_session and not has_filled_board_this_session:
		var tween = self.create_tween()
		tween.set_parallel()
		tween.tween_property(self, "theme_override_colors/font_color", Color.WHITE, 1.0).from(Color.YELLOW)
		tween.tween_property(bestLabel, "theme_override_colors/font_color", Color.WHITE, 1.0).from(Color.YELLOW)
		tween.play()
	else:
		gridAnimationPlayer.do()
		session_done_anim = true
		
	if has_filled_board_this_session or grid.filled_slot_count() < grid.letter_count():
		return	
	
	has_filled_board_this_session = true
	show_scoreboard(current)

func show_scoreboard(score: int):
	if !CheddaBoards.is_authenticated():
		push_warning("[BestScoreIndicator] waiting for leaderboard load")
		CheddaBoards.leaderboard_loaded.connect(submit)
	
	scoreboard.visible = true
	
	if CheddaBoards.is_authenticated():
		push_warning("[BestScoreIndicator] submitting score as already authenticated")
		CheddaBoards.submit_score(score)

func submit(_entries):
	push_warning("[BestScoreIndicator] Submitting score after leaderboard load: " + str(best))
	CheddaBoards.submit_score(best)

func save(score : int):
	CheddaBoards.submit_score(score)
	push_warning("[BestScoreIndicator] Submitting score: " + str(score))
	allScores[dailyGenerator.daySeed] = score
	
	var f = FileAccess.open(saveFile, FileAccess.WRITE_READ)
	f.get_path_absolute()
	f.store_var(allScores)
	f.close()

func load():
	if !FileAccess.file_exists(saveFile):
		return
	
	var f = FileAccess.open(saveFile, FileAccess.READ)
	allScores = f.get_var()
	f.close()
	
	if allScores.has(dailyGenerator.daySeed):
		best = allScores[dailyGenerator.daySeed]
		if best > 5:
			had_best_score_at_start_of_session = true
	
	var best_text = str(best)
	self.text = best_text
