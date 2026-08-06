class_name GoalProgressTick
extends Panel

enum TickState
{
	NOT_REACHED,
	REACHED_CURRENT,
	REACHED_PREVIOUS,
	RESET
}

@export var progress_bar : GoalProgressBar
@export var state_styleboxes : Dictionary[TickState, StyleBox]

@export var tooltip : Control
@export var tooltip_label : Label

var target_amount : int
var state : TickState = TickState.RESET

var tooltip_tween : Tween

func _enter_tree() -> void:
	tooltip.scale = Vector2.ZERO
	tooltip.self_modulate.a = 0

func set_target(target : int):
	target_amount = target
	tooltip_label.text = str(target_amount)

# Called when the node enters the scene tree for the first time.
func set_state(new_state : TickState):
	if state == new_state:
		return
	state = new_state
	add_theme_stylebox_override("panel", state_styleboxes[state])

func update_position():
	self.position.x = self.get_parent_control().size.x * progress_bar.get_bar_proportion(target_amount)
	
func on_tooltip_show():
	if tooltip_tween != null and tooltip_tween.is_valid():
		if !tooltip_tween.is_running():
			tooltip_tween.kill()
		else:
			return #already showing the tooltip, no need to restart showing it
	
	tooltip.scale = Vector2.ONE
	
	tooltip_tween = create_tween()
	tooltip_tween.set_parallel(false)
	tooltip_tween.set_trans(Tween.TRANS_QUAD)
	tooltip_tween.set_ease(Tween.EASE_IN)
	tooltip_tween.tween_property(tooltip, "self_modulate:a", 1.0, 0.3).from(0.0)
	tooltip_tween.chain().tween_interval(0.8)
	tooltip_tween.tween_property(tooltip, "self_modulate:a", 0.0, 0.3)
	tooltip_tween.parallel().tween_property(tooltip, "scale", Vector2.ZERO, 0.3)
	tooltip_tween.play()
	
