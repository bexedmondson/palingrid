extends Node

@export var horizontal_layout_ratio_to_resizeReference_width : float = 0.07#9
@export var vertical_layout_ratio_to_resizeReference_width : float = 0.12#5

@export var tiles : Array[DropTile] = []
@export var cells : Array[DropSlot] = []
@export var referenceControl : Control
@export var tiledock : TileDock

var reference_tile_size : Vector2

func _enter_tree() -> void:
	get_viewport().size_changed.connect(resize)
	tiles[0].tree_entered.connect(grabreference)
	wait_for_tree_ready()

func grabreference():
	reference_tile_size = tiles[0].size

func wait_for_tree_ready():
	await get_tree().root.ready
	resize()

func resize():
	get_viewport().size_changed.disconnect(resize)
	
	if reference_tile_size == Vector2.ZERO:
		reference_tile_size = tiles[0].size
	
	var screen_size = get_viewport().size
	var is_vertical = screen_size.x * 1.1 < screen_size.y
	
	var new_size_val = min(referenceControl.size.x / (8 if is_vertical else 14), referenceControl.size.y / 12)
	var new_cell_size = Vector2.ONE * new_size_val
	var new_tile_size = new_cell_size - Vector2.ONE * 5
	var tile_label_scale_factor = new_tile_size / reference_tile_size
	
	for c in cells:
		c.custom_minimum_size = new_cell_size
	for t in tiles:
		t.custom_minimum_size = new_tile_size
		t.letter_label.scale = tile_label_scale_factor
	
	reconnect_after_layout_reorganised()

func reconnect_after_layout_reorganised():
	await get_tree().process_frame
	get_viewport().size_changed.connect(resize)
