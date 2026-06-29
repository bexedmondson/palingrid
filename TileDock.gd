class_name TileDock extends Control

func dragged_away(tile: DropTile) -> void:
	#push_warning(self.name + " " + tile.name + " tiledock draggedaway")
	tile.dragged_away.disconnect(dragged_away)
	tile.swapped.disconnect(swapped_for)

func swapped_for(oldTile: DropTile, newTile: DropTile) -> void:
	#push_warning(self.name + " " + oldTile.name + " " + newTile.name + " tiledock swap")
	oldTile.dragged_away.disconnect(dragged_away)
	oldTile.swapped.disconnect(swapped_for)
	
	add_tile(newTile)

func setup_tile(tile: DropTile) -> void:
	tile.dragged_away.connect(dragged_away)
	tile.swapped.connect(swapped_for)

func add_tile(tile: DropTile) -> void:
	#push_warning(self.name + " " + tile.name + " tiledock add")
	tile.dragged_away.connect(dragged_away)
	tile.swapped.connect(swapped_for)
	tile.reparent(self)

func tile_count():
	return self.get_child_count()
	
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var tile: DropTile = data as DropTile
	#push_warning(self.name + " " + tile.name + " tiledock drop")
	tile.dragged_away.emit(tile)
	add_tile(tile)

func get_tile():
	if tile_count() == 0:
		return null
	return get_child(0)