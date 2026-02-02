class_name GrowableLineBase
extends Line2D

var endpoint_position: Vector2:
	get:
		return points[-1]
	set(value):
		points[-1] = value

var previous_displacement: Vector2:
	get:
		return points[-1] - points[-2]

func grow_to(location: Vector2) -> void:
	assert(is_inside_tree(), "Must be inside tree!")
	add_point(endpoint_position)
	var grow_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	grow_tween.tween_property(self, "endpoint_position", location, 1.0)
	grow_tween.tween_property(self, "width", width + 0.5, 1.0)
	$GrowthHandle.position = location

func _ready() -> void:
	GameState.next_turn.connect(_on_next_turn)

func _on_next_turn() -> void:
	if ($GrowthHandle.was_moved):
		grow_to($GrowthHandle.position)
		$GrowthHandle.was_moved = false
