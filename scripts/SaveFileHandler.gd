class_name SaveFileHandler
extends Node

enum SaveType
{
	SCORE,
	HOWTOPLAY
}

signal loadAttemptFinished

const saveTypeToFilePathMap : Dictionary = { 
	SaveType.SCORE: "user://score.dat",
	SaveType.HOWTOPLAY: "user://tutorial.dat"
}

var loadedSaveDatas : Dictionary = {}

var loadInProgress: bool = false

func request_load(saveType : SaveType):
	var savePath = saveTypeToFilePathMap[saveType]
	
	if !FileAccess.file_exists(savePath):
		return [false, null]
	
	var f = FileAccess.open(savePath, FileAccess.READ)
	
	match saveType:
		SaveType.SCORE:
			loadedSaveDatas[saveType] = f.get_var()
		SaveType.HOWTOPLAY:
			loadedSaveDatas[saveType] = true if f.get_8() == 1 else false
	
	f.close()
	return [true, loadedSaveDatas[saveType]]

func get_loaded_save_data_for(saveType : SaveType):
	if not loadedSaveDatas.has(saveType):
		return null
	return loadedSaveDatas[saveType]

func get_save_path_far(saveType: SaveType):
	return saveTypeToFilePathMap[saveType]
