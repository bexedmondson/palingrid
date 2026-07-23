extends Node

@export var wordListScroller : ScrollContainer
@export var leftGridSpacer : Control
@export var rightGridSpacer : Control
@export var kofiButton : TextureButton

@export var debug_label : Label

@export var onOnlyWhenHorizontal : Array[Control]

var most_recent_check_vertical : bool = false
var leftSpacerFlagsVertical = Control.SizeFlags.SIZE_FILL
var rightSpacerFlagsVertical = (Control.SizeFlags.SIZE_EXPAND & Control.SizeFlags.SIZE_SHRINK_END)
var spacerFlagsHorizontal = (Control.SizeFlags.SIZE_EXPAND & Control.SizeFlags.SIZE_SHRINK_CENTER)

func _on_ready():
	tweak()

func tweak():
	var screen = get_tree().get_root().size
	var is_vertical = screen.x * 1.1 < screen.y
	
	debug_label.text = "is vertical? " + str(is_vertical) + " " + str(screen)
	
	if most_recent_check_vertical == is_vertical:
		return
	
	most_recent_check_vertical = is_vertical
	
	wordListScroller.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED if is_vertical else ScrollContainer.SCROLL_MODE_RESERVE
	
	leftGridSpacer.set_h_size_flags(leftSpacerFlagsVertical if is_vertical else spacerFlagsHorizontal)
	rightGridSpacer.set_h_size_flags(rightSpacerFlagsVertical if is_vertical else spacerFlagsHorizontal)
	
	_toggle_items()
	_update_tile_grid_sizes()

func _toggle_items():
	for control in onOnlyWhenHorizontal:
		control.visible = !most_recent_check_vertical

func _update_tile_grid_sizes():
	get_tree().call_group("layout_size_change", "update_min_size_for_layout", most_recent_check_vertical)
	get_tree().call_group("layout_size_change", "update_min_size_for_layout", most_recent_check_vertical)
	
