class_name TileDock extends Control

func dragged_away(tile: DropTile) -> void:
	tile.dragged_away.disconnect(dragged_away)
	remove_child(tile)

func setup_tile(tile: DropTile) -> void:
	tile.dragged_away.connect(dragged_away)

func add_tile(tile: DropTile) -> void:
	tile.dragged_away.connect(dragged_away)
	add_child(tile)
	
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var tile: DropTile = data as DropTile
	tile.dragged_away.emit(tile)
	add_tile(tile)
