extends Node2D

@onready var game_manager: Node = %GameManager
@onready var tool_notification: Label = $CanvasLayer/ToolNotification
@onready var care_bar: ProgressBar = $CanvasLayer/CareBar
@onready var distortion_overlay: ColorRect = $CanvasLayer/DistortionOverlay
@onready var care_popup: CarePopup = $CanvasLayer/CarePopup
@onready var game_over_panel: GameOverPanel = $CanvasLayer/GameOverPanel

@onready var normal_room: Node2D = $Environment
@onready var distorted_room: Node2D = $DistortedEnvironment

@onready var level_complete_panel: LevelCompletePanel = $CanvasLayer/LevelCompletePanel

const NEXT_LEVEL_SCENE := preload("res://Levels/level 2.tscn")

const CARE_FLICKER_START: float = 50.0
const CARE_LOCK_DISTORTED: float = 15.0

const FLICKER_SLOW_INTERVAL: float = 0.30
const FLICKER_FAST_INTERVAL: float = 0.10

var cursor_mop = preload("res://Assets/UI/Mop button.png")
var cursor_trash = preload("res://Assets/UI/Trash button.png")

var popup_50_texture = preload("res://Assets/UI/care_popup_50.png")
var popup_20_texture = preload("res://Assets/UI/care_popup_20.png")

var has_shown_popup_50 := false
var has_shown_popup_20 := false
var previous_care := 100.0

var is_flickering := false
var is_locked_distorted := false
var visual_transition_running := false

var flicker_timer := 0.0
var flicker_interval := FLICKER_SLOW_INTERVAL
var flicker_show_distorted := false

func _ready() -> void:
	has_shown_popup_50 = false
	has_shown_popup_20 = false
	previous_care = 100.0

	is_flickering = false
	is_locked_distorted = false
	visual_transition_running = false
	flicker_timer = 0.0
	flicker_show_distorted = false

	normal_room.visible = true
	distorted_room.visible = false

	tool_notification.visible = true
	care_bar.visible = true

	distortion_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if game_over_panel != null:
		game_over_panel.hide_panel()
		game_over_panel.try_again_pressed.connect(_on_try_again_pressed)
	
	if level_complete_panel != null:
		level_complete_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		level_complete_panel.hide_panel()
		level_complete_panel.next_level_pressed.connect(_on_next_level_pressed)

	care_popup.popup_closed.connect(_on_popup_closed)

	game_manager.notification_requested.connect(_show_notification)
	game_manager.level_completed.connect(_on_level_completed)
	game_manager.tool_changed.connect(_on_tool_changed)
	game_manager.cleaning_progress.connect(_on_cleaning_progress)
	game_manager.care_changed.connect(_on_care_changed)
	game_manager.game_over.connect(_on_game_over)

	var trash_count: int = get_tree().get_nodes_in_group("trash").size()
	var water_count: int = get_tree().get_nodes_in_group("water").size()
	game_manager.setup_level(trash_count, water_count)

	_on_tool_changed(game_manager.current_tool)
	tool_notification.text = ""

func _process(delta: float) -> void:
	if care_popup.is_open():
		return

	if game_over_panel != null and game_over_panel.visible:
		return

	if is_flickering and not is_locked_distorted and not visual_transition_running:
		flicker_timer += delta
		if flicker_timer >= flicker_interval:
			flicker_timer = 0.0
			flicker_show_distorted = !flicker_show_distorted
			_set_distorted_room(flicker_show_distorted)

func _on_button_3_pressed() -> void:
	if care_popup.is_open():
		return
	if game_over_panel != null and game_over_panel.visible:
		return
	if level_complete_panel != null and level_complete_panel.visible:
		return
	game_manager.start_break()

func _on_mop_pressed() -> void:
	if care_popup.is_open():
		return
	if game_over_panel != null and game_over_panel.visible:
		return
	if level_complete_panel != null and level_complete_panel.visible:
		return
	game_manager.set_tool("Mop")

func _on_trash_pressed() -> void:
	if care_popup.is_open():
		return
	if game_over_panel != null and game_over_panel.visible:
		return
	if level_complete_panel != null and level_complete_panel.visible:
		return
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
	if care_popup.is_open():
		return
	if game_over_panel != null and game_over_panel.visible:
		return

	tool_notification.text = message
	tool_notification.modulate.a = 1.0

	var tween := create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(tool_notification, "modulate:a", 0.0, 0.5)

