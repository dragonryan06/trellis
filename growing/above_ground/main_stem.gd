class_name MainStem
extends GrowableLineBase

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
		remove_child(child)
	
	if (len(points) == 3):
		var new_handle = load("res://growing/ui/branch_handle.tscn").instantiate()
		new_handle.position = points[-1]
		add_child(new_handle)
