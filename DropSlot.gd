class_name DropSlot extends Control

signal tile_changed(slot: DropSlot)

@export var circle: Control
@export var container: Container

var slotTile: DropTile

func dragged_away(tile: DropTile) -> void:
	tile.dragged_away.disconnect(dragged_away)
	tile.swapped.disconnect(swapped_for)
	slotTile = null
	tile_changed.emit(self)

func swapped_for(oldTile: DropTile, newTile: DropTile) -> void:
	oldTile.dragged_away.disconnect(dragged_away)
	oldTile.swapped.disconnect(swapped_for)
	
	add_tile(newTile)
	slotTile = newTile
	tile_changed.emit(self)

func setup_tile(tile: DropTile) -> void:
	tile.dragged_away.connect(dragged_away)
	tile.swapped.connect(swapped_for)

func add_tile(tile: DropTile) -> void:
	tile.dragged_away.connect(dragged_away)
	tile.swapped.connect(swapped_for)
	tile.reparent(container)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var newTile: DropTile = data as DropTile
	
	if (slotTile != null):
		var tileRemoved = slotTile
		slotTile.dragged_away.emit(slotTile)
		newTile.swapped.emit(newTile, tileRemoved)
	
	add_tile(newTile)
	slotTile = newTile
	tile_changed.emit(self)

func letter():
	if (slotTile == null):
		return "-"
	return slotTile.letter().to_lower()

var tween: Tween
func highlight():
	if (tween == null || !tween.is_valid()):
		tween = create_tween()
		tween.tween_property(circle, "modulate:a", 0, 0.8).from(1.0)
	if (tween.is_running()):
		tween.stop()
	tween.play()
