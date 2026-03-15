extends ColorRect
class_name LevelCompletePanel

signal next_level_pressed

@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/PanelContainer/VBoxContainer/SubtitleLabel
@onready var next_level_button: Button = $CenterContainer/PanelContainer/VBoxContainer/NextLevelButton

func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	next_level_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	next_level_button.pressed.connect(_on_next_level_button_pressed)

	color = Color(0, 0, 0, 0.0)
	_setup_styles()

func _setup_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.12, 0.08, 0.96)
	panel_style.border_color = Color(0.55, 0.9, 0.55, 1.0)
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

	title_label.text = "LEVEL COMPLETE"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.9, 1.0, 0.9))

	subtitle_label.text = "You cleaned the room.\nReady for the next level?"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", Color(0.9, 0.95, 0.9))

	next_level_button.text = "NEXT LEVEL"
	next_level_button.custom_minimum_size = Vector2(190, 46)

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.18, 0.5, 0.18, 1.0)
	normal_style.border_color = Color(0.8, 1.0, 0.8, 1.0)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 5
	normal_style.corner_radius_top_right = 5
	normal_style.corner_radius_bottom_left = 5
	normal_style.corner_radius_bottom_right = 5

	var hover_style: StyleBoxFlat = normal_style.duplicate()
	hover_style.bg_color = Color(0.24, 0.65, 0.24, 1.0)

	var pressed_style: StyleBoxFlat = normal_style.duplicate()
	pressed_style.bg_color = Color(0.12, 0.32, 0.12, 1.0)

	next_level_button.add_theme_stylebox_override("normal", normal_style)
	next_level_button.add_theme_stylebox_override("hover", hover_style)
	next_level_button.add_theme_stylebox_override("pressed", pressed_style)
	next_level_button.add_theme_color_override("font_color", Color(1, 1, 1))

func show_panel() -> void:
	visible = true
	modulate.a = 0.0
	panel.scale = Vector2(0.92, 0.92)
	color = Color(0, 0, 0, 0.0)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.parallel().tween_property(self, "color", Color(0, 0, 0, 0.72), 0.25)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.2)

func hide_panel() -> void:
	visible = false

func _on_next_level_button_pressed() -> void:
	next_level_pressed.emit()
