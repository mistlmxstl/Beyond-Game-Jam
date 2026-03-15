extends Panel

func _ready():
	hide()
	$CloseButton.pressed.connect(_on_close_pressed)

func _on_close_pressed():
	hide()
	mouse_filter = Control.MOUSE_FILTER_STOP
