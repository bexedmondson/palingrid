class_name Scoreboard
extends Node

# ============================================================
# CONFIGURATION
# ============================================================

const LEADERBOARD_LIMIT: int = 1000 ## How many entries to load per page
const LOAD_TIMEOUT_SECONDS: float = 15.0 ## How long to wait before timing out

const SCOREBOARD_DAILY: String = "daily" ## Scoreboard IDs — update these to match your canister config

# ============================================================
# COLORS — CheddaBoards brand palette
# ============================================================

@export var COLOR_ACCENT: Color = Color("f5a623")         # CheddaBoards gold/cheese
@export var COLOR_TEXT: Color = Color("e0e0e0")
@export var COLOR_TEXT_DIM: Color = Color("888888")
@export var COLOR_HIGHLIGHT_PLAYER: Color = Color(0.2, 0.5, 0.2, 0.4)
@export var COLOR_HIGHLIGHT_GOLD: Color = Color(0.5, 0.4, 0.1, 0.5)
@export var COLOR_HIGHLIGHT_SILVER: Color = Color(0.4, 0.4, 0.45, 0.3)
@export var COLOR_HIGHLIGHT_BRONZE: Color = Color(0.4, 0.25, 0.1, 0.3)

# ============================================================
# NODE REFERENCES
# ============================================================

@export var name_change_handler : NameChangeHandler
@export var margin_container: MarginContainer
@export var title_label: Label
@export var refresh_button: Button

# Leaderboard display
@export var column_header: HBoxContainer
@export var leaderboard_scroll: ScrollContainer
@export var leaderboard_list: VBoxContainer

# Footer
@export var status_label: Label
@export var back_button: Button

var setup : bool = false

var has_shown_set_name_prompt : bool

# ============================================================
# STATE
# ============================================================

var scoreboard_id: String = SCOREBOARD_DAILY ## Current scoreboard ID being viewed

var is_loading: bool = false ## Whether we're loading
var load_timeout_timer: Timer = null ## Load timeout timer


# ============================================================
# INITIALIZATION
# ============================================================
func _ready() -> void:
	self.visible = false

