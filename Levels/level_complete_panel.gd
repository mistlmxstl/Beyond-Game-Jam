extends ColorRect
class_name LevelCompletePanel

signal next_level_pressed

@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/PanelContainer/VBoxContainer/SubtitleLabel
@onready var next_level_button: Button = $CenterContainer/PanelContainer/VBoxContainer/NextLevelButton

var button_pulse_tween: Tween
var title_float_tween: Tween
var hover_tween: Tween

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	next_level_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	next_level_button.pressed.connect(_on_next_level_button_pressed)
	next_level_button.mouse_entered.connect(_on_button_mouse_entered)
	next_level_button.mouse_exited.connect(_on_button_mouse_exited)
	next_level_button.focus_entered.connect(_on_button_focus_entered)
	next_level_button.focus_exited.connect(_on_button_focus_exited)

	color = Color(0, 0, 0, 0.0)
	_setup_styles()

func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept"):
		next_level_pressed.emit()

func _setup_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.10, 0.18, 0.12, 0.96)
	panel_style.border_color = Color(0.72, 1.0, 0.78, 1.0)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.content_margin_left = 28
	panel_style.content_margin_right = 28
	panel_style.content_margin_top = 24
	panel_style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", panel_style)

	title_label.text = "YAY, ALL CLEAN!"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_color_override("font_color", Color(0.95, 1.0, 0.95))

	subtitle_label.text = "The room looks so much better now.\nLet's go to the next one!"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", Color(0.90, 0.97, 0.90))

	next_level_button.text = "LET'S GO!"
	next_level_button.custom_minimum_size = Vector2(210, 48)

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.22, 0.56, 0.24, 1.0)
	normal_style.border_color = Color(0.92, 1.0, 0.92, 1.0)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8

	var hover_style: StyleBoxFlat = normal_style.duplicate()
	hover_style.bg_color = Color(0.30, 0.70, 0.32, 1.0)

	var pressed_style: StyleBoxFlat = normal_style.duplicate()
	pressed_style.bg_color = Color(0.16, 0.40, 0.18, 1.0)

	next_level_button.add_theme_stylebox_override("normal", normal_style)
	next_level_button.add_theme_stylebox_override("hover", hover_style)
	next_level_button.add_theme_stylebox_override("pressed", pressed_style)
	next_level_button.add_theme_color_override("font_color", Color(1, 1, 1))

func show_panel() -> void:
	visible = true
	modulate.a = 0.0
	panel.scale = Vector2(0.85, 0.85)
	panel.rotation = deg_to_rad(-2.0)
	next_level_button.scale = Vector2.ONE
	title_label.position = Vector2.ZERO
	color = Color(0, 0, 0, 0.0)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.parallel().tween_property(self, "color", Color(0, 0, 0, 0.68), 0.25)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(panel, "scale", Vector2(1.04, 1.04), 0.16)
	tween.parallel().tween_property(panel, "rotation", 0.0, 0.16)
	await tween.finished

	var settle := create_tween()
	settle.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	settle.tween_property(panel, "scale", Vector2.ONE, 0.10)

	next_level_button.grab_focus()
	_start_button_pulse()
	_start_title_float()

func hide_panel() -> void:
	if button_pulse_tween != null:
		button_pulse_tween.kill()
	if title_float_tween != null:
		title_float_tween.kill()
	if hover_tween != null:
		hover_tween.kill()

	visible = false

func _start_button_pulse() -> void:
	if button_pulse_tween != null:
		button_pulse_tween.kill()

	button_pulse_tween = create_tween()
	button_pulse_tween.set_loops()
	button_pulse_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	button_pulse_tween.tween_property(next_level_button, "scale", Vector2(1.04, 1.04), 0.55)
	button_pulse_tween.tween_property(next_level_button, "scale", Vector2.ONE, 0.55)

func _start_title_float() -> void:
	if title_float_tween != null:
		title_float_tween.kill()

	title_float_tween = create_tween()
	title_float_tween.set_loops()
	title_float_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	title_float_tween.tween_property(title_label, "position:y", -3.0, 0.9)
	title_float_tween.tween_property(title_label, "position:y", 0.0, 0.9)

func _on_button_mouse_entered() -> void:
	_button_hover_on()

func _on_button_mouse_exited() -> void:
	_button_hover_off()

func _on_button_focus_entered() -> void:
	_button_hover_on()

func _on_button_focus_exited() -> void:
	_button_hover_off()

func _button_hover_on() -> void:
	if hover_tween != null:
		hover_tween.kill()

	next_level_button.text = "GO GO GO! ✨"

	hover_tween = create_tween()
	hover_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	hover_tween.tween_property(next_level_button, "scale", Vector2(1.10, 1.10), 0.12)

func _button_hover_off() -> void:
	if hover_tween != null:
		hover_tween.kill()

	next_level_button.text = "LET'S GO!"

	hover_tween = create_tween()
	hover_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	hover_tween.tween_property(next_level_button, "scale", Vector2.ONE, 0.12)

func _on_next_level_button_pressed() -> void:
	next_level_pressed.emit()
