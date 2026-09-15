class_name SummaryPopup
extends Control

@export var grid : Grid
@export var scoreboard : Scoreboard
@export var goalProgressBar : GoalProgressBar
@export var bestScoreHandler : BestScoreIndicator

@export var scoreLabel : Label
@export var infoContainer : Control

@export var wordAnimation : InstancePlaceholder
@export var totalWordsLabel : Label
@export var usedTilesLabel : Label
@export var bestWordLabel : Label
@export var rankLabel : RichTextLabel

var show_hide_tween : Tween
var wordAnimInstance : WordAnimation

func do_show():
	super.show()

	wordAnimInstance = wordAnimation.create_instance()
	wordAnimInstance.modulate.a = 0
	
	scoreLabel.text = " %d " % bestScoreHandler.best
	infoContainer.modulate.a = 0;
	totalWordsLabel.text = "total words: %d" % grid.wordInstanceMap.size()
	usedTilesLabel.text = "tiles used: %d/%d" % [grid.count_used_tiles(), grid.tiles.size()]
	bestWordLabel.text = ""#"best word:\n%s - %d" % []
	rankLabel.text = ""#"[img height=1.25em align=top,top]res://textures/podium-complex.svg[/img]" # "leaderboard rank: %d" % Cheddaboards.get_leaderboard_rank()

	show_hide_tween = TweenLibrary.popup_in(show_hide_tween, self)
	show_hide_tween.play()
	
	show_hide_tween.finished.connect(do_word_animation)


func on_leaderboard_button():
	scoreboard.show()
	
func do_word_animation():
	show_hide_tween.finished.disconnect(do_word_animation)
	
	wordAnimInstance.modulate.a = 1
	wordAnimInstance.animate_in(goalProgressBar.get_current_goal_name())
	#wordAnimInstance.tween.finished.connect(show_more_info)
	show_more_info()

func show_more_info():
	var fadeTween = create_tween()
	fadeTween.tween_interval(0.5)
	fadeTween.tween_property(infoContainer, "modulate:a", 1.0, 0.1)
	fadeTween.play()
	

func do_hide():
	wordAnimInstance.animate_out()
	wordAnimInstance.tween.finished.connect(hide_self)
	
func hide_self():
	#wordAnimInstance.queue_free() #<- will do this itself, no need to do it here
	wordAnimInstance = null
	
	show_hide_tween = TweenLibrary.popup_out(show_hide_tween, self)
	show_hide_tween.play()

	await show_hide_tween.finished
	self.visible = false
	infoContainer.modulate.a = 0;
