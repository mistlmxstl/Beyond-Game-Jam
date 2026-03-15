extends CanvasLayer

@onready var pause_button: Button = $PauseButton
@onready var pause_menu: Control = $PauseMenu
@onready var dark_bg: ColorRect = $PauseMenu/DarkBg
@onready var resume_button: Button = $PauseMenu/Panel/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PauseMenu/Panel/VBoxContainer/RestartButton
@onready var quit_button: Button = $PauseMenu/Panel/VBoxContainer/QuitButton

func _ready() -> void:
	get_tree().paused = false

	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
	quit_button.process_mode = Node.PROCESS_MODE_ALWAYS

	pause_menu.hide()
	pause_menu.visible = false

	pause_button.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu.mouse_filter = Control.MOUSE_FILTER_STOP
	dark_bg.mouse_filter = Control.MOUSE_FILTER_STOP

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
	get_tree().quit()
