@tool
class_name DailyLetterSetGenerator extends Node

@export var statsFile : JSON

var today_dict

var cumulative_letter_distribution_data = {}
var generated_set = []

var minvowels = 7
var vowels = {
	"a": 0.25, 
	"e": 0.55, 
	"i": 0.75, 
	"o": 0.9, 
	"u": 1.0
	}

var daySeed : int

func gen_date(count, day, month, year):
	var date = { "year": year, "month": month, "day": day }
	daySeed = Time.get_unix_time_from_datetime_dict(date)
	seed(daySeed)
	
	load_letter_distribution()
	
	var vowel_count = 0
	
	generated_set = []
	for i in range(count):
		if i == count - 1 and "q" in generated_set and "u" not in generated_set:
			generated_set.append("u")
			continue
		
		var r = randf()
		if i > count - minvowels and vowel_count < minvowels:
			for v in vowels:
				if r < vowels[v]:
					generated_set.append(v)
					vowel_count += 1
					break
		else:
			for d in cumulative_letter_distribution_data:
				if (r < cumulative_letter_distribution_data[d]):
					generated_set.append(d)
					if d in vowels:
						vowel_count += 1
					break
	
	return generated_set


func generate(count: int):
	today_dict = Time.get_date_dict_from_system(true)
	gen_date(count, today_dict["day"], today_dict["month"], today_dict["year"])
	return generated_set


func load_letter_distribution() -> void:
	var rawdata = statsFile.data
	cumulative_letter_distribution_data = {}
	var cumulative = 0.0
	for d in rawdata:
		cumulative += rawdata[d]
		cumulative_letter_distribution_data[d] = cumulative
