extends Node


func _ready() -> void:
	self.visible = false
	CheddaBoards.session_expired.connect(_on_session_expired)


func _on_session_expired():
	self.visible = true
	CheddaBoards.session_expired.disconnect(_on_session_expired)
	CheddaBoards.login_success.connect(_on_logged_in)

func _on_logged_in():
	CheddaBoards.login_success.disconnect(_on_logged_in)
	self.visible = false