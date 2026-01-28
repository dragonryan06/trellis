extends Node2D

var active_line : Line2D

func _input(event : InputEvent) -> void:
	if (event is InputEventMouseButton and event.is_pressed()):
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if (active_line == null):
					return
				active_line.add_point(get_local_mouse_position())
				active_line.add_point(get_local_mouse_position())
			
			MOUSE_BUTTON_RIGHT:
				if (active_line != null):
					active_line.remove_point(len(active_line.points) - 1)
				active_line = $LineBase.duplicate()
				active_line.add_point(get_local_mouse_position())
				active_line.add_point(get_local_mouse_position())
				add_child(active_line)

func _process(delta : float) -> void:
	if (active_line != null):
		active_line.points[-1] = get_local_mouse_position()
