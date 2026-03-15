extends Sprite2D

@onready var game_manager: Node = %GameManager
@onready var frames: int = int(texture.get_width() / region_rect.size.x)
@onready var care_popup: Control = $CanvasLayer/CarePopup
@onready var popup_image: TextureRect = $CanvasLayer/CarePopup/PopupImage
@onready var close_button: Button = $CanvasLayer/CarePopup/CloseButton

var popup_50_texture = preload("res://Assets/UI/care_popup_50.png")
var popup_20_texture = preload("res://Assets/UI/care_popup_20.png")

var has_shown_popup_50 := false
var has_shown_popup_20 := false
var is_popup_open := false

func _ready() -> void:
	add_to_group("trash")
	var random_index = randi_range(0, frames - 1)
	region_rect.position.x = random_index * region_rect.size.x

func _input(event):
	if event.is_action_pressed("click"):
		if get_rect().has_point(get_local_mouse_position()) and game_manager.current_tool == "Trash bag":
			game_manager.pickup_trash()
			queue_free()
func _show_care_popup(texture: Texture2D) -> void:
	if is_popup_open:
		return

	is_popup_open = true
	popup_image.texture = texture
	care_popup.visible = true
	get_tree().paused = true
	
func _on_close_popup_pressed() -> void:
	care_popup.visible = false
	is_popup_open = false
	get_tree().paused = false
