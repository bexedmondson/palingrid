class_name LoadingSpinnerTweenController
extends Control

@export var play_immediately : bool = true

@export var spinner_bar : Control
@export var spinner_bar2 : Control

@export var to_show_when_playing : Array[Control]
@export var to_hide_when_playing : Array[Control]

var is_playing : bool = false

var spinner_tween1 : Tween
var spinner_tween2 : Tween
var spinner_tweenValue : Tween
var node_show_state_before_play : Dictionary[Control, bool]

func _ready() -> void:
	if spinner_tween1 == null or !spinner_tween1.is_valid():
		spinner_tween1 = create_tween()
		spinner_tween1.set_loops()
		spinner_tween1.set_loops()
		spinner_tween1.tween_property(spinner_bar, "rotation_degrees", 360.0, 1.5).from(0.0)
	
	if spinner_tween2 == null or !spinner_tween2.is_valid():
		spinner_tween2 = create_tween()
		spinner_tween2.set_loops()
		spinner_tween2.tween_property(spinner_bar2, "rotation_degrees", 360.0, 2.5).from(0.0)
	spinner_tween2.pause()
	
	if spinner_tweenValue == null or !spinner_tweenValue.is_valid():
		spinner_tweenValue = create_tween()
		spinner_tweenValue.set_loops()
		spinner_tweenValue.tween_property(spinner_bar, "value", 10.0, 0.5).from(28.0)
		spinner_tweenValue.tween_property(spinner_bar, "value", 28.0, 0.5)

	if !to_show_when_playing.has(spinner_bar):
		to_show_when_playing.append(spinner_bar)
	if !to_show_when_playing.has(spinner_bar2):
		to_show_when_playing.append(spinner_bar2)
	
	if play_immediately:
		play()
	else:
		stop()
		
func play():
	if is_playing:
		return
	
	is_playing = true
	
	for to_show in to_show_when_playing:
		node_show_state_before_play[to_show] = to_show.visible
	for to_hide in to_hide_when_playing:
		node_show_state_before_play[to_hide] = to_hide.visible
		
	print(str(node_show_state_before_play))
	
	for to_show in to_show_when_playing:
		to_show.visible = true
	for to_hide in to_hide_when_playing:
		to_hide.visible = false
	
	spinner_tween1.play()
	spinner_tween2.play()
	spinner_tweenValue.play()

func stop():
	if !is_playing:
		return
	
	is_playing = false

	print(str(node_show_state_before_play))
	for to_show in to_show_when_playing:
		to_show.visible = node_show_state_before_play[to_show]
	for to_hide in to_hide_when_playing:
		to_hide.visible = node_show_state_before_play[to_hide]
	node_show_state_before_play.clear()
	
	spinner_tween1.pause()
	spinner_tween2.pause()
	spinner_tweenValue.pause()
	
