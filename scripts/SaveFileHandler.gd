class_name SaveFileHandler
extends Node

enum SaveType
{
	SCORE = 1,
	HOWTOPLAY = 2,
	LIGHTDARK = 3
}

const saveTypeToFilePathMap : Dictionary = { 
	SaveType.SCORE: "user://score.dat",
	SaveType.HOWTOPLAY: "user://flags.cfg",
	SaveType.LIGHTDARK: "user://flags.cfg"
}

var flagSectionName = "flags"

var loadedSaveDatas : Dictionary = {}

var loadInProgress: bool = false

func request_load(saveType : SaveType):
	if loadedSaveDatas.has(saveType):
		push_warning("SaveFileHandler already has loaded data for save file type " + str(saveType) + ", exiting without attempting load")
		return [true, loadedSaveDatas[saveType]]
	
	var savePath = saveTypeToFilePathMap[saveType]
	
	if !FileAccess.file_exists(savePath):
		return [false, null]
	
	match saveType:
		SaveType.SCORE:
			var f = FileAccess.open(savePath, FileAccess.READ)
			loadedSaveDatas[saveType] = f.get_var()
			f.close()
			
		_:
			var result = _parse_settings_config_file(savePath, saveType)
			if !result:
				return [false, null]
	
	return [true, loadedSaveDatas[saveType]]


func _parse_settings_config_file(filePath: String, saveType : SaveType) -> bool:
	var configFile = ConfigFile.new()
	
	var error = configFile.load(filePath)
	if error != OK:
		return false
	
	var foundSaveType = false
	
	for flagKey in configFile.get_section_keys(flagSectionName):
		var flagSaveType = int(flagKey) as SaveType
		loadedSaveDatas[flagSaveType] = bool(configFile.get_value(flagSectionName, flagKey))
		
		if flagSaveType == saveType:
			foundSaveType = true
	
	return foundSaveType


func update_flag_and_save_all_flags(saveType: SaveType, flagVal: bool):
	var configFile = ConfigFile.new()
	
	loadedSaveDatas[saveType] = flagVal
	
	var savePath = get_save_path_for(saveType)
	for s in SaveType.values():
		# finding all other things saved in the same file as this saveType
		if loadedSaveDatas.has(s) && saveTypeToFilePathMap[s] == savePath:
			configFile.set_value(flagSectionName, str(s), loadedSaveDatas[s])
	
	var error = configFile.save(savePath)
	if error != OK:
		push_error("Saving " + savePath + " failed with error code " + str(error))


func get_loaded_save_data_for(saveType : SaveType):
	if not loadedSaveDatas.has(saveType):
		return null
	return loadedSaveDatas[saveType]


func get_save_path_for(saveType: SaveType):
	return saveTypeToFilePathMap[saveType]


func update_save_data(saveType: SaveType, data):
	loadedSaveDatas[saveType] = data
