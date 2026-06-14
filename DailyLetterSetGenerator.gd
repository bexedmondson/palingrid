class_name DailyLetterSetGenerator extends Node

@export var statsFile : JSON

var data = {}
var generated_set = []

var daySeed : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func alt_generator(count, day, valid_words):
	var date = { "year": 2026, "month": 6, "day":day, "weekday": 1 }
	daySeed = Time.get_unix_time_from_datetime_dict(date)
	seed(daySeed)
	
	load_letter_distribution()
	
	generated_set = []
	var wordPickCount = randi_range(1, 4)
	
	for w in wordPickCount:
		var r = randi_range(0, valid_words.size() - 1)
		var word_letters = valid_words[r].split()
		generated_set.append_array(word_letters)
	
	var set_length = generated_set.size()
	for i in range(set_length, count):
		var r = randf()
		for d in data:
			if (r < data[d]):
				generated_set.append(d)
				break
	
	return generated_set
	
func gen_date(count, day, month, year):
	var date = { "year": year, "month": month, "day": day }
	daySeed = Time.get_unix_time_from_datetime_dict(date)
	seed(daySeed)
	
	load_letter_distribution()
	
	generated_set = []
	for i in count:
		var r = randf()
		for d in data:
			if (r < data[d]):
				generated_set.append(d)
				break
	
	return generated_set

func generate(count: int):
	var date = Time.get_date_dict_from_system(true)
	daySeed = Time.get_unix_time_from_datetime_dict(date)
	seed(daySeed)
	
	load_letter_distribution()
	
	generated_set = []
	for i in count:
		var r = randf()
		for d in data:
			if (r < data[d]):
				generated_set.append(d)
				break
	
	return generated_set

func load_letter_distribution() -> void:
	var rawdata = statsFile.data
	data = {}
	var cumulative = 0.0
	for d in rawdata:
		cumulative += rawdata[d]
		data[d] = cumulative
