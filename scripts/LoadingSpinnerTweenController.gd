class_name LoadingSpinnerTweenController
extends Control

@export var _play_immediately : bool

@export var _spinner_bar : Control
@export var _spinner_bar2 : Control

@export var to_show_when_playing : Array[Control]
@export var to_hide_when_playing : Array[Control]

var _is_playing : bool = false

var _spinner_tween1 : Tween
var _spinner_tween2 : Tween
var _spinner_tweenValue : Tween
var _node_show_state_before_play : Dictionary[Control, bool]

func _ready() -> void:
	if _spinner_tween1 == null or !_spinner_tween1.is_valid():
		_spinner_tween1 = create_tween()
		_spinner_tween1.set_loops()
		_spinner_tween1.set_loops()
		_spinner_tween1.tween_property(_spinner_bar, "rotation_degrees", 360.0, 1.5).from(0.0)
	
	if _spinner_tween2 == null or !_spinner_tween2.is_valid():
		_spinner_tween2 = create_tween()
		_spinner_tween2.set_loops()
		_spinner_tween2.tween_property(_spinner_bar2, "rotation_degrees", 360.0, 2.5).from(0.0)
	_spinner_tween2.pause()
	
	if _spinner_tweenValue == null or !_spinner_tweenValue.is_valid():
		_spinner_tweenValue = create_tween()
		_spinner_tweenValue.set_loops()
		_spinner_tweenValue.tween_property(_spinner_bar, "value", 10.0, 0.5).from(28.0)
		_spinner_tweenValue.tween_property(_spinner_bar, "value", 28.0, 0.5)

	if !to_show_when_playing.has(_spinner_bar):
		to_show_when_playing.append(_spinner_bar)
	if !to_show_when_playing.has(_spinner_bar2):
		to_show_when_playing.append(_spinner_bar2)
	
	if _play_immediately:
		play()
	else:
		stop()
		
func play():
	if _is_playing:
		return
	
	_is_playing = true
	
	for to_show in to_show_when_playing:
		_node_show_state_before_play[to_show] = to_show.visible
	for to_hide in to_hide_when_playing:
		_node_show_state_before_play[to_hide] = to_hide.visible
	
	for to_show in to_show_when_playing:
		to_show.visible = true
	for to_hide in to_hide_when_playing:
		to_hide.visible = false
	
	_spinner_tween1.play()
	_spinner_tween2.play()
	_spinner_tweenValue.play()

func stop():
	if !_is_playing:
		return
	
	_is_playing = false

	for to_show in to_show_when_playing:
		to_show.visible = _node_show_state_before_play[to_show]
	for to_hide in to_hide_when_playing:
		to_hide.visible = _node_show_state_before_play[to_hide]
	_node_show_state_before_play.clear()
	
	_spinner_tween1.pause()
	_spinner_tween2.pause()
	_spinner_tweenValue.pause()
	
