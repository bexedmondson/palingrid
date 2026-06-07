class_name DropSlot extends Control

signal tile_changed(slot: DropSlot)

@export var circle: Control
@export var container: Container

@export var tileDock : TileDock

var slotTile: DropTile

func remove_tile(tile: DropTile) -> void:
	#push_warning(self.name + " " + tile.name + " remove, current " + (slotTile.name if slotTile != null else "null"))
	if (tile != slotTile):
		push_error(self.name + " removing tile " + tile.name + " but current tile is " + slotTile.name)
	slotTile.dragged_away.disconnect(dragged_away)
	slotTile.swapped.disconnect(swapped_for)
	slotTile.quick_move_to_dock.disconnect(quick_move_tile_to_dock)
	slotTile = null
	tile_changed.emit(self)

func dragged_away(tile: DropTile) -> void:
	#push_warning(self.name + " " + tile.name + " draggedaway, current " + ((slotTile.name if slotTile != null else "null") if slotTile != null else "null"))
	remove_tile(tile)

func swapped_for(oldTile: DropTile, newTile: DropTile) -> void:
	#push_warning(self.name + " " + oldTile.name + " old, " + newTile.name + "new, swap, current " + (slotTile.name if slotTile != null else "null"))
	remove_tile(oldTile)
	add_tile(newTile)

func add_tile(tile: DropTile) -> void:
	#push_warning(self.name + " " + tile.name + " add, current " + (slotTile.name if slotTile != null else "null"))
	tile.dragged_away.connect(dragged_away)
	tile.swapped.connect(swapped_for)
	tile.quick_move_to_dock.connect(quick_move_tile_to_dock)
	tile.reparent(container)
	slotTile = tile
	tile_changed.emit(self)

func quick_move_tile_to_dock(tile: DropTile) -> void:
	#push_warning(self.name + " " + tile.name + " quick move")
	var tile_to_move = tile
	remove_tile(tile)
	tileDock.add_tile(tile)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var newTile: DropTile = data as DropTile
	#push_warning(self.name + " " + newTile.name + " drop, current " + ((slotTile.name if slotTile != null else "null") if slotTile != null else "null"))
	
	if (slotTile == newTile):
		#if we're dropping the same tile where it was originally, we don't need to do anything
		return
	
	if (slotTile != null):
		# if we have a tile here already, we need to swap them
		var tileRemoved = slotTile
		#push_warning(self.name + " drop_data if " + ((slotTile.name if slotTile != null else "null") if slotTile != null else "null"))
		
		#remove the current tile that's here from its parent (i.e. us, but let's do it with signals to be consistent)
		slotTile.dragged_away.emit(slotTile)
		
		#and use the swapped signal on the new tile to both add the tile that's here and clean up the old that was there
		newTile.swapped.emit(newTile, tileRemoved)
	else:
		# clean up the old attachments from the new tile's previous parent
		newTile.dragged_away.emit(newTile)
	
	# finally, add the new tile here
	add_tile(newTile)

func letter():
	if (slotTile == null):
		return "-"
	return slotTile.letter().to_lower()

var tween: Tween
func highlight():
	if (tween == null || !tween.is_valid()):
		tween = create_tween()
		tween.tween_property(circle, "modulate:a", 0, 1.2).from(1.0)
	if (tween.is_running()):
		tween.stop()
	tween.play()
