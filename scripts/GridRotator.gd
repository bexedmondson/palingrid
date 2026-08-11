extends Node

@export var grid : Grid

var rotatedSlotIndexMap = [
	4,  9,  14, 19, 24,
	3,  8,  13, 18, 23,
	2,  7,  12, 17, 22,
	1,  6,  11, 16, 21,
	0,  5,  10, 15, 20
]

# TODO stop the grid from rechecking for words until all tiles have been removed and replaced

func rotate():
	var cells = grid.slots
	
	var tileToCellIndexMap = {}
	
	for index in cells.size():
		var cell = cells[index]
		if cell.slotTile == null:
			continue
		
		tileToCellIndexMap[cell.slotTile] = index
		cell.remove_tile(cell.slotTile)
	
	for tile in tileToCellIndexMap:
		var currentCellIndex = tileToCellIndexMap[tile]
		var targetCellIndex = rotatedSlotIndexMap[currentCellIndex]
		var targetCell = cells[targetCellIndex]
		targetCell.add_tile(tile)