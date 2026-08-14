class_name GridRotator
extends Node

signal end_of_frame

@export var grid : Grid
@export var gridInputBlocker : Control

var rotatedSlotIndexMap = [
	4,  9,  14, 19, 24,
	3,  8,  13, 18, 23,
	2,  7,  12, 17, 22,
	1,  6,  11, 16, 21,
	0,  5,  10, 15, 20
]

# TODO stop the grid from rechecking for words until all tiles have been removed and replaced

var _rotate_tween : Tween

func _ready() -> void:
	gridInputBlocker.visible = false

func rotate():
	if get_is_rotating():
		return
	
	var cells = grid.slots
	
	var tileToCellIndexMap : Dictionary[DropTile, int] = {}
	var tileToOriginalGlobalPositionMap : Dictionary[DropTile, Vector2] = {}
	
	for index in cells.size():
		var cell = cells[index]
		if cell.slotTile == null:
			continue
		
		tileToCellIndexMap[cell.slotTile] = index
		tileToOriginalGlobalPositionMap[cell.slotTile] = cell.slotTile.global_position
		cell.remove_tile(cell.slotTile)
	
	for tile in tileToCellIndexMap:
		var currentCellIndex = tileToCellIndexMap[tile]
		var targetCellIndex = rotatedSlotIndexMap[currentCellIndex]
		var targetCell = cells[targetCellIndex]
		targetCell.add_tile(tile)

	on_end_of_frame.call_deferred()
	await end_of_frame

	gridInputBlocker.visible = true
	_rotate_tween = create_tween()
	_rotate_tween.set_parallel(true)
	_rotate_tween.set_trans(Tween.TRANS_SINE)
	_rotate_tween.set_ease(Tween.EASE_IN_OUT)
	
	for tile in tileToOriginalGlobalPositionMap:
		tile.offset_transform_enabled = true
		tile.offset_transform_position = tileToOriginalGlobalPositionMap[tile] - tile.global_position
		_rotate_tween.tween_property(tile, "offset_transform_position", Vector2.ZERO, 0.6)
	
	##TODO to get tiles moving in arcs around the center point, consider offsetting to have the pivot at the grid centre and then rotating around maybe? but keeping y up obvs

	_rotate_tween.finished.connect(on_rotate_finished)
	_rotate_tween.play()

	
func on_end_of_frame():
	end_of_frame.emit()


func on_rotate_finished():
	gridInputBlocker.visible = false
	

func get_is_rotating():
	return _rotate_tween != null && _rotate_tween.is_valid()