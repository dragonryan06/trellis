extends Line2D

var root_tip_position: Vector2:
	get:
		return points[-1]
	set(value):
		points[-1] = value

func _ready() -> void:
	GameState.next_turn.connect(_on_next_turn)

func _on_next_turn() -> void:
	add_point(root_tip_position)
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "root_tip_position", $GrowthHandle.position, 1.0)
	tween.tween_property(self, "width", width + 0.5, 1.0)
