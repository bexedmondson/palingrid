extends Node

@export var wordListScroller : ScrollContainer

func _on_ready():
	get_viewport().size_changed.connect(tweak)

func tweak():
	var screen = get_viewport().get_screen_transform()
	if (screen.x < screen.y):
		wordListScroller.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	else:
		wordListScroller.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_RESERVE
