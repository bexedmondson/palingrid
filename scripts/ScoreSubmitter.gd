extends Node

var letter_set_generator : DailyLetterSetGenerator

func on_generator_enter_tree(generator):
	letter_set_generator = generator

func submit_score(score):
	var date = Time.get_date_dict_from_system(true)
	if date != letter_set_generator.today_dict:
		print("Score submitter: current day unix time %d doesn't match the letter set daySeed %d" % [date, letter_set_generator.daySeed])
		#TODO display error to the user
		CheddaBoards.score_error.emit("Current day doesn't match letter set")
		return
	
	CheddaBoards.submit_score(score)
