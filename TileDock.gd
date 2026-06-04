class_name TileDock extends Control

func dragged_away(tile: DropTile) -> void:
	tile.dragged_away.disconnect(dragged_away)
	tile.swapped.disconnect(swapped_for)

func swapped_for(oldTile: DropTile, newTile: DropTile) -> void:
	push_error(str(oldTile) + " " + str(newTile) + " swap " + str(self))
	oldTile.dragged_away.disconnect(dragged_away)
	oldTile.swapped.disconnect(swapped_for)
	
	add_tile(newTile)

func setup_tile(tile: DropTile) -> void:
	tile.dragged_away.connect(dragged_away)
	tile.swapped.connect(swapped_for)

func add_tile(tile: DropTile) -> void:
	tile.dragged_away.connect(dragged_away)
	tile.swapped.connect(swapped_for)
	tile.reparent(self)
	
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var tile: DropTile = data as DropTile
	tile.dragged_away.emit(tile)
	add_tile(tile)
