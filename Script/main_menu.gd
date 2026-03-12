extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/level 1.tscn")

func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Tutorial.tscn")

func _on_about_pressed() -> void:
	print("About page")
