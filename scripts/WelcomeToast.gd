extends PanelContainer

@export var label : Label

var welcomed : bool = false

func _ready() -> void:
	CheddaBoards.profile_loaded.connect(_on_profile_loaded)

func _on_profile_loaded(nickname: String, _score: int, _streak: int, _achievements: Array, _play_count: int):
	if welcomed:
		return
	welcomed = true
	
	label.text = "Welcome, %s!" % nickname
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", 0.0, 0.7)
	tween.tween_interval(2.0)
	tween.tween_property(self, "position:y", -100.0, 0.55).set_ease(Tween.EASE_IN)
