class_name DropSlot extends Control

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
	var card: DropTile = data as DropTile
	card.dragged_away.emit(card)
	add_tile(card)
