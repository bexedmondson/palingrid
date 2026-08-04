@tool
extends Node

@export var generator : DailyLetterSetGenerator

@export var output_to_file : bool = true

@export_range(1, 31) var start_day = 1 :
	set(d):
		if d != start_day:
			start_day = d
			_check_valid_date()

@export_range(1, 12) var start_month : int = 7 :
	set(m):
		if m != start_month:
			start_month = m
			_check_valid_date()
@export_range(2026, 2400) var start_year : int = 2026 :
	set(y):
		if y != start_year:
			start_year = y
			_check_valid_date()


@export var is_range : bool
@export_range(1, 31) var end_day : int = 1 :
	set(d):
		if d != end_day:
			end_day = d
			_check_valid_date()
@export_range(1, 12) var end_month : int = 7 :
	set(m):
		if m != end_month:
			end_month = m
			_check_valid_date()
@export_range(2026, 2400) var end_year : int = 2026 :
	set(y):
		if y != end_year:
			end_year = y
			_check_valid_date()

@export_tool_button("gen date sets") var gendate : Callable = gen_particular_date

func _check_valid_date():
	if !is_range || end_year > start_year:
		return

	if end_year < start_year:
		#EditorInterface.get_editor_toaster().push_toast("End year %d less than start year %d!" % [end_year, start_year], EditorToaster.Severity.SEVERITY_ERROR)
		return

	if end_month > start_month:
		return

	if end_month < start_month:
		#EditorInterface.get_editor_toaster().push_toast("End month %d less than start month %d!" % [end_month, start_month], EditorToaster.Severity.SEVERITY_ERROR)
		return

	if end_day < start_day:
		#EditorInterface.get_editor_toaster().push_toast("End day %d less than start day %d!" % [end_day, start_day], EditorToaster.Severity.SEVERITY_ERROR)
		return

func gen_particular_date():
	var results = []
	var count = 25
	if !is_range:
		var dict = {}
		var letterSetArray = generator.gen_date(count, start_day, start_month, start_year)
		var letterSetString = ""
		for character in letterSetArray:
			letterSetString += character
		dict["date"] = "%04d-%02d-%02d" % [start_year, start_month, start_day]
		dict["letterset"] = letterSetString
		results.append(dict)
	else:
		var day = start_day
		var month = start_month
		var year = start_year
		while year <= end_year:
			var monthToIterateTo = end_month if year == end_year else 12
			while month <= monthToIterateTo:
				var dayToIterateTo = end_day if year == end_year and month == end_month else 31
				while day <= dayToIterateTo:
					var dict = {}
					var letterSetArray = generator.gen_date(count, day, month, year)
					var letterSetString = ""
					for character in letterSetArray:
						letterSetString += character
					dict["date"] = "%04d-%02d-%02d" % [year, month, day]
					dict["letterset"] = letterSetString
					results.append(dict)
					day += 1
				month += 1
				day = 1
			year += 1
			month = 1
			day = 1
	
	for r in results:
		print(r)
	
	if output_to_file:
		var json = JSON.stringify(results," ")
		var filename = "res://notes/letter_sets_" + results[0]["date"] + "-" + results[-1]["date"] + ".json"
		print(filename)
		var file = FileAccess.open(filename, FileAccess.WRITE)
		print(str(file))
		file.store_string(json)
