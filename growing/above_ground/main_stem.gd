class_name MainStem
extends GrowableLineBase

const LEAF_BRANCH_FIRST_SEGMENT_LENGTH := 8.0

func _ready() -> void:
	super._ready()
	cost[SoilResources.Types.ICHOR] = 1

func _on_next_phase() -> void:
	super._on_next_phase()
	
	if (GameState.phase_name != "Dusk"):
		return
	
	for child in get_children():
		if (!(child is BranchHandle and child.was_moved)):
			continue
		var branch = load("res://growing/above_ground/leaf_branch.tscn").instantiate()
		branch.add_point(child.origin)
		add_child(branch)
		
		if child.displacement.dot(Vector2.RIGHT) < 0.0:
			branch.get_node(^"EndLeaf").mirror_sprite()
		
		branch.grow_to(child.position)
		remove_child(child)
	
	if (len(points) % 2 == 1):
		var new_handle = load("res://growing/ui/branch_handle.tscn").instantiate()
		new_handle.position = points[-1]
		new_handle.max_displacement = LEAF_BRANCH_FIRST_SEGMENT_LENGTH
		add_child(new_handle)
