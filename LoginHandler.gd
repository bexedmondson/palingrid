class_name LoginHandler
extends Node


const deviceIdFile : String = "user://deviceId.dat"
const leaderboardInfoFile: String = "user://leaderboard_info.dat"

const PROFILE_TIMEOUT_DURATION: float = 10.0
const POLL_INTERVAL: float = 0.5
const MAX_PROFILE_LOAD_ATTEMPTS: int = 3
const MAX_POLL_ATTEMPTS: int = 15

var is_logging_in: bool = false
var waiting_for_profile: bool = false
var nickname : String

var profile_poll_timer: Timer = null
var profile_timeout_timer: Timer = null
var profile_load_attempts: int = 0
var profile_poll_attempts: int = 0

var local_state : PlayerInfo.State = PlayerInfo.State.INITIALISING
var remote_state : PlayerInfo.State = PlayerInfo.State.INITIALISING

func _ready() -> void:
	# --- CheddaBoards credentials (managed by Setup Wizard) ---
	CheddaBoards.set_api_key("cb_word-grid_84523752")
	CheddaBoards.set_game_id("word-grid")
	
	# Connect scoreboard rank signal
#	CheddaBoards.scoreboard_rank_loaded.connect(_on_scoreboard_rank_loaded)
#	
#	CheddaBoards.score_submitted.connect(_on_score_submitted)
#	CheddaBoards.score_error.connect(_on_score_error)
#	CheddaBoards.play_session_started.connect(_on_play_session_started)
#	CheddaBoards.play_session_error.connect(_on_play_session_error)
	
	if CheddaBoards.is_ready():
		_on_sdk_ready()
	else:
		CheddaBoards.sdk_ready.connect(_on_sdk_ready)


func _on_sdk_ready():
	if CheddaBoards.sdk_ready.is_connected(_on_sdk_ready):
		CheddaBoards.sdk_ready.disconnect(_on_sdk_ready)

	var device_id_found = _try_get_native_device_id()
	
	print("[LoginHandler] found device id? " + str(device_id_found))
	if not device_id_found:
		print("[LoginHandler] creating new device id")
		_create_new_device_id()

	var has_data = _try_load_player_data()
	print("[LoginHandler] found local data? " + str(has_data))
	
	local_state = PlayerInfo.State.EXISTS if has_data else PlayerInfo.State.NONE_FOUND
	
	if local_state == PlayerInfo.State.EXISTS:
		CheddaBoards.login_anonymous(nickname)
	
	_load_anonymous_profile()
	# Connect CheddaBoards signals
	CheddaBoards.profile_loaded.connect(_on_profile_loaded)
	CheddaBoards.no_profile.connect(_on_no_profile)
	CheddaBoards.nickname_changed.connect(_on_nickname_changed)


func _try_get_native_device_id() -> bool:
	"""Get existing device ID, if it exists"""
	if !FileAccess.file_exists(deviceIdFile):
		print("[LoginHandler] device id file not found " + deviceIdFile)
		return false

	var file = FileAccess.open(deviceIdFile, FileAccess.READ)
	if file:
		var deviceId = file.get_line().strip_edges()
		CheddaBoards.set_player_id(deviceId)
		file.close()
		return true
	
	return false


func _create_new_device_id() -> void:
	"""Create new device ID (persisted to file)"""
	randomize()
	var deviceId = "device_%d_%08x" % [Time.get_unix_time_from_system(), randi()]

	var file = FileAccess.open(deviceIdFile, FileAccess.WRITE)
	if file:
		file.store_line(deviceId)
		file.close()

	CheddaBoards.set_player_id(deviceId)


