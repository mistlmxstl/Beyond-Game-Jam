extends Node

var current_tool = "none"
var current_sanity = 100
var trash_picked = 0
var water_mopped = 0

func pickup_trash():
	trash_picked += 1
	print("Picked up trash")

func mop_floor():
	water_mopped += 1
	print("Mopped floor")

func _ready() -> void:
	var current_tool = "none"
	var current_sanity = 100
	var trash_picked = 0
	var water_mopped = 0
