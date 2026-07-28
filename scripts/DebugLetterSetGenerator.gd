@tool
extends Node

@export var generator : DailyLetterSetGenerator

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
		EditorInterface.get_editor_toaster().push_toast("End year %d less than start year %d!" % [end_year, start_year], EditorToaster.Severity.SEVERITY_ERROR)
		return
	
	if end_month > start_month:
		return
	
	if end_month < start_month:
		EditorInterface.get_editor_toaster().push_toast("End month %d less than start month %d!" % [end_month, start_month], EditorToaster.Severity.SEVERITY_ERROR)
		return
	
	if end_day < start_day:
		EditorInterface.get_editor_toaster().push_toast("End day %d less than start day %d!" % [end_day, start_day], EditorToaster.Severity.SEVERITY_ERROR)

func gen_particular_date():
	var count = 25
	if !is_range:
		var letterSetArray = generator.gen_date(count, start_day, start_month, start_year)
		var letterSetString = ""
		for character in letterSetArray:
			letterSetString += character
		print("%02d/%02d/%04d \t%s" % [start_day, start_month, start_year, letterSetString])
	else:
		var day = start_day
		var month = start_month
		var year = start_year
		while year <= end_year:
			var monthToIterateTo = end_month if year == end_year else 12
			while month <= monthToIterateTo:
				var dayToIterateTo = end_day if year == end_year and month == end_month else 31
				while day <= dayToIterateTo:
					var letterSetArray = generator.gen_date(count, day, month, year)
					var letterSetString = ""
					for character in letterSetArray:
						letterSetString += character
					print("%02d/%02d/%04d \t%s" % [day, month, year, letterSetString])
					day += 1
				month += 1
				day = 1
			year += 1
			month = 1
			day = 1
