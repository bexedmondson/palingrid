extends Button

@export var grid : Grid
@export var letter_set_generator : DailyLetterSetGenerator

@export var copy_indicator : Control

const map = {
	"a": "𝙰",
	"b": "𝙱",
	"c": "𝙲",
	"d": "𝙳",
	"e": "𝙴",
	"f": "𝙵",
	"g": "𝙶",
	"h": "𝙷",
	"i": "𝙸",
	"j": "𝙹",
	"k": "𝙺",
	"l": "𝙻",
	"m": "𝙼",
	"n": "𝙽",
	"o": "𝙾",
	"p": "𝙿",
	"q": "𝚀",
	"r": "𝚁",
	"s": "𝚂",
	"t": "𝚃",
	"u": "𝚄",
	"v": "𝚅",
	"w": "𝚆",
	"x": "𝚇",
	"y": "𝚈",
	"z": "𝚉",
	"-": "_ "
}

func _enter_tree() -> void:
	copy_indicator.modulate.a = 0;

func on_pressed():
	var date = Time.get_date_string_from_unix_time(letter_set_generator.daySeed)
	var share = "Palingrid %s: %d points" % [ date, grid.total ]
	
	var count = 0
	for slot in grid.slots:
		if count % 5 == 0:
			share += "\n"
		count += 1
		share += map[slot.letter()] + " "
		
	share += "\n\nhttps://bexmakesgames.itch.io/palingrid/"
	
	DisplayServer.clipboard_set(share)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(copy_indicator, "modulate:a", 0, 1.2).from(1)
	tween.play()
	
