class_name GoalProgressTick
extends Panel

enum TickState
{
	NOT_REACHED,
	REACHED_CURRENT,
	REACHED_PREVIOUS,
	RESET
}

@export var state_styleboxes : Dictionary[TickState, StyleBox]

var target_amount : int
var state : TickState = TickState.RESET

func set_target(target : int, progress_bar_max : int):
	target_amount = target
	self.position.x = self.get_parent_control().size.x / progress_bar_max * target

# Called when the node enters the scene tree for the first time.
func set_state(new_state : TickState):
	if state == new_state:
		return
	state = new_state
	add_theme_stylebox_override("panel", state_styleboxes[state])
