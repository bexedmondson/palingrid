extends Node

var timeSinceFirstClick = 0
var clickCount = 0

var debug_on = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in get_children():
		c.visible = debug_on


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if clickCount == 0:
		return
	
	timeSinceFirstClick += delta

	if timeSinceFirstClick > 1:
		clickCount = 0
		timeSinceFirstClick = 0

func on_click():
	clickCount += 1
	
	if clickCount >= 3:
		timeSinceFirstClick = 0
		clickCount = 0
		toggle_debug()
	

func toggle_debug():
	debug_on = !debug_on
	for c in get_children():
		c.visible = debug_on