func on_visibility_changed():
	if setup:
		return
	
	if (!self.visible):
		_clear_load_timeout()
		return
	
	# Wait for CheddaBoards
	if not CheddaBoards.is_ready():
		status_label.text = "Connecting to leaderboard provider CheddaBoards..."
		await CheddaBoards.wait_until_ready()
	
	# Connect other buttons
	refresh_button.pressed.connect(_on_refresh_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect CheddaBoards signals
	CheddaBoards.scoreboard_loaded.connect(_on_scoreboard_loaded)
	CheddaBoards.scoreboard_error.connect(_on_scoreboard_error)
	
	CheddaBoards.login_success.connect(_on_login_success)
	CheddaBoards.login_failed.connect(_on_login_failed)
	
	_load_leaderboard()
	
	push_warning("[Leaderboard] v2.0.0 initialized (Mobile: %s, Scale: %.2f)" % [MobileUI.is_mobile, MobileUI.ui_scale])
	setup = true

# ============================================================
# LOADING
# ============================================================

func _load_leaderboard():
	push_warning("[Leaderboard] start load")
	if is_loading:
		push_warning("[Leaderboard] already loading, exiting load request early")
		return
	
	refresh_button.disabled = true
	_clear_leaderboard()
	status_label.text = "Loading..."
	status_label.add_theme_color_override("font_color", COLOR_TEXT)
	
	if name_change_handler.on_closed.is_connected(_load_leaderboard):
		name_change_handler.on_closed.disconnect(_load_leaderboard)
		
	if not CheddaBoards.has_account() and not CheddaBoards.is_authenticated() and not has_shown_set_name_prompt:
		name_change_handler.on_closed.connect(_on_prompt_shown)
		name_change_handler._show_name_entry_panel()
		return
	
	_set_loading(true)
	_start_load_timeout()
	
	push_warning("[Leaderboard] Requesting scoreboard '%s'" % scoreboard_id)
	CheddaBoards.get_scoreboard(scoreboard_id, LEADERBOARD_LIMIT)

func _set_loading(loading: bool):
	is_loading = loading
	refresh_button.disabled = loading

func _clear_leaderboard():
	for child in leaderboard_list.get_children():
		child.queue_free()

func _on_prompt_shown():
	has_shown_set_name_prompt = true
	#if CheddaBoards.is_authenticated():
	_load_leaderboard()

# ============================================================
# SIGNAL HANDLERS — SCOREBOARDS
# ============================================================

func _on_scoreboard_loaded(sb_id: String, config: Dictionary, entries: Array):
	if sb_id != scoreboard_id:
		return
	_display_entries(entries)

func _on_scoreboard_error(reason: String):
	push_warning("[Leaderboard] Error: %s" % reason)
	_clear_load_timeout()
	_set_loading(false)
	status_label.text = "Error loading leaderboard"
	status_label.add_theme_color_override("font_color", Color.RED)

func _on_login_success(nickname: String):
	_set_status("")


func _on_login_failed(reason: String):
	_set_status("Login failed: %s" % reason, true)


# ============================================================
# TITLE UPDATES
# ============================================================

func _format_timestamp(timestamp_ns: int) -> String:
	if timestamp_ns == 0:
		return ""
	var timestamp_s = timestamp_ns / 1_000_000_000
	var dt = Time.get_datetime_dict_from_unix_time(timestamp_s)
	return "%02d/%02d/%d" % [dt.day, dt.month, dt.year]

# ============================================================
# STATUS UPDATES
# ============================================================

func _set_status(message: String, is_error: bool = false):
	"""Set status label"""
	status_label.text = message
	if is_error:
		status_label.add_theme_color_override("font_color", Color.RED)
	else:
		status_label.remove_theme_color_override("font_color")

# ============================================================
# DISPLAY ENTRIES
# ============================================================

func _display_entries(entries: Array):
	_clear_load_timeout()
	_set_loading(false)
	
	if entries.is_empty():
		status_label.text = "No scores yet — be the first!"
		status_label.add_theme_color_override("font_color", Color.YELLOW)
		return
	
	status_label.text = "%d players" % entries.size()
	status_label.add_theme_color_override("font_color", COLOR_TEXT_DIM)
	
	_clear_leaderboard()
	
	var sorted_entries = _sort_entries(entries)
	
	for i in range(sorted_entries.size()):
		_add_leaderboard_entry(i + 1, sorted_entries[i])

func _sort_entries(entries: Array) -> Array:
	var sorted = entries.duplicate()
	sorted.sort_custom(func(a, b):
		return _get_sort_value(a) > _get_sort_value(b)
	)
	return sorted

func _get_sort_value(entry) -> int:
	if typeof(entry) == TYPE_ARRAY:
		return entry[1] if entry.size() > 1 else 0
	elif typeof(entry) == TYPE_DICTIONARY:
		return entry.get("score", entry.get("highScore", 0))
	return 0

func _add_leaderboard_entry(rank: int, entry) -> void:
	# Parse entry data
	var nickname: String
	var score: int
	
	if typeof(entry) == TYPE_ARRAY:
		nickname = str(entry[0]) if entry.size() > 0 else "Unknown"
		score = entry[1] if entry.size() > 1 else 0
	elif typeof(entry) == TYPE_DICTIONARY:
		nickname = str(entry.get("nickname", entry.get("username", "Unknown")))
		score = entry.get("score", entry.get("highScore", 0))
	else:
		return
	
	var player_nickname = CheddaBoards.get_nickname()
	var is_current_player = (nickname == player_nickname) and player_nickname != ""
	
	# Entry container
	var entry_container = PanelContainer.new()
	#entry_container.custom_minimum_size = Vector2(0, MobileUI.get_touch_size(44))
	
	# Row styling
	var stylebox = StyleBoxFlat.new()
	stylebox.set_corner_radius_all(int(MobileUI.get_size(4)))
	
	if is_current_player:
		stylebox.bg_color = COLOR_HIGHLIGHT_PLAYER
	elif rank == 1:
		stylebox.bg_color = COLOR_HIGHLIGHT_GOLD
	elif rank == 2:
		stylebox.bg_color = COLOR_HIGHLIGHT_SILVER
	elif rank == 3:
		stylebox.bg_color = COLOR_HIGHLIGHT_BRONZE
	else:
		# Alternating row colors for readability
		stylebox.bg_color = Color("1a1a2e") if rank % 2 == 1 else Color("16162a")
	
	entry_container.add_theme_stylebox_override("panel", stylebox)
	
	# Margin
	var margin = MarginContainer.new()
	var h_margin = int(MobileUI.get_size(12))
	var v_margin = int(MobileUI.get_size(4))
	margin.add_theme_constant_override("margin_left", h_margin)
	margin.add_theme_constant_override("margin_right", h_margin)
	margin.add_theme_constant_override("margin_top", v_margin)
	margin.add_theme_constant_override("margin_bottom", v_margin)
	entry_container.add_child(margin)
	
	# HBox
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", int(MobileUI.get_size(12)))
	margin.add_child(hbox)
	
	# Rank
	var rank_label = Label.new()
	#rank_label.custom_minimum_size = Vector2(MobileUI.get_size(44), 0)
	#rank_label.add_theme_font_size_override("font_size", MobileUI.get_font_size(18))
	rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	match rank:
		1:
			rank_label.text = "#1"
			rank_label.add_theme_color_override("font_color", Color.GOLD)
		2:
			rank_label.text = "#2"
			rank_label.add_theme_color_override("font_color", Color.SILVER)
		3:
			rank_label.text = "#3"
			rank_label.add_theme_color_override("font_color", Color("#CD7F32"))
		_:
			rank_label.text = "#%d" % rank
			rank_label.add_theme_color_override("font_color", COLOR_TEXT_DIM)
	
	hbox.add_child(rank_label)
	
	# Nickname
	var name_label = Label.new()
	name_label.text = nickname
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#name_label.add_theme_font_size_override("font_size", MobileUI.get_font_size(18))
	name_label.add_theme_color_override("font_color", Color.WHITE if is_current_player else COLOR_TEXT)
	name_label.clip_text = true
	hbox.add_child(name_label)
	
	# Value
	var value_label = Label.new()
	value_label.text = _format_score(score)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	#value_label.custom_minimum_size = Vector2(MobileUI.get_size(90), 0)
	#value_label.add_theme_font_size_override("font_size", MobileUI.get_font_size(18))
	value_label.add_theme_color_override("font_color", COLOR_ACCENT if rank <= 3 else COLOR_TEXT)
	hbox.add_child(value_label)
	
	leaderboard_list.add_child(entry_container)

func _format_score(value: int) -> String:
	"""Format score with commas for readability"""
	var s = str(value)
	if s.length() <= 3:
		return s
	var result = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = s[i] + result
		count += 1
	return result


# ============================================================
# BUTTON HANDLERS
# ============================================================

func _on_refresh_pressed():
	_load_leaderboard()

func _on_back_pressed():
	self.visible = false;
	return


# ============================================================
# TIMEOUT
# ============================================================

func _start_load_timeout():
	_clear_load_timeout()
	load_timeout_timer = Timer.new()
	load_timeout_timer.wait_time = LOAD_TIMEOUT_SECONDS
	load_timeout_timer.one_shot = true
	load_timeout_timer.timeout.connect(_on_load_timeout)
	add_child(load_timeout_timer)
	load_timeout_timer.start()

func _clear_load_timeout():
	if load_timeout_timer:
		load_timeout_timer.stop()
		load_timeout_timer.queue_free()
		load_timeout_timer = null

func _on_load_timeout():
	if is_loading:
		_set_loading(false)
		status_label.text = "Timed out — tap Refresh to retry"
		status_label.add_theme_color_override("font_color", Color.RED)

# ============================================================
# PUBLIC API
# ============================================================

func set_scoreboard(new_id: String):
	scoreboard_id = new_id
	_load_leaderboard()

func show_current():
	_load_leaderboard()

# ============================================================
# CLEANUP
# ============================================================

func _exit_tree():
	_clear_load_timeout()
