extends Control

@export var wordListScroller : ScrollContainer
@export var leftGridSpacer : Control
@export var rightGridSpacer : Control
@export var kofiButton : TextureButton
@export var cell : DropSlot

@export var debug_label : Label

@export var onOnlyWhenHorizontal : Array[Control]

var leftSpacerFlagsVertical = Control.SizeFlags.SIZE_FILL
var rightSpacerFlagsVertical = (Control.SizeFlags.SIZE_EXPAND & Control.SizeFlags.SIZE_SHRINK_END)
var spacerFlagsHorizontal = (Control.SizeFlags.SIZE_EXPAND & Control.SizeFlags.SIZE_SHRINK_CENTER)

func _ready():
	self.grab_focus.call_deferred()
	var screen_size = get_tree().get_root().size
	
	debug_label.text = "v0" + str(screen_size) + " " + str(get_viewport().size)
	get_viewport().size_changed.connect(tweak)

func tweak():
	var screen_size = get_tree().get_root().size
	var is_vertical = screen_size.x * 1.1 < screen_size.y
	
	debug_label.text = "v0" + str(screen_size) + " " + str(get_viewport().size)
	
	leftGridSpacer.set_h_size_flags(leftSpacerFlagsVertical if is_vertical else spacerFlagsHorizontal)
	rightGridSpacer.set_h_size_flags(rightSpacerFlagsVertical if is_vertical else spacerFlagsHorizontal)
	
	for control in onOnlyWhenHorizontal:
		control.visible = !is_vertical
	
	get_tree().call_group("layout_size_change", "update_min_size_for_layout", is_vertical, screen_size)
