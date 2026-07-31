extends Node

@export var letter_set_generator : DailyLetterSetGenerator

func submit_score(score):
	var date = Time.get_date_dict_from_system(true)
	var current_day_unix_time: int = Time.get_unix_time_from_datetime_dict(date)
	if current_day_unix_time != letter_set_generator.daySeed:
		print("Score submitter: current day unix time %d doesn't match the letter set daySeed %d" % [current_day_unix_time, letter_set_generator.daySeed])
		#TODO display error to the user
		CheddaBoards.score_error.emit("Current day doesn't match letter set")
		return
	
	CheddaBoards.submit_score(score)