extends Node2D

@onready var game_manager: Node = %GameManager
@onready var mop: Button = $Buttons/Mop
@onready var trash: Button = $Buttons/Trash

#Self care button
func _on_button_3_pressed() -> void:
	print ("Took care of myself!")

#Mop button
func _on_mop_pressed() -> void:
	game_manager.current_tool = "Mop"
	print ("Mop equipped")

#Trash bin button
func _on_trash_pressed() -> void:
	game_manager.current_tool = "Trash bag"
	print ("Trash bag equipped!")
