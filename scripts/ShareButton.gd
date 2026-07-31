extends Button

@export var grid : Grid

const map = {
	"a": "🇦",
	"b": "🇧",
	"c": "🇨",
	"d": "🇩",
	"e": "🇪",
	"f": "🇫",
	"g": "🇬",
	"h": "🇭",
	"i": "🇮",
	"j": "🇯",
	"k": "🇰",
	"l": "🇱",
	"m": "🇲",
	"n": "🇳",
	"o": "🇴",
	"p": "🇵",
	"q": "🇶",
	"r": "🇷",
	"s": "🇸",
	"t": "🇹",
	"u": "🇺",
	"v": "🇻",
	"w": "🇼",
	"x": "🇽",
	"y": "🇾",
	"z": "🇿",
	"-": "⭕"
}

func on_pressed():
	var share = ""
	var count = 0
	for slot in grid.slots:
		if count % 5 == 0:
			share += "\n"
		count += 1
		share += map[slot.letter()] + " "
	DisplayServer.clipboard_set(share)
	
