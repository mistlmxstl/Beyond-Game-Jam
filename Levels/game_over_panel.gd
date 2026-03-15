extends ColorRect
class_name GameOverPanel

signal try_again_pressed

@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/PanelContainer/VBoxContainer/SubtitleLabel
@onready var try_again_button: Button = $CenterContainer/PanelContainer/VBoxContainer/TryAgainButton

var pulse_tween: Tween

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	try_again_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	try_again_button.pressed.connect(_on_try_again_button_pressed)

	color = Color(0, 0, 0, 0.0)
	_setup_styles()

func _setup_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.04, 0.05, 0.96)
	panel_style.border_color = Color(0.75, 0.18, 0.22, 1.0)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.content_margin_left = 28
	panel_style.content_margin_right = 28
	panel_style.content_margin_top = 24
	panel_style.content_margin_bottom = 24
	panel.add_theme_stylebox_override("panel", panel_style)

	title_label.text = "GAME OVER"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.78))
	title_label.modulate = Color(1.0, 0.9, 0.9, 1.0)

	subtitle_label.text = "You pushed yourself too far.\nThe room is still watching."
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", Color(0.86, 0.82, 0.82))

	try_again_button.text = "TRY AGAIN"
	try_again_button.custom_minimum_size = Vector2(190, 46)

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.38, 0.08, 0.10, 1.0)
	normal_style.border_color = Color(0.95, 0.65, 0.65, 1.0)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 5
	normal_style.corner_radius_top_right = 5
	normal_style.corner_radius_bottom_left = 5
	normal_style.corner_radius_bottom_right = 5

	var hover_style: StyleBoxFlat = normal_style.duplicate()
	hover_style.bg_color = Color(0.55, 0.10, 0.12, 1.0)

	var pressed_style: StyleBoxFlat = normal_style.duplicate()
	pressed_style.bg_color = Color(0.22, 0.04, 0.05, 1.0)

	try_again_button.add_theme_stylebox_override("normal", normal_style)
	try_again_button.add_theme_stylebox_override("hover", hover_style)
	try_again_button.add_theme_stylebox_override("pressed", pressed_style)
	try_again_button.add_theme_color_override("font_color", Color(1, 0.95, 0.95))

func show_panel() -> void:
	visible = true
	modulate.a = 0.0
	panel.scale = Vector2(0.92, 0.92)
	color = Color(0, 0, 0, 0.0)
	title_label.modulate = Color(1.0, 0.9, 0.9, 1.0)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.parallel().tween_property(self, "color", Color(0.02, 0.0, 0.0, 0.84), 0.35)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.25)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.22)

	await tween.finished
	_start_horror_pulse()

func hide_panel() -> void:
	if pulse_tween != null:
		pulse_tween.kill()
	visible = false

func _start_horror_pulse() -> void:
	if pulse_tween != null:
		pulse_tween.kill()

	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	pulse_tween.parallel().tween_property(panel, "scale", Vector2(1.015, 1.015), 1.2)
	pulse_tween.parallel().tween_property(title_label, "modulate", Color(0.85, 0.55, 0.55, 0.9), 0.9)
	pulse_tween.tween_interval(0.05)
	pulse_tween.parallel().tween_property(panel, "scale", Vector2.ONE, 1.0)
	pulse_tween.parallel().tween_property(title_label, "modulate", Color(1.0, 0.9, 0.9, 1.0), 0.8)

func _on_try_again_button_pressed() -> void:
	try_again_pressed.emit()
