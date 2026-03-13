extends Node2D

@onready var game_manager: Node = %GameManager
@onready var mop: Button = $Buttons/Mop
@onready var trash: Button = $Buttons/Trash
@onready var tool_notification: Label = $CanvasLayer/ToolNotification
@onready var care_bar: ProgressBar = $CanvasLayer/CareBar
@onready var care_label: Label = $CanvasLayer/CareLabel
@onready var distortion_overlay: ColorRect = $CanvasLayer/DistortionOverlay

var cursor_mop = preload("res://Assets/UI/Mop button.png")
var cursor_trash = preload("res://Assets/UI/Trash button.png")

func _ready() -> void:
	game_manager.notification_requested.connect(_show_notification)
	game_manager.level_completed.connect(_on_level_completed)
	game_manager.tool_changed.connect(_on_tool_changed)
	game_manager.cleaning_progress.connect(_on_cleaning_progress)
	game_manager.care_changed.connect(_on_care_changed)

	var trash_count = get_tree().get_nodes_in_group("trash").size()
	var water_count = get_tree().get_nodes_in_group("water").size()
	game_manager.setup_level(trash_count, water_count)

	_on_tool_changed(game_manager.current_tool)
	tool_notification.text = ""

func _on_button_3_pressed() -> void:
	game_manager.add_care(3.0)
	_show_notification("Care +3")

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

func _show_notification(message: String) -> void:
	tool_notification.text = message
	tool_notification.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(tool_notification, "modulate:a", 0.0, 0.5)

func _on_level_completed() -> void:
	_show_notification("All clean! Next level unlocked")

func _on_care_changed(current_care: float, max_care: float, distortion_strength: float, chaos_strength: float) -> void:
	care_bar.max_value = max_care
	care_bar.value = current_care
	care_label.text = "Care: " + str(int(ceil(current_care))) + " / " + str(int(max_care))

	# Efek sederhana dulu: overlay makin kuat saat care turun
	var alpha := distortion_strength * 0.35
	var red := 0.2 + chaos_strength * 0.4
	distortion_overlay.color = Color(red, 0.0, 0.0, alpha)
