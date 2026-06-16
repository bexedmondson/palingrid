class_name BestScoreIndicator
extends Label

@export var gridAnimationPlayer : GridRippleAnimator 
@export var dailyGenerator : DailyLetterSetGenerator
@export var bestLabel : Label
@export var bestContainer : Control
@export var grid : Grid

const saveFile : String = "user://score.dat"

var allScores : Dictionary = {}
var best : int = 0
var session_done_anim : bool = false
var has_filled_board_this_session : bool = false
var had_best_score_at_start_of_session : bool = false

func update(current: int) -> void:
	if best >= current:
		return
	
	best = current
	self.text = str(best)
	
	save(current)
	if grid.filled_slot_count() >= grid.letter_count():
		has_filled_board_this_session = true
	
	#print("updates " + str(updates_since_anim))
	
	# in these specific circumstances, even though this is your best score we DON'T want to trigger the big celebration
	# - basically when you're filling in the grid for the first time, we don't want to celebrate every move
	if  grid.filled_slot_count() < grid.letter_count() and not had_best_score_at_start_of_session and not has_filled_board_this_session:
		var tween = self.create_tween()
		tween.set_parallel()
		tween.tween_property(self, "theme_override_colors/font_color", Color.WHITE, 1.0).from(Color.YELLOW)
		tween.tween_property(bestLabel, "theme_override_colors/font_color", Color.WHITE, 1.0).from(Color.YELLOW)
		#tween.tween_property(bestContainer, "scale", Vector2.ONE, 1).from(Vector2.ONE * 1.05)
		#tween.tween_property(bestContainer, "pivot_offset_ratio", Vector2.ONE * 0.5, 1)
		#tween.tween_property(self, "pivot_offset_ratio", Vector2.ONE * 0.5, 1)
		#tween.tween_property(bestLabel, "pivot_offset_ratio", Vector2.ONE * 0.5, 1)
		tween.play()
	else:
		gridAnimationPlayer.do()
		session_done_anim = true

func save(score : int):
	#print("allscores " + str(allScores))
	#print("dayseed " + str(dailyGenerator.daySeed) + " score " + str(score))
	allScores[dailyGenerator.daySeed] = score
	
	#print("allscores " + str(allScores))
	var f = FileAccess.open(saveFile, FileAccess.WRITE_READ)
	f.store_var(allScores)
	f.close()

func load():
	if !FileAccess.file_exists(saveFile):
		return
	
	var f = FileAccess.open(saveFile, FileAccess.READ)
	allScores = f.get_var()
	f.close()
	
	#print(str(allScores))
	
	if allScores.has(dailyGenerator.daySeed):
		best = allScores[dailyGenerator.daySeed]
		if best > 5:
			had_best_score_at_start_of_session = true
	
	var best_text = str(best)
	#print("best score: " + best_text)
	self.text = best_text