func _try_load_player_data() -> bool:
	"""Trying to load saved player data (e.g. nickname)"""
	if not FileAccess.file_exists(leaderboardInfoFile):
		push_warning("[LoginHandler] No save file found")
		return false

	var file = FileAccess.open(leaderboardInfoFile, FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()

		if data is Dictionary:
			nickname = data.get("nickname", "")
			print("[LoginHandler] Loaded anonymous data: nickname='%s'" % [nickname])
			return true
	
	return false


func _save_player_data():
	"""Save player data (anonymous nickname + has_played status)"""
	var file = FileAccess.open(leaderboardInfoFile, FileAccess.WRITE)
	if file:
		var data = {
			"nickname": nickname,
			"player_id": CheddaBoards.get_player_id()
		}
		file.store_var(data)
		file.close()
		print("[LoginHandler] Saved player data")
	
	local_state = PlayerInfo.State.EXISTS
		


func _load_anonymous_profile():
	"""Load and display stats for anonymous player from CheddaBoards API"""
	print("[LoginHandler] Loading anonymous profile...")

	var profile = CheddaBoards.get_cached_profile()

	if not profile.is_empty():
		print("[LoginHandler] Found cached profile")
		return
	else:
		print("[LoginHandler] No cached profile")

	print("[LoginHandler] Requesting profile refresh...")
	_request_profile_with_timeout()

# ============================================================
# PROFILE REQUEST HANDLING
# ============================================================

func _request_profile_with_timeout():
	"""Request profile with timeout"""
	CheddaBoards.refresh_profile()
	_start_profile_polling()
	_start_profile_timeout()


func _on_profile_loaded(loaded_nickname: String, score: int, _streak: int, achievements: Array, play_count: int):
	"""Profile loaded from backend.

	SDK v2.2.0+ emits play_count as 5th arg — prefer it over digging into
	the cached profile dict, which can be stale or inconsistently shaped
	between session-auth and API-key paths."""
	print("[LoginHandler] Profile loaded: %s (weekly score: %d, plays: %d)" % [loaded_nickname, score, play_count])
	
	remote_state = PlayerInfo.State.EXISTS
	
	if not loaded_nickname.is_empty():
		# If backend has different nickname (e.g. auto-suffixed), update local storage
		if nickname != loaded_nickname or local_state == PlayerInfo.State.NONE_FOUND or local_state == PlayerInfo.State.CHECK_FAILED:
			print("[LoginHandler] Updating local nickname: '%s' -> '%s' (backend sync)" % [nickname if not nickname.is_empty() else "[none]", loaded_nickname])
			local_state = PlayerInfo.State.EXISTS
			nickname = loaded_nickname
			_save_player_data()

	_clear_profile_timeout()
	_stop_profile_polling()


func _on_no_profile():
	"""No profile found"""
	print("[LoginHandler] No remote profile found")
	
	remote_state = PlayerInfo.State.NONE_FOUND
	
	_clear_profile_timeout()
	_stop_profile_polling()

# ============================================================
# PROFILE POLLING
# ============================================================

func _start_profile_polling():
	"""Start polling for profile"""
	_stop_profile_polling()
	print("[LoginHandler] beginning profile poll")
	profile_poll_timer = Timer.new()
	profile_poll_timer.wait_time = POLL_INTERVAL
	profile_poll_timer.timeout.connect(_check_profile_poll)
	add_child(profile_poll_timer)
	profile_poll_timer.start()
	profile_poll_attempts = 0


func _check_profile_poll():
	"""Check if profile has loaded"""
	print("[LoginHandler] doing profile check")
	profile_poll_attempts += 1

	var profile = CheddaBoards.get_cached_profile()

	if not profile.is_empty() and waiting_for_profile:
		print("[LoginHandler] Profile found via polling")
		_clear_profile_timeout()
		_stop_profile_polling()
		waiting_for_profile = false
		return

	if profile_poll_attempts >= MAX_POLL_ATTEMPTS:
		_stop_profile_polling()


func _stop_profile_polling():
	"""Stop polling"""
	print("[LoginHandler] stopping profile poll")
	if profile_poll_timer:
		profile_poll_timer.stop()
		profile_poll_timer.queue_free()
		profile_poll_timer = null

# ============================================================
# PROFILE TIMEOUT
# ============================================================

func _start_profile_timeout():
	"""Start timeout for profile loading"""
	_clear_profile_timeout()
	print("[LoginHandler] starting profile poll timeout")

	profile_timeout_timer = Timer.new()
	profile_timeout_timer.wait_time = PROFILE_TIMEOUT_DURATION
	profile_timeout_timer.one_shot = true
	profile_timeout_timer.timeout.connect(_on_profile_timeout)
	add_child(profile_timeout_timer)
	profile_timeout_timer.start()


func _clear_profile_timeout():
	"""Clear profile timeout"""
	print("[LoginHandler] clearing profile poll timeout")
	if profile_timeout_timer:
		profile_timeout_timer.stop()
		profile_timeout_timer.queue_free()
		profile_timeout_timer = null


func _on_profile_timeout():
	"""Handle profile timeout"""
	if not waiting_for_profile:
		return
	print("[LoginHandler] profile poll timeout check")

	profile_load_attempts += 1
	push_warning("Profile timeout (attempt %d/%d)" % [profile_load_attempts, MAX_PROFILE_LOAD_ATTEMPTS])

	if profile_load_attempts < MAX_PROFILE_LOAD_ATTEMPTS:
		_request_profile_with_timeout()
	else:
		push_warning("[LoginHandler] ending profile polling due to max attempts reached")
		_clear_profile_timeout()
		_stop_profile_polling()
		waiting_for_profile = false
		#if initialising, set this so we know we need to retry later if the player wants their remote info
		if remote_state == PlayerInfo.State.INITIALISING:
			remote_state = PlayerInfo.State.CHECK_FAILED

func update_nickname(new_nickname: String):
	CheddaBoards.change_nickname(new_nickname)

func _on_nickname_changed(new_nickname: String):
	nickname = new_nickname
	CheddaBoards.login_anonymous(nickname)
	_save_player_data()



#func _check_existing_auth():
#	"""Check if user has REAL authentication OR is a returning anonymous player"""
#	push_warning("Checking existing auth...")
#	push_warning("  has_account: %s" % CheddaBoards.has_account())
#	push_warning("  is_authenticated: %s" % CheddaBoards.is_authenticated())
#	push_warning("  is_anonymous: %s" % CheddaBoards.is_anonymous())
#	push_warning("  anonymous_nickname: '%s'" % nickname)
#	
#	# Check for real (non-anonymous) authenticated user
#	#if CheddaBoards.has_account() and CheddaBoards.is_authenticated() and not CheddaBoards.is_anonymous():
#	#	print("User has real account and is authenticated - loading profile")
#	#	_load_authenticated_profile()
#	# Returning anonymous player (has played / submitted a score before, per the
#	# save file) → anonymous dashboard on ANY launch, cold restart included, so
#	# they land on their saved score. Only a brand-new player sees the first menu.
#	if not CheddaBoards.get_player_id().is_empty():
#		push_warning("Returning anonymous player - logging in and loading player data")
#		_silent_anonymous_login()
#		_load_player_data()
#	else:
#		# Brand-new player (never played)
#		push_warning("New player - no existing auth found")
#		_create_new_device_id()
#		
#
#func _silent_anonymous_login():
#	"""Silently log in as anonymous to fetch profile data (don't trigger full login flow)"""
#	push_warning("Starting silent anonymous login as: %s (ID: %s)" % [nickname, CheddaBoards.get_player_id()])
#	CheddaBoards.login_anonymous(nickname)
#
#func _load_player_data():
#	"""Load saved player data (anonymous nickname + has_played status)"""
#	if not FileAccess.file_exists(leaderboardInfoFile):
#		push_warning("No save file found")
#		return
#	
#	var file = FileAccess.open(leaderboardInfoFile, FileAccess.READ)
#	if file:
#		var data = file.get_var()
#		file.close()
#		
#		if data is Dictionary:
#			nickname = data.get("nickname", "")
#			push_warning("Loaded anonymous data: nickname='%s'" % [nickname])
#

#func _request_profile_with_timeout():
#	"""Request profile with timeout"""
#	CheddaBoards.refresh_profile()
#	_start_profile_polling()
#	_start_profile_timeout()
#		file.store_var(data)
#		file.close()
#		push_warning("Saved player data")
#
#
#func _on_login_success(nickname: String):
#	"""Login succeeded"""
#	push_warning("Login success: %s" % nickname)
#	is_logging_in = false
#	
#	push_warning("Silent login complete - loading anonymous stats")
#	await get_tree().create_timer(0.3).timeout
#	_load_anonymous_stats()
#	return
#
#
#func _on_login_failed(reason: String):
#	"""Login failed"""
#	push_warning("Login failed: %s" % reason)
#	is_logging_in = false
#
#
#
#
#
#



#	# Anonymous dashboard / silent login: a "no profile" here just means the
#	# backend has no record for this anonymous player yet. Stay put and keep
#	# showing cached/placeholder stats — do NOT bounce back to the login panel.
#	# (Anonymous players report has_account() == false and the silent login
#	# never sets is_logging_in, so without this guard the old code fell into
#	# the branch below and reset the UI to the start screen.)
##	if _is_silent_login or (anonymous_panel and anonymous_panel.visible):
##		print("Ignoring no_profile (anonymous dashboard / silent login active)")
##		return
##	
##	if not CheddaBoards.has_account() and not is_logging_in:
##		_stop_all_timers()
##		waiting_for_profile = false
##		_show_login_panel()
##	elif is_logging_in:
##		pass
##	else:
##		_stop_all_timers()
##		waiting_for_profile = false
##		# SDK v2.2.0+: get_nickname() returns "" for unnamed anonymous players.
##		var nick = CheddaBoards.get_nickname()
##		if nick.is_empty():
##			nick = "Guest"
##		_show_main_panel({
##			"nickname": nick,
##			"score": 0,
##			"streak": 0,
##			"playCount": 0
##		})
#
