extends Area2D

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		print("garbage collected!")
		queue_free()
