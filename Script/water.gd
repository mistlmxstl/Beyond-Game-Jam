extends Sprite2D

@onready var game_manager: Node = %GameManager
@onready var frames: int = int(texture.get_width() / region_rect.size.x)

func _ready() -> void:
	add_to_group("water")
	var random_index = randi_range(0, frames - 1)
	region_rect.position.x = random_index * region_rect.size.x

func _input(event):
	if event.is_action_pressed("click"):
		if get_rect().has_point(get_local_mouse_position()) and game_manager.current_tool == "Mop":
			game_manager.mop_floor()
			queue_free()
