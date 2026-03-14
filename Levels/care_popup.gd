extends Control
class_name CarePopup

signal popup_closed

@onready var popup_image: TextureRect = $PopupImage
@onready var close_button: Button = $PopupImage/CloseButton

const CLOSE_MARGIN := 8.0
const POPUP_MAX_SCREEN_RATIO := 0.65 # popup max 65% dari layar

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	close_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	close_button.pressed.connect(_on_close_button_pressed)

	set_anchors_preset(Control.PRESET_FULL_RECT)

	popup_image.mouse_filter = Control.MOUSE_FILTER_STOP
	popup_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	popup_image.stretch_mode = TextureRect.STRETCH_SCALE

func show_texture(texture: Texture2D) -> void:
	popup_image.texture = texture
	_resize_and_center_popup()
	_place_close_button()

	visible = true
	get_tree().paused = true

func hide_popup() -> void:
	visible = false
	get_tree().paused = false
	popup_closed.emit()

func is_open() -> bool:
	return visible

func _on_close_button_pressed() -> void:
	hide_popup()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and visible:
		_resize_and_center_popup()
		_place_close_button()

func _resize_and_center_popup() -> void:
	if popup_image.texture == null:
		return

	var tex_size: Vector2 = popup_image.texture.get_size()
	var max_size: Vector2 = size * POPUP_MAX_SCREEN_RATIO

	var scale_x: float = max_size.x / tex_size.x
	var scale_y: float = max_size.y / tex_size.y
	var scale: float = minf(minf(scale_x, scale_y), 1.0)

	var final_size: Vector2 = tex_size * scale

	popup_image.size = final_size
	popup_image.position = (size - final_size) / 2.0

func _place_close_button() -> void:
	close_button.reset_size()
	close_button.position = Vector2(
		popup_image.size.x - close_button.size.x - CLOSE_MARGIN,
		CLOSE_MARGIN
	)
