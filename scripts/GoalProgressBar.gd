class_name GoalProgressBar
extends ProgressBar

@export var grid : Grid
@export var ticks : Array[GoalProgressTick]

func _ready() -> void:
	self.value = 0
	
	if grid.is_node_ready():
		_initialise()
	else:
		grid.ready.connect(_initialise)
	grid.score_updated.connect(_on_score_updated)

func _initialise():
	#do tick target setup here
	self.max_value = 50
	for i in ticks.size():
		ticks[i].set_target(10 * (i + 1), self.max_value)
	
	var best = grid.bestScore.best
	for t in ticks:
		if t.target_amount <= best:
			t.set_state(GoalProgressTick.TickState.REACHED_PREVIOUS)
		else:
			t.set_state(GoalProgressTick.TickState.NOT_REACHED)

func _on_score_updated(new_score : int):
	for t in ticks:
		if t.target_amount <= new_score:
			if t.state == GoalProgressTick.TickState.NOT_REACHED:
				#TODO change to tween anim
				t.set_state(GoalProgressTick.TickState.REACHED_CURRENT)
			else:
				t.set_state(GoalProgressTick.TickState.REACHED_CURRENT)
		else:
			if t.state == GoalProgressTick.TickState.NOT_REACHED:
				#TODO change to tween anim
				t.set_state(GoalProgressTick.TickState.REACHED_PREVIOUS)
			else:
				t.set_state(GoalProgressTick.TickState.NOT_REACHED)
