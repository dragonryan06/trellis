class_name HandleBase
extends Area2D

const INVALID_COLOR := Color("#ff0000")
const VALID_COLOR := Color("#00ff00")

var was_moved := false:
	get():
		return was_moved
	set(value):
		was_moved = value
		_update_cost_display()
		if (was_moved):
			get_parent().add_to_group(&"to_be_grown")
			
			var resources: Dictionary[SoilResources.Types, int] = {}
			for growable: GrowableLineBase in get_tree().get_nodes_in_group(&"to_be_grown"):
				for type: SoilResources.Types in growable.cost:
					resources[type] = resources.get_or_add(type, 0) + growable.cost[type]
			
			var player = get_node(GlobalLookups.player) as Player
			if (!player.can_afford(resources)):
				cant_afford = true
			else:
				cant_afford = false
		else:
			get_parent().remove_from_group(&"to_be_grown")

## NOTE: Yeah this validation system isn't great but it works so long as you dont directly set invalid.
var invalid := false:
	get:
		return invalid
	set(value):
		invalid = value
		
		if (invalid):
			GameState.hold(self)
			$PointLight2D.color = INVALID_COLOR
			$AnimatedSprite2D.play(&"invalid")
		else:
			GameState.release_hold(self)
			$PointLight2D.color = VALID_COLOR
			# Surely the only way it can become valid again is if the mouse is over it actively.
			$AnimatedSprite2D.play(&"active")
		
		_update_cost_display()

var bad_position := false:
	get:
		return bad_position
	set(value):
		bad_position = value
		
		if (bad_position):
			invalid = true
		elif (!cant_afford and !bad_position):
			invalid = false

var cant_afford := false:
	get:
		return cant_afford
	set(value):
		cant_afford = value
		
		if (cant_afford):
			invalid = true
		elif (!bad_position and !cant_afford):
			invalid = false

var mouse_hover := false:
	get:
		return mouse_hover
	set(value):
		mouse_hover = value
		
		if (mouse_drag):
			return
		
		$PointLight2D.enabled = mouse_hover
		
		if (invalid):
			return
		
		if (mouse_hover):
			$AnimatedSprite2D.play(&"active")
		else:
			$AnimatedSprite2D.play(&"default")

var mouse_drag := false:
	get:
		return mouse_drag
	set(value):
		if (!mouse_drag and value and !was_moved):
			origin = position
		
		mouse_drag = value
		was_moved = true
		
		if (!mouse_hover and !mouse_drag and !invalid):
			$PointLight2D.enabled = false
			$AnimatedSprite2D.play(&"default")

var origin := Vector2(0.0, 0.0)
var displacement := Vector2(0.0, 0.0)
var max_displacement: float = INF

func _ready() -> void:
	top_level = true
	var update_visibility = func(): visible = GameState.phase_name == "Noon"
	GameState.next_phase.connect(update_visibility)
	update_visibility.call()

func _draw() -> void:
	if (!was_moved):
		return
	
	var start = origin - position
	var end = start + displacement
	draw_line(start, end, Color.DARK_MAGENTA)

func _process(_delta: float) -> void:
	queue_redraw()
	if (!mouse_drag):
		return
	
	var parent = get_parent() as GrowableLineBase
	assert(parent != null, "HandleBase must be child of GrowableLineBase!")
	
	position = parent.get_local_mouse_position()
	displacement = position - origin
	
	if (displacement.length() > max_displacement):
		var clamped_displacement = displacement.limit_length(max_displacement)
		position -= displacement - clamped_displacement
		displacement = clamped_displacement
	
	bad_position = displacement.dot(parent.previous_displacement) <= 0

func _unhandled_input(event: InputEvent) -> void:
	if (!(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT)):
		return
	
	if (mouse_drag and !event.is_pressed()):
		mouse_drag = false

func _update_cost_display() -> void:
	var display_string := "[shake][color=#990000] " if invalid else " "
	display_string += get_parent().cost_string
	$CostDisplay.text = display_string
	
	if (was_moved):
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property($CostDisplay, ^"modulate:a", 1.0, 0.25)
	else:
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property($CostDisplay, ^"modulate:a", 0.0, 0.25)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (!(event is InputEventMouseButton)):
		return
	
	match (event.button_index):
		MOUSE_BUTTON_LEFT:
			mouse_drag = event.is_pressed()
		MOUSE_BUTTON_RIGHT when event.is_pressed():
			position = origin
			displacement = Vector2.ZERO
			bad_position = false
			cant_afford = false
			was_moved = false

func _on_mouse_entered() -> void:
	mouse_hover = true

func _on_mouse_exited() -> void:
	mouse_hover = false
