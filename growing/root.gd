class_name Root
extends GrowableLineBase

@onready
var BranchHandleScene = preload("res://growing/ui/branch_handle.tscn")

func grow_to(location: Vector2) -> void:
	super.grow_to(location)
	$DirtParticles.emitting = true
	var tween = get_tree().create_tween()
	tween.tween_property($DirtParticles, ^"position", location, 1.0)
	tween.tween_callback($DirtParticles.set.bind(&"emitting", false))

func _on_next_phase() -> void:
	super._on_next_phase()
	
	if (GameState.phase_name != "Dusk"):
		return
	
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

func _ready() -> void:
	super._ready()
	
	$DirtParticles.position = endpoint_position
