extends Label

var today_dict = {}

func _ready() -> void:
	today_dict = Time.get_date_dict_from_system(true)

func _process(delta: float) -> void:
	var now_dict = Time.get_datetime_dict_from_system(true)
	if now_dict["year"] != today_dict["year"] or now_dict["year"] != today_dict["year"] or now_dict["year"] != today_dict["year"]:
		self.text = "new challenge available! refresh to play"
		return
	
	self.text = "new letter set in %02d:%02d:%02d" % [23 - now_dict["hour"], 59 - now_dict["minute"], 59 - now_dict["second"]]
	
