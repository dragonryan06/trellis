class_name Root
extends GrowableLineBase

@onready
var BranchHandleScene = preload("res://growing/ui/branch_handle.tscn")

func _on_next_turn() -> void:
	super._on_next_turn()
	
	for child in get_children():
		if (!(child is BranchHandle and child.was_moved)):
			continue
		var branch = load("res://growing/root.tscn").instantiate()
		branch.add_point(child.origin)
		add_sibling(branch)
		branch.grow_to(child.position)
		remove_child(child)
	
	if ((len(points) + 1) % 2 == 0):
		var new_handle = BranchHandleScene.instantiate()
		new_handle.position = points[len(points) - 2]
		add_child(new_handle)
