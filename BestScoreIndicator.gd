extends Control

@export var dailyGenerator : DailyLetterSetGenerator

const saveFile : String = "user://score.txt"
const newline : String = "\n"

var best : int = 0

func convert_to_save_data(score: int):
	return dailyGenerator.daySeed + score
	
func convert_from_save_string(saveString : String):
	var saveNumber = saveString.to_int()
	var day = saveNumber - saveNumber % 86400
	print(Time.get_date_dict_from_unix_time(day))
	
var done = false
func _process(delta: float) -> void:
	if (done):
		return
	if (dailyGenerator.daySeed == 0):
		return
	
	done = true

func save(score : int):
	var saveData = convert_to_save_data(score)
	var f = FileAccess.open(saveFile, FileAccess.READ_WRITE)
	f.seek_end()
	f.store_string(newline)
	f.store_16(saveData)
	f.close()

func load():
	if !FileAccess.file_exists(saveFile):
		return
	
	var f = FileAccess.open(saveFile, FileAccess.READ)
	f.seek_end(-16)
	var last_save = f.get_16()
	
