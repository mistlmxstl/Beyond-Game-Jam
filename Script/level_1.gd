extends Node2D

@onready var game_manager: Node = %GameManager
@onready var mop: Button = $Buttons/Mop
@onready var trash: Button = $Buttons/Trash

var cursor_mop = preload("res://Assets/UI/Mop button.png")
var cursor_trash = preload("res://Assets/UI/Trash button.png")

func _ready() -> void:
	game_manager.level_completed.connect(_on_level_completed)
	game_manager.tool_changed.connect(_on_tool_changed)
	game_manager.cleaning_progress.connect(_on_cleaning_progress)

	var trash_count = get_tree().get_nodes_in_group("trash").size()
	var water_count = get_tree().get_nodes_in_group("water").size()
	game_manager.setup_level(trash_count, water_count)

	_on_tool_changed(game_manager.current_tool)

#Care button
func _on_button_3_pressed() -> void:
	pass

func _on_mop_pressed() -> void:
	game_manager.set_tool("Mop")

func _on_trash_pressed() -> void:
	game_manager.set_tool("Trash bag")

func _on_cleaning_progress(trash_left, water_left) -> void:
	print("Trash left: ", trash_left, " | Water left: ", water_left)

func _on_tool_changed(tool_name: String) -> void:
	match tool_name:
		"Mop":
			Input.set_custom_mouse_cursor(cursor_mop)
		"Trash bag":
			Input.set_custom_mouse_cursor(cursor_trash)
		_:
			Input.set_custom_mouse_cursor(null)


func _on_level_completed() -> void:
	pass # get_tree().change_scene_to_file("res://Levels/level_2.tscn")
