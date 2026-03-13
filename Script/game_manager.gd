extends Node

signal tool_changed(tool_name)
signal notification_requested(message)
signal cleaning_progress(trash_left, water_left)
signal level_completed
signal care_changed(current_care, max_care, distortion_strength, chaos_strength)

var current_tool = "none"

var max_care := 100.0
var current_care := 100.0
var care_drain_per_second := 5.0

var trash_picked = 0
var water_mopped = 0

var total_trash = 0
var total_water = 0

var is_level_finished := false

func _ready() -> void:
	current_tool = "none"
	current_care = max_care
	trash_picked = 0
	water_mopped = 0
	is_level_finished = false

func _process(delta: float) -> void:
	if is_level_finished:
		return

	if current_care > 0.0:
		current_care -= care_drain_per_second * delta
		current_care = max(current_care, 0.0)
		_emit_care()

func setup_level(trash_count: int, water_count: int) -> void:
	current_tool = "none"
	current_care = max_care
	trash_picked = 0
	water_mopped = 0
	total_trash = trash_count
	total_water = water_count
	is_level_finished = false

	_emit_progress()
	tool_changed.emit(current_tool)
	_emit_care()

func set_tool(tool_name: String) -> void:
	current_tool = tool_name
	tool_changed.emit(current_tool)

	match tool_name:
		"Mop":
			notification_requested.emit("Mop equipped")
		"Trash bag":
			notification_requested.emit("Trash bag equipped")
		"none":
			notification_requested.emit("No tool equipped")
		_:
			notification_requested.emit(tool_name + " equipped")

func add_care(amount: float) -> void:
	current_care += amount
	current_care = clamp(current_care, 0.0, max_care)
	_emit_care()
	notification_requested.emit("Care +" + str(int(amount)))
	
func pickup_trash() -> void:
	trash_picked += 1
	print("Picked up trash")
	_check_level_complete()

func mop_floor() -> void:
	water_mopped += 1
	print("Mopped floor")
	_check_level_complete()

func can_go_next_level() -> bool:
	return trash_picked >= total_trash and water_mopped >= total_water

func _check_level_complete() -> void:
	_emit_progress()
	if can_go_next_level():
		is_level_finished = true
		notification_requested.emit("All clean! Next level unlocked")
		level_completed.emit()

func _emit_progress() -> void:
	var trash_left = max(total_trash - trash_picked, 0)
	var water_left = max(total_water - water_mopped, 0)
	cleaning_progress.emit(trash_left, water_left)

func _emit_care() -> void:
	care_changed.emit(
		current_care,
		max_care,
		get_distortion_strength(),
		get_chaos_strength()
	)

func get_distortion_strength() -> float:
	if current_care > 25.0:
		return 0.0
	elif current_care > 20.0:
		return remap(current_care, 25.0, 20.0, 0.05, 0.35)
	else:
		return remap(current_care, 20.0, 0.0, 0.4, 1.0)

func get_chaos_strength() -> float:
	if current_care > 20.0:
		return 0.0
	return remap(current_care, 20.0, 0.0, 0.0, 1.0)
