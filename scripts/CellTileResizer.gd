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
	
	var min_newsize = referenceControl.size.x * (vertical_layout_ratio_to_resizeReference_width if is_vertical else min(horizontal_layout_ratio_to_resizeReference_width, tiledock.size. x / 10))
	print("min_newsize %d, max size %d, reference control %s size %d, is vert %s" % [min_newsize, screen_size.y / 8, referenceControl.name, referenceControl.size.x, str(is_vertical)])

	#var max_newsize = screen_size.x / 8 if is_vertical else screen_size.y / 10
	#print("max_newsize %d, screen size x %d (scaled %d), is vert %s, screen size y %d (scaled %d)" % [max_newsize, screen_size.x, screen_size.x /7, str(is_vertical), screen_size.y, screen_size.y / 10])
	var newsize = Vector2.ONE * min(min_newsize, screen_size.y / 8) #min(, max_newsize)
	#print("screen size %dx%d, max size %d, min size %d, new size %d" % [screen_size.x, screen_size.y, max_newsize, min_newsize, newsize.x])
	
	for c in cells:
		c.custom_minimum_size = newsize
	for t in tiles:
		t.custom_minimum_size = newsize - Vector2.ONE * 5
		var scale_factor = t.custom_minimum_size / reference_tile_size
		t.letter_label.scale = scale_factor
	
	reconnect_after_layout_reorganised()

func reconnect_after_layout_reorganised():
	await get_tree().process_frame
	get_viewport().size_changed.connect(resize)
