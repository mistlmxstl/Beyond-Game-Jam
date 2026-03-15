extends CanvasLayer

@onready var pause_button: Button = get_node_or_null("PauseButton")
@onready var pause_menu: Control = get_node_or_null("PauseMenu")
@onready var dark_bg: ColorRect = get_node_or_null("PauseMenu/DarkBg")
@onready var resume_button: Button = get_node_or_null("PauseMenu/Panel/VBoxContainer/ResumeButton")
@onready var restart_button: Button = get_node_or_null("PauseMenu/Panel/VBoxContainer/RestartButton")
@onready var quit_button: Button = get_node_or_null("PauseMenu/Panel/VBoxContainer/QuitButton")

func _ready() -> void:
	if pause_button == null:
		push_error("PauseButton not found")
		return
	if pause_menu == null:
		push_error("PauseMenu not found")
		return
	if dark_bg == null:
		push_error("PauseMenu/DarkBg not found")
		return
	if resume_button == null:
		push_error("ResumeButton not found")
		return
	if restart_button == null:
		push_error("RestartButton not found")
		return
	if quit_button == null:
		push_error("QuitButton not found")
		return
	
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	quit_button.process_mode = Node.PROCESS_MODE_ALWAYS

	pause_menu.hide()

	pause_button.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	dark_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	resume_button.mouse_filter = Control.MOUSE_FILTER_STOP
	restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
	quit_button.mouse_filter = Control.MOUSE_FILTER_STOP

	if not pause_button.pressed.is_connected(_on_pause_button_pressed):
		pause_button.pressed.connect(_on_pause_button_pressed)

	if not resume_button.pressed.is_connected(_on_resume_button_pressed):
		resume_button.pressed.connect(_on_resume_button_pressed)

	if not restart_button.pressed.is_connected(_on_restart_button_pressed):
		restart_button.pressed.connect(_on_restart_button_pressed)

	if not quit_button.pressed.is_connected(_on_quit_button_pressed):
		quit_button.pressed.connect(_on_quit_button_pressed)

func _on_pause_button_pressed() -> void:
	pause_menu.show()
	get_tree().paused = true

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	pause_menu.hide()

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Levels/Main_menu.tscn")
