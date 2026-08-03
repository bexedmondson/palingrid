class_name GoalProgressTick
extends Panel

enum TickState
{
	NOT_REACHED,
	REACHED_CURRENT,
	REACHED_PREVIOUS
}

@export var state_styleboxes : Dictionary[TickState, StyleBox]

var target_amount : int
var state : TickState

func set_target(target : int, max : int):
	target_amount = target
	self.position.x = self.get_parent_control().size.x / max * target

# Called when the node enters the scene tree for the first time.
func set_state(new_state : TickState):
	if state == new_state:
		return
