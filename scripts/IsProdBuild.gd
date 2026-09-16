extends Node

var isProd : bool = false

func _ready() -> void:
	isProd = !Engine.is_editor_hint()