func _on_level_completed() -> void:
	print("LEVEL COMPLETED")
	Input.set_custom_mouse_cursor(null)

	tool_notification.visible = false
	care_bar.visible = false

	if level_complete_panel != null:
		level_complete_panel.show_panel()

	get_tree().paused = true


func _on_next_level_pressed() -> void:
	print("NEXT LEVEL SIGNAL RECEIVED")
	get_tree().paused = false
	call_deferred("_go_to_next_level")

func _go_to_next_level() -> void:
	var err := get_tree().change_scene_to_packed(NEXT_LEVEL_SCENE)
	print("CHANGE SCENE RESULT: ", err)

func _on_care_changed(current_care: float, max_care: float, distortion_strength: float, chaos_strength: float) -> void:
	care_bar.max_value = max_care
	care_bar.value = current_care

	var alpha: float = distortion_strength * 0.35
	var red: float = 0.2 + chaos_strength * 0.4
	distortion_overlay.color = Color(red, 0.0, 0.0, alpha)

	if visual_transition_running:
		previous_care = current_care
		return

	if current_care > CARE_FLICKER_START:
		_show_normal_room()

	elif current_care > CARE_LOCK_DISTORTED:
		if previous_care > CARE_FLICKER_START and current_care <= CARE_FLICKER_START and not has_shown_popup_50:
			has_shown_popup_50 = true
			previous_care = current_care

			await _flash_room(6, 0.10, true)
			_start_distortion_flicker(current_care)

			Input.set_custom_mouse_cursor(null)
			care_popup.show_texture(popup_50_texture)
			return

		elif previous_care <= CARE_LOCK_DISTORTED and current_care > CARE_LOCK_DISTORTED:
			_start_distortion_flicker(current_care)

		else:
			if not is_locked_distorted:
				is_flickering = true
				flicker_interval = _get_flicker_interval(current_care)

	else:
		if previous_care > CARE_LOCK_DISTORTED and current_care <= CARE_LOCK_DISTORTED and not has_shown_popup_20:
			has_shown_popup_20 = true
			previous_care = current_care

			await _flash_room(10, 0.06, true)
			_lock_distorted_room()

			Input.set_custom_mouse_cursor(null)
			care_popup.show_texture(popup_20_texture)
			return
		else:
			_lock_distorted_room()

	previous_care = current_care

func _set_distorted_room(enabled: bool) -> void:
	normal_room.visible = not enabled
	distorted_room.visible = enabled

func _show_normal_room() -> void:
	is_flickering = false
	is_locked_distorted = false
	flicker_timer = 0.0
	flicker_show_distorted = false
	_set_distorted_room(false)

func _start_distortion_flicker(current_care: float) -> void:
	is_flickering = true
	is_locked_distorted = false
	flicker_timer = 0.0
	flicker_interval = _get_flicker_interval(current_care)
	flicker_show_distorted = true
	_set_distorted_room(true)

func _lock_distorted_room() -> void:
	is_flickering = false
	is_locked_distorted = true
	flicker_timer = 0.0
	flicker_show_distorted = true
	_set_distorted_room(true)

func _get_flicker_interval(current_care: float) -> float:
	var interval: float = remap(
		current_care,
		CARE_FLICKER_START,
		CARE_LOCK_DISTORTED,
		FLICKER_SLOW_INTERVAL,
		FLICKER_FAST_INTERVAL
	)
	return clampf(interval, FLICKER_FAST_INTERVAL, FLICKER_SLOW_INTERVAL)

func _flash_room(times: int, interval: float, end_distorted: bool) -> void:
	if visual_transition_running:
		return

	visual_transition_running = true
	is_flickering = false
	flicker_timer = 0.0

	for i in range(times):
		var show_distorted: bool = (i % 2 == 0)
		_set_distorted_room(show_distorted)
		await get_tree().create_timer(interval).timeout

	_set_distorted_room(end_distorted)
	visual_transition_running = false

func _on_popup_closed() -> void:
	_on_tool_changed(game_manager.current_tool)

func _on_game_over() -> void:
	Input.set_custom_mouse_cursor(null)

	tool_notification.visible = false
	care_bar.visible = false
	distortion_overlay.color = Color(0.35, 0.0, 0.0, 0.45)

	if game_over_panel != null:
		game_over_panel.show_panel()

	get_tree().paused = true

func _on_try_again_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
