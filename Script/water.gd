extends Sprite2D

@onready var game_manager: Node = %GameManager
var frames = texture.get_width() / region_rect.size.x

func _input(event):
	if event.is_action_pressed("click"):
		if self.get_rect().has_point(get_local_mouse_position()) and game_manager.current_tool == "Mop":
			game_manager.pickup_trash()
			queue_free()

func _ready() -> void:
	var random_index = randi_range(0, frames-1)
	region_rect.position.x = random_index * region_rect.size.x
