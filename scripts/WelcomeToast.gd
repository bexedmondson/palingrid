extends PanelContainer

@export var label : Label
@export var notYouButton : Button

@export var accountPopup : AccountPopup

var welcomed : bool = false

func _ready() -> void:
	CheddaBoards.profile_loaded.connect(_on_profile_loaded)
	CheddaBoards.session_expired.connect(_on_session_expired)

func _on_profile_loaded(nickname: String, _score: int, _streak: int, _achievements: Array, _play_count: int):
	if welcomed:
		return
	welcomed = true
	
	label.text = "Welcome, %s!" % nickname
	notYouButton.text = "not you? tap here to login!"
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", 0.0, 0.7)
	tween.tween_interval(2.0)
	tween.tween_property(self, "position:y", -1 * (self.size.y + 55), 0.55).set_ease(Tween.EASE_IN)

func _on_session_expired():
	welcomed = false
	
	label.text = "Your login session has expired!\nLog in again to use the leaderboard and save your progress"
	notYouButton.text = "log back in here"
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", 0.0, 0.7)
	tween.tween_interval(3.0)
	tween.tween_property(self, "position:y", -1 * (self.size.y + 55), 0.55).set_ease(Tween.EASE_IN)

func on_account_button_pressed():
	accountPopup.do_show()
