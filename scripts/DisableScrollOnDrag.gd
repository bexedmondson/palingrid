extends ScrollContainer

var _scroll_lock : bool
var _scroll_lock_val: int

func _process(_delta: float) -> void:
	if (_scroll_lock):
		scroll_vertical = _scroll_lock_val

func _notification(notification_type):
	if (notification_type == NOTIFICATION_DRAG_BEGIN):
		_scroll_lock = true
		_scroll_lock_val = scroll_vertical
	elif (notification_type == NOTIFICATION_DRAG_END):
		_scroll_lock = false
