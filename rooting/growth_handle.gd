extends Area2D

const MAX_DISPLACEMENT = 64.0

var mouse_hover := false:
	get:
		return mouse_hover
	set(value):
		mouse_hover = value
		
		if (mouse_drag):
			return
		
		$PointLight2D.enabled = mouse_hover
		
		if (mouse_hover):
			$AnimatedSprite2D.play(&"active")
		else:
			$AnimatedSprite2D.play(&"default")

var mouse_drag := false:
	get:
		return mouse_drag
	set(value):
		if (!mouse_drag and value):
			origin = position
		
		mouse_drag = value
		
		if (!mouse_hover and !mouse_drag):
			$PointLight2D.enabled = false
			$AnimatedSprite2D.play(&"default")

var origin := Vector2(0.0, 0.0)
var displacement := Vector2(0.0, 0.0)

func _process(delta: float) -> void:
	if (!mouse_drag):
		return
	
	position = get_parent().get_local_mouse_position()
	displacement = position - origin
	
	if (displacement.length() > MAX_DISPLACEMENT):
		var clamped_displacement = displacement.limit_length(MAX_DISPLACEMENT)
		position -= displacement - clamped_displacement
		displacement = clamped_displacement

func _unhandled_input(event: InputEvent) -> void:
	if (!(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT)):
		return
	
	if (mouse_drag and !event.is_pressed()):
		mouse_drag = false

func _on_mouse_entered() -> void:
	mouse_hover = true

func _on_mouse_exited() -> void:
	mouse_hover = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (!(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT)):
		return
	
	mouse_drag = event.is_pressed()
