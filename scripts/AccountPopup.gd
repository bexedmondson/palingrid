class_name AccountPopup
extends Control

@export var name_change_handler : NameChangeHandler
@export var login_handler : LoginHandler

@export var name_label : Label
@export var connection_warning : Control
@export var loading_indicator : Control

var show_hide_tween : Tween

func do_show():
	connection_warning.visible = !CheddaBoards.is_logged_in()
	name_label.text = "Hello %s!" % login_handler.nickname
	
	super.show()
	
	if show_hide_tween != null and show_hide_tween.is_valid():
		show_hide_tween.kill()
	show_hide_tween = create_tween()
	show_hide_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	show_hide_tween.tween_property(self, "scale", Vector2(1,1), 0.2).from(Vector2.ZERO)
	show_hide_tween.play()


func on_rename_pressed():
	if name_change_handler.on_closed.is_connected(_on_name_change_prompt_closed):
		name_change_handler.on_closed.disconnect(_on_name_change_prompt_closed)

	name_change_handler.on_closed.connect(_on_name_change_prompt_closed)
	name_change_handler._show_name_entry_panel(true)


func _on_name_change_prompt_closed():
	name_change_handler.on_closed.disconnect(_on_name_change_prompt_closed)
	connection_warning.visible = !CheddaBoards.is_logged_in()
	name_label.text = "Hello %s!" % login_handler.nickname


func _on_back_pressed():
	if show_hide_tween != null and show_hide_tween.is_valid():
		show_hide_tween.kill()
	show_hide_tween = create_tween()
	show_hide_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	show_hide_tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	show_hide_tween.play()

	await show_hide_tween.finished

	self.visible = false;
