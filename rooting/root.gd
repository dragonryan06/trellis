class_name Root
extends Line2D

@onready
var BranchHandleScene = preload("res://rooting/branch_handle.tscn")

var root_tip_position: Vector2:
	get:
		return points[-1]
	set(value):
		points[-1] = value

func grow_to(location: Vector2) -> void:
	assert(is_inside_tree(), "Must be inside tree!")
	add_point(root_tip_position)
	var grow_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	grow_tween.tween_property(self, "root_tip_position", location, 1.0)
	grow_tween.tween_property(self, "width", width + 0.5, 1.0)
	$GrowthHandle.position = location

func _ready() -> void:
	GameState.next_turn.connect(_on_next_turn)

func _on_next_turn() -> void:
	if ($GrowthHandle.was_moved):
		grow_to($GrowthHandle.position)
		$GrowthHandle.was_moved = false
	
	for child in get_children():
		if (!(child is BranchHandle and child.was_moved)):
			continue
		var branch = load("res://rooting/root.tscn").instantiate()
		branch.add_point(child.origin)
		add_sibling(branch)
		branch.grow_to(child.position)
		remove_child(child)
	
	if ((len(points) + 1) % 2 == 0):
		var new_handle = BranchHandleScene.instantiate()
		new_handle.position = points[len(points) - 2]
		add_child(new_handle)
