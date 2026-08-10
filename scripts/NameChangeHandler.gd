class_name NameChangeHandler
extends Control

signal on_closed 

@export var loginHandler : LoginHandler
@export var best_score_indicator : BestScoreIndicator
@export var title_label : Label
@export var subtitle_label : Label
@export var name_line_edit : LineEdit
@export var name_status_label : Label
@export var confirm_button : Button
@export var back_button : Button

const MIN_NAME_LENGTH: int = 3
const MAX_NAME_LENGTH: int = 12

const valid_chars = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
					'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
					'0','1','2','3','4','5','6','7','8','9',
					'_']

var is_rename = false

var show_hide_tween : Tween

func _ready() -> void:
	self.visible = false

# ============================================================
# NAME ENTRY PANEL HANDLERS
# ============================================================
func _show_name_entry_panel(rename: bool = false):
	"""Show name entry panel. rename: false = no account found on this device, true = return player"""
	pivot_offset = size * 0.5
	if show_hide_tween != null and show_hide_tween.is_valid():
		show_hide_tween.kill()
	show_hide_tween = create_tween()
	show_hide_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	show_hide_tween.tween_property(self, "scale", Vector2(1,1), 0.2).from(Vector2.ZERO)
	show_hide_tween.play()
	
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
		#else:
			#name_line_edit.text = _generate_default_name()
	
	name_line_edit.placeholder_text = "Enter your name..."
	name_status_label.text = ""
	
	self.visible = true
	
	name_line_edit.grab_focus()
	_update_confirm_button_state()


func _on_name_text_changed(_new_text: String):
	"""Handle name text changes"""
	_update_confirm_button_state()


func _on_name_submitted(_name_text: String):
	"""Handle Enter key in name field"""
	if not confirm_button.disabled:
		_on_confirm_name_pressed()


func _update_confirm_button_state():
	"""Enable/disable confirm button based on name validity"""
	var name_text = name_line_edit.text.strip_edges()
	var is_valid_length = name_text.length() >= MIN_NAME_LENGTH and name_text.length() <= MAX_NAME_LENGTH
	if not is_valid_length:
		name_status_label.text = "Please enter a username between %d and %d characters long" % [MIN_NAME_LENGTH, MAX_NAME_LENGTH]
		confirm_button.disabled = true
		return
	
	for c in name_text:
		if not valid_chars.has(c):
			name_status_label.text = "Please enter a username containing only letters, numbers, and/or underscores"
			confirm_button.disabled = true
			return
			
	name_status_label.text = ""
	confirm_button.disabled = false


func _on_confirm_name_pressed():
	"""Confirm name - behaviour depends on _name_entry_mode"""
	var name_text = name_line_edit.text.strip_edges()
	
	print("=== NAME CONFIRMATION (mode: %s) ===" % "rename" if is_rename else "first time")
	print("Entered name: '%s'" % name_text)
	print("Player ID: '%s'" % CheddaBoards.get_player_id())
	
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
	
	name_status_label.text = "Saving..."
	name_status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	confirm_button.disabled = true
	back_button.disabled = true
	
	loginHandler.update_nickname(name_text)
	
	if is_rename:
		print("[NameChangeHandler] Renaming to: %s" % name_text)
	else:                                                                  
		print("[NameChangeHandler] Entering leaderboard as: %s (ID: %s)" % [loginHandler.nickname, CheddaBoards.get_player_id()])


func _on_profile_loaded(nickname: String, score: int, streak: int, achievements: Array, play_count: int):
	if nickname != name_line_edit.text.strip_edges():
		_on_confirm_name_pressed()

var new_set_nickname
func _on_nickname_change_success(new_nickname: String):
	new_set_nickname = new_nickname
	print("[NameChangeHandler] name changed to " + new_nickname)
	if CheddaBoards.nickname_changed.is_connected(_on_nickname_change_success):
		CheddaBoards.nickname_changed.disconnect(_on_nickname_change_success)
	if CheddaBoards.nickname_error.is_connected(_on_nickname_changed_error):
		CheddaBoards.nickname_error.disconnect(_on_nickname_changed_error)
	
	#CheddaBoards.refresh_profile()
	#await CheddaBoards.profile_loaded
	
	if is_rename:
		print("[NameChangeHandler] Renamed successfully to: %s (loginHandler nickname: %s) (ID: %s)" % [new_nickname, loginHandler.nickname, CheddaBoards.get_player_id()])
		on_closed.emit()
		self.visible = false
		confirm_button.disabled = false
		back_button.disabled = false
	else:
		print("[NameChangeHandler] Starting game successfully as: %s (loginHandler nickname: %s) (cheddaboards nickname: %s) (ID: %s)" % [new_nickname, loginHandler.nickname, CheddaBoards._nickname, CheddaBoards.get_player_id()])
		do_first_score_submit()

func do_first_score_submit():
	if !CheddaBoards.score_submitted.is_connected(_on_first_score_submitted):
		CheddaBoards.score_submitted.connect(_on_first_score_submitted)
	if !CheddaBoards.score_error.is_connected(_on_first_score_submitted):
		CheddaBoards.score_error.connect(_on_first_score_submitted)
		
	ScoreSubmitter.submit_score(best_score_indicator.best)

func _on_first_score_submitted(score, streak):
	if CheddaBoards.score_submitted.is_connected(_on_first_score_submitted):
		CheddaBoards.score_submitted.disconnect(_on_first_score_submitted)
	if CheddaBoards.score_error.is_connected(_on_first_score_submitted):
		CheddaBoards.score_error.disconnect(_on_first_score_submitted)

	name_status_label.text = "Setting up profile..."

	CheddaBoards.refresh_profile()
	await CheddaBoards.profile_loaded

	name_status_label.text = "Finalising..."

	CheddaBoards.change_nickname(new_set_nickname)
	await CheddaBoards.nickname_changed
	
	confirm_button.disabled = false
	back_button.disabled = false

	#TODO close
	on_closed.emit()
	self.visible = false


func _on_nickname_changed_error(error):
	confirm_button.disabled = false
	back_button.disabled = false
	
	if CheddaBoards.nickname_changed.is_connected(_on_nickname_change_success):
		CheddaBoards.nickname_changed.disconnect(_on_nickname_change_success)
	if CheddaBoards.nickname_error.is_connected(_on_nickname_changed_error):
		CheddaBoards.nickname_error.disconnect(_on_nickname_changed_error)
	name_status_label.text = "Error - please try again"
	_update_confirm_button_state()

func _on_cancel_name_pressed():
	"""Cancel name entry, go back to previous panel"""
	
	if show_hide_tween != null and show_hide_tween.is_valid():
		show_hide_tween.kill()
	show_hide_tween = create_tween()
	show_hide_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	show_hide_tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	show_hide_tween.play()
	
	await show_hide_tween.finished
	self.visible = false
