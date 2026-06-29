class_name NameChangeHandler
extends Control

signal on_closed 

@export var loginHandler : LoginHandler
@export var title_label : Label
@export var subtitle_label : Label
@export var name_line_edit : LineEdit
@export var name_status_label : Label
@export var confirm_button : Button

const MIN_NAME_LENGTH: int = 2
const MAX_NAME_LENGTH: int = 16

var is_rename = false

func _ready() -> void:
	self.visible = false

# ============================================================
# NAME ENTRY PANEL HANDLERS
# ============================================================
func _show_name_entry_panel(rename: bool = false):
	"""Show name entry panel. Mode: 'first_play' = start game after, 'rename' = return to dashboard"""
	is_rename = rename
	
	if is_rename:
		if title_label:
			title_label.text = "Change Name"
		if subtitle_label:
			subtitle_label.text = "This will update the leaderboard too"
		if confirm_button:
			confirm_button.text = "SAVE"
		var current_nick = CheddaBoards.get_nickname()
		if current_nick != "":
			name_line_edit.text = current_nick
		elif not loginHandler.nickname.is_empty():
			name_line_edit.text = loginHandler.nickname
		else:
			name_line_edit.text = ""
	else:
		if title_label:
			title_label.text = "Enter Your Name"
		if subtitle_label:
			subtitle_label.text = "This will appear on the leaderboard"
		if confirm_button:
			confirm_button.text = "LET'S GO!"
		if not loginHandler.nickname.is_empty():
			name_line_edit.text = loginHandler.nickname
		else:
			name_line_edit.text = _generate_default_name()
	
	name_line_edit.placeholder_text = "Enter your name..."
	name_status_label.text = ""
	
	self.visible = true
	
	name_line_edit.grab_focus()
	_update_confirm_button_state()


func _generate_default_name() -> String:
	"""Generate a unique default name like 'Player_4829'"""
	randomize()
	var suffix = str(randi() % 10000).pad_zeros(4)
	return "Player_%s" % suffix


func _on_name_text_changed(_new_text: String):
	"""Handle name text changes"""
	_update_confirm_button_state()
	name_status_label.text = ""


func _on_name_submitted(_name_text: String):
	"""Handle Enter key in name field"""
	if not confirm_button.disabled:
		_on_confirm_name_pressed()


func _update_confirm_button_state():
	"""Enable/disable confirm button based on name validity"""
	var name_text = name_line_edit.text.strip_edges()
	var is_valid = name_text.length() >= MIN_NAME_LENGTH and name_text.length() <= MAX_NAME_LENGTH
	confirm_button.disabled = not is_valid


func _on_confirm_name_pressed():
	"""Confirm name - behaviour depends on _name_entry_mode"""
	var name_text = name_line_edit.text.strip_edges()
	
	push_warning("=== NAME CONFIRMATION (mode: %s) ===" % "rename" if is_rename else "first time")
	push_warning("Entered name: '%s'" % name_text)
	push_warning("Player ID: '%s'" % CheddaBoards.get_player_id())
	
	if name_text.length() < MIN_NAME_LENGTH:
		name_status_label.text = "Name too short (min %d characters)" % MIN_NAME_LENGTH
		name_status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	if name_text.length() > MAX_NAME_LENGTH:
		name_status_label.text = "Name too long (max %d characters)" % MAX_NAME_LENGTH
		name_status_label.add_theme_color_override("font_color", Color.RED)
		return
	
	CheddaBoards.nickname_changed.connect(_on_nickname_change_success)
	CheddaBoards.nickname_error.connect(_on_nickname_changed_error)
	
	if CheddaBoards.get_cached_profile().is_empty():
		CheddaBoards.refresh_profile()
		CheddaBoards.profile_loaded.connect(_on_profile_loaded)
		return
	
	if is_rename:
		push_warning("Renaming to: %s" % name_text)
		loginHandler.nickname = name_text
		
		name_status_label.text = "Saving..."
		name_status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		
		CheddaBoards.change_nickname(name_text)
	else:                                                                  
		# First play: set up anonymous identity and start the game
		loginHandler.nickname = name_text
		
		CheddaBoards.change_nickname(loginHandler.nickname)
		CheddaBoards.login_anonymous(loginHandler.nickname)
		
		push_warning("Starting game as: %s (ID: %s)" % [loginHandler.nickname, CheddaBoards.get_player_id()])
		#TODO close
		on_closed.emit()
		self.visible = false

func _on_profile_loaded(nickname: String, score: int, streak: int, achievements: Array, play_count: int):
	if nickname != name_line_edit.text.strip_edges():
		_on_confirm_name_pressed()

func _on_nickname_change_success(new_nickname: String):
	push_warning("[NameChangeHandler] name changed to " + new_nickname)
	if CheddaBoards.nickname_changed.is_connected(_on_nickname_change_success):
		CheddaBoards.nickname_changed.disconnect(_on_nickname_change_success)
	if CheddaBoards.nickname_error.is_connected(_on_nickname_changed_error):
		CheddaBoards.nickname_error.disconnect(_on_nickname_changed_error)
	
	CheddaBoards.refresh_profile()
	await CheddaBoards.profile_loaded
	
	if is_rename:
		push_warning("Renamed to: %s (loginHandler nickname: %s) (ID: %s)" % [new_nickname, loginHandler.nickname, CheddaBoards.get_player_id()])
		#TODO toast
		#TODO close
		on_closed.emit()
		self.visible = false
	else:
		push_warning("Starting game as: %s (loginHandler nickname: %s) (ID: %s)" % [new_nickname, loginHandler.nickname, CheddaBoards.get_player_id()])
		#TODO close
		on_closed.emit()
		self.visible = false

func _on_nickname_changed_error():
	if CheddaBoards.nickname_changed.is_connected(_on_nickname_change_success):
		CheddaBoards.nickname_changed.disconnect(_on_nickname_change_success)
	if CheddaBoards.nickname_error.is_connected(_on_nickname_changed_error):
		CheddaBoards.nickname_error.disconnect(_on_nickname_changed_error)
	name_status_label.text = "Error - please try again"
	_update_confirm_button_state()

func _on_cancel_name_pressed():
	"""Cancel name entry, go back to previous panel"""
	self.visible = false
