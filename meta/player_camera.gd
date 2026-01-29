extends Camera2D

var dragging: bool:
	get():
		return dragging
	set(value):
		dragging = value
		if (dragging):
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE):
		dragging = event.is_pressed()
	elif (dragging and event is InputEventMouseMotion):
		position -= event.relative
