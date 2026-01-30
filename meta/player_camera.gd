extends Camera2D

const KEY_MOVE_MAX_VELOCITY := 500.0
const KEY_MOVE_ACCELERATION := 25.0
const KEY_MOVE_DAMPING := 1000.0

var dragging: bool:
	get():
		return dragging
	set(value):
		dragging = value
		if (dragging):
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		else:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

var key_move_velocity: Vector2:
	get():
		return key_move_velocity
	set(value):
		key_move_velocity = value.limit_length(KEY_MOVE_MAX_VELOCITY)

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE):
		dragging = event.is_pressed()
	elif (dragging and event is InputEventMouseMotion):
		position -= event.relative

func _process(delta: float) -> void:
	if (Input.is_action_pressed(&"camera_pan_up")):
		key_move_velocity += KEY_MOVE_ACCELERATION * Vector2.UP
	if (Input.is_action_pressed(&"camera_pan_down")):
		key_move_velocity += KEY_MOVE_ACCELERATION * Vector2.DOWN
	if (Input.is_action_pressed(&"camera_pan_left")):
		key_move_velocity += KEY_MOVE_ACCELERATION * Vector2.LEFT
	if (Input.is_action_pressed(&"camera_pan_right")):
		key_move_velocity += KEY_MOVE_ACCELERATION * Vector2.RIGHT
	
	position += key_move_velocity * delta
	key_move_velocity = key_move_velocity.move_toward(Vector2.ZERO, KEY_MOVE_DAMPING * delta)
