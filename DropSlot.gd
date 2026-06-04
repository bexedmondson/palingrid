class_name DropSlot extends Control

signal tile_changed(slot: DropSlot)

@export var circle: Control

var slotTile: DropTile

func dragged_away(tile: DropTile) -> void:
	tile.dragged_away.disconnect(dragged_away)
	remove_child(tile)
	slotTile = null
	tile_changed.emit(self)

func setup_tile(tile: DropTile) -> void:
	tile.dragged_away.connect(dragged_away)

func add_tile(tile: DropTile) -> void:
	tile.dragged_away.connect(dragged_away)
	add_child(tile)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return slotTile == null

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var tile: DropTile = data as DropTile
	tile.dragged_away.emit(tile)
	add_tile(tile)
	slotTile = tile
	tile_changed.emit(self)

func letter():
	if (slotTile == null):
		return "-"
	return slotTile.letter().to_lower()

var tween: Tween
func highlight():
	if (tween == null || !tween.is_valid()):
		tween = create_tween()
		tween.tween_property(circle, "modulate:a", 0, 0.5).from(1.0)
	if (tween.is_running()):
		tween.stop()
	tween.play()
