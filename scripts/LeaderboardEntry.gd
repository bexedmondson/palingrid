class_name LeaderboardEntry
extends PanelContainer

@export var rank_label : Label
@export var name_label : Label
@export var score_label : Label
@export var player_outline : Control
@export var background : PanelContainer
@export var rank1_style : StyleBox
@export var rank2_style : StyleBox
@export var rank3_style : StyleBox
@export var even_style : StyleBox
@export var odd_style : StyleBox
@export var accent_text_color: Color = Color("f5a623")         # CheddaBoards gold/cheese
@export var default_text_color: Color = Color("e0e0e0")
@export var dim_text_color: Color = Color("888888")

func set_entry(rank : int, name: String, score: int, is_player: bool):
	rank_label.text = "#%d" % rank
	name_label.text = name
	score_label.text = str(score)
	player_outline.visible = is_player
	
	match rank:
		1:
			background.set_theme_type_variation(&"LeaderboardEntryRank1")
			rank_label.add_theme_color_override("font_color", Color.GOLD)
		2:
			background.set_theme_type_variation(&"LeaderboardEntryRank2")
			rank_label.add_theme_color_override("font_color", Color.SILVER)
		3:
			background.set_theme_type_variation(&"LeaderboardEntryRank3")
			rank_label.add_theme_color_override("font_color", Color("#CD7F32"))
		_:
			background.set_theme_type_variation(&"LeaderboardEntryRankEven" if rank % 2 == 0 else &"LeaderboardEntryRankOdd")
			rank_label.add_theme_color_override("font_color", dim_text_color)
	
	name_label.add_theme_color_override("font_color", Color.WHITE if is_player else default_text_color)
	score_label.add_theme_color_override("font_color", accent_text_color if rank <= 3 else default_text_color)
