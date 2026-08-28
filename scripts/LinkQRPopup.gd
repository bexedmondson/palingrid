class_name LinkQRPopup
extends Control

@export var qr_code : TextureRect
@export var code_label : Label

var _verification_url : String

func _enter_tree() -> void:
	hide()

func show_with_code(user_code: String, verification_url: String, qr_data_url: String):
	_verification_url = verification_url
	code_label.text = user_code

	## Decode a base64 PNG data URL onto a TextureRect. Returns true on success.
	# Strip the "data:image/png;base64," prefix
	var comma = qr_data_url.find(",")
	if comma == -1:
		CheddaBoards.device_code_error.emit("Invalid QR data URL (no comma found)")
		return

	var b64 = qr_data_url.substr(comma + 1)
	var raw: PackedByteArray = Marshalls.base64_to_raw(b64)
	if raw.is_empty():
		CheddaBoards.device_code_error.emit("Invalid QR data URL (could not convert to bytes)")
		return

	var img = Image.new()
	if img.load_png_from_buffer(raw) != OK:
		CheddaBoards.device_code_error.emit("Invalid QR data URL (image load from buffer failed)")
		return

	CheddaBoards.device_code_expired.connect(on_device_code_changed)
	CheddaBoards.device_code_error.connect(on_device_code_changed)
	CheddaBoards.device_code_approved.connect(on_device_code_changed)

	qr_code.texture = ImageTexture.create_from_image(img)
	self.visible = true

func on_device_code_changed(_data: String = ""):
	if CheddaBoards.device_code_approved.is_connected(on_device_code_changed):
		CheddaBoards.device_code_approved.disconnect(on_device_code_changed)
	if CheddaBoards.device_code_expired.is_connected(on_device_code_changed):
		CheddaBoards.device_code_expired.disconnect(on_device_code_changed)
	if CheddaBoards.device_code_error.is_connected(on_device_code_changed):
		CheddaBoards.device_code_error.disconnect(on_device_code_changed)

	self.visible = false


func on_verification_link_button():
	OS.shell_open(_verification_url)
