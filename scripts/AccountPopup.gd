class_name AccountPopup
extends Control

@export var name_change_handler : NameChangeHandler
@export var login_handler : LoginHandler

@export var name_label : Label
@export var connection_warning : Control

@export var link_account_section : Control
@export var link_popup : LinkQRPopup
@export var loading_spinner : LoadingSpinnerTweenController
@export var link_error_message : Label

@export var logout_section : Control

var show_hide_tween : Tween

func _enter_tree() -> void:
	hide()

func do_show():
	_refresh_ui()
	
	super.show()
	
	if show_hide_tween != null and show_hide_tween.is_valid():
		show_hide_tween.kill()
	show_hide_tween = create_tween()
	show_hide_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	show_hide_tween.tween_property(self, "scale", Vector2(1,1), 0.2).from(Vector2.ZERO)
	show_hide_tween.play()


func _refresh_ui():
	link_popup.visible = false
	connection_warning.visible = !CheddaBoards.is_logged_in()
	link_account_section.visible = !CheddaBoards.has_account()
	logout_section.visible = CheddaBoards.has_account() || CheddaBoards.get_nickname() != ""
	update_name_label()


func update_name_label():
	name_label.text = "Hello %s!" % (login_handler.nickname if login_handler.nickname != "" else "Guest")


func on_rename_pressed():
	if name_change_handler.on_closed.is_connected(_on_name_change_prompt_closed):
		name_change_handler.on_closed.disconnect(_on_name_change_prompt_closed)

	name_change_handler.on_closed.connect(_on_name_change_prompt_closed)
	name_change_handler._show_name_entry_panel(true)


func _on_name_change_prompt_closed():
	name_change_handler.on_closed.disconnect(_on_name_change_prompt_closed)
	connection_warning.visible = !CheddaBoards.is_logged_in()
	update_name_label()


func _on_back_pressed():
	if show_hide_tween != null and show_hide_tween.is_valid():
		show_hide_tween.kill()
	show_hide_tween = create_tween()
	show_hide_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	show_hide_tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	show_hide_tween.play()

	await show_hide_tween.finished

	self.visible = false;


func on_link_account_pressed():
	CheddaBoards.device_code_received.connect(on_device_code_received)
	CheddaBoards.device_code_error.connect(on_device_code_error)
	
	link_error_message.visible = false
	loading_spinner.play()
	
	CheddaBoards.login_with_device_code()

func on_device_code_error(reason: String):
	push_error("[AccountPopup] Device code error: " + reason)
	CheddaBoards.device_code_error.disconnect(on_device_code_error)
	
	if CheddaBoards.device_code_received.is_connected(on_device_code_received):
		CheddaBoards.device_code_received.disconnect(on_device_code_received)
	if CheddaBoards.device_code_expired.is_connected(on_device_code_expired):
		CheddaBoards.device_code_expired.disconnect(on_device_code_expired)
	
	loading_spinner.stop()
	link_popup.visible = false
	link_error_message.text = "An error occurred. Please try again."
	link_error_message.visible = true

func on_device_code_received(user_code: String, verification_url: String, qr_data_url: String):
	CheddaBoards.device_code_received.disconnect(on_device_code_received)
	#note: keep the device code error signal connection here 
	
	loading_spinner.stop()
	link_error_message.visible = false
	link_popup.show_with_code(user_code, verification_url, qr_data_url)
	
func on_device_code_expired():
	CheddaBoards.device_code_expired.disconnect(on_device_code_expired)
	CheddaBoards.device_code_error.disconnect(on_device_code_error)
	
	link_error_message.text = "Code expired. Please try again."
	link_error_message.visible = true
	link_popup.visible = false


func on_device_code_approved(_nickname: String):
	CheddaBoards.device_code_approved.disconnect(on_device_code_approved)
	CheddaBoards.device_code_expired.disconnect(on_device_code_expired)
	CheddaBoards.device_code_error.disconnect(on_device_code_error)

	link_popup.visible = false
	_refresh_ui()

func on_cancel_device_code_button():
	CheddaBoards.device_code_approved.disconnect(on_device_code_approved)
	CheddaBoards.device_code_expired.disconnect(on_device_code_expired)
	CheddaBoards.device_code_error.disconnect(on_device_code_error)

	link_popup.visible = false
	CheddaBoards.cancel_device_code()
	
func on_logout_button():
	CheddaBoards.logout_success.connect(_on_logged_out)
	CheddaBoards.logout()
	
func _on_logged_out():
	_refresh_ui()
