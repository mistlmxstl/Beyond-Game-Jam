extends Node

signal tool_changed(tool_name)
signal notification_requested(message)
signal cleaning_progress(trash_left, water_left)
signal level_completed
signal sanity_changed(current_sanity, max_sanity, distortion_strength)

var current_tool = "none"

var max_sanity := 30.0
var current_sanity := 30.0
var sanity_drain_per_second := 1.0

var trash_picked = 0
var water_mopped = 0

var total_trash = 0
var total_water = 0

var is_level_finished := false

func _ready() -> void:
	current_tool = "none"
	current_sanity = max_sanity
	trash_picked = 0
	water_mopped = 0
	is_level_finished = false

func _process(delta: float) -> void:
	if is_level_finished:
		return

	if current_sanity > 0.0:
		current_sanity -= sanity_drain_per_second * delta
		current_sanity = max(current_sanity, 0.0)
		_emit_sanity()

func setup_level(trash_count: int, water_count: int) -> void:
	current_tool = "none"
	current_sanity = max_sanity
	trash_picked = 0
	water_mopped = 0
	total_trash = trash_count
	total_water = water_count
	is_level_finished = false

	_emit_progress()
	tool_changed.emit(current_tool)
	_emit_sanity()

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

func _emit_sanity() -> void:
	sanity_changed.emit(current_sanity, max_sanity, get_distortion_strength())

func get_distortion_strength() -> float:
	if current_sanity > 15.0:
		return 0.0

	if current_sanity > 12.0:
		# mulai distort pelan dari 15 ke 12
		return remap(current_sanity, 15.0, 12.0, 0.05, 0.18)

	# di bawah 12 distort makin parah
	return remap(current_sanity, 12.0, 0.0, 0.2, 0.8)
