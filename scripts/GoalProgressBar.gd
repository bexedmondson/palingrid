class_name GoalProgressBar
extends ProgressBar

@export var score_prediction_file : JSON

@export var grid : Grid
@export var ticks : Array[GoalProgressTick]
@export var best_bar : ProgressBar
@export var best_label : Label
@export var best_pointer : Control

var predicted_top_score : int
var model_prediction_halfrange : float

var current_displayed_score = 0

var goals = []
var bar_tween : Tween

func _ready() -> void:
	self.value = 0
	best_bar.value = 0
	
	if grid.is_node_ready():
		_initialise_bar()
	else:
		grid.ready.connect(_initialise_bar)
	grid.score_updated.connect(_on_score_updated)

func _initialise_bar():
	var score_prediction_data = score_prediction_file.data
	var today_dict = grid.generator.today_dict
	var today_prediction_data = score_prediction_data["%d-%02d-%02d" % [ today_dict["year"], today_dict["month"], today_dict["day"] ]]
	predicted_top_score = today_prediction_data["topscore"]
	model_prediction_halfrange = today_prediction_data["halfrange"]
	
	#get reasonable highest goal value from predicted top score and halfrange
	var top_goal = predicted_top_score
	
	if model_prediction_halfrange < 1:
		top_goal -= 1
	elif model_prediction_halfrange > 5:
		top_goal -= 5
	
	#ensure halfrange value isn't disproportionately big or small to ensure tick separation is sensible
	var tick_diff = round(model_prediction_halfrange)
	tick_diff = max(5, tick_diff)
	
	#making sure the minimum possible goal is around 16, because that should be doable i hope
	var max_tick_diff = round((top_goal - 16.0) / (ticks.size() - 1))
	tick_diff = min(max_tick_diff, tick_diff)
	
	#TODO add bonus goal that's same as predicted top score, that only appears after reaching the original top goal
	
	self.max_value = top_goal # TODO make these spaced out a lot more!!
	best_bar.max_value = top_goal
	for i in ticks.size():
		ticks[i].set_target(self.max_value - tick_diff * (ticks.size() - i - 1), self)
	
	var best = grid.bestScore.best
	best_bar.value = best
	
	for t in ticks:
		if t.target_amount <= best:
			t.set_state(GoalProgressTick.TickState.REACHED_PREVIOUS)
		else:
			t.set_state(GoalProgressTick.TickState.NOT_REACHED)

func _on_score_updated(new_score : int):
	if bar_tween != null and bar_tween.is_running():
		bar_tween.kill()
	
	bar_tween = create_tween()
	bar_tween.set_ease(Tween.EASE_IN_OUT)
	bar_tween.set_trans(Tween.TRANS_QUAD)
	bar_tween.tween_method(_update_bar, float(current_displayed_score), float(new_score), 0.3)
	
	bar_tween.play()

func _update_bar(tween_value : float):
	current_displayed_score = tween_value
	var proportion = get_bar_proportion(tween_value)
	
	self.value = proportion * max_value
	
	var best = grid.bestScore.best
	if best_bar.value < best:
		best_bar.value = tween_value
		best_pointer.position.x = self.size.x / self.max_value * tween_value
		best_label.text = "best: %d" % (round(tween_value))
	
	for t in ticks:
		if t.target_amount <= tween_value:
			if t.state == GoalProgressTick.TickState.NOT_REACHED or t.state == GoalProgressTick.TickState.RESET:
				#TODO change to tween anim
				t.set_state(GoalProgressTick.TickState.REACHED_CURRENT)
			else:
				t.set_state(GoalProgressTick.TickState.REACHED_CURRENT)
		else:
			if t.target_amount <= best:
				t.set_state(GoalProgressTick.TickState.REACHED_PREVIOUS)
			else:
				t.set_state(GoalProgressTick.TickState.NOT_REACHED)

func get_bar_proportion(amount):
	var lowest_goal = ticks[0].target_amount
	var x_proportion_before_first_goal = 0.4 * min(amount, lowest_goal) / lowest_goal
	var x_proportion_after_first_goal = 0.6 * max(0, amount - lowest_goal) / (self.max_value - lowest_goal)
	return x_proportion_before_first_goal + x_proportion_after_first_goal
