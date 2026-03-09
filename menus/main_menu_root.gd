extends Root

const MIN_GROW_TIME := 1.0
const MAX_GROW_TIME := 2.0

const MAX_VARIATION := 10.0

const MAX_POINTS := 16
const MAX_BRANCHES := 8

@onready
var grow_timer := Timer.new()

static var total_branches := 0

func _ready() -> void:
	super._ready()
	
	grow_timer.autostart = true
	grow_timer.wait_time = randf_range(MIN_GROW_TIME, MAX_GROW_TIME)
	grow_timer.timeout.connect(_on_grow_timer_timeout)
	add_child(grow_timer)

func _on_grow_timer_timeout() -> void:
	if (len(points) > MAX_POINTS):
		grow_timer.queue_free()
	else:
		grow_timer.wait_time = randf_range(MIN_GROW_TIME, MAX_GROW_TIME)
	
	var new_pos = _get_random_point()
	
	if (total_branches < MAX_BRANCHES and (len(points) + 3) % 6 == 0):
		total_branches += 1
		var branch = load("res://menus/main_menu_root.tscn").instantiate()
		branch.clear_points()
		branch.add_point(endpoint_position)
		add_child(branch)
		branch.grow_to(_get_random_point())
	
	grow_to(new_pos)

func _get_random_point() -> Vector2:
	var length_variation := randf_range(-MAX_VARIATION, MAX_VARIATION)
	var new_pos := endpoint_position + previous_displacement.rotated(randf_range(-PI/4.0, PI/4.0)) + Vector2(
		length_variation, length_variation)
	
	# Angle adjustment
	while ((new_pos - endpoint_position).dot(Vector2.UP) > -0.2):
		new_pos.y += MAX_VARIATION / 2.0
	
	return new_pos
