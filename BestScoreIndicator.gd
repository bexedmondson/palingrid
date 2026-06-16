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
var updates_since_anim : int = 0

func update(current: int) -> void:
	if best >= current:
		return
	
	best = current
	self.text = str(best)
	
	save(current)
	#print("updates " + str(updates_since_anim))
	if  grid.filled_slot_count() < grid.letter_count() or (session_done_anim and updates_since_anim < 1):
		var tween = self.create_tween()
		tween.set_parallel()
		tween.tween_property(self, "theme_override_colors/font_color", Color.WHITE, 1).from(Color.YELLOW)
		tween.tween_property(bestLabel, "theme_override_colors/font_color", Color.WHITE, 1).from(Color.YELLOW)
		#tween.tween_property(bestContainer, "scale", Vector2.ONE, 1).from(Vector2.ONE * 1.05)
		#tween.tween_property(bestContainer, "pivot_offset_ratio", Vector2.ONE * 0.5, 1)
		#tween.tween_property(self, "pivot_offset_ratio", Vector2.ONE * 0.5, 1)
		#tween.tween_property(bestLabel, "pivot_offset_ratio", Vector2.ONE * 0.5, 1)
		tween.play()
		updates_since_anim = updates_since_anim + 1
	else:
		gridAnimationPlayer.do()
		session_done_anim = true
		updates_since_anim = 0

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
	
	var best_text = str(best)
	#print("best score: " + best_text)
	self.text = best_text
