extends Node

@export var wordListScroller : ScrollContainer
@export var leftGridSpacer : Control
@export var rightGridSpacer : Control
@export var kofiButton : TextureButton
@export var cell : DropSlot

@export var debug_label : Label

@export var onOnlyWhenHorizontal : Array[Control]

var most_recent_check_vertical : bool = false
var leftSpacerFlagsVertical = Control.SizeFlags.SIZE_FILL
var rightSpacerFlagsVertical = (Control.SizeFlags.SIZE_EXPAND & Control.SizeFlags.SIZE_SHRINK_END)
var spacerFlagsHorizontal = (Control.SizeFlags.SIZE_EXPAND & Control.SizeFlags.SIZE_SHRINK_CENTER)

func _on_ready():
	var screen_size = get_tree().get_root().size
	most_recent_check_vertical = screen_size.x * 1.1 < screen_size.y
	
	debug_label.text = "v0"+ str(screen_size) + " " + str(Vector2.ONE * (screen_size.x / 8 - 5)) + " " + str(cell.size)
	_do_tweak(screen_size)

func tweak():
	var screen_size = get_tree().get_root().size
	var is_vertical = screen_size.x * 1.1 < screen_size.y
	
	debug_label.text = "v0"+ str(screen_size) + " " + str(Vector2.ONE * (screen_size.x / 8 - 5)) + " " + str(cell.size)
	
	if most_recent_check_vertical == is_vertical:
		return
		
	most_recent_check_vertical = is_vertical
	_do_tweak(screen_size)
	
func _do_tweak(screen_size: Vector2i):
	
	wordListScroller.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED if most_recent_check_vertical else ScrollContainer.SCROLL_MODE_RESERVE
	
	leftGridSpacer.set_h_size_flags(leftSpacerFlagsVertical if most_recent_check_vertical else spacerFlagsHorizontal)
	rightGridSpacer.set_h_size_flags(rightSpacerFlagsVertical if most_recent_check_vertical else spacerFlagsHorizontal)
	
	_toggle_items()
	_update_tile_grid_sizes(screen_size)
	

func _toggle_items():
	for control in onOnlyWhenHorizontal:
		control.visible = !most_recent_check_vertical

func _update_tile_grid_sizes(screen_size: Vector2i):
	get_tree().call_group("layout_size_change", "update_min_size_for_layout", most_recent_check_vertical, screen_size)
	get_tree().call_group("layout_size_change", "update_min_size_for_layout", most_recent_check_vertical, screen_size)
	
