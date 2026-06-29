extends Node

@export var grid : Grid
@export var dock : TileDock

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F:
			try_add_random_tile_to_board()

func try_add_random_tile_to_board():
	var tile = dock.get_tile()
	if tile == null:
		return
	var slot = grid.get_empty_slot()
	if slot == null:
		return
	
	slot._drop_data(Vector2.ZERO, tile)
		