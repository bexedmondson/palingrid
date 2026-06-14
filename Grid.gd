class_name Grid
extends Control

@export var generator : DailyLetterSetGenerator
@export var tileHolder : TileDock
@export var slots : Array[DropSlot]
@export var tiles : Array[DropTile]
@export var wordScene : InstancePlaceholder
@export var score : Label
@export var bestScore : BestScoreIndicator

var lineSlotIndexes = [
	[0,  1,  2,  3,  4], 
	[5,  6,  7,  8,  9], 
	[10, 11, 12, 13, 14], 
	[15, 16, 17, 18, 19], 
	[20, 21, 22, 23, 24], 
	
	[0, 5, 10, 15, 20], 
	[1, 6, 11, 16, 21], 
	[2, 7, 12, 17, 22], 
	[3, 8, 13, 18, 23], 
	[4, 9, 14, 19, 24], 
	
	[0, 6, 12, 18, 24], 
	[4, 8, 12, 16, 20],
	
	[1, 7, 13, 19],
	[3, 7, 11, 15],
	[5, 11, 17, 23],
	[9, 13, 17, 21],
	
	[2, 6, 10],
	[2, 8, 14],
	[10, 16, 22],
	[14, 18, 22]
]

const grid_width : int = 5
const grid_height : int = 5
func letter_count(): return grid_width * grid_height

var valid_words = []
var wordInstanceMap = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generator.generate(letter_count())
	
	generator.generated_set.shuffle()
	print(generator.generated_set)
	
	bestScore.load()
	
	var i = 0
	for tile in tiles:
		tile.set_letter(generator.generated_set[i])
		i += 1
		tileHolder.setup_tile(tile)
	
	for slot in slots:
		slot.tile_changed.connect(update)
	
	var file = FileAccess.open("res://small.txt", FileAccess.READ)
	while (file.get_position() <file.get_length()):
		var line = file.get_line()
		valid_words.append(line)
	file.close()
	
var dash = "-"

func update(slot: DropSlot):
	#push_warning("grid - update from slot " + slot.name)
	var words = {}
	for line in lineSlotIndexes:
		add_line_words(line, words)
	
	#push_warning("grid - words: " + str(words))
	#push_warning("grid - wordinstancemap: " + str(wordInstanceMap))
	var wordInstancesToRemove = []
	for wordInstance in wordInstanceMap:
		#push_warning("grid - wordinstance for " + str(wordInstance) + " in words?: " + str(words.has(wordInstance)))
		if !words.has(wordInstance):
			wordInstanceMap[wordInstance].queue_free()
			wordInstancesToRemove.append(wordInstance)
	
	for wordInstanceToRemove in wordInstancesToRemove:
		wordInstanceMap.erase(wordInstanceToRemove)
	
	for word in words:
		make_word(word, words[word])
	#push_warning("grid - wordinstancemap: " + str(wordInstanceMap))
	
	var total = 0
	for word in wordInstanceMap:
		total += wordInstanceMap[word].get_points()
	
	score.text = "SCORE: " + str(total)
	
	bestScore.update(total)

func add_line_words(line: Array, words: Dictionary):
	#print(str(line))
	var l2 = line[2]
	#if middle slot empty, no words possible in this line so can early exit this check
	var c = slots[l2].letter()
	if (c == dash):
		return
		
	var l0 = line[0]
	var a = slots[l0].letter()
	var l1 = line[1]
	var b = slots[l1].letter()
	
	var chunk : String = a+b+c
	check_chunk(chunk, [l0,l1,l2], words)
	
	if (line.size() < 4):
		return
	
	var l3 = line[3]
	var d = slots[l3].letter()
	if (d == dash):
		return
	
	chunk = b+c+d
	check_chunk(chunk, [l1,l2,l3], words)
	
	chunk = a+b+c+d
	check_chunk(chunk, [l0,l1,l2,l3], words)
	
	if (line.size() < 5):
		return
	
	var l4 = line[4]
	var e = slots[l4].letter()
	if (e == dash):
		return
	
	chunk = c+d+e
	check_chunk(chunk, [l2,l3,l4], words)
	if (b == dash):
		return
	
	chunk = b+c+d+e
	check_chunk(chunk, [l1,l2,l3,l4], words)
	if (a == dash):
		return
	
	chunk = a+b+c+d+e
	check_chunk(chunk, [l0,l1,l2,l3,l4], words)

func check_chunk(chunk: String, indexes: Array[int], words: Dictionary):
	#print(chunk)
	if (chunk.contains(dash)):
		return
	if (valid_words.has(chunk)):
		words[chunk] = indexes
		#print("----yay that's a word!")
	chunk = chunk.reverse()
	if (valid_words.has(chunk)):
		words[chunk] = indexes
		#print("----yay that's a word!")

func make_word(word: String, indexes: Array[int]):
	if word in wordInstanceMap:
		return
	var wordInstance : Word = wordScene.create_instance()
	wordInstance.set_word(word, indexes, self)
	wordInstanceMap[word] = wordInstance

func highlight(indexes):
	for index in indexes:
		slots[index].highlight()
		
func filled_slot_count():
	return letter_count() - tileHolder.tile_count()
		
func reset_tiles():
	for slot in slots:
		if slot.slotTile == null:
			continue
		var tile = slot.slotTile
		tile.dragged_away.emit(tile)
		tileHolder.add_tile(tile)
