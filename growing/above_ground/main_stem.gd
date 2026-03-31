class_name MainStem
extends GrowableLineBase

const LEAF_BRANCH_FIRST_SEGMENT_LENGTH := 8.0

# Upward growth is paused until a branch is started from here.
var awaiting_branch := false:
	get:
		return awaiting_branch
	set(value):
		awaiting_branch = value
		$GrowthHandle.disabled = awaiting_branch

func _ready() -> void:
	super._ready()
	cost[SoilResources.Types.ICHOR] = 1

func _on_next_phase() -> void:
	super._on_next_phase()
	
	for child in get_children():
		if (!(child is BranchHandle and child.was_moved)):
			continue
		var branch = load("res://growing/above_ground/leaf_branch.tscn").instantiate()
		branch.add_point(child.origin)
		
		if child.displacement.dot(Vector2.RIGHT) < 0.0:
			branch.get_node(^"EndLeaf").flip = true
		
		add_child(branch)
		branch.grow_to(child.position)
		remove_child(child)
		awaiting_branch = false

func _post_growth_callback() -> void:
	super._post_growth_callback()
	
	if len(points) == 3 or (len(points) > 3 and len(points) % 2 == 0):
		awaiting_branch = true
		var tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, ^"width", width + 1.0, 1.0)
		
		var handle_scene = load("res://growing/ui/branch_handle.tscn")
		
		for i in range(2):
			var new_handle = handle_scene.instantiate() as BranchHandle
			new_handle.position = endpoint_position
			new_handle.origin = endpoint_position
			new_handle.max_displacement = LEAF_BRANCH_FIRST_SEGMENT_LENGTH
			add_child(new_handle)
