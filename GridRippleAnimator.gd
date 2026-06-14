class_name GridRippleAnimator
extends Node

@export var grid : Grid
@export var grid_bg : Panel
@export var grid_glow : Panel
@export var confetti : CPUParticles2D

func do():
	var x = 0
	var y = 0
	var i = 0
	
	grid_bg.material.set("shader_parameter/control_size", grid_bg.size.x + 20.0) #accountng for border size
	
	var tween = create_tween()
	tween.set_parallel()
	
	tween.tween_property(grid_bg.material, "shader_parameter/shine_progress", 1.0, 1.8).from(0.0)
	
	update_confetti_size()
	
	while x * y < grid.letter_count():
		if x < grid.grid_width and y < grid.grid_height:
			add_tween(tween, x, y, i)
		
		if y > 0:
			x = x + 1
			y = y - 1
		else:
			i = i + 1
			y = i
			x = 0
	
	tween.chain().tween_callback(func doConfetti(): confetti.emitting = true)
	tween.tween_property(grid_glow, "modulate:a", 1.0, 0.3)
	tween.chain().tween_interval(0.3)
	tween.chain().tween_property(grid_glow, "modulate:a", 0.0, 0.4)
	tween.play()

func add_tween(tween : Tween, x : int, y : int, i : int):
	var slot = grid.slots[x + y * grid.grid_width]
	var subtween = create_tween()
	subtween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	subtween.chain().tween_property(
		slot, 
		"scale",
		Vector2(1.05, 1.05),
		0.35
	)
	subtween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	subtween.tween_property(
		slot, 
		"scale",
		Vector2(1.1, 1.1),
		0.1
	)
	subtween.tween_interval(0.1)
	subtween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	subtween.tween_property(
		slot, 
		"scale",
		Vector2(1.05, 1.05),
		0.1
	)
	subtween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	subtween.chain().tween_property(
		slot, 
		"scale",
		Vector2.ONE,
		0.45
	)
	tween.tween_subtween(subtween).set_delay(i * 0.1)

func update_confetti_size():
	var scale = grid.size.x / (250 * 2)
	confetti.get_parent().scale = Vector2(scale, scale)
