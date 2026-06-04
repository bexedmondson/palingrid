extends Node

@export var tileHolder : TileDock
@export var slots : Array[DropSlot]
@export var tiles : Array[DropTile]
@export var wordScene : InstancePlaceholder
@export var score : Label

var lineSlotIndexes = [[0, 1, 2, 3, 4], 
[5, 6, 7, 8, 9], 
[10, 11, 12, 13, 14], 
[15, 16, 17, 18, 19], 
[20, 21, 22, 23, 24], 
[0, 5, 10, 15, 20], 
[1, 6, 11, 16, 21], 
[2, 7, 12, 17, 22], 
[3, 8, 13, 18, 23], 
[4, 9, 14, 19, 24], 
[0, 6, 12, 18, 24], 
[5, 8, 12, 16, 20]]

var test_letter_set = ["s","p","a","n","s","m","n","r","a","t","a","u","i","o","o","r","n","l","p","p","t","r","a","p","s"]

var valid_words = []
var wordInstanceMap = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	test_letter_set.shuffle()
	var i = 0
	for tile in tiles:
		tile.set_letter(test_letter_set[i])
		i += 1
		tileHolder.setup_tile(tile)
	
	for slot in slots:
		slot.tile_changed.connect(update)
		
	var file = FileAccess.open("res://small.txt", FileAccess.READ)
	while (file.get_position() <file.get_length()):
		var line = file.get_line()
		valid_words.append(line)
	file.close()

func update(slot: DropSlot):
	var words = []
	for line in lineSlotIndexes:
		#if middle slot empty, no words possible in this line so can early exit this check
		var c = slots[line[2]].letter()
		if (c == "-"):
			continue
		var a = slots[line[0]].letter()
		var b = slots[line[1]].letter()
		var d = slots[line[3]].letter()
		var e = slots[line[4]].letter()
		
		var lastChunk : String = c+d+e
		print(lastChunk)
		if (!lastChunk.contains("-") && valid_words.has(lastChunk.to_lower())):
			words.append(lastChunk)
			print("----yay that's a word!")
		if (b == "-"):
			continue
			
		var firstChunk : String = a+b+c
		print(firstChunk)
		if (!firstChunk.contains("-") && valid_words.has(firstChunk.to_lower())):
			words.append(firstChunk)
			print("----yay that's a word!")
		if (d == "-"):
			continue
			
		var middleChunk : String = b+c+d
		print(middleChunk)
		if (!middleChunk.contains("-") && valid_words.has(middleChunk.to_lower())):
			words.append(middleChunk)
			print("----yay that's a word!")
		
		var lastChunkLong : String = b+c+d+e
		print(lastChunkLong)
		if (!lastChunkLong.contains("-") && valid_words.has(lastChunkLong.to_lower())):
			words.append(lastChunkLong)
			print("----yay that's a word!")
		if (a == "-"):
			continue
			
		var firstChunkLong : String = a+b+c+d
		print(firstChunkLong)
		if (!firstChunkLong.contains("-") && valid_words.has(firstChunkLong.to_lower())):
			words.append(firstChunkLong)
			print("----yay that's a word!")
		if (e == "-"):
			continue
		
		var linestring: String = a+b+c+d+e
		print(linestring)
		if (valid_words.has(linestring.to_lower())):
			words.append(linestring)
			print("----yay that's a word!")
	
	for wordInstance in wordInstanceMap:
		if !words.has(wordInstance):
			wordInstanceMap[wordInstance].queue_free()
			wordInstanceMap.erase(wordInstance)
	
	for word in words:
		make_word(word)
	
	var total = 0
	for word in wordInstanceMap:
		total += wordInstanceMap[word].get_points()
	
	score.text = "SCORE: " + str(total)

func make_word(word: String):
	if word in wordInstanceMap:
		return
	var wordInstance : Word = wordScene.create_instance()
	wordInstance.set_word(word)
	wordInstanceMap[word] = wordInstance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
