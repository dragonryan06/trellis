class_name GrowableLineBase
extends Line2D

signal shape_changed

var endpoint_position: Vector2:
	get:
		return points[-1]
	set(value):
		points[-1] = value

var previous_displacement: Vector2:
	get:
		return points[-1] - points[-2]

var cost: Dictionary[SoilResources.Types, int] = {}

var cost_string:
	get:
		if (len(cost) == 0):
			return "Free! :P"
		
		var ret = "%d[color=%s]%s" % [
			cost.values()[0], 
			SoilResources.COLORS[cost.keys()[0]].to_html(false),
			SoilResources.SYMBOLS[cost.keys()[0]]
		]
		
		if (len(cost) == 1):
			return ret
		
		for idx in range(1, len(cost)):
			ret += "[/color], %d[color=%s]%s" % [
				cost.values()[idx],
				SoilResources.COLORS[cost.keys()[idx]].to_html(false),
				SoilResources.SYMBOLS[cost.keys()[idx]]
			]
		
		return ret

func grow_to(location: Vector2) -> void:
	assert(is_inside_tree(), "Must be inside tree!")
	add_point(endpoint_position)
	var grow_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	grow_tween.tween_property(self, "endpoint_position", location, 1.0)
	grow_tween.tween_property(self, "width", width + 0.5, 1.0)
	$GrowthHandle.position = location
	shape_changed.emit()

func _ready() -> void:
	GameState.next_phase.connect(_on_next_phase)

func _on_next_phase() -> void:
	if (GameState.phase_name != "Dusk"):
		return
	
	await get_tree().process_frame
	
	if ($GrowthHandle.was_moved):
		grow_to($GrowthHandle.position)
		$GrowthHandle.was_moved = false
