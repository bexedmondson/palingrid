extends ScrollContainer

var scroll_lock : bool
var scroll_lock_val: float

func _process(delta: float) -> void:
	if (scroll_lock):
		scroll_vertical = scroll_lock_val

func _notification(notification_type):
	if (notification_type == NOTIFICATION_DRAG_BEGIN):
		scroll_lock = true
		scroll_lock_val = scroll_vertical
	elif (notification_type == NOTIFICATION_DRAG_END):
		scroll_lock = false
